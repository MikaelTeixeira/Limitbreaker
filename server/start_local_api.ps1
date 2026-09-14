<#
.SYNOPSIS
Ensures that the local Limit Breaker API is available before Flutter starts.
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$serverDirectory = $PSScriptRoot
$runtimeDirectory = Join-Path $serverDirectory '.runtime'
$healthUrl = 'http://127.0.0.1:8080/health'

function Test-LocalApiHealthy {
  <#
  .SYNOPSIS
  Returns whether the local API and its database are responding normally.
  #>

  try {
    $response = Invoke-WebRequest -UseBasicParsing -Uri $healthUrl -TimeoutSec 1
    return $response.StatusCode -eq 200
  } catch {
    return $false
  }
}

function Get-LocalEnvironmentValue {
  <#
  .SYNOPSIS
  Reads one local environment value from server/.env or the current process.
  #>

  param([Parameter(Mandatory)] [string] $Name)

  $environmentFile = Join-Path $serverDirectory '.env'
  if (Test-Path -LiteralPath $environmentFile) {
    $escapedName = [regex]::Escape($Name)
    $line = Get-Content -LiteralPath $environmentFile |
      Where-Object { $_ -match "^\s*$escapedName\s*=" } |
      Select-Object -First 1
    if ($null -ne $line) {
      $value = ($line -replace "^\s*$escapedName\s*=", '').Trim()
      if ($value.Length -ge 2 -and (
          ($value.StartsWith('"') -and $value.EndsWith('"')) -or
          ($value.StartsWith("'") -and $value.EndsWith("'"))
        )) {
        return $value.Substring(1, $value.Length - 2)
      }
      return $value
    }
  }

  return [Environment]::GetEnvironmentVariable($Name, 'Process')
}

function Import-LocalEnvironment {
  <#
  .SYNOPSIS
  Loads only the API and administrator settings needed by child Dart processes.
  #>

  $names = @(
    'DATABASE_URL',
    'ADMIN_USERNAME',
    'ADMIN_DISPLAY_NAME',
    'ADMIN_EMAIL',
    'ADMIN_PASSWORD',
    'ADMIN_AGE',
    'ADMIN_HEIGHT_CM',
    'ADMIN_WEIGHT_KG',
    'ADMIN_RESET_PASSWORD'
  )
  foreach ($name in $names) {
    $value = Get-LocalEnvironmentValue -Name $name
    if ($null -ne $value) {
      Set-Item -Path "Env:$name" -Value $value
    }
  }
}

function Get-DartExecutable {
  <#
  .SYNOPSIS
  Locates the Dart executable bundled with Flutter or available on the PATH.
  #>

  if (-not [string]::IsNullOrWhiteSpace($env:LIMITBREAKER_DART_EXECUTABLE) -and
      (Test-Path -LiteralPath $env:LIMITBREAKER_DART_EXECUTABLE)) {
    return $env:LIMITBREAKER_DART_EXECUTABLE
  }

  $dartCommand = Get-Command -Name 'dart' -CommandType Application -ErrorAction SilentlyContinue |
    Select-Object -First 1
  if ($null -ne $dartCommand -and (Test-Path -LiteralPath $dartCommand.Source)) {
    return $dartCommand.Source
  }

  if (-not [string]::IsNullOrWhiteSpace($env:FLUTTER_ROOT)) {
    $flutterDart = Join-Path $env:FLUTTER_ROOT 'bin\cache\dart-sdk\bin\dart.exe'
    if (Test-Path -LiteralPath $flutterDart) {
      return $flutterDart
    }
  }

  throw 'Dart do Flutter não foi encontrado. Configure o Flutter antes de iniciar o projeto.'
}

function Invoke-ServerDart {
  <#
  .SYNOPSIS
  Runs a Dart command from the server directory and stops on failure.
  #>

  param(
    [Parameter(Mandatory)] [string] $DartExecutable,
    [Parameter(Mandatory)] [string[]] $DartArguments
  )

  Push-Location $serverDirectory
  try {
    & $DartExecutable @DartArguments
    if ($LASTEXITCODE -ne 0) {
      throw "O comando Dart falhou: dart $($DartArguments -join ' ')."
    }
  } finally {
    Pop-Location
  }
}

function Restore-ServerDependencies {
  <#
  .SYNOPSIS
  Restores the API packages before starting or seeding the local server.
  #>

  param([Parameter(Mandatory)] [string] $DartExecutable)

  Invoke-ServerDart -DartExecutable $DartExecutable -DartArguments @('pub', 'get')
}

function Invoke-AdminSeed {
  <#
  .SYNOPSIS
  Creates or promotes the configured local administrator without exposing secrets.
  #>

  param([Parameter(Mandatory)] [string] $DartExecutable)

  Invoke-ServerDart -DartExecutable $DartExecutable -DartArguments @('run', 'bin/seed_admin.dart')
}

function Start-LocalApi {
  <#
  .SYNOPSIS
  Starts the Dart API in the background with the configured database connection.
  #>

  param(
    [Parameter(Mandatory)] [string] $DatabaseUrl,
    [Parameter(Mandatory)] [string] $DartExecutable
  )

  New-Item -ItemType Directory -Path $runtimeDirectory -Force | Out-Null
  $env:DATABASE_URL = $DatabaseUrl
  $startOptions = @{
    FilePath = $dartExecutable
    ArgumentList = @('run', 'bin/server.dart')
    WorkingDirectory = $serverDirectory
    WindowStyle = 'Hidden'
    RedirectStandardOutput = Join-Path $runtimeDirectory 'api.stdout.log'
    RedirectStandardError = Join-Path $runtimeDirectory 'api.stderr.log'
  }
  return Start-Process @startOptions -PassThru
}

function Wait-LocalApiHealthy {
  <#
  .SYNOPSIS
  Waits for the background API to respond and reports its log on startup failure.
  #>

  param([Parameter(Mandatory)] [System.Diagnostics.Process] $Process)

  $deadline = (Get-Date).AddSeconds(20)
  while ((Get-Date) -lt $deadline) {
    if (Test-LocalApiHealthy) {
      return
    }
    if ($Process.HasExited) {
      break
    }
    Start-Sleep -Milliseconds 250
  }

  $errorLog = Join-Path $runtimeDirectory 'api.stderr.log'
  $details = if (Test-Path -LiteralPath $errorLog) {
    (Get-Content -LiteralPath $errorLog -Tail 20 | Out-String).Trim()
  }
  if ([string]::IsNullOrWhiteSpace($details)) {
    throw 'A API local não ficou disponível em http://127.0.0.1:8080/health.'
  }
  throw "A API local não iniciou corretamente:`n$details"
}

Import-LocalEnvironment
$databaseUrl = $env:DATABASE_URL
if ([string]::IsNullOrWhiteSpace($databaseUrl)) {
  throw 'DATABASE_URL não foi encontrada em server/.env nem nas variáveis do processo.'
}

$apiHealthy = Test-LocalApiHealthy
$shouldSeedAdmin = -not [string]::IsNullOrWhiteSpace($env:ADMIN_USERNAME)
if (-not $apiHealthy -or $shouldSeedAdmin) {
  $dartExecutable = Get-DartExecutable
  Restore-ServerDependencies -DartExecutable $dartExecutable
  if ($shouldSeedAdmin) {
    Invoke-AdminSeed -DartExecutable $dartExecutable
  }
}

if (-not $apiHealthy) {
  $process = Start-LocalApi -DatabaseUrl $databaseUrl -DartExecutable $dartExecutable
  Wait-LocalApiHealthy -Process $process
}
