#Requires AutoHotkey v2.0

; ==================== 全局变量定义 ====================

; 模块状态 Map (模块名 -> 是否启用)
global ModuleStates := Map()

; 模块信息 Map (模块名 -> 详细信息)
global ModuleInfo := Map()

; 应用程序路径配置 (从 config.ini 读取)
global VscodePath := ""
global EdgePath := ""
global WeComPath := ""

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
        "description", "快速切换或启动常用应用程序。未启动则启动，后台则激活，已激活则最小化。",
        "hotkeys", [
            "Alt + 1: VSCode",
            "Alt + 2: Edge 浏览器",
            "Alt + 3: 企业微信"
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
    global ModuleStates, VscodePath, EdgePath, WeComPath, ConfigFilePath

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

        ; 读取应用程序路径
        VscodePath := IniRead(ConfigFilePath, "Paths", "VSCode", "D:\SoftWare\Develop\Microsoft VS Code\Code.exe")
        EdgePath := IniRead(ConfigFilePath, "Paths", "Edge",
            "explorer.exe shell:Appsfolder\Microsoft.MicrosoftEdge_8wekyb3d8bbwe!MicrosoftEdge")
        WeComPath := IniRead(ConfigFilePath, "Paths", "WeCom", "D:\SoftWare\Communication\WeCom\WXWork\WXWork.exe")
    } catch Error as err {
        MsgBox("配置文件读取失败，使用默认配置。`n错误信息: " . err.Message, "警告", "Icon!")
        CreateDefaultConfig()
    }
}

; 保存配置文件
SaveConfig() {
    global ModuleStates, VscodePath, EdgePath, WeComPath, ConfigFilePath

    try {
        ; 保存模块状态
        IniWrite(ModuleStates["vim"] ? "1" : "0", ConfigFilePath, "Modules", "vim")
        IniWrite(ModuleStates["fArea"] ? "1" : "0", ConfigFilePath, "Modules", "fArea")
        IniWrite(ModuleStates["emoji"] ? "1" : "0", ConfigFilePath, "Modules", "emoji")
        IniWrite(ModuleStates["markdown"] ? "1" : "0", ConfigFilePath, "Modules", "markdown")
        IniWrite(ModuleStates["winSwitch"] ? "1" : "0", ConfigFilePath, "Modules", "winSwitch")
        IniWrite(ModuleStates["symbol"] ? "1" : "0", ConfigFilePath, "Modules", "symbol")

        ; 保存应用程序路径
        IniWrite(VscodePath, ConfigFilePath, "Paths", "VSCode")
        IniWrite(EdgePath, ConfigFilePath, "Paths", "Edge")
        IniWrite(WeComPath, ConfigFilePath, "Paths", "WeCom")

        return true
    } catch Error as err {
        MsgBox("配置文件保存失败！`n错误信息: " . err.Message, "错误", "IconX")
        return false
    }
}

; 创建默认配置
CreateDefaultConfig() {
    global ModuleStates, VscodePath, EdgePath, WeComPath

    ; 默认所有模块启用
    ModuleStates["vim"] := true
    ModuleStates["fArea"] := true
    ModuleStates["emoji"] := true
    ModuleStates["markdown"] := true
    ModuleStates["winSwitch"] := true
    ModuleStates["symbol"] := true

    ; 默认应用程序路径（从 winSwitch.ahk 迁移）
    VscodePath := "D:\SoftWare\Develop\Microsoft VS Code\Code.exe"
    EdgePath := "explorer.exe shell:Appsfolder\Microsoft.MicrosoftEdge_8wekyb3d8bbwe!MicrosoftEdge"
    WeComPath := "D:\SoftWare\Communication\WeCom\WXWork\WXWork.exe"

    ; 保存到文件
    SaveConfig()
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