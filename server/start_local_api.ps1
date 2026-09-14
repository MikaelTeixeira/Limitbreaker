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
$dartCommand = Get-Command dart.bat -ErrorAction SilentlyContinue
$dartExecutable = if ($null -ne $dartCommand) {
  Join-Path (Split-Path (Split-Path $dartCommand.Source)) 'bin\cache\dart-sdk\bin\dart.exe'
} else {
  (Get-Command dart.exe -ErrorAction SilentlyContinue).Source
}

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

function Get-DatabaseUrl {
  <#
  .SYNOPSIS
  Reads the database connection string from the ignored local environment file.
  #>

  $environmentFile = Join-Path $serverDirectory '.env'
  if (Test-Path -LiteralPath $environmentFile) {
    $line = Get-Content -LiteralPath $environmentFile |
      Where-Object { $_ -match '^\s*DATABASE_URL\s*=' } |
      Select-Object -First 1
    if ($null -ne $line) {
      $fileValue = ($line -replace '^\s*DATABASE_URL\s*=', '').Trim()
      $isPlaceholder = $fileValue -match 'SUA_SENHA|USUARIO|SENHA'
      if (-not [string]::IsNullOrWhiteSpace($fileValue) -and -not $isPlaceholder) {
        return $fileValue
      }
    }
  }

  return $env:DATABASE_URL
}

function Start-LocalApi {
  <#
  .SYNOPSIS
  Starts the Dart API in the background with the configured database connection.
  #>

  param([Parameter(Mandatory)] [string] $DatabaseUrl)

  if ([string]::IsNullOrWhiteSpace($dartExecutable) -or
      -not (Test-Path -LiteralPath $dartExecutable)) {
    throw 'Dart não foi encontrado no PATH.'
  }

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
  Start-Process @startOptions | Out-Null
}

function Stop-UnhealthyLocalApi {
  <#
  .SYNOPSIS
  Stops a stale Dart API that still owns the local port but lost its database connection.
  #>

  $listeners = netstat -ano -p TCP | Select-String -Pattern '^\s*TCP\s+\S+:8080\s+\S+\s+LISTENING\s+(\d+)\s*$'
  foreach ($listener in $listeners) {
    $processId = [int] $listener.Matches[0].Groups[1].Value
    $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
    if ($null -ne $process -and $process.ProcessName -in @('dart', 'dartvm')) {
      Stop-Process -Id $processId -Force
      $process.WaitForExit(3000)
    }
  }
}

if (-not (Test-LocalApiHealthy)) {
  $databaseUrl = Get-DatabaseUrl
  if ([string]::IsNullOrWhiteSpace($databaseUrl)) {
    throw 'DATABASE_URL não foi encontrada em server/.env.'
  }
  Stop-UnhealthyLocalApi
  Start-LocalApi -DatabaseUrl $databaseUrl
  foreach ($attempt in 1..20) {
    Start-Sleep -Milliseconds 250
    if (Test-LocalApiHealthy) {
      return
    }
  }
  $errorLog = Join-Path $runtimeDirectory 'api.stderr.log'
  throw "A API local nao iniciou. Consulte $errorLog e confirme que o PostgreSQL esta ativo."
}
