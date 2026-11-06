@echo off
setlocal
cd /d "%~dp0"
wsl -e bash -lc "cd /mnt/c/repositorio/Exemplos_ERP-PDV/T2TiERP-2-Delphi/docker && docker compose down"
exit /b 0
