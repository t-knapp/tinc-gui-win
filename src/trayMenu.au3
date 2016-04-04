;*****************************************
; TrayMenu by Boerek
; Erstellt mit ISN AutoIt Studio v. 1.00
;*****************************************
#AutoIt3Wrapper_Res_File_Add=..\res\tinc-grey.ico,   RT_RCDATA, ICON_TRAY_STATUS_GREY, 0
#AutoIt3Wrapper_Res_File_Add=..\res\tinc-green.ico,  RT_RCDATA, ICON_TRAY_STATUS_GREEN, 0
#AutoIt3Wrapper_Res_File_Add=..\res\tinc-yellow.ico, RT_RCDATA, ICON_TRAY_STATUS_YELLOW, 0

#include <Array.au3>; Only required to display the arrays
#include <File.au3>
#include <MsgBoxConstants.au3>
#include <WinAPIFiles.au3>
#include <TrayConstants.au3>; Required for the $TRAY_ICONSTATE_SHOW constant.

#include '..\lib\ResourcesEx.au3' ; Requires compilation to exe to use _Resources_*() Functions

Opt("TrayMenuMode", 3) ; The default tray menu items will not be shown and items are not checked when selected. These are options 1 and 2 for TrayMenuMode.

Dim $aArray[1][1] ; 2D Array for VPN Name | Pointer Button Connect | Pointer Button Edit

VPN2Tray()
Traymenu()

Func setTrayIcon()
	Local $pathToIcon = @TempDir & '\tinc-gray-tmp.ico'
	_Resource_SaveToFile($pathToIcon, 'ICON_TRAY_STATUS_GREY')
	TraySetIcon($pathToIcon)
EndFunc

Func VPN2Tray()
	Local $sAutoItDir =  "C:\Program Files (x86)\tinc\"

	; Ordner in array
	; The filter also applies to folders when recursively searching for folders
	$aArray = _FileListToArrayRec($sAutoItDir, "*", $FLTAR_FOLDERS, $FLTAR_noRECUR, $FLTAR_SORT)
	_ArrayDelete($aArray,0)
	_ArrayColInsert($aArray, 1) ;Connect
	_ArrayColInsert($aArray, 2) ;Bearbeiten
	; Now a 2D array

    $i = 0
	$arrayLengh = UBound($aArray)
	While $i < $arrayLengh
		If FileExists($sAutoItDir & $aArray[$i][0] & "tinc.conf") Then
			; Remove trailing "\" from VPN name
			$aArray[$i][0] = StringReplace($aArray[$i][0], "\", "")

            Local $iVPN = TrayCreateMenu($aArray[$i][0]) ; Create a tray menu sub menu with two sub items.
			$aArray[$i][1] = TrayCreateItem("Connect", $iVPN)
			$aArray[$i][2] = TrayCreateItem("Edit", $iVPN)
		Else
			_ArrayDelete($aArray, $i)
			$i = $i - 1
		EndIf
		$arrayLengh = UBound($aArray)
		$i = $i + 1
	WEnd
	_ArrayDisplay($aArray, "Folder recur with filter")

EndFunc   ;==>VPN2Tray


Func Traymenu()
	Local $iSettings = TrayCreateMenu("Settings") ; Create a tray menu sub menu with two sub items.
	Local $iDisplay = TrayCreateItem("Display", $iSettings)
	Local $iPrinter = TrayCreateItem("Printer", $iSettings)
	TrayCreateItem("") ; Create a separator line.

	Local $idAbout = TrayCreateItem("About")
	TrayCreateItem("") ; Create a separator line.

	Local $idExit = TrayCreateItem("Exit")

	TraySetState($TRAY_ICONSTATE_SHOW) ; Show the tray menu.

    setTrayIcon()

	While 1
		$msg = TrayGetMsg()
		Switch $msg
			Case $idAbout ; Display a message box about the AutoIt version and installation path of the AutoIt executable.
				MsgBox($MB_SYSTEMMODAL, "", "AutoIt tray menu example." & @CRLF & @CRLF & _
						"Version: " & @AutoItVersion & @CRLF & _
						"Install Path: " & StringLeft(@AutoItExe, StringInStr(@AutoItExe, "\", 0, -1) - 1)) ; Find the folder of a full path.

			Case $iDisplay, $iPrinter
				;MsgBox($MB_SYSTEMMODAL, "", "A sub menu item was selected from the tray menu.")

			Case $idExit ; Exit the loop.
				ExitLoop
			Case Else
				If $msg <> 0 Then
					Local $notFound = True
					Local $i = 0
					While $i < UBound($aArray) And $notFound
						If $msg == $aArray[$i][1] Then
							$notFound = False
							MsgBox(0, "Connect to: ", $aArray[$i][0])
						ElseIf $msg == $aArray[$i][2] Then
							$notFound = False
							MsgBox(0, "Edit: ", $aArray[$i][0])
						EndIf
						$i = $i + 1
					WEnd
				EndIf
		EndSwitch
	WEnd
EndFunc   ;==>Traymenu




