#SingleInstance force ; allow only one instance of this script to be running

Menu, Tray, Icon, , , 1
Menu, Tray, NoStandard
Menu, Tray, Add, Suspend, SuspendProgram
Menu, Tray, Add, Exit, ExitProgram

Return ; end of auto-execute section

SuspendProgram:
Suspend, Toggle
Menu, Tray, ToggleCheck, Suspend
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
