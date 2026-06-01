@echo off
setlocal
if "%~2"=="" (
  echo Usage: build.bat ^<project-dir^> ^<project.dproj^> [Config] [Platform]
  echo Example: build.bat Retaguarda\Cliente\Cadastros T2TiERP_Cadastros.dproj Debug Win32
  exit /b 1
)

set "PROJECT_DIR=%~1"
set "PROJECT_FILE=%~2"
set "BUILD_CONFIG=%~3"
set "BUILD_PLATFORM=%~4"
if "%BUILD_CONFIG%"=="" set "BUILD_CONFIG=Debug"
if "%BUILD_PLATFORM%"=="" set "BUILD_PLATFORM=Win32"

call "C:\Program Files (x86)\Embarcadero\Studio\37.0\bin\rsvars.bat"
cd /d "%PROJECT_DIR%"
msbuild "%PROJECT_FILE%" /t:Build /p:Config=%BUILD_CONFIG% /p:Platform=%BUILD_PLATFORM% /v:minimal
exit /b %ERRORLEVEL%
