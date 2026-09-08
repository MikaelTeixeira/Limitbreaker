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
$dartExecutable = 'C:\tools\flutter\bin\cache\dart-sdk\bin\dart.exe'

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
  if (-not (Test-Path -LiteralPath $environmentFile)) {
    return $null
  }

  $line = Get-Content -LiteralPath $environmentFile |
    Where-Object { $_ -match '^\s*DATABASE_URL\s*=' } |
    Select-Object -First 1
  if ($null -eq $line) {
    return $null
  }

  return ($line -replace '^\s*DATABASE_URL\s*=', '').Trim()
}

function Start-LocalApi {
  <#
  .SYNOPSIS
  Starts the Dart API in the background with the configured database connection.
  #>

  param([Parameter(Mandatory)] [string] $DatabaseUrl)

  if (-not (Test-Path -LiteralPath $dartExecutable)) {
    throw "Dart do Flutter não foi encontrado em $dartExecutable."
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

if (-not (Test-LocalApiHealthy)) {
  $databaseUrl = Get-DatabaseUrl
  if ([string]::IsNullOrWhiteSpace($databaseUrl)) {
    throw 'DATABASE_URL não foi encontrada em server/.env.'
  }
  Start-LocalApi -DatabaseUrl $databaseUrl
}
