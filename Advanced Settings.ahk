; if advanced settings GUI already exists, activate it and return
Gui, 1:+LastFoundExist
if WinExist()
{
	WinActivate
	Return
}

; retrieve the title bar exception list
IniRead, exceptionList, %ConfigFile%, Advanced, TitleBarExceptionList, %A_Space%

; create advanced settings GUI
Gui, 1:New, hwndhGui AlwaysOnTop
Gui, 1:Default

; settings tab
Gui, Add, Tab3, , %TEXT_TitleBarExceptionList%

; title bar exception list
Gui, Tab, 1

Gui, Add, Edit, Section w240 r4 ReadOnly -VScroll -Wrap vCtrl_Title
Gui, Add, Checkbox, w240 vCtrl_FollowMouse, %TEXT_FollowMouse%
Gui, Add, Text, w240 r1 vCtrl_Freeze, %TEXT_NotFrozen%
Gui, Add, Button, ys w75 h23 vAddItem gAddItem, %TEXT_Add%

GBW1 := GroupBoxForTab3("GB1", TEXT_WindowInfo, 10, 10, "Ctrl_Title|Ctrl_FollowMouse|Ctrl_Freeze|AddItem")

Gui, Add, ListBox, Section xs AltSubmit r5 w240 vCtrl_ListBox, %exceptionList%
Gui, Add, Button, ys w75 h23 vDeleteItem gDeleteItem, %TEXT_Delete%

GBW2 := GroupBoxForTab3("GB2", TEXT_ExceptionList, 10, 10, "Ctrl_ListBox|DeleteItem")

; create hotkeys for suspending updates
Hotkey, ~*Ctrl, StopUpdate, On
Hotkey, ~*Shift, StopUpdate, On
Hotkey, ~*Ctrl up, StartUpdate, On
Hotkey, ~*Shift up, StartUpdate, On
Gosub, Update ; make the first execution to be immediate https://www.autohotkey.com/docs/commands/SetTimer.htm#Remarks
SetTimer, Update, 250
Gui, Show, NoActivate, %TEXT_AdvancedSettings%
Return

; https://autohotkey.com/board/topic/71065-groupbox-addwrap-around-existing-controls/
GroupBoxForTab3(GBvName, Title, TitleH, Margin, Piped_CtrlvNames, FixedWidth := "", FixedHeight := "") {
	Local maxX := maxY := 0, minX := minY := 99999, xPos, yPos ; force some variables to start with a default value
	Loop, Parse, Piped_CtrlvNames, |, %A_Space% ; loop the list of Controls
	{
		GuiControlGet, GB, Pos, %A_LoopField% ; GuiControlGet will get the position relative to the tab
		GuiControl, Move, %A_LoopField%, % "x" GBX " y" GBY ; but GuiControl, Move will move controls to the position relative to the window
		GuiControlGet, GBtemp, Pos, %A_LoopField% ; get the temporary new position to calculate the offset
		GuiControl, Move, %A_LoopField%, % "x" GBX - (GBtempX - GBX) + Margin " y" GBY - (GBtempY - GBY) + TitleH + Margin ; make space for the GroupBox
		minX := GBX < minX ? GBX : minX, maxX := GBX + GBW > maxX ? GBX + GBW : maxX ; check for minimum, and maximum X
		minY := GBY < minY ? GBY : minY, maxY := GBY + GBH > maxY ? GBY + GBH : maxY ; check for minimum, and maximum Y
	}
	GBW := FixedWidth ? FixedWidth : Margin + maxX - minX + Margin ; calculate the width for GroupBox
	GBH := FixedHeight ? FixedHeight : Margin + TitleH + maxY - MinY + Margin ; calculate the height for GroupBox
	Gui, Add, GroupBox, v%GBvName% x%minX% y%minY% w%GBW% h%GBH%, %Title% ; add the GroupBox
	Return, GBW
}

AddItem:
if (exeItem == "") ; don't add empty item
{
	Return
}
else
{
	Loop, Parse, exceptionList, `|
	{
		if (exeItem == A_LoopField) ; if item already exists
		{
			GuiControl, Choose, Ctrl_ListBox, %A_Index% ; select the existed item instead
			Return
		}
	}
}
; add item
if (exceptionList == "")
{
	exceptionList .= exeItem
}
else
{
	exceptionList .= "|"
	exceptionList .= exeItem
}
Gosub, Save
GuiControl, , Ctrl_ListBox, %exeItem%|| ; add the item to the ListBox and select it
Return

DeleteItem:
Gui %hGui%:Submit, NoHide
newList := ""
Loop, Parse, exceptionList, `|
{
	if (A_Index == Ctrl_ListBox)
	{
		Continue
	}
	newList := newList . A_LoopField . "|"
	
}
newList := SubStr(newList, 1, -1) ; remove the trailing delimiter
exceptionList := newList
Gosub, Save
GuiControl, , Ctrl_ListBox, |%exceptionList% ; construct new ListBox
GuiControl, Choose, Ctrl_ListBox, %Ctrl_ListBox% ; select the item below the deleted one
Return

Save:
Gosub, EnsureConfigDirExists
IniWrite, %exceptionList%, %ConfigFile%, Advanced, TitleBarExceptionList ; update the exception list setting
TitleBarExceptionList := exceptionList
Return

GuiSize:
Gui %hGui%:Default
SetTimer, Update, % A_EventInfo == 1 ? "Off" : "On" ; suspend on minimize
Return

Update:
Gui %hGui%:Default
GuiControlGet, Ctrl_FollowMouse
CoordMode, Mouse, Screen
MouseGetPos, msX, msY, msWin, msCtrl
actWin := WinExist("A")
if Ctrl_FollowMouse
{
	curWin := msWin
	curCtrl := msCtrl
	WinExist("ahk_id " curWin)
}
else
{
	curWin := actWin
	ControlGetFocus, curCtrl
}
WinGetTitle, t1
WinGetClass, t2
if (curWin == hGui || t2 == "MultitaskingViewFrame") ; our Gui || Alt-tab
{
	UpdateText("Ctrl_Freeze", TEXT_Frozen)
	Return
}
UpdateText("Ctrl_Freeze", TEXT_NotFrozen)
WinGet, t3, ProcessName
WinGet, t4, PID
;classItem := t2
exeItem := t3
UpdateText("Ctrl_Title", "Title " t1 "`nClass " t2 "`nEXE " t3 "`nPID " t4)
CoordMode, Mouse, Relative
CoordMode, Mouse, Client
Return

GuiClose:
Hotkey, ~*Ctrl, Off
Hotkey, ~*Shift, Off
Hotkey, ~*Ctrl up, Off
Hotkey, ~*Shift up, Off
SetTimer, Update, Off
Gui %hGui%:Destroy
Return

WinGetTextFast(detect_hidden)
{
	; WinGetText ALWAYS uses the "fast" mode - TitleMatchMode only affects
	; WinText/ExcludeText parameters.  In Slow mode, GetWindowText() is used
	; to retrieve the text of each control.
	WinGet controls, ControlListHwnd
	static WINDOW_TEXT_SIZE := 32767 ; Defined in AutoHotkey source.
	VarSetCapacity(buf, WINDOW_TEXT_SIZE * (A_IsUnicode ? 2 : 1))
	text := ""
	Loop Parse, controls, `n
	{
		if !detect_hidden && !DllCall("IsWindowVisible", "ptr", A_LoopField)
			continue
		if !DllCall("GetWindowText", "ptr", A_LoopField, "str", buf, "int", WINDOW_TEXT_SIZE)
			continue
		text .= buf "`r`n"
	}
	Return text
}

UpdateText(ControlID, NewText)
{
	; unlike using a pure GuiControl, this function causes the text of the
	; controls to be updated only when the text has changed, preventing periodic
	; flickering (especially on older systems).
	static OldText := {}
	global hGui
	if (OldText[ControlID] != NewText)
	{
		GuiControl, %hGui%:, % ControlID, % NewText
		OldText[ControlID] := NewText
	}
}

StopUpdate:
;Gui 1:+LastFoundExist
;if !WinExist()
;{
;	Return
;}
SetTimer, Update, Off
UpdateText("Ctrl_Freeze", TEXT_Frozen)
Return

StartUpdate:
;Gui 1:+LastFoundExist
;if !WinExist()
;{
;	Return
;}
SetTimer, Update, On
Return

