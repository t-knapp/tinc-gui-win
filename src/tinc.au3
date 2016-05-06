#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.2
 Author:         B0erek, t-knapp

 Script Function:
	Script encapsulate tinc functions join, start, stop

#ce ----------------------------------------------------------------------------

#include-once
#include "Globals.au3"
#include "Tray.au3"

#Region Tinc functions

Func tinc_join()
	Local $joinCode = GUICtrlRead($idInputCode)
	; Works! B.c. StderrRead
	$tincJoinOutput = _GetDOSOutput($gTincDirEscaped & 'tinc.exe --batch join ' & $joinCode)
	If StringInStr($tincJoinOutput, "Invitation succesfully accepted") <> 0 Then
		MsgBox($MB_ICONINFORMATION + $MB_OK, "Invitation finished", "You successfully joined the network.", 0, $guiNetwork)
		; Clear and rebuild tray list
		trayClearNetworks()  ; Clear tray menu
		;trayCreateNetworks()
		tincSetNetworks()    ; Refresh network array
		trayInsertNetworks() ; Rebuild tray menu based on network array
	ElseIf StringInStr($tincJoinOutput, "Invalid invitation URL") <> 0 Then
		MsgBox($MB_OK + $MB_ICONERROR, "Invalid invitation code", "The entered invitation code is not valid.", 0, $guiNetwork)
	Else
		MsgBox($MB_OK + $MB_ICONERROR, "Invitation failed", "Oops. Something went wrong. See console output for details.", 0, $guiNetwork)
	EndIf
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

	$sTincTAPDeviceGUID = "" ; Reset
	TraySetToolTip()

	setTrayIcon($ICON_TRAY_GREY)
EndFunc   ;==>tinc_stop

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

#EndRegion

#Region Tinc paths for network lookup and start in console
Func tincGetTincPaths()
	$gTincDir        = "C:\Program Files\tinc\"
	$gTincDirEscaped = StringReplace($gTincDir, "Program Files", '"Program Files"')
	; TODO: Check if exists, else FileOpenDialog
	; TODO: Save paths to Ini, SQLite, Registry

	; Debug
	ConsoleWrite("$gTincDir       : " & $gTincDir & @CRLF)
	ConsoleWrite("$gTincDirEscaped: " & $gTincDirEscaped & @CRLF)
EndFunc
#EndRegion

Func tincSetNetworks()
	; The filter also applies to folders when recursively searching for folders
	$aArray = _FileListToArrayRec($gTincDir, "*", $FLTAR_FOLDERS, $FLTAR_noRECUR, $FLTAR_SORT)
	_ArrayDelete($aArray,0)
	_ArrayColInsert($aArray, 1) ; Network (required for clear tray menu)
	_ArrayColInsert($aArray, 2) ;   + Connect
	_ArrayColInsert($aArray, 3) ;   + Edit

    Local $i = 0
	Local $arrayLengh = UBound($aArray)
	While $i < $arrayLengh
		If Not FileExists($gTincDir & $aArray[$i][0] & "tinc.conf") Then
			_ArrayDelete($aArray, $i)
			$i = $i - 1
		EndIf
		$arrayLengh = UBound($aArray)
		$i = $i + 1
	WEnd
EndFunc   ;==>VPN2Tray