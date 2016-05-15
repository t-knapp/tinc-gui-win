#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\res\tinc-green-new.ico
#AutoIt3Wrapper_Outfile=..\tinc-gui.exe
#AutoIt3Wrapper_Res_File_Add=..\res\tinc-grey-new.ico,   RT_RCDATA, ICON_TRAY_STATUS_GREY, 0
#AutoIt3Wrapper_Res_File_Add=..\res\tinc-green-new.ico,  RT_RCDATA, ICON_TRAY_STATUS_GREEN, 0
#AutoIt3Wrapper_Res_File_Add=..\res\tinc-yellow-new.ico, RT_RCDATA, ICON_TRAY_STATUS_YELLOW, 0
#AutoIt3Wrapper_Res_File_Add=..\res\tinc-red-new.ico,    RT_RCDATA, ICON_TRAY_STATUS_RED, 0
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.2
 Author:         Boerek, t-knapp

#ce ----------------------------------------------------------------------------


#include <Array.au3>; Only required to display the arrays
#include <File.au3>
#include <Date.au3>
#include <MsgBoxConstants.au3>
#include <WinAPIFiles.au3>
#include <TrayConstants.au3>; Required for the $TRAY_ICONSTATE_SHOW constant.
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiEdit.au3>
#include <Process.au3>

#include '..\lib\ResourcesEx.au3' ; Requires compilation to exe to use _Resources_*() Functions

#include "Globals.au3"
#include "NetworkAdapter.au3" ; Functions for reading TAP devices information
#include "Tinc.au3"
#include "Tray.au3"
#include "GUI.au3"

Opt("TrayMenuMode", 3)   ; The default tray menu items will not be shown and items are not checked when selected. These are options 1 and 2 for TrayMenuMode.
Opt("GUIOnEventMode", 1) ; Change to OnEvent mode

Func main()
	TrayCreateItem("")
    Local $idJoin = TrayCreateItem("Join new network")

	TrayCreateItem("")
	Local $idExit = TrayCreateItem("Exit")

	TraySetState($TRAY_ICONSTATE_SHOW) ; Show the tray menu.

    setTrayIcon($ICON_TRAY_GREY)

	While 1
		$msg = TrayGetMsg()
		Switch $msg

			Case $idJoin ; Show join window for entering an invitation code for a network.
				joinNetworkGUI()

			Case $idExit ; Exit tinc and terminate script
				If $bTincStarted == True Then
					tinc_stop()
				EndIf
				ExitLoop

			Case Else
				; Lookup the pressed tray menu item
				If $msg <> 0 Then
					Local $bNotFound = True
					Local $i = 0
					While $i < UBound($aArray) And $bNotFound
						$sTincNetworkName = $aArray[$i][0] ; Global set selected network name
						If $msg == $aArray[$i][2] Then
							$bNotFound = False
							guiTincStart($sTincNetworkName) ; Show GUI
							If Not ProcessExists("tincd.exe") Then
								tinc_start($sTincNetworkName) ; Start tinc with selected network
								$hTrayTincConnect = $aArray[$i][2]
								TrayItemSetText($hTrayTincConnect, "Status") ; Change from "Connect" to "Status"
							EndIf
						ElseIf $msg == $aArray[$i][3] Then
							$bNotFound = False
							MsgBox(0, "Edit: ", $sTincNetworkName)
							;MsgBox(0, "tinc.conf", tincGetNetworkOwnHostName($sTincNetworkName))
							MsgBox(0, "tinc.conf", tincGetNetworkSubnet($sTincNetworkName))
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
					; TODO: Split at EOL and foreach...
					_GUICtrlEdit_AppendText($hTincStartLog, "[" & _Now() & "]: " & $sTincStartValue)

					; Find GUID of TAP Device to read details
					If $sTincTAPDeviceGUID == "" Then
						Local $iIndexStart = StringInStr($sTincStartValue, '{')
						Local $iIndexEnd   = StringInStr($sTincStartValue, '}')
						If $iIndexStart <> 0 And $iIndexEnd <> 0 Then
							$sTincTAPDeviceGUID = StringMid($sTincStartValue, $iIndexStart, $iIndexEnd - $iIndexStart + 1)
							$iTincTAPDeviceIndex = adaptersGetIndexForGUID($sTincTAPDeviceGUID)
						EndIf
					EndIf
				EndIf
			EndIf

			; Workarround for setting TrayIcon corresponding to IP Address
			If Not $bValidIPAddress Then
				Local $sIP = adaptersGetIpAddress($iTincTAPDeviceIndex)
				If StringInStr($sIP, tincGetNetworkSubnet($sTincNetworkName)) == 1 Then
					TrayTip("Connected to " & $sTincNetworkName, "Your IP-Address is " & $sIP, 0, $TIP_ICONASTERISK + $TIP_NOSOUND)
					TraySetToolTip("Your IP-Address is " & $sIP)
					setTrayIcon($ICON_TRAY_GREEN)
					$bValidIPAddress = True
				EndIf
			EndIf
		EndIf

	WEnd
EndFunc   ;==>Traymenu

tincGetTincPaths()   ; Set global tinc paths
tincSetNetworks()    ; Set global array of available tinc networks
trayInsertNetworks() ; Create tray menu items based on available networks
main()               ; Main-Loop