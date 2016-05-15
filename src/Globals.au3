#include-once

; GUI related
Global $idInputCode
Global $gTincDirEscaped
Global $guiNetwork
Global $hTincDisconnectButton

; TrayIcon related
Global Const $ICON_TRAY_GREY   = 'ICON_TRAY_STATUS_GREY'
Global Const $ICON_TRAY_GREEN  = 'ICON_TRAY_STATUS_GREEN'
Global Const $ICON_TRAY_YELLOW = 'ICON_TRAY_STATUS_YELLOW'

; Tinc related
Global $iTincStartPid
Global $hTincStartLog    ; tinc start log output
Global $hTrayTincConnect ; Tray 'Connect'
Global $idMyedit         ; tinc join log output
Global $gTincDir         ; full path to tinc dir
Global $gTincDirEscaped  ; full path to tinc dir escaped for usage in @ComSpec
Dim $aArray[1][1]        ; 2D Array for VPN Name | Pointer [NetworkName] Menu | Pointer Button Connect | Pointer Button Edit
Global $aArray           ; Array

; Tinc start related
Global $iTincStartPid
Global $bTincStarted = False
Global $bTincStartGui = False
Global $hTincStartLog
Global $hTrayTincConnect
Global $sTincNetworkName        ; Holds the name of the currently connected network
Global $bValidIPAddress = False ; Determines if interface already got IP Address by DHCP

; NetworkAdapters related
Global $sTincTAPDeviceGUID = "" ; GUID of Virtual TAP Device, used to look-up index
Global $iTincTAPDeviceIndex     ; Index of Virtual TAP Device, used for interface stats