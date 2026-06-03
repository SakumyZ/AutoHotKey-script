@echo off

setlocal EnableDelayedExpansion
set WrkDir=%~dp0
set "LinkName=index.ahk.lnk"
set "ScriptPath=%~dp0index.ahk"
set "AhkExe="

for %%I in (
	"C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
	"C:\Program Files\AutoHotkey\AutoHotkey64.exe"
	"D:\Software\Develop\AutoHotKey\v2\AutoHotkey64.exe"
	"D:\Software\Develop\AutoHotKey\v2.0.2\AutoHotkey64.exe"
) do (
	if exist %%~I (
		set "AhkExe=%%~I"
		goto :found
	)
)

echo AutoHotkey v2 interpreter was not found.
echo Please install AutoHotkey v2 or update autoStart.bat with the correct path.
pause
exit /b 1

:found

mshta VBScript:Execute("Set Shell=CreateObject(""WScript.Shell""):Set Link=Shell.CreateShortcut(""!LinkName!""):Link.TargetPath=""!AhkExe!"":Link.Arguments=""""""!ScriptPath!"""""":Link.WorkingDirectory=""!WrkDir!"":Link.Save:close"^)

move /y index.ahk.lnk "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"

pause