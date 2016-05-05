;*****************************************
; TrayMenu by Boerek
; Erstellt mit ISN AutoIt Studio v. 1.00
;*****************************************
#AutoIt3Wrapper_Res_File_Add=..\res\tinc-grey.ico,   RT_RCDATA, ICON_TRAY_STATUS_GREY, 0
#AutoIt3Wrapper_Res_File_Add=..\res\tinc-green.ico,  RT_RCDATA, ICON_TRAY_STATUS_GREEN, 0
#AutoIt3Wrapper_Res_File_Add=..\res\tinc-yellow.ico, RT_RCDATA, ICON_TRAY_STATUS_YELLOW, 0

#RequireAdmin

#include <Array.au3>; Only required to display the arrays
#include <File.au3>
#include <MsgBoxConstants.au3>
#include <WinAPIFiles.au3>
#include <TrayConstants.au3>; Required for the $TRAY_ICONSTATE_SHOW constant.

#include '..\lib\ResourcesEx.au3' ; Requires compilation to exe to use _Resources_*() Functions

#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiEdit.au3>
#include <Process.au3>


Opt("TrayMenuMode", 3) ; The default tray menu items will not be shown and items are not checked when selected. These are options 1 and 2 for TrayMenuMode.

Opt("GUIOnEventMode", 1) ; Change to OnEvent mode

Dim $aArray[1][1] ; 2D Array for VPN Name | Pointer [NetworkName] Menu | Pointer Button Connect | Pointer Button Edit



#Region Set tray icon stuff
Global Const $ICON_TRAY_GREY   = 'ICON_TRAY_STATUS_GREY'
Global Const $ICON_TRAY_GREEN  = 'ICON_TRAY_STATUS_GREEN'
Global Const $ICON_TRAY_YELLOW = 'ICON_TRAY_STATUS_YELLOW'

Func setTrayIcon($trayIconColor)
	Local $pathToIcon = @TempDir & '\' & $trayIconColor & '.ico'
	If Not FileExists($pathToIcon) Then
		_Resource_SaveToFile($pathToIcon, $trayIconColor)
	EndIf
	TraySetIcon($pathToIcon)
EndFunc
#EndRegion

#Region Tinc paths for network lookup and start in console
Global $gTincDir
Global $gTincDirEscaped
Func tincGetTincPaths()
	$gTincDir        = "C:\Program Files\tinc\"
	$gTincDirEscaped = StringReplace($gTincDir, "Program Files", '"Program Files"')
	; TODO: Check if exists, else FileOpenDialog
	; TODO: Save paths to Ini, SQLite, Registry

	; Debug
	ConsoleWrite("$gTincDir       : " & $gTincDir & @CRLF)
	ConsoleWrite("$gTincDirEscaped: " & $gTincDirEscaped & @CRLF)
EndFunc

tincGetTincPaths()
#EndRegion

Func trayCreateNetworks()

	; Ordner in array
	; The filter also applies to folders when recursively searching for folders
	Global $aArray = _FileListToArrayRec($gTincDir, "*", $FLTAR_FOLDERS, $FLTAR_noRECUR, $FLTAR_SORT)
	_ArrayDelete($aArray,0)
	_ArrayColInsert($aArray, 1) ; Network (required for clear tray menu)
	_ArrayColInsert($aArray, 2) ;   + Connect
	_ArrayColInsert($aArray, 3) ;   + Bearbeiten
	; Now a 2D array

    Local $i = 0
	Local $arrayLengh = UBound($aArray)
	While $i < $arrayLengh
		If FileExists($gTincDir & $aArray[$i][0] & "tinc.conf") Then
			$aArray[$i][0] = StringReplace($aArray[$i][0], "\", "") ; Remove trailing "\" from VPN name
            $aArray[$i][1] = TrayCreateMenu($aArray[$i][0], -1, 0) ; Create a tray menu sub menu with two sub items.
			$aArray[$i][2] = TrayCreateItem("Connect", $aArray[$i][1])
			$aArray[$i][3] = TrayCreateItem("Edit", $aArray[$i][1])
		Else
			_ArrayDelete($aArray, $i)
			$i = $i - 1
		EndIf
		$arrayLengh = UBound($aArray)
		$i = $i + 1
	WEnd
	;_ArrayDisplay($aArray, "Folder recur with filter")

EndFunc   ;==>VPN2Tray

Func trayClearNetworks()
	Local $i = 0
	Local $arrayLengh = UBound($aArray)
	While $i < $arrayLengh
		TrayItemDelete($aArray[$i][3])
		TrayItemDelete($aArray[$i][2])
		TrayItemDelete($aArray[$i][1])
		$i = $i + 1
	WEnd
EndFunc   ;==>trayClearNetworks

; tinc start related
Global $iTincStartPid
Global $bTincStarted = False
Global $bTincStartGui = False
Global $hTincStartLog;
Global $hTrayTincConnect;

Func trayMenu()
	Local $iSettings = TrayCreateMenu("Settings") ; Create a tray menu sub menu with two sub items.
	Local $iDisplay = TrayCreateItem("Clear Networks", $iSettings)
	Local $iPrinter = TrayCreateItem("Reload Networks", $iSettings)
	TrayCreateItem("") ; Create a separator line.

    Local $idJoin = TrayCreateItem("Join network")
	TrayCreateItem("") ; Create a separator line.

	Local $idAbout = TrayCreateItem("About")
	TrayCreateItem("") ; Create a separator line.

	Local $idExit = TrayCreateItem("Exit")

	TraySetState($TRAY_ICONSTATE_SHOW) ; Show the tray menu.

    setTrayIcon($ICON_TRAY_GREY)

    Global $development = 0

	While 1
		$msg = TrayGetMsg()
		Switch $msg
			Case $idAbout ; Display a message box about the AutoIt version and installation path of the AutoIt executable.
				MsgBox($MB_SYSTEMMODAL, "", "AutoIt tray menu example." & @CRLF & @CRLF & _
						"Version: " & @AutoItVersion & @CRLF & _
						"Install Path: " & StringLeft(@AutoItExe, StringInStr(@AutoItExe, "\", 0, -1) - 1)) ; Find the folder of a full path.

			Case $iDisplay
				trayClearNetworks()

			Case $iPrinter
				trayCreateNetworks()

			Case $idJoin ; Show join window for entering an invitation code for a network.
				;MsgBox($MB_SYSTEMMODAL, "Join", "Enter invitation URL")
				joinNetworkGUI()

			Case $idExit ; Exit the loop.
				If $bTincStarted == True Then
					tinc_stop()
				EndIf
				ExitLoop

			Case Else
				If $msg <> 0 Then
					Local $bNotFound = True
					Local $i = 0
					While $i < UBound($aArray) And $bNotFound
						If $msg == $aArray[$i][2] Then
							$bNotFound = False
							;MsgBox(0, "Connect to: ", $aArray[$i][0])
							guiTincStart($aArray[$i][0])
							; Start tinc with selected network
							If Not ProcessExists("tincd.exe") Then
								tinc_start($aArray[$i][0])

								$hTrayTincConnect = $aArray[$i][2]
								TrayItemSetText($hTrayTincConnect, "Status")
							EndIf
						ElseIf $msg == $aArray[$i][3] Then
							$bNotFound = False
							MsgBox(0, "Edit: ", $aArray[$i][0])
						EndIf
						$i = $i + 1
					WEnd
				EndIf
		EndSwitch

		; Tinc is running, collect console output
		If $bTincStarted == True Then
			$sTincStartValue = StderrRead($iTincStartPid)
			If Not @error Then
				If StringLen(StringStripCR(StringStripWS($sTincStartValue, $STR_STRIPALL))) > 0 Then
					;ConsoleWrite($sTincStartValue)
					_GUICtrlEdit_AppendText($hTincStartLog, $sTincStartValue)
				EndIf
			EndIf
		EndIf

	WEnd
EndFunc   ;==>Traymenu

#Region Functions for tinc start / tinc status GUI
Global $bIsTincStartGuiCreated = False ; Create once and hide/show on demand
Global $hTincDisconnectButton
Func guiTincStart($sNetworkName)
	If Not $bIsTincStartGuiCreated Then
		ConsoleWrite("Creating tinc start GUI" & @CRLF)
		Local $iWidth = 600
		Local $iHeight = 400

		Local $iButtonWidth = 125
		Local $iButtonHeight = 24

		Global $hTincStartGui = GUICreate("tinc '" & $sNetworkName & "'", $iWidth, $iHeight, @DesktopWidth/2 - $iWidth/2, @DesktopHeight/2 - $iHeight/2, $WS_CAPTION + $WS_MINIMIZEBOX + $WS_SYSMENU); + $WS_THICKFRAME)
		$hTincStartLog = GUICtrlCreateEdit("", 5, 5, $iWidth - 10, $iHeight - 15 - $iButtonHeight, $ES_AUTOVSCROLL + $WS_VSCROLL)
		GUICtrlSetFont($hTincStartLog, 8.5,0, 0, "Courier New")
		$hTincDisconnectButton = GUICtrlCreateButton("Disconnect", $iWidth - 5 - $iButtonWidth, $iHeight - $iButtonHeight - 5, $iButtonWidth, $iButtonHeight)
		GUICtrlSetOnEvent($hTincDisconnectButton, "tinc_stop")

		$bIsTincStartGuiCreated = True

		GUISetOnEvent($GUI_EVENT_CLOSE, "guiTincHide", $hTincStartGui)
	EndIf
	GUISetState(@SW_SHOW, $hTincStartGui)
EndFunc

Func guiTincHide()
	If $bIsTincStartGuiCreated Then
		GUISetState(@SW_HIDE, $hTincStartGui)
	EndIf
EndFunc

Func guiTincShow()
	If $bIsTincStartGuiCreated Then
		GUISetState(@SW_SHOW, $hTincStartGui)
	EndIf
EndFunc
#EndRegion

Global $gTincJoinOutput = ""
Global $gIsTincJoinGuiCreated = False
Func joinNetworkGUI()
	ConsoleWrite($gIsTincJoinGuiCreated)
	If $gIsTincJoinGuiCreated == False Then
		$guiWidth = 600
		$guiHeight = 400
		Global $guiNetwork = GUICreate("tinc", $guiWidth, $guiHeight, @DesktopWidth/2 - $guiWidth/2, @DesktopHeight/2 - $guiHeight/2)
		GUICtrlCreateLabel("Enter the invitation code generated by the tinc server.", 5, 5)
		GUICtrlCreateLabel("Invitation code:", 5, 30)

		Global $idInputCode  = GUICtrlCreateInput("", 82, 27, 430)
		Local $idButtonJoin = GUICtrlCreateButton("Join", 515, 25, 50)
		GUICtrlSetOnEvent($idButtonJoin, "tinc_join")

		Global $idMyedit = GUICtrlCreateEdit("", 5, 60, $guiWidth-10, 300, $ES_AUTOVSCROLL + $WS_VSCROLL)

		GUISetOnEvent($GUI_EVENT_CLOSE, "joinNetworkGUI_exit")
		$gIsTincJoinGuiCreated = True
	EndIf
	GUISetState(@SW_SHOW, $guiNetwork)
EndFunc   ;==>joinNetworkGUI

Func joinNetworkGUI_exit()
	GUISetState(@SW_HIDE, $guiNetwork)
	;GUIDelete($guiNetwork)
	;Exit
EndFunc   ;==>joinNetworkGUI_exit

#Region Tinc functions
Func tinc_join()
	Local $joinCode = GUICtrlRead($idInputCode)
	; Works! B.c. StderrRead
	$tincJoinOutput = _GetDOSOutput($gTincDirEscaped & 'tinc.exe --batch join ' & $joinCode)
	If StringInStr($tincJoinOutput, "Invitation succesfully accepted") <> 0 Then
		MsgBox($MB_ICONINFORMATION + $MB_OK, "Invitation finished", "You successfully joined the network.", 0, $guiNetwork)
		; Clear and rebuild tray list
		trayClearNetworks()
		trayCreateNetworks()
	ElseIf StringInStr($tincJoinOutput, "Invalid invitation URL") <> 0 Then
		MsgBox($MB_OK + $MB_ICONERROR, "Invalid invitation code", "The entered invitation code is not valid.", 0, $guiNetwork)
	Else
		MsgBox($MB_OK + $MB_ICONERROR, "Invitation failed", "Oops. Something went wrong. See console output for details.", 0, $guiNetwork)
	EndIf

	;ConsoleWrite(_GetDOSOutput('C:\"Program Files"\tinc\tinc --batch join nukenuke.zapto.org/xxzaKY9HTVBfZsUJoA2L3Lasm-DzREYrQjySRkC6mJrYSi8Z'))
	;ConsoleWrite(_RunDos('C:\"Program Files"\tinc\tinc --batch join ' & $joinCode))
	;RunWait('cmd /c C:\"Program Files"\tinc\tinc --batch help ' & $joinCode & ' || pause', "", @SW_MAXIMIZE)
	;RunWait('cmd /c C:\"Program Files"\tinc\tinc --batch join ' & $joinCode & ' > tinc.join.txt', "", @SW_MAXIMIZE)
	;RunWait('cmd /c C:\"Program Files"\tinc\tinc -n gaming start -D -d3', "", @SW_MAXIMIZE)
EndFunc   ;==>tinc_join

Func tinc_start($networkName)
	; Run in ComSpec
	Local $sCommand = $gTincDirEscaped & 'tinc.exe -n ' & $networkName & ' start -D -d3'
	;ConsoleWrite($sCommand & @CRLF)
	$iTincStartPid = Run('"' & @ComSpec & '" /c ' & $sCommand, "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	; Set Boolean used in main loop
	$bTincStarted = True
	GUICtrlSetState($hTincDisconnectButton, $GUI_ENABLE)

	setTrayIcon($ICON_TRAY_GREEN)
EndFunc   ;==>tinc_start

Func tinc_stop()
	;ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $iTincStartPid = ' & $iTincStartPid & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console
	Local $iTincdPid = ProcessExists("tincd.exe")
	;ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $iTincdPid = ' & $iTincdPid & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console
	ProcessClose($iTincStartPid)
	ProcessClose($iTincdPid)

	_GUICtrlEdit_AppendText($hTincStartLog, "+-------------------------------+" & @CRLF & _
	                                        "| tinc stopped                  |" & @CRLF & _
											"+-------------------------------|" & @CRLF)
	TrayItemSetText($hTrayTincConnect, "Connect") ; Reset

	GUICtrlSetState($hTincDisconnectButton, $GUI_DISABLE)

	setTrayIcon($ICON_TRAY_GREY)
EndFunc   ;==>tinc_stop
#EndRegion

Func _GetDOSOutput($sCommand)
    Local $iPID, $sOutput = "", $value
    $iPID = Run('"' & @ComSpec & '" /c ' & $sCommand, "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
    While 1
		;$value = StdoutRead($iPID, False, False)
		$value = StderrRead($iPID, False, False)
        $sOutput &= $value
        If @error Then
            ExitLoop
		Else
			_GUICtrlEdit_AppendText($idMyedit, $value)
        EndIf
        Sleep(10)
    WEnd
    Return $sOutput
EndFunc   ;==>_GetDOSOutput

trayCreateNetworks()
trayMenu()