#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.2
 Author:         B0erek

 Script Function:
	Script encapsulate tinc functions.

#ce ----------------------------------------------------------------------------

#include <MsgBoxConstants.au3>


tincSearchInstallDir()
Func tincSearchInstallDir()
; STUB
;[ ] prüfen ob Tin installiert ist
;[ ] Regfile nach Installationspfad durchsuchen
;[ ] HDD durchsuchen nach tinc
;[ ] menuelle Suche erlauben ?!?!

;prüfen ob os 32 oder 64 bit


if @OSArch = "X64" Then
	Local $TPfad = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\tinc", "") ;win10 64bit (32bit Tool unter 64bit os)
	MsgBox($MB_SYSTEMMODAL, "Betriebssystem 64 bit ", @OSVersion & " " & @OSArch)
Else
	Local $TPfad = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\tinc", "") ;win7 32bit (32bit Tool unter 32bit os)
	MsgBox($MB_SYSTEMMODAL, "Betriebssystem 32 bit ", @OSVersion & " " & @OSArch)
EndIf

if $TPfad <> "" Then
	MsgBox($MB_SYSTEMMODAL, "Tinc.exe file is in:", $TPfad)

;prüfen Per Pfad
ElseIf FileExists ( @ProgramFilesDir&"\tinc" ) then
		msgbox(0,"Info",@ProgramFilesDir&"\tinc")

Else
	MsgBox($MB_SYSTEMMODAL, "Kein Pfad gefunden", $TPfad)
EndIf

EndFunc