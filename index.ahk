#Requires AutoHotkey v2.0
#SingleInstance Force

; ==================== 加载配置和 GUI ====================
#Include "./config.ahk"
#Include "./gui.ahk"

; 加载配置文件
LoadConfig()

; ==================== 加载功能模块 ====================
#Include "./vim.ahk"
#Include "./fArea.ahk"
#Include "./emoji.ahk"
#Include "./markdown.ahk"
#Include "./winSwitch.ahk"
#Include "./symbol.ahk"

; ==================== 托盘菜单设置 ====================
InitTrayMenu()

; ==================== 托盘菜单初始化函数 ====================
InitTrayMenu() {
    ; 删除默认菜单项
    A_TrayMenu.Delete()

    ; 添加"打开设置"菜单项
    A_TrayMenu.Add("⚙ 打开设置", (*) => ShowConfigGui())
    A_TrayMenu.Default := "⚙ 打开设置"
    A_TrayMenu.Add("⌨ 查看按键历史", (*) => KeyHistory())

    A_TrayMenu.Add()  ; 分隔线

    ; 添加模块快捷开关
    for moduleName in GetAllModules() {
        info := ModuleInfo[moduleName]
        menuText := info["name"]

        ; 创建菜单项
        A_TrayMenu.Add(menuText, ToggleModuleFromTray.Bind(moduleName))

        ; 设置勾选状态
        if ModuleStates[moduleName]
            A_TrayMenu.Check(menuText)
    }

    A_TrayMenu.Add()  ; 分隔线

    ; 添加重载和退出
    A_TrayMenu.Add("🔄 重载脚本", (*) => Reload())
    A_TrayMenu.Add("❌ 退出脚本", (*) => ExitApp())
}

; 从托盘菜单切换模块状态
ToggleModuleFromTray(moduleName, *) {
    ; 切换状态
    ModuleStates[moduleName] := !ModuleStates[moduleName]
    SaveConfig()

    if moduleName = "winSwitch"
        try RegisterWinSwitchHotkeys()

    ; 更新菜单勾选状态
    info := ModuleInfo[moduleName]
    menuText := info["name"]

    if ModuleStates[moduleName]
        A_TrayMenu.Check(menuText)
    else
        A_TrayMenu.Uncheck(menuText)

    ; 显示提示
    status := ModuleStates[moduleName] ? "已启用" : "已禁用"
    TrayTip(info["name"] . " " . status, "AutoHotKey 脚本管理器", "Mute")
}
