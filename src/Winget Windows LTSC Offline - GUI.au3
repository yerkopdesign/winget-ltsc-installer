#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\Icon\WindowsPackageManager.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_Res_Description=Winget para Windows LTSC
#AutoIt3Wrapper_Res_CompanyName=Yerko Paniagua
#AutoIt3Wrapper_Res_Language=16394
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#RequireAdmin ; Fuerza permisos de Administrador

; Declaración manual de constantes
Local Const $WS_CAPTION = 0x00C00000
Local Const $WS_SYSMENU = 0x00080000
Local Const $PBS_SMOOTH = 0x01
Local Const $GUI_SHOW = 1
Local Const $GUI_HIDE = 5
Local Const $GUI_DISABLE = 128
Local Const $GUI_EVENT_CLOSE = -3

; --- DISEÑO DE LA INTERFAZ GUI ---
Local $hGUI = GUICreate("Instalador WinGet LTSC (Local)", 360, 160, -1, -1, 0x00C80000)
GUISetBkColor(0xF2F2F2)

Local $lblTitle = GUICtrlCreateLabel("Instalador de WinGet", 20, 15, 320, 20)
GUICtrlSetFont($lblTitle, 11, 800, 0, "Segoe UI")

Local $lblStatus = GUICtrlCreateLabel("Presiona 'Instalar' para usar los archivos locales.", 20, 40, 320, 20)
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
            Exit

        Case $btnStart
            ; Validar primero que los archivos realmente existan al lado del script
            If Not FileExists(@ScriptDir & "\VCLibs.appx") Or _
               Not FileExists(@ScriptDir & "\UIXaml.appx") Or _
               Not FileExists(@ScriptDir & "\WinGet.msixbundle") Or _
               Not FileExists(@ScriptDir & "\License.xml") Then
                MsgBox(16, "Error", "Faltan archivos de instalación en la carpeta actual (@ScriptDir).")
                ContinueLoop
            EndIf

            GUICtrlSetState($btnStart, $GUI_DISABLE)
            GUICtrlSetState($idProgress, $GUI_SHOW)

            ; 1. Fase de Instalación silenciosa usando @ScriptDir de origen
            GUICtrlSetData($lblTitle, "Instalando...")
            GUICtrlSetData($lblStatus, "Instalando dependencias de C++ (VCLibs)...")
            GUICtrlSetData($idProgress, 25)
            RunWait("powershell -NoProfile -Command ""Add-AppxPackage -Path '" & @ScriptDir & "\VCLibs.appx' -ForceApplicationShutdown""", "", @SW_HIDE)

            GUICtrlSetData($lblStatus, "Instalando interfaz gráfica (UIXaml)...")
            GUICtrlSetData($idProgress, 50)
            RunWait("powershell -NoProfile -Command ""Add-AppxPackage -Path '" & @ScriptDir & "\UIXaml.appx' -ForceApplicationShutdown""", "", @SW_HIDE)

            GUICtrlSetData($lblStatus, "Instalando WinGet principal...")
            GUICtrlSetData($idProgress, 75)
            RunWait("powershell -NoProfile -Command ""Add-AppxPackage -Path '" & @ScriptDir & "\WinGet.msixbundle' -ForceUpdateFromAnyVersion""", "", @SW_HIDE)

            GUICtrlSetData($lblStatus, "Registrando aprovisionamiento y licencia...")
            GUICtrlSetData($idProgress, 85)
            RunWait("powershell -NoProfile -Command ""Add-AppxProvisionedPackage -Online -PackagePath '" & @ScriptDir & "\WinGet.msixbundle' -LicensePath '" & @ScriptDir & "\License.xml' -ForceTargetApplicationShutdown""", "", @SW_HIDE)

            ; 2. Ajustes de entorno y desconexión de la Store
            GUICtrlSetData($lblTitle, "Configurando entorno...")
            GUICtrlSetData($lblStatus, "Desvinculando origen msstore (Offline)...")
            GUICtrlSetData($idProgress, 95)

            EnvSet("PATH", EnvGet("PATH") & ";" & @AppDataDir & "\Microsoft\WindowsApps")
            RunWait('winget source remove msstore', "", @SW_HIDE)

            GUICtrlSetData($idProgress, 100)
            GUICtrlSetData($lblTitle, "¡Completado!")
            GUICtrlSetData($lblStatus, "WinGet instalado localmente con éxito.")

            Sleep(1200)
            GUIDelete($hGUI)

            ; 3. Verificación final interactiva
            Run('powershell -NoProfile -NoExit -Command "winget --version; echo ''''; echo ''[EXITO] WinGet instalado desde el directorio local.''; echo ''Cuando el equipo tenga red, recuerda ejecutar: winget source update''"', "", @SW_SHOW)

            Exit
    EndSwitch
WEnd