#SingleInstance ignore ; allow only one instance of this script to be running

; add tray menu
Menu, Tray, Icon, , , 1
Menu, Tray, NoStandard
Menu, Tray, Add, Autostart, AutostartProgram
Menu, Tray, Add, Suspend, SuspendProgram
Menu, Tray, Add
Menu, Tray, Add, Help, HelpMsg
Menu, Tray, Add, Exit, ExitProgram

; add shortcut to Startup folder
SplitPath, A_Scriptname, , , , OutNameNoExt
LinkFile := A_Startup . "\" . OutNameNoExt . ".lnk"
if A_IsAdmin
{
	FileCreateShortcut, %A_ScriptFullPath%, %LinkFile%
}

; check Autostart menu if shortcut exists in Startup folder
IsAutostart := FileExist(LinkFile)
if IsAutostart
{
	Menu, Tray, Check, Autostart
}

Return ; end of auto-execute section

AutostartProgram:
if IsAutostart
{
	Menu, Tray, Uncheck, Autostart ; uncheck Autostart menu
	FileDelete, %LinkFile% ; delete shortcut
	IsAutostart := false
}
else
{
	; restart and try run as administrator
	full_command_line := DllCall("GetCommandLine", "str")
	if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
	{
		MsgBox, Close It will need your premission to create a shortcut in the Windows Startup folder.
		try
		{
			if A_IsCompiled
			{
				Run *RunAs "%A_ScriptFullPath%" /restart
			}
			else
			{
				Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
			}
			ExitApp
		}
	}
	else
	{
		if A_IsAdmin
		{
			FileCreateShortcut, %A_ScriptFullPath%, %LinkFile%
			Menu, Tray, Check, Autostart
			IsAutostart := true
		}
	}
}
Return

SuspendProgram:
Menu, Tray, ToggleCheck, Suspend
Suspend, Toggle
Return

HelpMsg:
MsgBox,
(

Middle click 	+ title bar 	= close window.
Right click 	+ title bar 	= minize window.
Left click and hold + title bar 	= toggle window always on top.
Right click 	+ taskbar button 	= pointer moves to "Close window".
)

ExitProgram:
ExitApp

RemoveToolTip:
SetTimer, RemoveToolTip, Off
ToolTip
Return

MouseIsOver(WinTitle)
{
	MouseGetPos, , , win
	Return, WinExist(WinTitle . " ahk_id " . win)
}

MouseIsOverTitlebar()
{
	static WM_NCHITTEST := 0x84, HTCAPTION := 2
	CoordMode, Mouse, Screen
	MouseGetPos, x, y, win
	if WinExist("ahk_class Shell_TrayWnd ahk_id " win) ; exclude the taskbar
	{
		Return, false
	}
	SendMessage, WM_NCHITTEST, , x | (y << 16), , ahk_id %win%
	WinExist("ahk_id " win) ; set Last Found Window for convenience
	Return, ErrorLevel = HTCAPTION
}

#If MouseIsOver("ahk_class Shell_TrayWnd") ; apply the following hotkey only when the mouse is over the taskbar
~RButton:: ; when right clicked
Sleep 500 ; wait for the Jump List to pop up (if clicked on apps)
if WinActive("ahk_class Windows.UI.Core.CoreWindow") ; if Jump List pops up
{
	WinGetPos, , , width, height, A ; get active window (Jump List) position
	MouseMove, (width - 128), (height - 24), 1 ; move mouse to the bottom of the Jump List (Close window)
}
Return

; https://autohotkey.com/board/topic/82066-minimize-by-right-click-titlebar-close-by-middle-click/#entry521659
#If MouseIsOverTitlebar() ; apply the following hotkey only when the mouse is over title bars
RButton::WinMinimize
MButton::
if MouseIsOver("ahk_class Chrome_WidgetWin_1") or MouseIsOver("ahk_class MozillaWindowClass") ; if on Chrome and Firefox
{
	Return ; disable middle click to close windows
}
else
{
	WinClose
}
Return
~LButton::
CoordMode, Mouse, Screen
MouseGetPos, xOld, yOld
WinGet, ExStyle, ExStyle ; get extended window style
if (ExStyle & 0x8) ; 0x8 is WS_EX_TOPMOST
{
	ExStyle = Not always on top
}
else
{
	ExStyle = Always on top
}
KeyWait, LButton, T1 ; wait for left mouse button to release with timeout set to 1 second
MouseGetPos, xNew, yNew
if % (xOld == xNew) && (yOld == yNew) && ErrorLevel ; if mouse did not move and long clicked
{
	Winset, Alwaysontop, Toggle, A ; toggle always on top
	ToolTip, %ExStyle%, 7, -25 ; display a tooltip with current topmost status
	SetTimer, RemoveToolTip, 1000 ; remove the tooltip after 1 second
}
Return

#If ; apply the following hotkey with no conditions
~Esc::
if (A_TimeSincePriorHotkey < 400) and (A_PriorHotkey = "~Esc") ; if double press Esc
{
	KeyWait, Esc ; wait for Esc to be released
	WinGetClass, class, A
	if class in Shell_TrayWnd,Progman,WorkerW
	{
		Return ; do nothing if the active window is taskbar or desktop
	}
	WinClose, A ; close active window
}
Return
