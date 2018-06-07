#SingleInstance ignore ; allow only one instance of this script to be running
; add tray menu
Menu, Tray, Icon, , , 1
Menu, Tray, NoStandard
Menu, Tray, Add, Autostart, AutostartProgram
Menu, Tray, Add, Suspend, SuspendProgram
Menu, Tray, Add, Exit, ExitProgram

; add shortcut to Startup folder
SplitPath, A_Scriptname, , , , OutNameNoExt
LinkFile := A_Startup . "\" . OutNameNoExt . ".lnk"
if A_IsAdmin {
	FileCreateShortcut, %A_ScriptFullPath%, %LinkFile%
}
Autostart := FileExist(LinkFile)
if Autostart {
	Menu, Tray, Check, Autostart
}

Return ; end of auto-execute section

AutostartProgram:
if Autostart {
	Menu, Tray, Uncheck, Autostart
	FileDelete, %LinkFile%
	Autostart := false
} else {
	; run as administrator
	full_command_line := DllCall("GetCommandLine", "str")
	if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)")) {
		MsgBox, Close It will need your premission to create a shortcut in the Windows Startup folder.
		try {
			if A_IsCompiled {
				Run *RunAs "%A_ScriptFullPath%" /restart
			} else {
				Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
			}
			ExitApp
		}
	} else {
		if A_IsAdmin {
			FileCreateShortcut, %A_ScriptFullPath%, %LinkFile%
			Menu, Tray, Check, Autostart
			Autostart := true
		}
	}
}
Return

SuspendProgram:
Menu, Tray, ToggleCheck, Suspend
Suspend, Toggle
Return

ExitProgram:
ExitApp

#If MouseIsOver("ahk_class Shell_TrayWnd") ; if mouse is over the taskbar
RButton:: ; replace right click with the following commands
MouseClick, right ; right click
sleep 350 ; wait for the Jump List to pop up (if clicked on apps)

if WinActive("ahk_class Windows.UI.Core.CoreWindow") { ; if Jump List pops up
	WinGetPos, , , width, height, A ; get active window (Jump List) position
	MouseMove, (width - 128), (height - 24), 1 ; move mouse to the bottom of the Jump List (Close window)
}

MouseIsOver(WinTitle) {
	MouseGetPos, , , Win
	Return WinExist(WinTitle . " ahk_id " . Win)
}
