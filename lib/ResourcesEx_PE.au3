Global $g_vMacro_J3611D687A2E2445F907F05FFD04B3A5DD611C3C6DAB446A4B196B389830541DFA8D8248BB4584FB0AE1CE6BDD0DCE952 = @AutoItExe
#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6
#include-once
#include <APIResConstants.au3>
#include <ButtonConstants.au3>
#include <GDIPlus.au3>
#include <GUIMenu.au3>
#include <Memory.au3>
#include <StaticConstants.au3>
#include <WinAPIMisc.au3>
#include <WinAPIRes.au3>
#include <WindowsConstants.au3>
OnAutoItExitRegister(_GDIPlus_Shutdown)
OnAutoItExitRegister(_Resource_DestroyAll)
_GDIPlus_Startup()
Func _Resource_Destroy($sResNameOrID, $iResType = $RT_RCDATA, $iResLang = Default, $sDllOrExePath = Default)
If $iResLang = Default Then $iResLang = 0
If $iResType = Default Then $iResType = $RT_RCDATA
Return __Resource_Storage(9, $sDllOrExePath, Null, $sResNameOrID, $iResType, $iResLang, $iResType, Null)
EndFunc
Func _Resource_DestroyAll()
Return __Resource_Storage(10, Null, Null, Null, Null, Null, Null, Null)
EndFunc
Func _Resource_GetAsBitmap($sResNameOrID, $iResType = $RT_RCDATA, $sDllOrExePath = Default)
Local $hHBITMAP = 0, $hBitmap = _Resource_GetAsImage($sResNameOrID, $iResType, $sDllOrExePath)
Local $iError = @error
Local $iLength = @extended
If $iError = 0 And $iLength > 0 Then
$hHBITMAP = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hBitmap)
If @error Then
$iError = 7
Else
_GDIPlus_BitmapDispose($hBitmap)
$hBitmap = 0
EndIf
EndIf
If $iError <> 0 Then $hHBITMAP = 0
Return SetError($iError, $iLength, $hHBITMAP)
EndFunc
Func _Resource_GetAsCursor($sResNameOrID, $iResType = $RT_RCDATA, $sDllOrExePath = Default)
Local $hCursor = __Resource_Get($sResNameOrID, $iResType, 0, $sDllOrExePath, $RT_CURSOR)
Local $iError = @error
Local $iLength = @extended
If $iError <> 0 Then $hCursor = 0
Return SetError($iError, $iLength, $hCursor)
EndFunc
Func _Resource_GetAsBytes($sResNameOrID, $iResType = $RT_RCDATA, $iResLang = Default, $sDllOrExePath = Default)
Local $pResource = __Resource_Get($sResNameOrID, $iResType, $iResLang, $sDllOrExePath, $RT_RCDATA)
Local $iError = @error
Local $iLength = @extended
Local $dBytes = Binary(Null)
If $iError = 0 And $iLength > 0 Then
Local $tBuffer = DllStructCreate('byte array[' & $iLength & ']', $pResource)
$dBytes = DllStructGetData($tBuffer, 'array')
EndIf
Return SetError($iError, $iLength, $dBytes)
EndFunc
Func _Resource_GetAsIcon($sResNameOrID, $iResType = $RT_RCDATA, $sDllOrExePath = Default)
Local $hIcon = __Resource_Get($sResNameOrID, $iResType, 0, $sDllOrExePath, $RT_ICON)
Local $iError = @error
Local $iLength = @extended
If $iError <> 0 Then $hIcon = 0
Return SetError($iError, $iLength, $hIcon)
EndFunc
Func _Resource_GetAsImage($sResNameOrID, $iResType = $RT_RCDATA, $sDllOrExePath = Default)
If $iResType = Default Then $iResType = $RT_RCDATA
Local $iError = 10, $iLength = 0, $hBitmap = 0
Switch $iResType
Case $RT_BITMAP
Local $hHBITMAP = __Resource_Get($sResNameOrID, $RT_BITMAP, 0, $sDllOrExePath, $RT_BITMAP)
$iError = @error
$iLength = @extended
If $iError = 0 And $iLength > 0 Then
$hBitmap = _GDIPlus_BitmapCreateFromHBITMAP($hHBITMAP)
If @error Then
$iError = 10
Else
EndIf
EndIf
Case Else
Local $pResource = __Resource_Get($sResNameOrID, $iResType, 0, $sDllOrExePath, $RT_RCDATA)
$iError = @error
$iLength = @extended
If $iError = 0 And $iLength > 0 Then
$hBitmap = __Resource_ConvertToBitmap($pResource, $iLength)
EndIf
EndSwitch
Return SetError($iError, $iLength, $hBitmap)
EndFunc
Func _Resource_GetAsRaw($sResNameOrID, $iResType = $RT_RCDATA, $iResLang = Default, $sDllOrExePath = Default)
Local $hResource = __Resource_Get($sResNameOrID, $iResType, $iResLang, $sDllOrExePath, $RT_RCDATA)
Return SetError(@error, @extended, $hResource)
EndFunc
Func _Resource_GetAsString($sResNameOrID, $iResType = $RT_RCDATA, $iResLang = Default, $sDllOrExePath = Default)
Local $iError = 12, $iLength = 0, $sString = ''
Switch $iResType
Case $RT_RCDATA
Local $dBytes = _Resource_GetAsBytes($sResNameOrID, $iResType, $iResLang, $sDllOrExePath)
$iError = @error
$iLength = @extended
If $iError = 0 And $iLength > 0 Then
Local $iStart = 0, $iUTFEncoding = 1
Local $iUTF8 = 3, $iUTF16BE = 2, $iUTF16LE = 2, $iUTF32BE = 4, $iUTF32LE = 4
Select
Case BinaryMid($dBytes, 1, $iUTF32BE) = '0x0000FEFF'
$iStart = $iUTF32BE
$iUTFEncoding = 1
Case BinaryMid($dBytes, 1, $iUTF32LE) = '0xFFFE0000'
$iStart = $iUTF32LE
$iUTFEncoding = 1
Case BinaryMid($dBytes, 1, $iUTF16BE) = '0xFEFF'
$iStart = $iUTF16BE
$iUTFEncoding = 3
Case BinaryMid($dBytes, 1, $iUTF16LE) = '0xFFFE'
$iStart = $iUTF16LE
$iUTFEncoding = 2
Case BinaryMid($dBytes, 1, $iUTF8) = '0xEFBBBF'
$iStart = $iUTF8
$iUTFEncoding = 4
EndSelect
$iStart += 1
$iLength = $iLength + 1 - $iStart
$sString = BinaryToString(BinaryMid($dBytes, $iStart), $iUTFEncoding)
EndIf
$dBytes = 0
Case $RT_STRING
$sString = __Resource_Get($sResNameOrID, $iResType, $iResLang, $sDllOrExePath, $iResType)
$iError = @error
$iLength = @extended
EndSwitch
Return SetError($iError, $iLength, $sString)
EndFunc
Func _Resource_LoadFont($sResNameOrID, $iResLang = Default, $sDllOrExePath = Default)
Local $pResource = __Resource_Get($sResNameOrID, $RT_FONT, $iResLang, $sDllOrExePath, $RT_FONT)
Local $iError = @error
Local $iLength = @extended
If $iError = 0 Then
Local $hFont = _WinAPI_AddFontMemResourceEx($pResource, $iLength)
__Resource_Storage(8, $sDllOrExePath, $hFont, $sResNameOrID, 1002, $iResLang, 1002, $iLength)
$hFont = 0
EndIf
Return SetError($iError, $iLength, $pResource)
EndFunc
Func _Resource_LoadSound($sResNameOrID, $iFlags = $SND_SYNC, $sDllOrExePath = Default)
Local $bIsInternal = False, $bReturn = False
Local $hInstance = __Resource_LoadModule($sDllOrExePath, $bIsInternal)
If Not $hInstance Then Return SetError(11, 0, $bReturn)
Local $dSound = _Resource_GetAsBytes($sResNameOrID)
Local $iLength = @extended
If Not $iLength Then
$bReturn = _WinAPI_PlaySound($sResNameOrID, BitOR($SND_RESOURCE, $iFlags), $hInstance)
Else
Local $sAlign_Buffer = '00', $sHeader_1 = '0x52494646', $sHeader_2 = '57415645666D74201E0000005500020044AC0000581B0000010000000C00010002000000B600010071056661637404000000640E060064617461'
Local $sMp3 = StringTrimLeft(Binary($dSound), 2)
Local $iMp3Size = StringRegExpReplace(Hex($iLength, 8), '(..)(..)(..)(..)', '$4$3$2$1')
Local $iWavSize = StringRegExpReplace(Hex($iLength + 63, 8), '(..)(..)(..)(..)', '$4$3$2$1')
Local $sHybridWav = $sHeader_1 & $iWavSize & $sHeader_2 & $iMp3Size & $sMp3
If Mod($iMp3Size, 2) Then
$sHybridWav &= $sAlign_Buffer
EndIf
Local $tWAV = DllStructCreate('byte array[' & BinaryLen($sHybridWav) & ']')
DllStructSetData($tWAV, 'array', $sHybridWav)
$iFlags = BitOR($SND_MEMORY, $SND_NODEFAULT, $iFlags)
$bReturn = _WinAPI_PlaySound(DllStructGetPtr($tWAV), $iFlags, $hInstance)
EndIf
__Resource_UnloadModule($hInstance, $bIsInternal)
Return $bReturn
EndFunc
Func _Resource_SaveToFile($sFilePath, $sResNameOrID, $iResType = $RT_RCDATA, $iResLang = Default, $bCreatePath = Default, $sDllOrExePath = Default)
Local $bReturn = False, $iCreatePath = (IsBool($bCreatePath) And $bCreatePath ? $FO_CREATEPATH : 0), $iError = 0, $iLength = 0
If $iResType = Default Then $iResType = $RT_RCDATA
If $iResType = $RT_BITMAP Then
Local $hImage = _Resource_GetAsImage($sResNameOrID, $iResType)
$iError = @error
$iLength = @extended
If $iError = 0 And $iLength > 0 Then
FileClose(FileOpen($sFilePath, BitOR($FO_OVERWRITE, $FO_BINARY, $iCreatePath)))
$bReturn = _GDIPlus_ImageSaveToFile($hImage, $sFilePath)
_GDIPlus_ImageDispose($hImage)
EndIf
Else
Local $dBytes = _Resource_GetAsBytes($sResNameOrID, $iResType, $iResLang, $sDllOrExePath)
$iError = @error
$iLength = @extended
If $iError = 0 And $iLength > 0 Then
Local $hFileOpen = FileOpen($sFilePath, BitOR($FO_OVERWRITE, $FO_BINARY, $iCreatePath))
If $hFileOpen > -1 Then
$bReturn = True
FileWrite($hFileOpen, $dBytes)
FileClose($hFileOpen)
EndIf
EndIf
EndIf
Return SetError($iError, $iLength, $bReturn)
EndFunc
Func _Resource_SetBitmapToCtrlID($iCtrlID, $hHBITMAP, $bResize = Default)
Local $bReturn = __Resource_SetToCtrlID($iCtrlID, $hHBITMAP, $RT_BITMAP, False, $bResize)
Return SetError(@error, @extended, $bReturn)
EndFunc
Func _Resource_SetCursorToCtrlID($iCtrlID, $hCursor, $bResize = Default)
Local $bReturn = __Resource_SetToCtrlID($iCtrlID, $hCursor, $RT_CURSOR, False, $bResize)
Return SetError(@error, @extended, $bReturn)
EndFunc
Func _Resource_SetIconToCtrlID($iCtrlID, $hIcon, $bResize = Default)
Local $bReturn = __Resource_SetToCtrlID($iCtrlID, $hIcon, $RT_ICON, False, $bResize)
Return SetError(@error, @extended, $bReturn)
EndFunc
Func _Resource_SetImageToCtrlID($iCtrlID, $hBitmap, $bResize = Default)
Local $hHBITMAP = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hBitmap)
If @error Then
$hHBITMAP = 0
Else
_GDIPlus_BitmapDispose($hBitmap)
EndIf
$hBitmap = 0
Local $bReturn = __Resource_SetToCtrlID($iCtrlID, $hHBITMAP, $RT_BITMAP, False, $bResize)
Return SetError(@error, @extended, $bReturn)
EndFunc
Func _Resource_SetToCtrlID($iCtrlID, $sResNameOrID, $iResType = $RT_RCDATA, $sDllOrExePath = Default, $bResize = Default)
If $iResType = Default Then $iResType = $RT_RCDATA
Local $aWinGetPos = 0, $bDestroy = True, $bReturn = False, $iError = 5, $iLength = 0, $vReturn = False
Local $hWnd = 0
__Resource_GetCtrlId($hWnd, $iCtrlID)
Switch $iResType
Case $RT_BITMAP, $RT_RCDATA
If StringStripWS($sResNameOrID, $STR_STRIPALL) = '' Or String($sResNameOrID) = '0' Then
$bReturn = __Resource_SetToCtrlID($iCtrlID, 0, $RT_BITMAP, True, False)
$iError = @error
Else
Local $hHBITMAP = _Resource_GetAsBitmap($sResNameOrID, $iResType, $sDllOrExePath)
$iError = @error
$iLength = @extended
If $iError = 0 And $iLength > 0 Then
$bReturn = __Resource_SetToCtrlID($iCtrlID, $hHBITMAP, $RT_BITMAP, $bDestroy, $bResize)
$iError = @error
If $bReturn Then
If $__WINVER >= 0x0600 Then
$bReturn = _WinAPI_DeleteObject($hHBITMAP) > 0
$vReturn = $bReturn
Else
__Resource_Storage(8, $sDllOrExePath, $hHBITMAP, $sResNameOrID, $iResType, Null, $iResType, $iLength)
$vReturn = $hHBITMAP
EndIf
EndIf
EndIf
EndIf
Case $RT_CURSOR
If StringStripWS($sResNameOrID, $STR_STRIPALL) = '' Or String($sResNameOrID) = '0' Then
$bReturn = __Resource_SetToCtrlID($iCtrlID, 0, $RT_CURSOR, True, False)
$iError = @error
Else
$bDestroy = False
Local $hCursor = 0
If $bResize Then
$aWinGetPos = WinGetPos($hWnd)
If Not @error Then
Local $aPos[2]
$aPos[0] = $aWinGetPos[3]
$aPos[1] = $aWinGetPos[2]
If $aPos[0] = 0 And $aPos[1] = 0 Then
GUICtrlSetImage($iCtrlID, $g_vMacro_J3611D687A2E2445F907F05FFD04B3A5DD611C3C6DAB446A4B196B389830541DFA8D8248BB4584FB0AE1CE6BDD0DCE952, 0)
$aWinGetPos = WinGetPos($hWnd)
If Not @error Then
$aPos[0] = $aWinGetPos[3]
$aPos[1] = $aWinGetPos[2]
EndIf
EndIf
$hCursor = __Resource_Get($sResNameOrID, $RT_CURSOR, 0, $sDllOrExePath, $RT_CURSOR, $aPos)
$iError = @error
$iLength = @extended
EndIf
Else
$hCursor = _Resource_GetAsCursor($sResNameOrID, $iResType, $sDllOrExePath)
$iError = @error
$iLength = @extended
EndIf
If $iError = 0 Then
$bReturn = __Resource_SetToCtrlID($iCtrlID, $hCursor, $RT_CURSOR, $bDestroy, $bResize)
EndIf
$hCursor = 0
$vReturn = $bReturn
EndIf
Case $RT_ICON
If StringStripWS($sResNameOrID, $STR_STRIPALL) = '' Or String($sResNameOrID) = '0' Then
$bReturn = __Resource_SetToCtrlID($iCtrlID, 0, $RT_ICON, True, False)
$iError = @error
Else
$bDestroy = False
Local $hIcon = 0
If $bResize Then
__Resource_GetCtrlId($hWnd, $iCtrlID)
$aWinGetPos = WinGetPos($hWnd)
If Not @error Then
Local $aPos[2]
$aPos[0] = $aWinGetPos[3]
$aPos[1] = $aWinGetPos[2]
If $aPos[0] = 0 And $aPos[1] = 0 Then
GUICtrlSetImage($iCtrlID, $g_vMacro_J3611D687A2E2445F907F05FFD04B3A5DD611C3C6DAB446A4B196B389830541DFA8D8248BB4584FB0AE1CE6BDD0DCE952, 0)
$aWinGetPos = WinGetPos($hWnd)
If Not @error Then
$aPos[0] = $aWinGetPos[3]
$aPos[1] = $aWinGetPos[2]
EndIf
EndIf
$hIcon = __Resource_Get($sResNameOrID, $RT_ICON, 0, $sDllOrExePath, $RT_ICON, $aPos)
$iError = @error
$iLength = @extended
EndIf
Else
$hIcon = _Resource_GetAsIcon($sResNameOrID, $iResType, $sDllOrExePath)
$iError = @error
$iLength = @extended
EndIf
If $iError = 0 Then
$bReturn = __Resource_SetToCtrlID($iCtrlID, $hIcon, $RT_ICON, $bDestroy, $bResize)
EndIf
$hIcon = 0
$vReturn = $bReturn
EndIf
EndSwitch
Return SetError($iError, $iLength, $vReturn)
EndFunc
Func __Resource_ConvertToBitmap($pResource, $iLength)
Local $hData = _MemGlobalAlloc($iLength, $GMEM_MOVEABLE)
Local $pData = _MemGlobalLock($hData)
_MemMoveMemory($pResource, $pData, $iLength)
_MemGlobalUnlock($hData)
Local $pStream = _WinAPI_CreateStreamOnHGlobal($hData)
Local $hBitmap = _GDIPlus_BitmapCreateFromStream($pStream)
_WinAPI_ReleaseStream($pStream)
Return $hBitmap
EndFunc
Func __Resource_Destroy($pResource, $iResType)
Local $bReturn = False
Switch $iResType
Case $RT_ANICURSOR, $RT_CURSOR
$bReturn = _WinAPI_DeleteObject($pResource) > 0
If Not $bReturn Then
$bReturn = _WinAPI_DestroyCursor($pResource) > 0
EndIf
Case $RT_BITMAP
$bReturn = _WinAPI_DeleteObject($pResource) > 0
Case $RT_FONT
$bReturn = True
Case $RT_ICON
$bReturn = _WinAPI_DeleteObject($pResource) > 0
If Not $bReturn Then
$bReturn = _WinAPI_DestroyIcon($pResource) > 0
EndIf
Case $RT_MENU
$bReturn = _GUICtrlMenu_DestroyMenu($pResource) > 0
Case $RT_STRING
$bReturn = True
Case 1000
$bReturn = _GDIPlus_BitmapDispose($pResource) > 0
Case 1001
$bReturn = _WinAPI_DeleteEnhMetaFile($pResource) > 0
Case 1002
$bReturn = _WinAPI_RemoveFontMemResourceEx($pResource) > 0
Case Else
$bReturn = True
EndSwitch
If Not IsBool($bReturn) Then $bReturn = $bReturn > 0
Return $bReturn
EndFunc
Func __Resource_Get($sResNameOrID, $iResType = $RT_RCDATA, $iResLang = Default, $sDllOrExePath = Default, $iCastResType = Default, $aPos = Null)
If $iResType = $RT_RCDATA And StringStripWS($sResNameOrID, $STR_STRIPALL) = '' Then Return SetError(4, 0, Null)
If $iCastResType = Default Then $iCastResType = $iResType
If $iResLang = Default Then $iResLang = 0
If $iResType = Default Then $iResType = $RT_RCDATA
Local $iError = 0, $iLength = 0, $vResource = __Resource_Storage(11, $sDllOrExePath, Null, $sResNameOrID, $iResType, $iResLang, $iCastResType, Null)
$iLength = @extended
If $vResource Then
Return SetError($iError, $iLength, $vResource)
EndIf
Local $bIsInternal = False
Local $hInstance = __Resource_LoadModule($sDllOrExePath, $bIsInternal)
If Not $hInstance Then Return SetError(11, 0, 0)
Local $hResource = (($iResLang <> 0) ? _WinAPI_FindResourceEx($hInstance, $iResType, $sResNameOrID, $iResLang) : _WinAPI_FindResource($hInstance, $iResType, $sResNameOrID))
If @error <> 0 Then $iError = 1
If $iError = 0 Then
If $aPos = Null Then
Local $aTemp[2] = [0, 0]
$aPos = $aTemp
$aTemp = 0
$aPos[0] = 0
$aPos[1] = 0
EndIf
$iLength = _WinAPI_SizeOfResource($hInstance, $hResource)
Switch $iCastResType
Case $RT_ANICURSOR, $RT_CURSOR
$vResource = _WinAPI_LoadImage($hInstance, $sResNameOrID, $IMAGE_CURSOR, $aPos[1], $aPos[0], $LR_DEFAULTCOLOR)
If @error <> 0 Or Not $vResource Then $iError = 8
Case $RT_BITMAP
$vResource = _WinAPI_LoadImage($hInstance, $sResNameOrID, $IMAGE_BITMAP, $aPos[1], $aPos[0], $LR_DEFAULTCOLOR)
If @error <> 0 Or Not $vResource Then $iError = 7
Case $RT_ICON
$vResource = _WinAPI_LoadImage($hInstance, $sResNameOrID, $IMAGE_ICON, $aPos[1], $aPos[0], $LR_DEFAULTCOLOR)
If @error <> 0 Or Not $vResource Then $iError = 9
Case $RT_STRING
$vResource = _WinAPI_LoadString($hInstance, $sResNameOrID)
$iLength = @extended
If @error <> 0 Then $iError = 12
Case Else
Local $hData = _WinAPI_LoadResource($hInstance, $hResource)
$vResource = _WinAPI_LockResource($hData)
$hData = 0
If Not $vResource Then $iError = 6
EndSwitch
If $iError = 0 Then
__Resource_Storage(8, $sDllOrExePath, $vResource, $sResNameOrID, $iResType, $iResLang, $iCastResType, $iLength)
Else
$vResource = Null
EndIf
EndIf
__Resource_UnloadModule($hInstance, $bIsInternal)
Return SetError($iError, $iLength, $vResource)
EndFunc
Func __Resource_GetCtrlId(ByRef $hWnd, ByRef $iCtrlID)
If $iCtrlID = Default Or $iCtrlID <= 0 Or Not IsInt($iCtrlID) Then $iCtrlID = -1
$hWnd = GUICtrlGetHandle($iCtrlID)
If $hWnd And $iCtrlID = -1 Then
$iCtrlID = _WinAPI_GetDlgCtrlID($hWnd)
EndIf
Return True
EndFunc
Func __Resource_GetLastImage($iCtrlID, $hResource, $sClassName, ByRef $hPrevious, ByRef $iPreviousResType)
$hPrevious = 0
$iPreviousResType = 0
Local $aGetImage = 0, $bReturn = True, $iMsg_Get = 0
Switch $sClassName
Case 'Button'
Local $aButton = [[$IMAGE_BITMAP, $RT_BITMAP], [$IMAGE_ICON, $RT_ICON]]
$aGetImage = $aButton
$aButton = 0
$iMsg_Get = $BM_GETIMAGE
Case 'Static'
Local $aStatic = [[$IMAGE_BITMAP, $RT_BITMAP], [$IMAGE_CURSOR, $RT_CURSOR], [$IMAGE_ENHMETAFILE, 1001], [$IMAGE_ICON, $RT_ICON]]
$aGetImage = $aStatic
$aStatic = 0
$iMsg_Get = 0x0173
Case Else
$bReturn = False
EndSwitch
If $bReturn Then
For $i = 0 To UBound($aGetImage) - 1
$hPrevious = GUICtrlSendMsg($iCtrlID, $iMsg_Get, $aGetImage[$i][0], 0)
If $hPrevious <> 0 And $hPrevious <> $hResource Then
$iPreviousResType = $aGetImage[$i][1]
ExitLoop
EndIf
Next
EndIf
Return $bReturn
EndFunc
Func __Resource_LoadModule(ByRef $sDllOrExePath, ByRef $bIsInternal)
$bIsInternal = ($sDllOrExePath = Default Or $sDllOrExePath = -1)
If Not $bIsInternal And Not StringRegExp($sDllOrExePath, '\.(?:cpl|dll|exe)$') Then
$bIsInternal = True
EndIf
Return ($bIsInternal ? _WinAPI_GetModuleHandle(Null) : _WinAPI_LoadLibraryEx($sDllOrExePath, $LOAD_LIBRARY_AS_DATAFILE))
EndFunc
Func __Resource_UnloadModule(ByRef $hInstance, ByRef $bIsInternal)
Local $bReturn = True
If $bIsInternal And $hInstance Then
$bReturn = _WinAPI_FreeLibrary($hInstance)
EndIf
Return $bReturn
EndFunc
Func __Resource_SetToCtrlID($iCtrlID, $hResource, $iResType, $bDestroy, $bResize)
Local $bReturn = False, $iError = 13
Local $hWnd = 0
__Resource_GetCtrlId($hWnd, $iCtrlID)
$iError = 2
If $hWnd And $iCtrlID > 0 Then
Local $aStyles[0]
$bReturn = True
$iError = 0
Local $iMsg_Set = 0, $iStyle = 0, $wParam = 0
Local $sClassName = _WinAPI_GetClassName($iCtrlID)
Switch $sClassName
Case 'Button'
Local $aButtonStyles = [$BS_BITMAP, $BS_ICON]
$aStyles = $aButtonStyles
$aButtonStyles = 0
$iMsg_Set = $BM_SETIMAGE
Switch $iResType
Case $RT_BITMAP
$iStyle = $BS_BITMAP
$wParam = $IMAGE_BITMAP
$bResize = False
Case $RT_ICON
$iStyle = $BS_ICON
$wParam = $IMAGE_ICON
$bResize = False
Case Else
$bReturn = False
$iError = 5
EndSwitch
Case 'Static'
Local $aStaticStyles = [$SS_BITMAP, $SS_ICON, 0xF]
$aStyles = $aStaticStyles
$aStaticStyles = 0
$iMsg_Set = 0x0172
Switch $iResType
Case $RT_BITMAP
$iStyle = $SS_BITMAP
$wParam = $IMAGE_BITMAP
Case $RT_CURSOR
$iStyle = $SS_ICON
$wParam = $IMAGE_CURSOR
Case 1001
$iStyle = 0xF
$wParam = $IMAGE_ENHMETAFILE
Case $RT_ICON
$iStyle = $SS_ICON
$wParam = $IMAGE_ICON
Case Else
$bReturn = False
$iError = 5
EndSwitch
Case Else
$bReturn = False
$iError = 3
EndSwitch
If $bReturn Then
Local $iCurrentStyle = _WinAPI_GetWindowLong($hWnd, $GWL_STYLE)
If Not @error Then
For $i = 0 To UBound($aStyles) - 1
If BitAND($aStyles[$i], $iCurrentStyle) Then
$iCurrentStyle = BitXOR($iCurrentStyle, $aStyles[$i])
EndIf
Next
If $bResize Then
_WinAPI_SetWindowLong($hWnd, $GWL_STYLE, BitOR($iCurrentStyle, 0x40, $iStyle))
Else
_WinAPI_SetWindowLong($hWnd, $GWL_STYLE, BitOR($iCurrentStyle, $iStyle))
EndIf
EndIf
Local $hPrevious = 0, $iPreviousResType = 0
__Resource_GetLastImage($iCtrlID, $hResource, $sClassName, $hPrevious, $iPreviousResType)
GUICtrlSendMsg($iCtrlID, $iMsg_Set, $wParam, $hResource)
If $iPreviousResType Then
__Resource_Destroy($hPrevious, $iPreviousResType)
__Resource_Storage(9, Null, $hPrevious, Null, Null, Null, Null, Null)
If $bDestroy = Default Or $bDestroy Then
__Resource_Destroy($hResource, $iResType)
__Resource_Storage(9, Null, $hResource, Null, Null, Null, Null, Null)
EndIf
_WinAPI_InvalidateRect($hWnd, 0, True)
_WinAPI_UpdateWindow($hWnd)
Else
$bReturn = False
$iError = 13
EndIf
EndIf
EndIf
Return SetError($iError, 0, $bReturn)
EndFunc
Func __Resource_Storage($iAction, $sDllOrExePath, $pResource, $sResNameOrID, $iResType, $iResLang, $iCastResType, $iLength)
Local Static $aStorage[1][7]
Local $bReturn = False
Switch $iAction
Case 8
If Not ($aStorage[0][0] = 'CA37F1E6-04D1-11E4-B340-4B0AE3E253B6') Then
$aStorage[0][0] = 'CA37F1E6-04D1-11E4-B340-4B0AE3E253B6'
$aStorage[0][1] = 0
$aStorage[0][2] = 0
$aStorage[0][3] = 1
EndIf
If Not ($pResource = Null) And Not __Resource_Storage(11, $sDllOrExePath, Null, $sResNameOrID, $iResType, $iResLang, $iCastResType, Null) Then
$bReturn = True
$aStorage[0][1] += 1
If $aStorage[0][1] >= $aStorage[0][3] Then
$aStorage[0][3] = Ceiling($aStorage[0][1] * 1.3)
ReDim $aStorage[$aStorage[0][3]][7]
EndIf
$aStorage[$aStorage[0][1]][0] = $sDllOrExePath
$aStorage[$aStorage[0][1]][3] = $pResource
$aStorage[$aStorage[0][1]][4] = $iResLang
$aStorage[$aStorage[0][1]][5] = $sResNameOrID
$aStorage[$aStorage[0][1]][6] = $iResType
$aStorage[$aStorage[0][1]][1] = $iCastResType
$aStorage[$aStorage[0][1]][2] = $iLength
EndIf
Case 9
Local $iDestoryCount = 0, $iDestoryed = 0
For $i = 1 To $aStorage[0][1]
If Not ($aStorage[$i][3] = Null) Then
If $aStorage[$i][3] = $pResource Or ($aStorage[$i][0] = $sDllOrExePath And $aStorage[$i][5] = $sResNameOrID And $aStorage[$i][6] = $iResType And $aStorage[$i][1] = $iCastResType) Then
$bReturn = __Resource_Storage_Destroy($aStorage, $i)
If $bReturn Then
$iDestoryed += 1
$aStorage[0][2] += 1
EndIf
$iDestoryCount += 1
EndIf
EndIf
Next
$bReturn = $iDestoryCount = $iDestoryed
If $aStorage[0][2] >= 20 Then
Local $iIndex = 0
For $i = 1 To $aStorage[0][1]
If Not ($aStorage[$i][3] = Null) Then
$iIndex += 1
For $j = 0 To 7 - 1
$aStorage[$iIndex][$j] = $aStorage[$i][$j]
Next
EndIf
Next
$aStorage[0][1] = $iIndex
$aStorage[0][2] = 0
$aStorage[0][3] = $iIndex + 1
ReDim $aStorage[$aStorage[0][3]][7]
EndIf
Case 10
$bReturn = True
For $i = 1 To $aStorage[0][1]
__Resource_Storage_Destroy($aStorage, $i)
Next
$aStorage[0][1] = 0
$aStorage[0][2] = 0
$aStorage[0][3] = 1
ReDim $aStorage[$aStorage[0][3]][7]
Case 11
Local $iExtended = 0, $pReturn = Null
Return SetExtended($iExtended, $pReturn)
EndSwitch
Return $bReturn
EndFunc
Func __Resource_Storage_Destroy(ByRef $aStorage, $iIndex)
Local $bReturn = False
If Not ($aStorage[$iIndex][3] = Null) Then
$bReturn = __Resource_Destroy($aStorage[$iIndex][3], $aStorage[$iIndex][6])
If $bReturn Then
$aStorage[$iIndex][3] = Null
$aStorage[$iIndex][4] = Null
$aStorage[$iIndex][5] = Null
$aStorage[$iIndex][6] = Null
EndIf
EndIf
Return $bReturn
EndFunc