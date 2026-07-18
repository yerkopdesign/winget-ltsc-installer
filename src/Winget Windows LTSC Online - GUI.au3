#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=WindowsPackageManager.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_Res_Description=Winget para Windows LTSC
#AutoIt3Wrapper_Res_CompanyName=Yerko Paniagua
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

; Declaración manual de constantes para evitar errores con rutas con acentos (Unicode)
Local Const $WS_CAPTION = 0x00C00000
Local Const $WS_SYSMENU = 0x00080000
Local Const $PBS_SMOOTH = 0x01
Local Const $GUI_SHOW = 1
Local Const $GUI_HIDE = 5
Local Const $GUI_DISABLE = 128
Local Const $GUI_EVENT_CLOSE = -3

Local $sTempDir = "C:\winget_autoit"
Local $sWinGetVersion = "v1.8.1791"

; Definición de URLs
Local $aDownloads[4][2] = [ _
    ["https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx", $sTempDir & "\VCLibs.appx"], _
    ["https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx", $sTempDir & "\UIXaml.appx"], _
    ["https://github.com/microsoft/winget-cli/releases/download/" & $sWinGetVersion & "/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle", $sTempDir & "\WinGet.msixbundle"], _
    ["https://raw.githubusercontent.com/microsoft/winget-cli/" & $sWinGetVersion & "/src/AppInstallerCLIE2ETests/Shared/AppInstaller_License1.xml", $sTempDir & "\License.xml"] _
]

; --- DISEÑO DE LA INTERFAZ GUI ---
Local $hGUI = GUICreate("Instalador WinGet para Windows LTSC 2021", 360, 160, -1, -1, 0x00C80000) ; Combinación de WS_CAPTION y WS_SYSMENU
GUISetBkColor(0xF2F2F2)

Local $lblTitle = GUICtrlCreateLabel("Preparado para instalar WinGet", 20, 15, 320, 20)
GUICtrlSetFont($lblTitle, 11, 800, 0, "Segoe UI")

Local $lblStatus = GUICtrlCreateLabel("Presiona 'Instalar' para comenzar el proceso.", 20, 40, 320, 20)
GUICtrlSetFont($lblStatus, 9, 400, 0, "Segoe UI")

Local $idProgress = GUICtrlCreateProgress(20, 70, 320, 20, $PBS_SMOOTH)
GUICtrlSetState($idProgress, $GUI_HIDE)

Local $btnStart = GUICtrlCreateButton("Instalar", 130, 105, 100, 30)
GUICtrlSetFont($btnStart, 9, 600, 0, "Segoe UI")

GUISetState($GUI_SHOW, $hGUI)

; --- BUCLE PRINCIPAL DE LA GUI ---
While 1
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            If FileExists($sTempDir) Then DirRemove($sTempDir, 1) ; 1 fuerza la eliminación recursiva
            Exit

        Case $btnStart
            GUICtrlSetState($btnStart, $GUI_DISABLE)
            GUICtrlSetState($idProgress, $GUI_SHOW)

            If Not FileExists($sTempDir) Then DirCreate($sTempDir)

            GUICtrlSetData($lblTitle, "Descargando...")
            For $i = 0 To UBound($aDownloads) - 1
                Local $hDownload = InetGet($aDownloads[$i][0], $aDownloads[$i][1], 1, 1)
                Do
                    Sleep(100)
                    Local $iPercentage = Int((InetGetInfo($hDownload, 0) / InetGetInfo($hDownload, 1)) * 100)

                    GUICtrlSetData($idProgress, $iPercentage)
                    GUICtrlSetData($lblStatus, "Archivo " & ($i + 1) & " de 4 (" & $iPercentage & "%)")
                Until InetGetInfo($hDownload, 2)
                InetClose($hDownload)
            Next

            GUICtrlSetData($lblTitle, "Instalando...")
            GUICtrlSetData($lblStatus, "Registrando paquetes en el sistema...")
            GUICtrlSetData($idProgress, 40)

            RunWait("powershell -NoProfile -Command ""Add-AppxPackage -Path '" & $sTempDir & "\VCLibs.appx' -ForceApplicationShutdown""", "", @SW_HIDE)
            GUICtrlSetData($idProgress, 60)

            RunWait("powershell -NoProfile -Command ""Add-AppxPackage -Path '" & $sTempDir & "\UIXaml.appx' -ForceApplicationShutdown""", "", @SW_HIDE)
            GUICtrlSetData($idProgress, 80)

            RunWait("powershell -NoProfile -Command ""Add-AppxPackage -Path '" & $sTempDir & "\WinGet.msixbundle' -ForceUpdateFromAnyVersion""", "", @SW_HIDE)
            GUICtrlSetData($idProgress, 90)

            RunWait("powershell -NoProfile -Command ""Add-AppxProvisionedPackage -Online -PackagePath '" & $sTempDir & "\WinGet.msixbundle' -LicensePath '" & $sTempDir & "\License.xml' -ForceTargetApplicationShutdown""", "", @SW_HIDE)

            GUICtrlSetData($lblTitle, "Configurando entorno...")
            GUICtrlSetData($lblStatus, "Removiendo Microsoft Store...")
            GUICtrlSetData($idProgress, 95)

            EnvSet("PATH", EnvGet("PATH") & ";" & @AppDataDir & "\Microsoft\WindowsApps")
            RunWait('winget source remove msstore', "", @SW_HIDE)
            RunWait('winget source update --source winget', "", @SW_HIDE)

            GUICtrlSetData($idProgress, 100)
            GUICtrlSetData($lblTitle, "¡Completado!")
            GUICtrlSetData($lblStatus, "WinGet optimizado con éxito.")

            Sleep(1000)
            GUIDelete($hGUI)

            Run('powershell -NoProfile -NoExit -Command "winget --version; echo ''''; echo ''[EXITO] WinGet optimizado para LTSC.''; echo ''Ya puedes usar: winget upgrade --all --source winget''"', "", @SW_SHOW)

            DirRemove($sTempDir, 1)
            Exit
    EndSwitch
WEnd