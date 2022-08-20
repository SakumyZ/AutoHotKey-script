@echo off

setlocal EnableDelayedExpansion
set WrkDir=%~dp0
set "LinkName=index.ahk.lnk"
set filname=index.ahk
set ThePath=%~dp0%index.ahk

mshta VBScript:Execute("Set Shell=CreateObject(""WScript.Shell""):Set Link=Shell.CreateShortcut(""!LinkName!""):Link.TargetPath=""!ThePath!"":Link.WorkingDirectory=""!WrkDir!"":Link.Save:close"^)

move /y index.ahk.lnk "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"

pause