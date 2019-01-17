#NoEnv
#SingleInstance ignore ; allow only one instance of this script to be running
SetWorkingDir %A_ScriptDir%

ScriptName := "CClose"
ScriptVersion := "1.3.6.0"
CopyrightNotice := "Copyright (c) 2018 Chaohe Shi"

; add tray menu
Menu, Tray, NoStandard ; remove the standard menu items
Menu, Tray, Add, Suspend, SuspendProgram
Menu, Tray, Default, Suspend ; set the default menu item
Menu, Tray, Add
Menu, Tray, Add, Autostart, AutostartProgram
Menu, Tray, Add
Menu, Tray, Add, Help, HelpMsg
Menu, Tray, Add, About, AboutMsg
Menu, Tray, Add
Menu, Tray, Add, Exit, ExitProgram
Menu, Tray, Tip, %ScriptName% ; change the tray icon's tooltip

IniDir := A_AppDataCommon . "\" . ScriptName
IniFile := IniDir . "\" . ScriptName . ".ini"
IniRead, IsAutostart, %IniFile%, setting, autostart ; retrieve autostart setting, the result can be on of the following: true/false/ERROR
IsAutostart := %IsAutostart% ; ensure the keyword true/false is saved, instead of the string "true/false"

if A_IsAdmin ; if run as administrator
{
	if (IsAutostart = true)
	{
		RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run, %ScriptName%, %A_ScriptFullPath% ; enable autostart
	}
	else if (IsAutostart = false)
	{
		RegDelete, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run, %ScriptName% ; disable autostart
	}
	; else in case of ERROR, do nothing
}

; update Autostart menu
RegRead, RegValue, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run, %ScriptName% ; retrieve autostart status
if (RegValue=A_ScriptFullPath) ; if autostart is enabled
{
	Menu, Tray, Check, Autostart ; check Autostart menu
	IsAutostart := true
}
else
{
	Menu, Tray, Uncheck, Autostart ; uncheck Autostart menu
	IsAutostart := false
}

; ensure IniDir exists
if !InStr(FileExist(IniDir), "D")
{
	FileCreateDir, %IniDir%
}

; update autostart setting
if IsAutostart
{
	IniWrite, true, %IniFile%, setting, autostart
}
else
{
	IniWrite, false, %IniFile%, setting, autostart
}

Return ; end of the auto-execute section

AutostartProgram:
if A_IsAdmin ; if run the script as administrator, then update menu, setting file, and registry
{
	if IsAutostart
	{
		Menu, Tray, Uncheck, Autostart
		IniWrite, false, %IniFile%, setting, autostart
		RegDelete, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run, %ScriptName% ; disable autostart
		IsAutostart := false
	}
	else
	{
		Menu, Tray, Check, Autostart
		IniWrite, true, %IniFile%, setting, autostart
		RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run, %ScriptName%, %A_ScriptFullPath% ; enable autostart
		IsAutostart := true
	}
}
else ; else update setting file only
{
	if IsAutostart
	{
		IniWrite, false, %IniFile%, setting, autostart
	}
	else
	{
		IniWrite, true, %IniFile%, setting, autostart
	}
}

; try restart and run the script as administrator
; https://autohotkey.com/docs/commands/Run.htm#RunAs
full_command_line := DllCall("GetCommandLine", "str")
if !(A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
{
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

; if run as administrator failed, rollback the autostart setting
if !A_IsAdmin
{
	if IsAutostart
	{
		IniWrite, true, %IniFile%, setting, autostart
	}
	else
	{
		IniWrite, false, %IniFile%, setting, autostart
	}
}
Return

SuspendProgram:
Menu, Tray, ToggleCheck, Suspend
Suspend, Toggle
Return

HelpMsg:
MsgBox, 0, Help,
(
Middle click   	+ title bar     	= close window
Right click    	+ title bar     	= minimize window
Hold left click	+ title bar     	= toggle window always on top
Double press   	+ Esc key       	= close active window
Right click    	+ taskbar button	= move pointer to "Close window"
)
Return

AboutMsg:
OnMessage(0x44, "WM_COMMNOTIFY") ; https://autohotkey.com/board/topic/56272-msgbox-button-label-change/?p=353457
MsgBox, 257, About,
(
%ScriptName% %ScriptVersion%

%CopyrightNotice%
)
IfMsgBox, OK
{
	if FileExist("Updater.exe")
	{
		TrayTip, %ScriptName%, Checking for updates...
		Run %A_ScriptDir%\Updater.exe /A
		Sleep 1000
		WinWait, ahk_exe Updater.exe, , 20
		HideTrayTip() ; https://autohotkey.com/docs/commands/TrayTip.htm#Remarks
	}
	else
	{
		MsgBox, 48, %ScriptName%, Updater not found!
	}
}
Return

ExitProgram:
ExitApp

RemoveToolTip:
SetTimer, RemoveToolTip, Off
ToolTip
Return

WM_COMMNOTIFY(wParam)
{
	if (wParam = 1027) ; AHK_DIALOG
	{
		Process, Exist
		DetectHiddenWindows, On
		if WinExist("About ahk_class #32770 ahk_pid " . ErrorLevel)
		{
			ControlSetText, Button1, &Update
			ControlSetText, Button2, &Close
		}
	}
}

HideTrayTip()
{
	TrayTip ; attempt to hide TrayTip in the normal way
	if SubStr(A_OSVersion, 1, 3) = "10." { ; if Windows 10
		; temporarily removing the tray icon to hide the TrayTip
		Menu Tray, NoIcon
		Sleep 100
		Menu Tray, Icon
	}
}

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
	if WinExist("ahk_class Shell_TrayWnd ahk_id " win) ; exclude taskbar
	{
		Return
	}
	SendMessage, WM_NCHITTEST, , x | (y << 16), , ahk_id %win%
	WinExist("ahk_id " win) ; set Last Found Window for convenience
	Return, ErrorLevel = HTCAPTION
}

#If MouseIsOver("ahk_class Shell_TrayWnd") ; apply the following hotkey only when the mouse is over the taskbar
~RButton:: ; when right clicked
Sleep 500 ; wait for the Jump List to pop up
if WinActive("ahk_class Windows.UI.Core.CoreWindow") ; if Jump List pops up (right clicked on taskbar app buttons)
{
	WinGetPos, , , width, height ; get the size of the last found window (Jump List)
	MouseMove, (width - 128), (height - 24), 1 ; move mouse to the bottom of the Jump List ("Close window")
}
else ; wait for more time
{
	Sleep 250
	if WinActive("ahk_class Windows.UI.Core.CoreWindow")
	{
		WinGetPos, , , width, height
		MouseMove, (width - 128), (height - 24), 1
	}
	else ; wait for more time
	{
		Sleep 250
		if WinActive("ahk_class Windows.UI.Core.CoreWindow")
		{
			WinGetPos, , , width, height
			MouseMove, (width - 128), (height - 24), 1
		}
		else ; wait for more time
		{
			Sleep 500
			if WinActive("ahk_class Windows.UI.Core.CoreWindow")
			{
				WinGetPos, , , width, height
				MouseMove, (width - 128), (height - 24), 1
			}
			else ; wait for more time
			{
				Sleep 500
				if WinActive("ahk_class Windows.UI.Core.CoreWindow")
				{
					WinGetPos, , , width, height
					MouseMove, (width - 128), (height - 24), 1
				}
			}
		}
	}
}
Return

; https://autohotkey.com/board/topic/82066-minimize-by-right-click-titlebar-close-by-middle-click/#entry521659
#If MouseIsOverTitlebar() ; apply the following hotkey only when the mouse is over title bars
RButton::WinMinimize
MButton::PostMessage, 0x112, 0xF060 ; alternative to WinClose, as WinClose is problematic when dealing with multiple Microsoft Excel instances. 0x112 = WM_SYSCOMMAND, 0xF060 = SC_CLOSE https://autohotkey.com/docs/commands/WinClose.htm#Remarks
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
if % (xOld == xNew) && (yOld == yNew) && ErrorLevel ; if mouse did not move
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
	else
	{
		PostMessage, 0x112, 0xF060, , , A ; close active window
	}
}
Return
