@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
title Instalador de WinGet en Windows LTSC
cls

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Ejecuta este script como ADMINISTRADOR.
    pause & exit
)

set "TEMP_DIR=C:\winget"
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"
cd /d "%TEMP_DIR%"

echo.
echo ============================================================
echo   Instalacion y configuracion de Winget para Windows LTSC
echo ============================================================
echo.

:: 1. Descargas de versiones altamente compatibles con LTSC 2021
echo [1/4] Descargando componentes estables para LTSC 2021...
curl -L -o VCLibs.appx "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx"
curl -L -o UIXaml.appx "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx"
curl -L -o WinGet.msixbundle "https://github.com/microsoft/winget-cli/releases/download/v1.8.1791/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
curl -L -o License.xml "https://raw.githubusercontent.com/microsoft/winget-cli/v1.8.1791/src/AppInstallerCLIE2ETests/Shared/AppInstaller_License1.xml"

echo.
echo [2/4] Instalando paquetes en el sistema...
echo ------------------------------------------------------------

echo Instalando VCLibs...
powershell -NoProfile -Command "Add-AppxPackage -Path '.\VCLibs.appx' -ForceApplicationShutdown"

echo Instalando UI Xaml (Interface)...
powershell -NoProfile -Command "Add-AppxPackage -Path '.\UIXaml.appx' -ForceApplicationShutdown"

echo Instalando WinGet principal...
powershell -NoProfile -Command "Add-AppxPackage -Path '.\WinGet.msixbundle' -ForceUpdateFromAnyVersion"

echo Registrando aprovisionamiento y licencia LTSC...
powershell -NoProfile -Command "Add-AppxProvisionedPackage -Online -PackagePath '.\WinGet.msixbundle' -LicensePath '.\License.xml' -ForceTargetApplicationShutdown"

echo.
echo [3/4] Removiendo dependencias de Microsoft Store...
echo ------------------------------------------------------------
:: Forzamos la ruta en la sesión actual por si acaso
set "PATH=%LOCALAPPDATA%\Microsoft\WindowsApps;%PATH%"

echo Eliminando origen 'msstore' para evitar conflictos...
winget source remove msstore >nul 2>&1
if %errorLevel% eq 0 (
    echo [OK] Origen 'msstore' eliminado correctamente.
) else (
    echo [AVISO] 'msstore' ya estaba eliminado o no se pudo remover.
)

echo Actualizando base de datos del origen 'winget'...
winget source update --source winget

echo.
echo [4/4] Comprobando resultado final...
echo ------------------------------------------------------------
timeout /t 2 >nul
winget --version >nul 2>&1
if %errorLevel% eq 0 (
    echo [EXITO] WinGet configurado correctamente y optimizado para LTSC.
    echo.
    echo Versión activa:
    winget --version
    echo.
    echo Ya puedes usar: winget upgrade --all --source winget
) else (
    echo [ERROR] No se pudo verificar la instalación. Intenta abrir una nueva consola.
)

rmdir /s /q "%TEMP_DIR%"
echo.
pause>nul
exit