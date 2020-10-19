#NoEnv ; recommended for performance and compatibility with future AutoHotkey releases
#SingleInstance force ; allow only one instance of this script to be running
;#Warn ; enable warnings to assist with detecting common errors
SendMode Input ; recommended for new scripts due to its superior speed and reliability
SetWorkingDir %A_ScriptDir% ; ensure a consistent starting directory

ScriptName := "CClose"
ScriptVersion := "1.4.1.0"
CopyrightNotice := "Copyright (c) 2018-2020 Chaohe Shi"

ConfigDir := A_AppData . "\" . ScriptName
ConfigFile := ConfigDir . "\" . ScriptName . ".ini"

LangFile := "lang.ini"

; set the script language
if (A_Language == "0804") ; https://autohotkey.com/docs/misc/Languages.htm
{
	Language := "Chinese"
}
else ; use English by default
{
	Language := "English"
}

; set the script texts
IniRead, TEXT_Suspend, %LangFile%, %Language%, TEXT_Suspend, Suspend
IniRead, TEXT_Settings, %LangFile%, %Language%, TEXT_Settings, Settings
IniRead, TEXT_Help, %LangFile%, %Language%, TEXT_Help, Help
IniRead, TEXT_About, %LangFile%, %Language%, TEXT_About, About
IniRead, TEXT_Exit, %LangFile%, %Language%, TEXT_Exit, Exit
IniRead, TEXT_Update, %LangFile%, %Language%, TEXT_Update, Update
IniRead, TEXT_Updater, %LangFile%, %Language%, TEXT_Updater, Updater
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
IniRead, TEXT_HelpMsg1, %LangFile%, %Language%, TEXT_HelpMsg1, Middle click   	+ title bar[1][2]	= close window
IniRead, TEXT_HelpMsg2, %LangFile%, %Language%, TEXT_HelpMsg2, Right click    	+ title bar[1][2]	= minimize window[3]
IniRead, TEXT_HelpMsg3, %LangFile%, %Language%, TEXT_HelpMsg3, Hold left click	+ title bar[1][2]	= toggle window always on top
IniRead, TEXT_HelpMsg4, %LangFile%, %Language%, TEXT_HelpMsg4, Double press   	+ Esc key        	= close active window
IniRead, TEXT_HelpMsg5, %LangFile%, %Language%, TEXT_HelpMsg5, Right click    	+ taskbar button 	= move pointer to "Close window"
IniRead, TEXT_HelpMsg6, %LangFile%, %Language%, TEXT_HelpMsg6, [1] If CClose is installed outside the default directory Program Files, you need to run it as administrator to manipulate high-privileged windows, e.g. the Task Manager.
IniRead, TEXT_HelpMsg7, %LangFile%, %Language%, TEXT_HelpMsg7, [2] Few programs don't have proper GUIs. Either there isn't a title bar, or the whole interface is technically a giant title bar. In such cases, title bar related functions will not work as expected. You can solve this issue by adding those programs to the exception list in advanced settings (Pro version required).
IniRead, TEXT_HelpMsg8, %LangFile%, %Language%, TEXT_HelpMsg8, [3] Hold right click for a normal right click.
TEXT_HelpMsg := TEXT_HelpMsg1 . "`n" . TEXT_HelpMsg2 . "`n" . TEXT_HelpMsg3 . "`n" . TEXT_HelpMsg4 . "`n" . TEXT_HelpMsg5 . "`n`n" . TEXT_HelpMsg6 . "`n`n" . TEXT_HelpMsg7 . "`n`n" . TEXT_HelpMsg8
TEXT_AboutMsg := ScriptName . " " . ScriptVersion . "`n`n" . CopyrightNotice
IniRead, TEXT_GetPro, %LangFile%, %Language%, TEXT_GetPro, Upgrade to Pro
IniRead, TEXT_GetProMsg1, %LangFile%, %Language%, TEXT_GetProMsg1, Upgrade to CClose Pro to unlock extra features, including:
IniRead, TEXT_GetProMsg2, %LangFile%, %Language%, TEXT_GetProMsg2, - Support windows without proper title bar
IniRead, TEXT_GetProMsg3, %LangFile%, %Language%, TEXT_GetProMsg3, - Blacklist for Esc key feature
IniRead, TEXT_GetProMsg4, %LangFile%, %Language%, TEXT_GetProMsg4, - Change window transparency
IniRead, TEXT_GetProMsg5, %LangFile%, %Language%, TEXT_GetProMsg5, - Support the developer and future updates
IniRead, TEXT_GetProMsg6, %LangFile%, %Language%, TEXT_GetProMsg6, Proceed to upgrade?
TEXT_GetProMsg := TEXT_GetProMsg1 . "`n`n" . TEXT_GetProMsg2 . "`n" . TEXT_GetProMsg3 . "`n" . TEXT_GetProMsg4 . "`n" . TEXT_GetProMsg5 . "`n`n" . TEXT_GetProMsg6

IniRead, TEXT_AdvancedSettingsTrial, %LangFile%, %Language%, TEXT_AdvancedSettingsTrial, Advanced Settings (Trial)
IniRead, TEXT_TrialNotice, %LangFile%, %Language%, TEXT_TrialNotice, Trial Notice
IniRead, TEXT_TrialMsg, %LangFile%, %Language%, TEXT_TrialMsg, The trial version allows you to test out some selected Pro features. However, the settings you made will not be saved beyond the current session. If you enjoy using CClose, please consider upgrading to Pro for a small fee to support the developer and future updates, thank you!

IniRead, TEXT_TitleBarExceptionList, %LangFile%, %Language%, TEXT_TitleBarExceptionList, Title Bar Exception List
IniRead, TEXT_EscHotkeyBlackList , %LangFile%, %Language%, TEXT_EscHotkeyBlackList, Esc Hotkey Blacklist
IniRead, TEXT_WindowInfo, %LangFile%, %Language%, TEXT_WindowInfo, Window Info
IniRead, TEXT_Title, %LangFile%, %Language%, TEXT_Title, Title
IniRead, TEXT_Class, %LangFile%, %Language%, TEXT_Class, Class
IniRead, TEXT_EXE, %LangFile%, %Language%, TEXT_EXE, EXE
IniRead, TEXT_PID, %LangFile%, %Language%, TEXT_PID, PID
IniRead, TEXT_FollowMouse, %LangFile%, %Language%, TEXT_FollowMouse, Follow Mouse
IniRead, TEXT_NotFrozen, %LangFile%, %Language%, TEXT_NotFrozen, (Hold Ctrl or Shift to suspend updates)
IniRead, TEXT_Frozen, %LangFile%, %Language%, TEXT_Frozen, (Updates suspended)
IniRead, TEXT_BlackList, %LangFile%, %Language%, TEXT_BlackList, Blacklist
IniRead, TEXT_ExceptionList, %LangFile%, %Language%, TEXT_ExceptionList, Exception List
IniRead, TEXT_Add, %LangFile%, %Language%, TEXT_Add, Add
IniRead, TEXT_Delete, %LangFile%, %Language%, TEXT_Delete, Delete

; add the tray menu
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
Menu, SettingMenu, Add
Menu, SettingMenu, Add, %TEXT_AdvancedSettingsTrial%, ConfigAdvSetting
Menu, Tray, Add, %TEXT_Settings%, :SettingMenu
Menu, Tray, Add
Menu, Tray, Add, %TEXT_Help%, ShowHelpMsg
Menu, Tray, Add, %TEXT_About%, ShowAboutMsg
Menu, Tray, Add, %TEXT_GetPro%, ShowGetProMsg
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
		  , KeyScope: "MouseIsOver(""ahk_class Shell_TrayWnd"") || MouseIsOver(""ahk_class Shell_SecondaryTrayWnd"")"
		  , KeySettingName: "EnableTaskbarButtonRightClick"
		  , KeySettingValue: EnableTaskbarButtonRightClick := 1
		  , MenuItemName: TEXT_MenuTaskbarButtonRightClick}
Hotkeys := [Hotkey1, Hotkey2, Hotkey3, Hotkey4, Hotkey5]

; retrieve the general settings
for index, element in Hotkeys
{
	IniRead, KeySettingValue, %ConfigFile%, General, % element.KeySettingName, 1
	element.KeySettingValue := KeySettingValue
}

; apply the general settings
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

; retrieve the autostart setting
IniRead, IsAutostart, %ConfigFile%, Autostart, EnableAutostart, 1

; apply the autostart setting if possible
if A_IsAdmin ; if run the script as administrator, apply the autostart setting
{
	if IsAutostart
	{
		Menu, SettingMenu, Check, %TEXT_MenuAutostart% ; check the autostart menu item
		RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run, %ScriptName%, %A_ScriptFullPath% ; enable autostart
	}
	else
	{
		RegDelete, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run, %ScriptName% ; disable autostart
	}
}
else ; else update the autostart setting
{
	RegRead, RegValue, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run, %ScriptName% ; retrieve autostart status
	if (RegValue == A_ScriptFullPath) ; if autostart is enabled
	{
		Menu, SettingMenu, Check, %TEXT_MenuAutostart% ; check the autostart menu item
		IsAutostart := 1
	}
	else
	{
		IsAutostart := 0
	}
	Gosub, EnsureConfigDirExists
	IniWrite, %IsAutostart%, %ConfigFile%, Autostart, EnableAutostart ; update the autostart setting
}

; retrieve the advanced settings
TitleBarExceptionList := ""
EscHotkeyBlackList := ""

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Return ; end of the auto-execute section
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; ensure ConfigDir exists
EnsureConfigDirExists:
if !InStr(FileExist(ConfigDir), "D")
{
	FileCreateDir, %ConfigDir%
}
Return

; config and apply the settings
ConfigSetting(ItemName, ItemPos, MenuName)
{
	global ; use assume-global mode to access global variables
	Menu, %MenuName%, ToggleCheck, %ItemName%
	for index, element in Hotkeys
	{
		if (ItemName == element.MenuItemName)
		{
			Hotkey, If, % element.KeyScope
			Hotkey, % element.KeyName, Toggle
			element.KeySettingValue := !element.KeySettingValue
			Gosub, EnsureConfigDirExists
			IniWrite, % element.KeySettingValue, %ConfigFile%, General, % element.KeySettingName
		}
	}
}

ConfigAdvSetting:
#Include Advanced Settings.ahk

AutostartProgram:
IsAutostart := !IsAutostart
Gosub, EnsureConfigDirExists
IniWrite, %IsAutostart%, %ConfigFile%, Autostart, EnableAutostart
if A_IsAdmin ; if run the script as administrator, apply the autostart setting
{
	Menu, SettingMenu, ToggleCheck, %TEXT_MenuAutostart%
	if IsAutostart
	{
		RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run, %ScriptName%, %A_ScriptFullPath% ; enable autostart
	}
	else
	{
		RegDelete, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run, %ScriptName% ; disable autostart
	}
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

; if run as administrator failed, rollback the autostart setting
if !A_IsAdmin
{
	IsAutostart := !IsAutostart
	Gosub, EnsureConfigDirExists
	IniWrite, %IsAutostart%, %ConfigFile%, Autostart, EnableAutostart
}
Return

SuspendProgram:
Menu, Tray, ToggleCheck, %TEXT_Suspend%
Suspend, Toggle
Return

ShowHelpMsg:
Process, Exist
DetectHiddenWindows, On
if WinExist(TEXT_Help . " ahk_class #32770 ahk_pid " . ErrorLevel) ; if the help message already exists
{
	WinShow ; show the message window if it is hidden
	WinActivate
}
else ; else display the help message
{
	MsgBox, 0, %TEXT_Help%, %TEXT_HelpMsg%
}
Return

ShowAboutMsg:
Process, Exist
DetectHiddenWindows, On
if WinExist(TEXT_About . " ahk_class #32770 ahk_pid " . ErrorLevel) ; if the about message already exists
{
	WinShow ; show the message window if it is hidden
	WinActivate
}
else ; else display the about message
{
	OnMessage(0x44, "WM_COMMNOTIFY") ; https://autohotkey.com/board/topic/56272-msgbox-button-label-change/?p=353457
	MsgBox, 257, %TEXT_About%, %TEXT_AboutMsg%
	IfMsgBox, OK
	{
		if FileExist("Updater.exe")
		{
			if WinExist(ScriptName . " ahk_exe Updater.exe") ; if the updater already exists
			{
				WinShow ; show the message window if it is hidden
				WinActivate
			}
			else
			{
				Run, %A_ScriptDir%\Updater.exe
			}
		}
		else
		{
			MsgBox, 48, %ScriptName%, %TEXT_Updater_Not_Found%
		}
	}
}
Return

ShowGetProMsg:
Process, Exist
DetectHiddenWindows, On
if WinExist(TEXT_GetPro . " ahk_class #32770 ahk_pid " . ErrorLevel) ; if the get pro message already exists
{
	WinShow ; show the message window if it is hidden
	WinActivate
}
else ; else display the get pro message
{
	MsgBox, 1, %TEXT_GetPro%, %TEXT_GetProMsg%
	IfMsgBox, OK
	{
		Run, https://chaohershi.github.io/cclose/
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
			ControlSetText, Button1, &%TEXT_Updater%
			ControlSetText, Button2, &%TEXT_Close%
		}
	}
}

HideTrayTip()
{
	TrayTip ; attempt to hide the TrayTip in the normal way
	if (SubStr(A_OSVersion, 1, 3) == "10.") ; if the OS version is Windows 10
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
	global TitleBarExceptionList
	CoordMode, Mouse, Screen
	MouseGetPos, x, y, win
	WinGetPos, xWin, yWin, , , ahk_id %win%
;	WinGetClass, classWin, ahk_id %win%
	WinGet, exeWin, ProcessName, ahk_id %win%
	if WinExist("ahk_class Shell_TrayWnd ahk_id " . win) || WinExist("ahk_class Shell_SecondaryTrayWnd ahk_id " . win) ; exclude the taskbar
	{
		Return, false
	}
	else
	{
		WinExist("ahk_id " . win) ; set the last found window for later use
		Loop, Parse, TitleBarExceptionList, `|
		{
			if (exeWin == A_LoopField) ; if item already exists
			{
				if (y >= yWin && y < yWin + 30 * A_ScreenDPI / 96) ; if within title bar width
				{
					Return, true
				}
				else
				{
					Return, false
				}
			}
		}
	}
	WinExist("ahk_id " . win) ; set the last found window for later use
	SendMessage, WM_NCHITTEST, , (x & 0xFFFF) | (y & 0xFFFF) << 16, , ahk_id %win%
	Return, (ErrorLevel == HTCAPTION)
}

#If MouseIsOver("ahk_class Shell_TrayWnd") || MouseIsOver("ahk_class Shell_SecondaryTrayWnd") ; apply the following hotkey only when the mouse is over the taskbar
~RButton:: ; when right clicked
CoordMode, Mouse, Screen
MouseGetPos, xOld, yOld
Sleep, 500 ; wait for the Jump List to pop up, n.b., this line also helps to provide a uniform waiting experience
MouseGetPos, xNew, yNew
CoordMode, Mouse, Window
if (Abs(xNew - xOld) < 8 && Abs(yNew - yOld) < 8) ; if the mouse did not move much
{
	Loop 6
	{
		if WinActive("ahk_class Windows.UI.Core.CoreWindow") ; if the Jump List pops up (right clicked on the taskbar app buttons)
		{
			WinGetPos, , , width, height ; get the size of the last found window (Jump List)
			MouseMove, (width / 2), (height - 3 * width / 32), 1 ; move the mouse to the bottom of the Jump List ("Close window")
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
	PostMessage, 0x112, 0xF020 ; alternative to WinMinimize
}
else ; else send a normal right click
{
	Send {Click, Right} ; n.b., do not use Send {RButton}
}
Return

~LButton::
CoordMode, Mouse, Screen
MouseGetPos, xOld, yOld
WinGet, ExStyle, ExStyle ; get the extended window style
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
if (xOld == xNew && yOld == yNew && ErrorLevel == 1) ; if the mouse did not move during the timeout period
{
	Winset, Alwaysontop, Toggle, A ; toggle window always on top
	ToolTip, %ExStyle%, , 0 ; display a tooltip with current topmost status
	SetTimer, RemoveToolTip, 1000 ; remove the tooltip after 1 second
}
Return

#If, true ; apply the following hotkey with no conditions
~Esc::
WinGet, idOld, ID, A ; get the window id
WinGet, exeName, ProcessName, A ; get the EXE name
Loop, Parse, EscHotkeyBlackList, `|
{
	if (exeName == A_LoopField) ; if item already exists
	{
		Return
	}
}
KeyWait, Esc ; wait for the Esc key to be released
KeyWait, Esc, D, T0.4 ; wait for the Esc key to be pressed again
if (ErrorLevel == 0)
{
	WinGet, idNew, ID, A ; get the window id after the Esc key has being pressed again
	WinGetClass, class, A
	if (idOld == idNew && class != "Shell_TrayWnd" && class != "Shell_SecondaryTrayWnd" && class != "Progman" && class != "WorkerW") ; if the current window is the same one as before and is not taskbar or desktop
	{
		Send !{F4}
	}
}
Return
