#NoEnv
#SingleInstance ignore ; allow only one instance of this script to be running
SetWorkingDir %A_ScriptDir%

ScriptName := "CClose"
ScriptVersion := "1.3.7.0"
CopyrightNotice := "Copyright (c) 2018 Chaohe Shi"

IniDir := A_AppDataCommon . "\" . ScriptName
IniFile := IniDir . "\" . ScriptName . ".ini"

LangFile := "lang.ini"

; set script language
if (A_Language == "0804") ; https://autohotkey.com/docs/misc/Languages.htm
{
Language := "Chinese"
}
else ; use English by default
{
Language := "English"
}

; set script texts
IniRead, TEXT_Suspend, %LangFile%, %Language%, TEXT_Suspend, Suspend
IniRead, TEXT_Autostart, %LangFile%, %Language%, TEXT_Autostart, Autostart
IniRead, TEXT_Help, %LangFile%, %Language%, TEXT_Help, Help
IniRead, TEXT_About, %LangFile%, %Language%, TEXT_About, About
IniRead, TEXT_Exit, %LangFile%, %Language%, TEXT_Exit, Exit
IniRead, TEXT_Update, %LangFile%, %Language%, TEXT_Update, Update
IniRead, TEXT_Close, %LangFile%, %Language%, TEXT_Close, Close
IniRead, TEXT_Checking_For_Updates, %LangFile%, %Language%, TEXT_Checking_For_Updates, Checking for updates...
IniRead, TEXT_Updater_Not_Found, %LangFile%, %Language%, TEXT_Updater_Not_Found, Updater not found!
IniRead, TEXT_Always_On_Top, %LangFile%, %Language%, TEXT_Always_On_Top, Always on top
IniRead, TEXT_Not_Always_On_Top, %LangFile%, %Language%, TEXT_Not_Always_On_Top, Not always on top
IniRead, TEXT_HelpMsg1, %LangFile%, %Language%, TEXT_HelpMsg1, Middle click   	+ title bar     	= close window
IniRead, TEXT_HelpMsg2, %LangFile%, %Language%, TEXT_HelpMsg2, Right click    	+ title bar     	= minimize window
IniRead, TEXT_HelpMsg3, %LangFile%, %Language%, TEXT_HelpMsg3, Hold left click	+ title bar     	= toggle window always on top
IniRead, TEXT_HelpMsg4, %LangFile%, %Language%, TEXT_HelpMsg4, Double press   	+ Esc key       	= close active window
IniRead, TEXT_HelpMsg5, %LangFile%, %Language%, TEXT_HelpMsg5, Right click    	+ taskbar button	= move pointer to "Close window"
TEXT_HelpMsg := TEXT_HelpMsg1 . "`n" . TEXT_HelpMsg2 . "`n" . TEXT_HelpMsg3 . "`n" . TEXT_HelpMsg4 . "`n" . TEXT_HelpMsg5

; add tray menu
Menu, Tray, NoStandard ; remove the standard menu items
Menu, Tray, Add, %TEXT_Suspend%, SuspendProgram
Menu, Tray, Default, %TEXT_Suspend% ; set the default menu item
Menu, Tray, Add
Menu, Tray, Add, %TEXT_Autostart%, AutostartProgram
Menu, Tray, Add
Menu, Tray, Add, %TEXT_Help%, HelpMsg
Menu, Tray, Add, %TEXT_About%, AboutMsg
Menu, Tray, Add
Menu, Tray, Add, %TEXT_Exit%, ExitProgram
Menu, Tray, Tip, %ScriptName% ; change the tray icon's tooltip

; update the Autostart menu
RegRead, RegValue, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run, %ScriptName% ; retrieve the autostart status
if (RegValue == A_ScriptFullPath) ; if autostart is enabled
{
	Menu, Tray, Check, %TEXT_Autostart% ; check Autostart menu
	IsAutostart := true
}
else
{
	Menu, Tray, Uncheck, %TEXT_Autostart% ; uncheck Autostart menu
	IsAutostart := false
}

; retrieve the toggle autostart setting
IniRead, IsToggleAutostart, %IniFile%, Setting, ToggleAutostart, false
IsToggleAutostart := %IsToggleAutostart% ; store the keyword true/false, instead of the string "true/false"

; update the autostart status
if A_IsAdmin ; if run as administrator
{
	if IsToggleAutostart
	{
		if IsAutostart
		{
			RegDelete, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run, %ScriptName% ; disable autostart
			Menu, Tray, Uncheck, %TEXT_Autostart% ; uncheck Autostart menu
			IsAutostart := false
		}
		else
		{
			RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run, %ScriptName%, %A_ScriptFullPath% ; enable autostart
			Menu, Tray, Check, %TEXT_Autostart% ; check Autostart menu
			IsAutostart := true
		}
		IniWrite, false, %IniFile%, Setting, ToggleAutostart
	}
	; else do nothing
}

Return ; end of the auto-execute section

AutostartProgram:
if A_IsAdmin ; if run the script as administrator, update the menu and the registry
{
	if IsAutostart
	{
		Menu, Tray, Uncheck, %TEXT_Autostart%
		RegDelete, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run, %ScriptName% ; disable autostart
		IsAutostart := false
	}
	else
	{
		Menu, Tray, Check, %TEXT_Autostart%
		RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run, %ScriptName%, %A_ScriptFullPath% ; enable autostart
		IsAutostart := true
	}
}
else ; else update the setting file
{
	; ensure IniDir exists
	if !InStr(FileExist(IniDir), "D")
	{
		FileCreateDir, %IniDir%
	}
	IniWrite, true, %IniFile%, Setting, ToggleAutostart
}

; try restart and run the script as administrator
; https://autohotkey.com/docs/commands/Run.htm#RunAs
full_command_line := DllCall("GetCommandLine", "str")
if !(A_IsAdmin || RegExMatch(full_command_line, " /restart(?!\S)"))
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

; if run as administrator failed, rollback the toggle autostart setting
if !A_IsAdmin
{
	IniWrite, false, %IniFile%, Setting, ToggleAutostart
}
Return

SuspendProgram:
Menu, Tray, ToggleCheck, %TEXT_Suspend%
Suspend, Toggle
Return

HelpMsg:
MsgBox, 0, %TEXT_Help%, %TEXT_HelpMsg%
Return

AboutMsg:
OnMessage(0x44, "WM_COMMNOTIFY") ; https://autohotkey.com/board/topic/56272-msgbox-button-label-change/?p=353457
MsgBox, 257, %TEXT_About%,
(
%ScriptName% %ScriptVersion%

%CopyrightNotice%
)
IfMsgBox, OK
{
	if FileExist("Updater.exe")
	{
		TrayTip, %ScriptName%, %TEXT_Checking_For_Updates%
		Run %A_ScriptDir%\Updater.exe /A
		Sleep 1000
		WinWait, ahk_exe Updater.exe, , 20
		HideTrayTip() ; https://autohotkey.com/docs/commands/TrayTip.htm#Remarks
	}
	else
	{
		MsgBox, 48, %ScriptName%, %TEXT_Updater_Not_Found%
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
	global ; use assume-global mode to access global variables
	if (wParam == 1027) ; AHK_DIALOG
	{
		Process, Exist
		DetectHiddenWindows, On
		if WinExist(TEXT_About . " ahk_class #32770 ahk_pid " . ErrorLevel)
		{
			ControlSetText, Button1, &%TEXT_Update%
			ControlSetText, Button2, &%TEXT_Close%
		}
	}
}

HideTrayTip()
{
	TrayTip ; attempt to hide TrayTip in the normal way
	if (SubStr(A_OSVersion, 1, 3) == "10.") ; if Windows 10
	{
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
	Return, ErrorLevel == HTCAPTION
}

#If MouseIsOver("ahk_class Shell_TrayWnd") ; apply the following hotkey only when the mouse is over the taskbar
~RButton:: ; when right clicked
Sleep 500 ; wait for the Jump List to pop up, n.b., this line also helps to provide a uniform waiting experience
Loop 6
{
	if WinActive("ahk_class Windows.UI.Core.CoreWindow") ; if Jump List pops up (right clicked on taskbar app buttons)
	{
		WinGetPos, , , width, height ; get the size of the last found window (Jump List)
		MouseMove, (width / 2), (height - 3 * width / 32), 1 ; move mouse to the bottom of the Jump List ("Close window")
		break
	}
	Sleep 250 ; wait for more time
}
Return

; https://autohotkey.com/board/topic/82066-minimize-by-right-click-titlebar-close-by-middle-click/#entry521659
#If MouseIsOverTitlebar() ; apply the following hotkey only when the mouse is over title bars
RButton::WinMinimize
MButton::PostMessage, 0x112, 0xF060 ; alternative to WinClose, as WinClose is a somewhat forceful method, e.g., if multiple Microsoft Excel instances exist, WinClose will close them all at once. 0x112 = WM_SYSCOMMAND, 0xF060 = SC_CLOSE https://autohotkey.com/docs/commands/WinClose.htm#Remarks
~LButton::
CoordMode, Mouse, Screen
MouseGetPos, xOld, yOld
WinGet, ExStyle, ExStyle ; get extended window style
if (ExStyle & 0x8) ; 0x8 is WS_EX_TOPMOST
{
	ExStyle := TEXT_Not_Always_On_Top
}
else
{
	ExStyle := TEXT_Always_On_Top
}
KeyWait, LButton, T1 ; wait for the left mouse button to be released with timeout set to 1 second
MouseGetPos, xNew, yNew
if (xOld == xNew && yOld == yNew && ErrorLevel == 1) ; if mouse did not move during the timeout period
{
	Winset, Alwaysontop, Toggle, A ; toggle always on top
	ToolTip, %ExStyle%, , 0 ; display a tooltip with current topmost status
	SetTimer, RemoveToolTip, 1000 ; remove the tooltip after 1 second
}
Return

#If ; apply the following hotkey with no conditions
~Esc::
if (A_TimeSincePriorHotkey < 400) && (A_PriorHotkey = "~Esc") ; if double press Esc
{
	KeyWait, Esc ; wait for Esc to be released
	WinGetClass, class, A
	; n.b., leave no space in the MatchList below https://autohotkey.com/docs/commands/IfIn.htm
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
