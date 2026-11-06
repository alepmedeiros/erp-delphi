Add-Type @"
using System;
using System.Runtime.InteropServices;
public static class NativeLoad {
  [DllImport("kernel32", SetLastError = true, CharSet = CharSet.Unicode)]
  public static extern IntPtr LoadLibraryW(string lpFileName);
  [DllImport("kernel32", SetLastError = true)]
  public static extern bool FreeLibrary(IntPtr hModule);
  [DllImport("kernel32", SetLastError = true, CharSet = CharSet.Unicode)]
  public static extern bool SetDllDirectoryW(string lpPathName);
}
"@

function Test-Load([string]$p) {
  $h = [NativeLoad]::LoadLibraryW($p)
  if ($h -eq [IntPtr]::Zero) {
    Write-Host "FAIL $([IO.Path]::GetFileName($p)) err=$([Runtime.InteropServices.Marshal]::GetLastWin32Error())"
    return $false
  }
  Write-Host "OK   $([IO.Path]::GetFileName($p))"
  [void][NativeLoad]::FreeLibrary($h)
  return $true
}

$dir = "C:\repositorio\Exemplos_ERP-PDV\T2TiERP-2-Delphi\Retaguarda\Cliente\Cadastros\lib\"
Write-Host "=== Cadastros\lib ==="
[void][NativeLoad]::SetDllDirectoryW($dir)
Test-Load ($dir + "libiconv-2.dll") | Out-Null
Test-Load ($dir + "libintl-8.dll") | Out-Null
Test-Load ($dir + "libcrypto-1_1.dll") | Out-Null
Test-Load ($dir + "libssl-1_1.dll") | Out-Null
Test-Load ($dir + "libpq.dll")
[void][NativeLoad]::SetDllDirectoryW($null)
