#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.2
 Author:         tknapp

 Script Function:
	Functions getting tinc network adapters details (IP, DHCP, etc.)

#ce ----------------------------------------------------------------------------

#requireadmin
#AutoIt3Wrapper_UseAnsi=y

#Region Functions getting tinc network adapters details (IP, DHCP, etc.)
; Get index for adapters GUID
Func adaptersGetIndexForGUID($sGUID)
    Local $oWMIService = ObjGet("winmgmts:{impersonationLevel = impersonate}!\\" & "." & "\root\cimv2")
    Local $oColItems = $oWMIService.ExecQuery("Select Index From Win32_NetworkAdapter WHERE GUID = '" & $sGUID & "'", "WQL", 0x30)
    If IsObj($oColItems) Then
		For $oObjectItem In $oColItems
		If IsNumber($oObjectItem.Index) Then
			Return $oObjectItem.Index
		EndIf
		Next
    EndIf
    Return SetError(1)
EndFunc

; Get IP Address for devices index
Func adaptersGetIpAddress($iIndex)
    Local $oWMIService = ObjGet("winmgmts:{impersonationLevel = impersonate}!\\" & "." & "\root\cimv2")
    Local $oColItems = $oWMIService.ExecQuery("Select IPAddress From Win32_NetworkAdapterConfiguration WHERE Index = '" & $iIndex & "'", "WQL", 0x30), $aReturn[9] = [8]
    If IsObj($oColItems) Then
        For $oObjectItem In $oColItems
        If IsString($oObjectItem.IPAddress(0)) Then
			Return $oObjectItem.IPAddress(0)
		EndIf
        Next
    EndIf
    Return SetError(1)
EndFunc

; Get IP Address of DHCP server
Func adaptersGetDHCPIpAddress($iIndex)
    Local $oWMIService = ObjGet("winmgmts:{impersonationLevel = impersonate}!\\" & "." & "\root\cimv2")
    Local $oColItems = $oWMIService.ExecQuery("Select DHCPServer From Win32_NetworkAdapterConfiguration WHERE Index = '" & $iIndex & "'", "WQL", 0x30), $aReturn[9] = [8]
    If IsObj($oColItems) Then
        For $oObjectItem In $oColItems
        If IsString($oObjectItem.DHCPServer) Then
			Return $oObjectItem.DHCPServer
		EndIf
        Next
    EndIf
    Return SetError(1)
EndFunc
#EndRegion