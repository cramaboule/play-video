#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=AutoItv11.ico
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <WinAPI.au3>
#Include <Array.au3>

;~ $FileToOpen="C:\Documents C\DEP2011-Maroc\Maroc-FR.wmv"
Global $__MonitorList[1][5] , $MonL[5], $MonT[5], $FileToOpen

_SearchPath()

GUICreate("Play vidéo", 300, 130)
$ButtonO = GUICtrlCreateButton("Ouvrir vidéo", 5, 5, 135, 25)
$ButtonP = GUICtrlCreateButton("Play vidéo", 155, 5, 135, 25)
$Label = GUICtrlCreateLabel("", 5, 95, 290, 35)
$Group1 = GUICtrlCreateGroup("Quel écran ?", 5, 35, 285, 50)
$Radio1 = GUICtrlCreateRadio("Ecran Prinipal", 15, 60, 115, 20)

#region Detect Monitor
$Monitor = _GetMonitors()
If $Monitor[0][0] = 2 Then
	If ($Monitor[1][1] = 0) And ($Monitor[1][2] = 0) Then; According to Microsoft, the Main Monitor has the coordinates 0,0, ..., ...
		$MonL[2] = $Monitor[2][1] ; Monitor 1 Main - Monitor 2 Display
		$MonT[2] = $Monitor[2][2]
		$MonL[1] = $Monitor[1][1]
		$MonT[1] = $Monitor[1][2]
		$Mon = 1
	Else
		$MonL[2] = $Monitor[1][1] ; Monitor 2 Main - Monitor 1 Display
		$MonT[2] = $Monitor[1][2]
		$MonL[1] = $Monitor[2][1]
		$MonT[1] = $Monitor[2][2]
		$Mon = 2
	EndIf
Else
	$Mon = 1 ; Only 1 Monitor
EndIf
#endregion Detect Monitor
If  $Mon= 2 Then $Radio2 = GUICtrlCreateRadio("Ecran Secondaire", 160, 60, 115, 20)
GUICtrlSetState( -1, $GUI_CHECKED)

GUICtrlCreateGroup("", -99, -99, 1, 1)
GUISetState(@SW_SHOW)

While 1
$msg = GUIGetMsg()
	Select
		Case $msg = $GUI_EVENT_CLOSE
			Exit
		Case $msg = $ButtonO
			$Open=FileOpenDialog("Ouvrir vidéo", @WorkingDir, "All (*.*)", Default, "", GUICreate(""))
			If Not @error Then
				$FileToOpen = $Open
				GUICtrlSetData ( $Label, $FileToOpen)
			Else
				$Open=""
			EndIf
		Case $msg = $ButtonP
			If GUICtrlRead($Radio1) = $GUI_CHECKED Then
				$Display = 1
			Else
				$Display = 2
			EndIf
			If $FileToOpen <> "" Then
				ShellExecute(_SearchPath(), '"' & $FileToOpen & '" --video-x=' & $MonL[$Display] + 10 & ' --video-y=' & $MonT[$Display] + 10 & ' --no-embedded-video -f --video-on-top --play-and-exit')
			EndIf
    EndSelect
WEnd

Func _SearchPath()
	$PathExe = StringSplit(RegRead("HKEY_CLASSES_ROOT\Applications\vlc.exe\shell\Open\command",""),Chr(34))
	If $PathExe[0] < 2 Then
		MsgBox (0, "Erreur:", "vlc.exe n'est pas installé sur ce PC, Veuilliez (ré-)installer vlc: http://www.videolan.org/")
		Exit
	Else
		Return Chr(34)&$PathExe[2]&Chr(34)
	EndIf
EndFunc



;==================================================================================================
; Function Name:   _GetMonitors()
; Description::    Load monitor positions
; Parameter(s):    n/a
; Return Value(s): 2D Array of Monitors
;                       [0][0] = Number of Monitors
;                       [i][0] = HMONITOR handle of this monitor.
;                       [i][1] = Left Position of Monitor
;                       [i][2] = Top Position of Monitor
;                       [i][3] = Right Position of Monitor
;                       [i][4] = Bottom Position of Monitor
; Note:            [0][1..4] are set to Left,Top,Right,Bottom of entire screen
;                  hMonitor is returned in [i][0], but no longer used by these routines.
;                  Also sets $__MonitorList global variable (for other subs to use)
; Author(s):       xrxca (autoit@forums.xrx.ca)
;==================================================================================================

Func _GetMonitors()
	$__MonitorList[0][0] = 0 ;  Added so that the global array is reset if this is called multiple times
	Local $handle = DllCallbackRegister("_MonitorEnumProc", "int", "hwnd;hwnd;ptr;lparam")
	DllCall("user32.dll", "int", "EnumDisplayMonitors", "hwnd", 0, "ptr", 0, "ptr", DllCallbackGetPtr($handle), "lparam", 0)
	DllCallbackFree($handle)
	Local $i = 0
	For $i = 1 To $__MonitorList[0][0]
		If $__MonitorList[$i][1] < $__MonitorList[0][1] Then $__MonitorList[0][1] = $__MonitorList[$i][1]
		If $__MonitorList[$i][2] < $__MonitorList[0][2] Then $__MonitorList[0][2] = $__MonitorList[$i][2]
		If $__MonitorList[$i][3] > $__MonitorList[0][3] Then $__MonitorList[0][3] = $__MonitorList[$i][3]
		If $__MonitorList[$i][4] > $__MonitorList[0][4] Then $__MonitorList[0][4] = $__MonitorList[$i][4]
	Next
	Return $__MonitorList
EndFunc   ;==>_GetMonitors


;==================================================================================================
; Function Name:   _MonitorEnumProc($hMonitor, $hDC, $lRect, $lParam)
; Description::    Enum Callback Function for EnumDisplayMonitors in _GetMonitors
; Author(s):       xrxca (autoit@forums.xrx.ca)
;==================================================================================================

Func _MonitorEnumProc($hMonitor, $hDC, $lRect, $lParam)
	Local $Rect = DllStructCreate("int left;int top;int right;int bottom", $lRect)
	$__MonitorList[0][0] += 1
	ReDim $__MonitorList[$__MonitorList[0][0] + 1][5]
	$__MonitorList[$__MonitorList[0][0]][0] = $hMonitor
	$__MonitorList[$__MonitorList[0][0]][1] = DllStructGetData($Rect, "left")
	$__MonitorList[$__MonitorList[0][0]][2] = DllStructGetData($Rect, "top")
	$__MonitorList[$__MonitorList[0][0]][3] = DllStructGetData($Rect, "right")
	$__MonitorList[$__MonitorList[0][0]][4] = DllStructGetData($Rect, "bottom")
	Return 1 ; Return 1 to continue enumeration
EndFunc   ;==>_MonitorEnumProc
