#Include "./config.ahk"

; 窗口切换项从 config.ahk 的 WinSwitchItems 读取
global WinSwitchLogPath := A_ScriptDir . "\winSwitch.log"
global RegisteredWinSwitchHotkeys := Map()
global WinSwitchDebug := WinSwitchLogEnabled ; 从 config.ini 读取日志配置

LogWinSwitch(message) {
    global WinSwitchLogPath, WinSwitchDebug
    if !WinSwitchDebug
        return

    try {
        timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
        FileAppend(timestamp . "." . Format("{:03}", A_MSec) . " " . message . "`n", WinSwitchLogPath, "UTF-8")
    }
}

MinimizeWindows(windowSelector) {
    hwnds := WinGetList(windowSelector)
    LogWinSwitch("Minimize all windows selector=" . windowSelector . " count=" . hwnds.Length)

    for hwnd in hwnds {
        try {
            LogWinSwitch("Minimize hwnd=" . hwnd)
            WinMinimize("ahk_id " hwnd)
        }
    }
}

SwitchWindow(ahkExe, launchTarget) {
    windowSelector := "ahk_exe " ahkExe
    LogWinSwitch("SwitchWindow start exe=" . ahkExe . " target=" . launchTarget)

    ; AHK v2 中对不存在的窗口执行 WinActivate 会直接抛错。
    ; 先判断窗口是否存在，再决定是切换还是启动。
    if hwnd := WinExist(windowSelector) {
        hwndSelector := "ahk_id " hwnd

        LogWinSwitch("Window found exe=" . ahkExe . " hwnd=" . hwnd
            . " active=" . WinActive(hwndSelector))

        if WinActive(hwndSelector) {
            LogWinSwitch("Action minimize active exe=" . ahkExe . " hwnd=" . hwnd)
            MinimizeWindows(windowSelector)
        } else {
            LogWinSwitch("Action activate hwnd=" . hwnd)
            WinActivate(hwndSelector)
            WinWaitActive(hwndSelector, , 0.5)
            LogWinSwitch("Activate done hwnd=" . hwnd . " active=" . WinActive(hwndSelector))
        }

        return
    }

    LogWinSwitch("Window not found, run target=" . launchTarget)
    Run(launchTarget)
}

global LastWinSwitchTime := 0

HandleWinSwitchHotkey(item, hotkeyName, *) {
    global ModuleStates, LastWinSwitchTime

    ; 限制 100ms 内只能触发一次，防止长按连发，同时避免 KeyWait 阻塞线程导致卡顿
    currentTime := A_TickCount
    if (currentTime - LastWinSwitchTime < 100) {
        return
    }
    LastWinSwitchTime := currentTime

    name := item["name"] != "" ? item["name"] : item["exe"]
    LogWinSwitch("Hotkey received hotkey=" . hotkeyName . " name=" . name)

    if !ModuleStates["winSwitch"] {
        LogWinSwitch("Skip because winSwitch module disabled")
        return
    }

    SwitchWindow(item["exe"], item["target"])
}

RegisterWinSwitchHotkeys() {
    global ModuleStates, WinSwitchItems, RegisteredWinSwitchHotkeys

    ; 显式重置后续 Hotkey 注册为全局无条件（不受任何 #HotIf 污染）
    HotIf()

    for hotkeyName, _ in RegisteredWinSwitchHotkeys {
        try Hotkey(hotkeyName, "Off")
    }
    RegisteredWinSwitchHotkeys := Map()

    if !ModuleStates["winSwitch"] {
        LogWinSwitch("Skip registering because winSwitch module disabled")
        return
    }

    for item in WinSwitchItems {
        hotkeyName := item["hotkey"]
        name := item["name"] != "" ? item["name"] : item["exe"]

        if hotkeyName = "" || item["exe"] = "" || item["target"] = "" {
            LogWinSwitch("Skip invalid item name=" . name . " hotkey=" . hotkeyName)
            continue
        }

        try {
            Hotkey(hotkeyName, HandleWinSwitchHotkey.Bind(item, hotkeyName), "On")
            RegisteredWinSwitchHotkeys[hotkeyName] := true
            LogWinSwitch("Registered hotkey=" . hotkeyName . " name=" . name)
        } catch Error as err {
            LogWinSwitch("Register failed hotkey=" . hotkeyName . " name=" . name . " error=" . err.Message)
        }
    }
}

RegisterWinSwitchHotkeys()