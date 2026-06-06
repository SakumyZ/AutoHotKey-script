#Requires AutoHotkey v2.0

#Include "./config.ahk"

; 已注册的快捷短语热键 Map（热键名 -> 是否已注册）
global RegisteredQuickPhraseHotkeys := Map()

; 注册快捷短语热键
RegisterQuickPhraseHotkeys() {
    global ModuleStates, QuickPhraseItems, RegisteredQuickPhraseHotkeys

    ; 如果模块未启用，卸载所有快捷短语热键
    if !ModuleStates["quickPhrase"] {
        for hotkeyName in RegisteredQuickPhraseHotkeys {
            try Hotkey(hotkeyName, "Off")
        }
        RegisteredQuickPhraseHotkeys.Clear()
        return
    }

    ; 清空之前注册的热键
    for hotkeyName in RegisteredQuickPhraseHotkeys {
        try Hotkey(hotkeyName, "Off")
    }
    RegisteredQuickPhraseHotkeys.Clear()

    ; 注册新的热键
    for item in QuickPhraseItems {
        if item["hotkey"] = ""
            continue

        hotkeyName := item["hotkey"]

        try {
            Hotkey(hotkeyName, HandleQuickPhraseHotkey.Bind(item, hotkeyName))
            RegisteredQuickPhraseHotkeys[hotkeyName] := true
        } catch Error as err {
            ; 热键注册失败，记录到提示
            TrayTip("快捷短语热键注册失败: " . hotkeyName, "错误", "Mute")
        }
    }
}

; 处理快捷短语热键
HandleQuickPhraseHotkey(item, hotkeyName, *) {
    global ModuleStates

    if !ModuleStates["quickPhrase"]
        return

    phrase := item["phrase"]
    if phrase = ""
        return

    ; 方法1：直接发送文本（推荐，支持大部分字符）
    ; 但需要确保焦点在正确的窗口
    try {
        ; 保存原始剪贴板内容
        savedClipboard := A_Clipboard

        ; 设置短语到剪贴板并粘贴
        A_Clipboard := phrase
        Sleep(100)  ; 确保剪贴板操作完成
        Send("^v")

        ; 恢复原始剪贴板内容（可选，取决于是否需要保留原始内容）
        Sleep(100)
        A_Clipboard := savedClipboard
    } catch {
        ; 如果复制粘贴失败，尝试直接发送文本
        ; 注意：这种方法可能不支持所有特殊字符
        try {
            SendText(phrase)
        } catch Error as err {
            TrayTip("快捷短语发送失败: " . err.Message, "错误", "Mute")
        }
    }
}

; 初始化快捷短语热键
InitQuickPhraseHotkeys() {
    try RegisterQuickPhraseHotkeys()
}
