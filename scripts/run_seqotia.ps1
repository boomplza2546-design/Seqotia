<#
.SYNOPSIS
Starts the Seqotia development stack from the correct Flutter project root.

.DESCRIPTION
Starts the local FastAPI server only when port 8000 is not already serving
Seqotia, then runs the active Flutter entry point: lib/main.dart. The local
SQLite development database avoids requiring Docker for day-to-day UI work.
#>

$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$backendApp = Join-Path $projectRoot 'backend\app'
$python = Join-Path $projectRoot 'backend\.venv\Scripts\python.exe'
$bundledFlutter = 'C:\src\flutter\bin\flutter.bat'
$flutter = if (Test-Path -LiteralPath $bundledFlutter) {
  $bundledFlutter
} elseif (Get-Command flutter -ErrorAction SilentlyContinue) {
  (Get-Command flutter -ErrorAction Stop).Source
} else {
  throw 'Flutter was not found. Install it or add flutter to PATH.'
}

if (-not (Test-Path -LiteralPath $python)) {
  throw "Seqotia's Python environment was not found at $python"
}

function Test-SeqotiaApi {
  try {
    $response = Invoke-WebRequest -UseBasicParsing -Uri 'http://127.0.0.1:8000/openapi.json' -TimeoutSec 2
    return $response.Content -match 'Seqotia API'
  } catch {
    return $false
  }
}

if (-not (Test-SeqotiaApi)) {
  $databasePath = Join-Path $projectRoot 'backend\seqotia-dev.db'
  $originalDatabaseUrl = $env:DATABASE_URL
  $originalJwtSecret = $env:JWT_SECRET
  $env:DATABASE_URL = 'sqlite:///' + ($databasePath -replace '\\', '/')
  $env:JWT_SECRET = 'seqotia-local-development-only'
  try {
    Start-Process -FilePath $python `
      -ArgumentList @('-m', 'uvicorn', 'main:app', '--host', '127.0.0.1', '--port', '8000') `
      -WorkingDirectory $backendApp `
      -WindowStyle Hidden
  } finally {
    $env:DATABASE_URL = $originalDatabaseUrl
    $env:JWT_SECRET = $originalJwtSecret
  }

  for ($attempt = 1; $attempt -le 20 -and -not (Test-SeqotiaApi); $attempt++) {
    Start-Sleep -Milliseconds 500
  }
  if (-not (Test-SeqotiaApi)) {
    throw 'The Seqotia API did not start on http://127.0.0.1:8000.'
  }
}

Set-Location $projectRoot
& $flutter run -d chrome -t lib\main.dart
