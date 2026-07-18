#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\WindowsPackageManager.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_Res_Description=Winget para Windows LTSC
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <File.au3>

Local $sTempDir = "C:\winget_autoit"
Local $sWinGetVersion = "v1.8.1791"

; Definición de URLs
Local $aDownloads[4][2] = [ _
    ["https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx", $sTempDir & "\VCLibs.appx"], _
    ["https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx", $sTempDir & "\UIXaml.appx"], _
    ["https://github.com/microsoft/winget-cli/releases/download/" & $sWinGetVersion & "/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle", $sTempDir & "\WinGet.msixbundle"], _
    ["https://raw.githubusercontent.com/microsoft/winget-cli/" & $sWinGetVersion & "/src/AppInstallerCLIE2ETests/Shared/AppInstaller_License1.xml", $sTempDir & "\License.xml"] _
]

; 1. Crear directorio temporal
If Not FileExists($sTempDir) Then DirCreate($sTempDir)

; --- CONFIGURACIÓN DE LA VENTANA DE PROGRESO ESTILIZADA ---
; Usamos la opción 16 (Windows Default Position) + un ancho fijo inicial
ProgressOn("Instalador WinGet LTSC", "Descargando componentes...", "Iniciando descargas...", -1, -1, 16)

; Forzamos un ancho de 420px y alto de 160px para que no se estire horizontalmente
WinMove("Instalador WinGet LTSC", "", Default, Default, 320, 130)

; 2. Descarga de archivos con barra de progreso controlada
For $i = 0 To UBound($aDownloads) - 1
    Local $hDownload = InetGet($aDownloads[$i][0], $aDownloads[$i][1], 1, 1)
    Do
        Sleep(100) ; Refresco rápido de 100ms para mayor fluidez visual
        Local $iPercentage = Int((InetGetInfo($hDownload, 0) / InetGetInfo($hDownload, 1)) * 100)

        ; El orden de los parámetros mantiene la negrita fija arriba y el detalle dinámico abajo
        ProgressSet($iPercentage, "Descargando archivo " & ($i + 1) & " de 4 (" & $iPercentage & "%)", "Descargando...")
    Until InetGetInfo($hDownload, 2) ; Esperar a que termine la descarga actual
    InetClose($hDownload)
Next

; Mantenemos el formato estético durante la instalación
ProgressSet(100, "Por favor, espera un momento...", "Instalando paquetes en el sistema...")

; 3. Instalación de dependencias mediante PowerShell corrigiendo la sintaxis de comillas doble-literal ("")
RunWait("powershell -NoProfile -Command ""Add-AppxPackage -Path '" & $sTempDir & "\VCLibs.appx' -ForceApplicationShutdown""", "", @SW_HIDE)
RunWait("powershell -NoProfile -Command ""Add-AppxPackage -Path '" & $sTempDir & "\UIXaml.appx' -ForceApplicationShutdown""", "", @SW_HIDE)
RunWait("powershell -NoProfile -Command ""Add-AppxPackage -Path '" & $sTempDir & "\WinGet.msixbundle' -ForceUpdateFromAnyVersion""", "", @SW_HIDE)
RunWait("powershell -NoProfile -Command ""Add-AppxProvisionedPackage -Online -PackagePath '" & $sTempDir & "\WinGet.msixbundle' -LicensePath '" & $sTempDir & "\License.xml' -ForceTargetApplicationShutdown""", "", @SW_HIDE)

ProgressSet(100, "Removiendo Microsoft Store...", "Configurando entorno de WinGet...")

; 4. Ajustes del entorno y remover la Store de forma invisible
EnvSet("PATH", EnvGet("PATH") & ";" & @AppDataDir & "\Microsoft\WindowsApps")
RunWait('winget source remove msstore', "", @SW_HIDE)
RunWait('winget source update --source winget', "", @SW_HIDE)

; Cerramos la interfaz gráfica antes de lanzar el resultado final
ProgressOff()

; 5. Verificación final interactiva (Muestra la versión en una consola limpia)
Local $iPID = Run('powershell -NoProfile -NoExit -Command "winget --version; echo ''''; echo ''[EXITO] WinGet optimizado para LTSC.''; echo ''Ya puedes usar: winget upgrade --all --source winget''"', "", @SW_SHOW)

; 6. Limpieza segura del directorio temporal
DirRemove($sTempDir, $DIR_REMOVE)

Exit