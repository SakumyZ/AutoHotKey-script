#Requires AutoHotkey v2.0

; ==================== 全局变量定义 ====================

; 模块状态 Map (模块名 -> 是否启用)
global ModuleStates := Map()

; 模块信息 Map (模块名 -> 详细信息)
global ModuleInfo := Map()

; 窗口切换配置列表
global WinSwitchItems := []

; WinSwitch 日志开关（从 config.ini 读取）
global WinSwitchLogEnabled := false

; 配置文件路径
global ConfigFilePath := A_ScriptDir . "\config.ini"

; ==================== 模块元数据定义 ====================

InitModuleInfo() {
    global ModuleInfo

    ; VIM 模块
    ModuleInfo["vim"] := Map(
        "name", "VIM 导航模式",
        "description", "将 CapsLock 改造为修饰键，提供类 VIM 的光标移动和编辑快捷键。",
        "hotkeys", [
            "CapsLock + H/J/K/L: 方向键（左/下/上/右）",
            "CapsLock + A: 行首",
            "CapsLock + I: Home（支持选择模式）",
            "CapsLock + M: End（支持选择模式）",
            "CapsLock + U/N: PageUp/PageDown",
            "CapsLock + Backspace: Delete"
        ]
    )

    ; F 区映射模块
    ModuleInfo["fArea"] := Map(
        "name", "F 功能键映射",
        "description", "双重模式的 F 键映射系统。CapsLock+数字始终可用，双击 ESC 切换单键模式。",
        "hotkeys", [
            "CapsLock + 1~9: F1~F9",
            "CapsLock + 0: F10",
            "CapsLock + -: F11",
            "CapsLock + =: F12",
            "双击 ESC: 切换单键模式（数字键直接映射 F 键）"
        ]
    )

    ; Emoji 模块
    ModuleInfo["emoji"] := Map(
        "name", "Emoji 快速输入",
        "description", "通过文本缩写快速输入 Emoji 表情，支持 200+ 个表情。",
        "hotkeys", [
            ":hash: → #️⃣",
            ":one: → 1️⃣",
            ":flag_ac: → 🇦🇨",
            ":copyright: → ©️",
            "更多请查看 emoji.ahk 文件"
        ]
    )

    ; Markdown 模块
    ModuleInfo["markdown"] := Map(
        "name", "Markdown 标题快捷键",
        "description", "快速为当前行添加或修改 Markdown 标题级别。",
        "hotkeys", [
            "Ctrl + 1: H1 标题",
            "Ctrl + 2: H2 标题",
            "Ctrl + 3: H3 标题",
            "Ctrl + 4: H4 标题",
            "Ctrl + 5: H5 标题",
            "Ctrl + 6: H6 标题"
        ]
    )

    ; 窗口切换模块
    ModuleInfo["winSwitch"] := Map(
        "name", "窗口快速切换",
        "description", "通过配置的快捷键快速切换或启动常用应用程序。未启动则启动，后台则激活，已激活则隐藏。",
        "hotkeys", [
            "请在配置窗口或 config.ini 的 [WinSwitch] 中维护"
        ]
    )

    ; 特殊符号模块
    ModuleInfo["symbol"] := Map(
        "name", "特殊符号输入",
        "description", "快速输入特殊 Unicode 字符。",
        "hotkeys", [
            ":fk: → ■",
            ":q1: ~ :q10: → ①②③④⑤⑥⑦⑧⑨⑩"
        ]
    )
}

; ==================== 配置管理函数 ====================

; 加载配置文件
LoadConfig() {
    global ModuleStates, ConfigFilePath

    ; 如果配置文件不存在，创建默认配置
    if !FileExist(ConfigFilePath) {
        CreateDefaultConfig()
        return
    }

    ; 读取模块状态
    try {
        ModuleStates["vim"] := IniRead(ConfigFilePath, "Modules", "vim", "1") = "1"
        ModuleStates["fArea"] := IniRead(ConfigFilePath, "Modules", "fArea", "1") = "1"
        ModuleStates["emoji"] := IniRead(ConfigFilePath, "Modules", "emoji", "1") = "1"
        ModuleStates["markdown"] := IniRead(ConfigFilePath, "Modules", "markdown", "1") = "1"
        ModuleStates["winSwitch"] := IniRead(ConfigFilePath, "Modules", "winSwitch", "1") = "1"
        ModuleStates["symbol"] := IniRead(ConfigFilePath, "Modules", "symbol", "1") = "1"

        LoadWinSwitchConfig()

        ; 读取 WinSwitch 日志配置
        global WinSwitchLogEnabled
        WinSwitchLogEnabled := IniRead(ConfigFilePath, "WinSwitch", "log", "0") = "1"

        UpdateWinSwitchModuleInfo()
    } catch Error as err {
        MsgBox("配置文件读取失败，使用默认配置。`n错误信息: " . err.Message, "警告", "Icon!")
        CreateDefaultConfig()
    }
}

; 保存配置文件
SaveConfig() {
    global ModuleStates, ConfigFilePath

    try {
        ; 保存模块状态
        IniWrite(ModuleStates["vim"] ? "1" : "0", ConfigFilePath, "Modules", "vim")
        IniWrite(ModuleStates["fArea"] ? "1" : "0", ConfigFilePath, "Modules", "fArea")
        IniWrite(ModuleStates["emoji"] ? "1" : "0", ConfigFilePath, "Modules", "emoji")
        IniWrite(ModuleStates["markdown"] ? "1" : "0", ConfigFilePath, "Modules", "markdown")
        IniWrite(ModuleStates["winSwitch"] ? "1" : "0", ConfigFilePath, "Modules", "winSwitch")
        IniWrite(ModuleStates["symbol"] ? "1" : "0", ConfigFilePath, "Modules", "symbol")

        SaveWinSwitchConfig()
        UpdateWinSwitchModuleInfo()

        return true
    } catch Error as err {
        MsgBox("配置文件保存失败！`n错误信息: " . err.Message, "错误", "IconX")
        return false
    }
}

; 创建默认配置
CreateDefaultConfig() {
    global ModuleStates, WinSwitchItems

    ; 默认所有模块启用
    ModuleStates["vim"] := true
    ModuleStates["fArea"] := true
    ModuleStates["emoji"] := true
    ModuleStates["markdown"] := true
    ModuleStates["winSwitch"] := true
    ModuleStates["symbol"] := true

    WinSwitchItems := GetDefaultWinSwitchItems()

    ; 保存到文件
    SaveConfig()
}

GetDefaultWinSwitchItems() {
    return [
        Map("name", "VSCode", "hotkey", "!1", "exe", "Code.exe", "target",
            "D:\Software\Develop\Microsoft VS Code\Code.exe"),
        Map("name", "Edge 浏览器", "hotkey", "!2", "exe", "msedge.exe", "target",
            "explorer.exe shell:Appsfolder\Microsoft.MicrosoftEdge_8wekyb3d8bbwe!MicrosoftEdge"),
        Map("name", "企业微信", "hotkey", "!3", "exe", "WXWork.exe", "target", "D:\Software\Communication\WXWork")
    ]
}

LoadWinSwitchConfig() {
    global WinSwitchItems, ConfigFilePath

    WinSwitchItems := []

    ; 使用UTF-8编码读取配置文件，避免乱码问题
    try {
        content := FileRead(ConfigFilePath, "UTF-8")
    } catch {
        WinSwitchItems := GetDefaultWinSwitchItems()
        return
    }

    ; 解析WinSwitch配置段
    inWinSwitchSection := false
    lines := StrSplit(content, "`n")
    count := 0

    for line in lines {
        line := Trim(line)

        ; 检测[WinSwitch]段
        if line = "[WinSwitch]" {
            inWinSwitchSection := true
            continue
        }

        ; 检测其他段的开始，结束WinSwitch段的解析
        if inWinSwitchSection && SubStr(line, 1, 1) = "[" {
            break
        }

        ; 在WinSwitch段中解析配置项
        if inWinSwitchSection && line != "" && SubStr(line, 1, 1) != ";" {
            ; 解析形如 Item1Name=VSCode 的配置
            if RegExMatch(line, "i)^Item(\d+)Name=(.*)", &match) {
                itemIndex := match[1]
                prefix := "Item" . itemIndex

                ; 从已解析的行中提取该Item的所有字段
                name := ""
                hotkey := ""
                exe := ""
                target := ""

                ; 遍历所有行，找到对应Item的所有字段
                for checkLine in lines {
                    checkLine := Trim(checkLine)
                    if RegExMatch(checkLine, "i)^" . prefix . "Name=(.*)", &m)
                        name := m[1]
                    if RegExMatch(checkLine, "i)^" . prefix . "Hotkey=(.*)", &m)
                        hotkey := m[1]
                    if RegExMatch(checkLine, "i)^" . prefix . "Exe=(.*)", &m)
                        exe := m[1]
                    if RegExMatch(checkLine, "i)^" . prefix . "Target=(.*)", &m)
                        target := m[1]
                }

                if hotkey != "" && exe != "" && target != "" {
                    WinSwitchItems.Push(Map("name", name, "hotkey", hotkey, "exe", exe, "target", target))
                    count++
                }
            }
        }
    }

    if WinSwitchItems.Length = 0
        WinSwitchItems := GetDefaultWinSwitchItems()
}

SaveWinSwitchConfig() {
    global WinSwitchItems, ConfigFilePath

    ; 读取现有配置文件内容，保留非WinSwitch的部分
    existingContent := ""
    try {
        existingContent := FileRead(ConfigFilePath, "UTF-8")
    } catch {
        ; 文件不存在，创建新文件
    }

    ; 构建新的WinSwitch配置段
    newWinSwitchSection := "[WinSwitch]`n"

    loop WinSwitchItems.Length {
        item := WinSwitchItems[A_Index]
        prefix := "Item" . A_Index
        newWinSwitchSection .= prefix . "Name=" . item["name"] . "`n"
        newWinSwitchSection .= prefix . "Hotkey=" . item["hotkey"] . "`n"
        newWinSwitchSection .= prefix . "Exe=" . item["exe"] . "`n"
        newWinSwitchSection .= prefix . "Target=" . item["target"] . "`n"
    }

    ; 移除旧的WinSwitch段，保留其他段
    lines := StrSplit(existingContent, "`n")
    resultLines := []
    skipWinSwitch := false

    for line in lines {
        if line = "[WinSwitch]" {
            skipWinSwitch := true
            continue
        }
        if skipWinSwitch && SubStr(Trim(line), 1, 1) = "[" {
            skipWinSwitch := false
        }
        if !skipWinSwitch {
            resultLines.Push(line)
        }
    }

    ; 构建最终内容：保留的内容 + 新的WinSwitch段
    finalContent := ""
    for line in resultLines {
        if Trim(line) != ""
            finalContent .= line . "`n"
    }
    finalContent .= newWinSwitchSection

    ; 使用UTF-8编码写入文件
    try {
        file := FileOpen(ConfigFilePath, "w", "UTF-8")
        file.Write(finalContent)
        file.Close()
    } catch Error as err {
        MsgBox("写入配置文件失败: " . err.Message)
    }
}

UpdateWinSwitchModuleInfo() {
    global ModuleInfo, WinSwitchItems

    if !ModuleInfo.Has("winSwitch")
        return

    hotkeys := []
    for item in WinSwitchItems {
        displayName := item["name"] != "" ? item["name"] : item["exe"]
        hotkeys.Push(FormatHotkeyForDisplay(item["hotkey"]) . ": " . displayName)
    }

    if hotkeys.Length = 0
        hotkeys.Push("尚未配置窗口切换项")

    ModuleInfo["winSwitch"]["hotkeys"] := hotkeys
}

FormatHotkeyForDisplay(hotkey) {
    parts := []
    rest := hotkey

    while rest != "" {
        ch := SubStr(rest, 1, 1)

        if ch = "!" {
            parts.Push("Alt")
        } else if ch = "^" {
            parts.Push("Ctrl")
        } else if ch = "+" {
            parts.Push("Shift")
        } else if ch = "#" {
            parts.Push("Win")
        } else {
            break
        }

        rest := SubStr(rest, 2)
    }

    parts.Push(rest)
    text := ""
    for part in parts {
        text .= (text = "" ? "" : " + ") . part
    }

    return text
}

; 切换模块状态
ToggleModule(moduleName) {
    global ModuleStates

    if ModuleStates.Has(moduleName) {
        ModuleStates[moduleName] := !ModuleStates[moduleName]
        SaveConfig()
        return ModuleStates[moduleName]
    }
    return false
}

; 获取所有模块名称列表
GetAllModules() {
    return ["vim", "fArea", "emoji", "markdown", "winSwitch", "symbol"]
}

; 启用所有模块
EnableAllModules() {
    global ModuleStates
    for moduleName in GetAllModules() {
        ModuleStates[moduleName] := true
    }
    SaveConfig()
}

; 禁用所有模块
DisableAllModules() {
    global ModuleStates
    for moduleName in GetAllModules() {
        ModuleStates[moduleName] := false
    }
    SaveConfig()
}

; ==================== 初始化 ====================

; 初始化模块信息
InitModuleInfo()