#NoEnv
#SingleInstance ignore ; allow only one instance of this script to be running
SetWorkingDir %A_ScriptDir%

ScriptName := "CClose"
ScriptVersion := "1.3.8.0"
CopyrightNotice := "Copyright (c) 2018 Chaohe Shi"

ConfigDir := A_AppData . "\" . ScriptName
ConfigFile := ConfigDir . "\" . ScriptName . ".ini"

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
IniRead, TEXT_Settings, %LangFile%, %Language%, TEXT_Settings, Settings
IniRead, TEXT_Help, %LangFile%, %Language%, TEXT_Help, Help
IniRead, TEXT_About, %LangFile%, %Language%, TEXT_About, About
IniRead, TEXT_Exit, %LangFile%, %Language%, TEXT_Exit, Exit
IniRead, TEXT_Update, %LangFile%, %Language%, TEXT_Update, Update
IniRead, TEXT_Close, %LangFile%, %Language%, TEXT_Close, Close
IniRead, TEXT_Checking_For_Updates, %LangFile%, %Language%, TEXT_Checking_For_Updates, Checking for updates...
IniRead, TEXT_Updater_Not_Found, %LangFile%, %Language%, TEXT_Updater_Not_Found, Updater not found!
IniRead, TEXT_Always_On_Top, %LangFile%, %Language%, TEXT_Always_On_Top, Always on top
IniRead, TEXT_Not_Always_On_Top, %LangFile%, %Language%, TEXT_Not_Always_On_Top, Not always on top
IniRead, TEXT_MenuAutostart, %LangFile%, %Language%, TEXT_MenuAutostart, Run %ScriptName% on system startup
IniRead, TEXT_MenuTitleBarMiddleClick, %LangFile%, %Language%, TEXT_MenuTitleBarMiddleClick, Middle click on title bar to close window
IniRead, TEXT_MenuTitleBarRightClick, %LangFile%, %Language%, TEXT_MenuTitleBarRightClick, Right click on title bar to minimize window
IniRead, TEXT_MenuTitleBarHoldLeftClick, %LangFile%, %Language%, TEXT_MenuTitleBarHoldLeftClick, Hold left click on title bar to toggle window always on top
IniRead, TEXT_MenuEscKeyDoublePress, %LangFile%, %Language%, TEXT_MenuEscKeyDoublePress, Double press Esc key to close active window
IniRead, TEXT_MenuTaskbarButtonRightClick, %LangFile%, %Language%, TEXT_MenuTaskbarButtonRightClick, Right click on taskbar button to move pointer to "Close window"
IniRead, TEXT_HelpMsg1, %LangFile%, %Language%, TEXT_HelpMsg1, Middle click   	+ title bar     	= close window
IniRead, TEXT_HelpMsg2, %LangFile%, %Language%, TEXT_HelpMsg2, Right click    	+ title bar     	= minimize window
IniRead, TEXT_HelpMsg3, %LangFile%, %Language%, TEXT_HelpMsg3, Hold left click	+ title bar     	= toggle window always on top
IniRead, TEXT_HelpMsg4, %LangFile%, %Language%, TEXT_HelpMsg4, Double press   	+ Esc key       	= close active window
IniRead, TEXT_HelpMsg5, %LangFile%, %Language%, TEXT_HelpMsg5, Right click    	+ taskbar button	= move pointer to "Close window"
TEXT_HelpMsg := TEXT_HelpMsg1 . "`n" . TEXT_HelpMsg2 . "`n" . TEXT_HelpMsg3 . "`n" . TEXT_HelpMsg4 . "`n" . TEXT_HelpMsg5
TEXT_AboutMsg := ScriptName . " " . ScriptVersion . "`n`n" . CopyrightNotice

; add tray menu
Menu, Tray, NoStandard ; remove the standard menu items
Menu, Tray, Add, %TEXT_Suspend%, SuspendProgram
Menu, Tray, Default, %TEXT_Suspend% ; set the default menu item
Menu, Tray, Add
Menu, SettingMenu, Add, %TEXT_MenuAutostart%, AutostartProgram
Menu, SettingMenu, Add
Menu, SettingMenu, Add, %TEXT_MenuTitleBarMiddleClick%, ConfigSetting
Menu, SettingMenu, Add, %TEXT_MenuTitleBarRightClick%, ConfigSetting
Menu, SettingMenu, Add, %TEXT_MenuTitleBarHoldLeftClick%, ConfigSetting
Menu, SettingMenu, Add, %TEXT_MenuEscKeyDoublePress%, ConfigSetting
Menu, SettingMenu, Add, %TEXT_MenuTaskbarButtonRightClick%, ConfigSetting
Menu, Tray, Add, %TEXT_Settings%, :SettingMenu
Menu, Tray, Add
Menu, Tray, Add, %TEXT_Help%, ShowHelpMsg
Menu, Tray, Add, %TEXT_About%, ShowAboutMsg
Menu, Tray, Add
Menu, Tray, Add, %TEXT_Exit%, ExitProgram
Menu, Tray, Tip, %ScriptName% ; change the tray icon's tooltip

; store hotkeys and their corresponding menu items in an associative array
Hotkey1 := {KeyName: "MButton"
		  , KeyScope: "MouseIsOverTitlebar()"
		  , KeySettingName: "EnableTitleBarMiddleClick"
		  , KeySettingValue: EnableTitleBarMiddleClick := 1
		  , MenuItemName: TEXT_MenuTitleBarMiddleClick}
Hotkey2 := {KeyName: "RButton"
		  , KeyScope: "MouseIsOverTitlebar()"
		  , KeySettingName: "EnableTitleBarRightClick"
		  , KeySettingValue: EnableTitleBarRightClick := 1
		  , MenuItemName: TEXT_MenuTitleBarRightClick}
Hotkey3 := {KeyName: "~LButton"
		  , KeyScope: "MouseIsOverTitlebar()"
		  , KeySettingName: "EnableTitleBarHoldLeftClick"
		  , KeySettingValue: EnableTitleBarHoldLeftClick := 1
		  , MenuItemName: TEXT_MenuTitleBarHoldLeftClick}
Hotkey4 := {KeyName: "~Esc"
		  , KeyScope: "true"
		  , KeySettingName: "EnableEscKeyDoublePress"
		  , KeySettingValue: EnableEscKeyDoublePress := 1
		  , MenuItemName: TEXT_MenuEscKeyDoublePress}
Hotkey5 := {KeyName: "~RButton"
		  , KeyScope: "MouseIsOver(""ahk_class Shell_TrayWnd"")"
		  , KeySettingName: "EnableTaskbarButtonRightClick"
		  , KeySettingValue: EnableTaskbarButtonRightClick := 1
		  , MenuItemName: TEXT_MenuTaskbarButtonRightClick}
Hotkeys := [Hotkey1, Hotkey2, Hotkey3, Hotkey4, Hotkey5]

; retrieve general settings
for index, element in Hotkeys
{
	IniRead, KeySettingValue, %ConfigFile%, General, % element.KeySettingName, 1
	element.KeySettingValue := KeySettingValue
}

; apply general settings
for index, element in Hotkeys
{
	if (!element.KeySettingValue)
	{
		Hotkey, If, % element.KeyScope
		Hotkey, % element.KeyName, Off
	}
	else
	{
		Menu, SettingMenu, Check, % element.MenuItemName
	}
}

; update the Autostart menu
RegRead, RegValue, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run, %ScriptName% ; retrieve the autostart status
if (RegValue == A_ScriptFullPath) ; if autostart is enabled
{
	Menu, SettingMenu, Check, %TEXT_MenuAutostart% ; check Autostart menu
	IsAutostart := true
}
else
{
	Menu, SettingMenu, Uncheck, %TEXT_MenuAutostart% ; uncheck Autostart menu
	IsAutostart := false
}

; retrieve the toggle autostart setting
IniRead, IsToggleAutostart, %ConfigFile%, Autostart, ToggleAutostart, 0

; apply the toggle autostart setting
if A_IsAdmin ; if run as administrator
{
	if IsToggleAutostart
	{
		if IsAutostart
		{
			RegDelete, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run, %ScriptName% ; disable autostart
			Menu, SettingMenu, Uncheck, %TEXT_MenuAutostart% ; uncheck Autostart menu
			IsAutostart := false
		}
		else
		{
			RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run, %ScriptName%, %A_ScriptFullPath% ; enable autostart
			Menu, SettingMenu, Check, %TEXT_MenuAutostart% ; check Autostart menu
			IsAutostart := true
		}
		IniWrite, 0, %ConfigFile%, Autostart, ToggleAutostart
	}
	; else do nothing
}

Return ; end of the auto-execute section

; config and apply the settings
ConfigSetting(ItemName, ItemPos, MenuName)
{
	global ; use assume-global mode to access global variables
	Menu, %MenuName%, ToggleCheck, %ItemName%
	; ensure ConfigDir exists
	if !InStr(FileExist(ConfigDir), "D")
	{
		FileCreateDir, %ConfigDir%
	}
	for index, element in Hotkeys
	{
		if (ItemName == element.MenuItemName)
		{
			Hotkey, If, % element.KeyScope
			Hotkey, % element.KeyName, Toggle
			element.KeySettingValue := !element.KeySettingValue
			IniWrite, % element.KeySettingValue, %ConfigFile%, General, % element.KeySettingName
		}
	}
}

AutostartProgram:
if A_IsAdmin ; if run the script as administrator, update the menu and the registry
{
	if IsAutostart
	{
		Menu, SettingMenu, Uncheck, %TEXT_MenuAutostart%
		RegDelete, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run, %ScriptName% ; disable autostart
		IsAutostart := false
	}
	else
	{
		Menu, SettingMenu, Check, %TEXT_MenuAutostart%
		RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run, %ScriptName%, %A_ScriptFullPath% ; enable autostart
		IsAutostart := true
	}
}
else ; else update the setting file
{
	; ensure ConfigDir exists
	if !InStr(FileExist(ConfigDir), "D")
	{
		FileCreateDir, %ConfigDir%
	}
	IniWrite, 1, %ConfigFile%, Autostart, ToggleAutostart
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
	IniWrite, 0, %ConfigFile%, Autostart, ToggleAutostart
}
Return

SuspendProgram:
Menu, Tray, ToggleCheck, %TEXT_Suspend%
Suspend, Toggle
Return

ShowHelpMsg:
Process, Exist
DetectHiddenWindows, On
if WinExist(TEXT_Help . " ahk_class #32770 ahk_pid " . ErrorLevel) ; if message already exists
{
	WinShow
	WinActivate ; active window
}
else ; else display message
{
	MsgBox, 0, %TEXT_Help%, %TEXT_HelpMsg%
}
Return

ShowAboutMsg:
Process, Exist
DetectHiddenWindows, On
if WinExist(TEXT_About . " ahk_class #32770 ahk_pid " . ErrorLevel) ; if message already exists
{
	WinShow
	WinActivate ; active window
}
else ; else display message
{
	OnMessage(0x44, "WM_COMMNOTIFY") ; https://autohotkey.com/board/topic/56272-msgbox-button-label-change/?p=353457
	MsgBox, 257, %TEXT_About%, %TEXT_AboutMsg%
	IfMsgBox, OK
	{
		if FileExist("Updater.exe")
		{
			TrayTip, %ScriptName%, %TEXT_Checking_For_Updates%
			Run %A_ScriptDir%\Updater.exe /A
			Sleep, 1000
			WinWait, ahk_exe Updater.exe, , 20
			HideTrayTip() ; https://autohotkey.com/docs/commands/TrayTip.htm#Remarks
		}
		else
		{
			MsgBox, 48, %ScriptName%, %TEXT_Updater_Not_Found%
		}
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
		Menu, Tray, NoIcon
		Sleep, 100
		Menu, Tray, Icon
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
	if WinExist("ahk_class Shell_TrayWnd ahk_id " . win) ; exclude taskbar
	{
		Return
	}
	SendMessage, WM_NCHITTEST, , x | (y << 16), , ahk_id %win%
	WinExist("ahk_id " . win) ; set Last Found Window for convenience
	Return, (ErrorLevel == HTCAPTION)
}

#If MouseIsOver("ahk_class Shell_TrayWnd") ; apply the following hotkey only when the mouse is over the taskbar
~RButton:: ; when right clicked
CoordMode, Mouse, Screen
MouseGetPos, xOld, yOld
Sleep, 500 ; wait for the Jump List to pop up, n.b., this line also helps to provide a uniform waiting experience
MouseGetPos, xNew, yNew
CoordMode, Mouse, Window
if (Abs(xNew - xOld) < 8 && Abs(yNew - yOld) < 8) ; if mouse did not move much
{
	Loop 6
	{
		if WinActive("ahk_class Windows.UI.Core.CoreWindow") ; if Jump List pops up (right clicked on taskbar app buttons)
		{
			WinGetPos, , , width, height ; get the size of the last found window (Jump List)
			MouseMove, (width / 2), (height - 3 * width / 32), 1 ; move mouse to the bottom of the Jump List ("Close window")
			break
		}
		Sleep, 250 ; wait for more time
	}
}
Return

; https://autohotkey.com/board/topic/82066-minimize-by-right-click-titlebar-close-by-middle-click/#entry521659
#If MouseIsOverTitlebar() ; apply the following hotkey only when the mouse is over title bars
MButton::PostMessage, 0x112, 0xF060 ; alternative to WinClose, as WinClose is a somewhat forceful method, e.g., if multiple Microsoft Excel instances exist, WinClose will close them all at once. 0x112 = WM_SYSCOMMAND, 0xF060 = SC_CLOSE https://autohotkey.com/docs/commands/WinClose.htm#Remarks

RButton::
KeyWait, RButton, T0.4 ; wait for the right mouse button to be released with timeout set to 0.4 second
if (ErrorLevel == 0) ; if the right mouse button is released during the timeout period, minimize the window
{
	; alternative to WinMinimize
	Send {Click} ; left click once to remove the remnant right click menu caused by previous clicks, n.b., do not use Send {LButton}, as it would behave inconsistently if the primary and secondary button have been swapped via the system's control panel
	PostMessage, 0x112, 0xF020
}
else ; else perform a normal right click
{
	Send {Click, Right} ; n.b., do not use Send {RButton}
}
Return

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

#If, true ; apply the following hotkey with no conditions
~Esc::
WinGet, idOld, ID, A ; get the window id
KeyWait, Esc ; wait for the Esc key to be released
KeyWait, Esc, D, T0.4 ; wait for the Esc key to be pressed again
if (ErrorLevel == 0)
{
	WinGet, idNew, ID, A ; get the window id after the Esc key has being pressed again
	WinGetClass, class, A
	if (idOld == idNew && class != "Shell_TrayWnd" && class != "Progman" && class != "WorkerW") ; if current window is the same one as before and is not taskbar or desktop
	{
		Send !{F4}
	}
}
Return
