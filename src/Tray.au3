#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.2
 Author:         t-knapp

 Script Function:
	Functions manipulating TrayIcon and TrayMenu

#ce ----------------------------------------------------------------------------

#include-once
#include "Globals.au3"

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

Func trayInsertNetworks()
	Local $i = 0
	Local $arrayLengh = UBound($aArray)
	While $i < $arrayLengh
		$aArray[$i][0] = StringReplace($aArray[$i][0], "\", "")    ; Remove trailing "\" from VPN name
		$aArray[$i][1] = TrayCreateMenu($aArray[$i][0], -1, 0)     ; Create a tray menu sub menu with two sub items.
		$aArray[$i][2] = TrayCreateItem("Connect", $aArray[$i][1]) ; Create submenu item connect
		$aArray[$i][3] = TrayCreateItem("Edit", $aArray[$i][1])    ; Create submenu item edit
		$arrayLengh = UBound($aArray)
		$i += 1
	WEnd
EndFunc

#Region Set tray icon stuff
Func setTrayIcon($trayIconColor)
	Local $pathToIcon = @TempDir & '\' & $trayIconColor & '.ico'
	If Not FileExists($pathToIcon) Then
		_Resource_SaveToFile($pathToIcon, $trayIconColor)
	EndIf
	TraySetIcon($pathToIcon)
EndFunc
#EndRegion