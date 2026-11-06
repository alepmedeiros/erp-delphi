# Copia DLLs do cliente PostgreSQL 10 (Win32) para Exemplos_ERP-PDV\lib e opcionalmente para a pasta do exe.
param(
  [string]$PgBinDir = "C:\repositorio\Exemplos_ERP-PDV\lib\_pg10_win32_extract\pgsql\bin",
  [string]$LibRoot = "C:\repositorio\Exemplos_ERP-PDV\lib",
  [string]$ExeDir = ""
)

$clientDlls = @(
  "libpq.dll", "libssl-1_1.dll", "libcrypto-1_1.dll",
  "libintl-8.dll", "libiconv-2.dll", "zlib1.dll"
)

if (-not (Test-Path "$PgBinDir\libpq.dll")) {
  Write-Error "libpq.dll nao encontrada em $PgBinDir. Extraia postgresql-10.23-win32-binaries.zip em $LibRoot."
  exit 1
}

foreach ($dir in @($LibRoot)) {
  New-Item -ItemType Directory -Force -Path $dir | Out-Null
  foreach ($f in $clientDlls) {
    Copy-Item "$PgBinDir\$f" $dir -Force
  }
  Write-Host "Copiado para $dir"
}

if ($ExeDir -ne "") {
  New-Item -ItemType Directory -Force -Path "$ExeDir\lib" | Out-Null
  foreach ($f in $clientDlls) {
    Copy-Item "$PgBinDir\$f" $ExeDir -Force
    Copy-Item "$PgBinDir\$f" "$ExeDir\lib" -Force
  }
  Write-Host "Copiado para $ExeDir e $ExeDir\lib"
}

if (-not (Test-Path "$env:WINDIR\SysWOW64\msvcr120.dll")) {
  Write-Warning @"
Instale o Visual C++ 2013 Redistributable (x86) � necessario para libcrypto/libpq:
  winget install Microsoft.VCRedist.2013.x86
  ou https://aka.ms/highdpimfc2013x86enu
"@
}
