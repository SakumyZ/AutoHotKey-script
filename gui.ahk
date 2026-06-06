#Requires AutoHotkey v2.0

; ==================== GUI 管理界面 ====================

; 全局变量：GUI 实例
global g_ConfigGui := ""
global g_WinSwitchGui := ""
global g_WinSwitchListView := ""
global g_QuickPhraseGui := ""
global g_QuickPhraseListView := ""

; 显示配置窗口
ShowConfigGui() {
    global g_ConfigGui

    ; 如果窗口已存在，激活它
    if IsObject(g_ConfigGui) {
        try {
            g_ConfigGui.Show()
            return
        }
    }

    ; 创建新窗口
    g_ConfigGui := Gui("+Resize", "AutoHotKey 脚本管理器")
    g_ConfigGui.SetFont("s10", "Microsoft YaHei UI")
    g_ConfigGui.MarginX := 20
    g_ConfigGui.MarginY := 15

    ; 标题
    g_ConfigGui.AddText("w460", "模块管理 - 即时生效，无需重启脚本")
    g_ConfigGui.AddText("w460 cGray", "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    ; 存储复选框控件的 Map
    global checkboxes := Map()

    ; 模块复选框
    modules := GetAllModules()
    for index, moduleName in modules {
        info := ModuleInfo[moduleName]

        ; 创建复选框（使用 xm 重置到左边距）
        cb := g_ConfigGui.AddCheckbox(
            "xm w320 Checked" . (ModuleStates[moduleName] ? "1" : "0"),
            info["name"]
        )
        cb.OnEvent("Click", CreateCheckboxHandler(moduleName, cb))
        checkboxes[moduleName] := cb

        ; 创建"详情"按钮（x360 表示绝对位置，yp 表示与上一个控件同行）
        btn := g_ConfigGui.AddButton("x360 yp w100 h30", "查看详情")
        btn.OnEvent("Click", CreateDetailsHandler(moduleName))
    }

    ; 为每个checkbox创建独立的事件处理器，正确捕获moduleName和cb
    CreateCheckboxHandler(moduleName, cb) {
        return (*) => OnModuleToggle(moduleName, cb)
    }

    ; 为每个模块的"详情"按钮创建独立的事件处理器，正确捕获moduleName
    CreateDetailsHandler(moduleName) {
        return (*) => ShowModuleDetails(moduleName)
    }

    ; 分隔线
    g_ConfigGui.AddText("xm w460 cGray", "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    ; 快捷操作按钮行1（一行3列）
    btnEnableAll := g_ConfigGui.AddButton("xm w140 h30", "✓ 全部启用")
    btnEnableAll.OnEvent("Click", (*) => OnEnableAll())

    btnDisableAll := g_ConfigGui.AddButton("x+10 w140 h30", "✗ 全部禁用")
    btnDisableAll.OnEvent("Click", (*) => OnDisableAll())

    btnCheckConflict := g_ConfigGui.AddButton("x+10 w140 h30", "🔍 检测冲突")
    btnCheckConflict.OnEvent("Click", (*) => CheckHotkeyConflicts())

    ; 快捷操作按钮行2（一行3列）
    btnWinSwitch := g_ConfigGui.AddButton("xm w140 h30", "窗口切换配置")
    btnWinSwitch.OnEvent("Click", (*) => ShowWinSwitchConfigGui())

    btnQuickPhrase := g_ConfigGui.AddButton("x+10 w140 h30", "快捷短语配置")
    btnQuickPhrase.OnEvent("Click", (*) => ShowQuickPhraseConfigGui())

    btnExport := g_ConfigGui.AddButton("x+10 w140 h30", "📤 导出配置")
    btnExport.OnEvent("Click", (*) => ExportConfig())

    ; 快捷操作按钮行3（一行3列）
    btnImport := g_ConfigGui.AddButton("xm w140 h30", "📥 导入配置")
    btnImport.OnEvent("Click", (*) => ImportConfig())

    btnReload := g_ConfigGui.AddButton("x+10 w140 h30", "🔄 重载脚本")
    btnReload.OnEvent("Click", (*) => ReloadScript())

    btnViewHelp := g_ConfigGui.AddButton("x+10 w140 h30", "ℹ 查看帮助")
    btnViewHelp.OnEvent("Click", (*) => ShowHelpInfo())

    ; 关闭窗口事件
    g_ConfigGui.OnEvent("Close", (*) => g_ConfigGui.Hide())

    ; 显示窗口
    g_ConfigGui.Show("w500 h600")
}

ShowWinSwitchConfigGui() {
    global g_WinSwitchGui, g_WinSwitchListView

    if IsObject(g_WinSwitchGui) {
        try {
            RefreshWinSwitchListView()
            g_WinSwitchGui.Show()
            return
        }
    }

    g_WinSwitchGui := Gui("+Resize", "窗口切换配置")
    g_WinSwitchGui.SetFont("s10", "Microsoft YaHei UI")
    g_WinSwitchGui.MarginX := 16
    g_WinSwitchGui.MarginY := 14

    g_WinSwitchGui.AddText("w680", "维护窗口切换项，保存后即时重新注册热键")
    g_WinSwitchListView := g_WinSwitchGui.AddListView("xm w680 h260 Grid", ["名称", "热键", "进程名", "启动目标"])

    btnAdd := g_WinSwitchGui.AddButton("xm w100 h30", "新增")
    btnAdd.OnEvent("Click", (*) => ShowWinSwitchItemEditor())

    btnEdit := g_WinSwitchGui.AddButton("x+8 w100 h30", "编辑")
    btnEdit.OnEvent("Click", (*) => EditSelectedWinSwitchItem())

    btnDelete := g_WinSwitchGui.AddButton("x+8 w100 h30", "删除")
    btnDelete.OnEvent("Click", (*) => DeleteSelectedWinSwitchItem())

    btnClose := g_WinSwitchGui.AddButton("x+268 w100 h30", "关闭")
    btnClose.OnEvent("Click", (*) => g_WinSwitchGui.Hide())

    g_WinSwitchGui.OnEvent("Close", (*) => g_WinSwitchGui.Hide())
    RefreshWinSwitchListView()
    g_WinSwitchGui.Show("w720 h380")
}

RefreshWinSwitchListView() {
    global WinSwitchItems, g_WinSwitchListView

    if !IsObject(g_WinSwitchListView)
        return

    g_WinSwitchListView.Delete()
    for item in WinSwitchItems {
        g_WinSwitchListView.Add(,
            item["name"],
            item["hotkey"],
            item["exe"],
            item["target"]
        )
    }

    loop 4
        g_WinSwitchListView.ModifyCol(A_Index, "AutoHdr")
}

EditSelectedWinSwitchItem() {
    global g_WinSwitchListView

    row := g_WinSwitchListView.GetNext()
    if row = 0 {
        MsgBox("请先选择要编辑的窗口切换项。", "提示", "Icon!")
        return
    }

    ShowWinSwitchItemEditor(row)
}

DeleteSelectedWinSwitchItem() {
    global WinSwitchItems, g_WinSwitchListView

    row := g_WinSwitchListView.GetNext()
    if row = 0 {
        MsgBox("请先选择要删除的窗口切换项。", "提示", "Icon!")
        return
    }

    name := WinSwitchItems[row]["name"] != "" ? WinSwitchItems[row]["name"] : WinSwitchItems[row]["exe"]
    result := MsgBox("确定删除窗口切换项吗？", "确认删除", "YesNo Icon?")
    if result = "No"
        return

    WinSwitchItems.RemoveAt(row)
    SaveWinSwitchAndRefresh()
}

ShowWinSwitchItemEditor(index := 0) {
    global WinSwitchItems, g_WinSwitchGui

    isEdit := index > 0
    item := isEdit ? WinSwitchItems[index] : Map("name", "", "hotkey", "", "exe", "", "target", "")

    editor := Gui("+Owner" . g_WinSwitchGui.Hwnd, isEdit ? "编辑窗口切换项" : "新增窗口切换项")
    editor.SetFont("s10", "Microsoft YaHei UI")
    editor.MarginX := 16
    editor.MarginY := 14

    editor.AddText("xm w90", "名称")
    nameEdit := editor.AddEdit("x120 yp w420", item["name"])

    editor.AddText("xm w90", "热键")
    hotkeyEdit := editor.AddEdit("x120 yp w420", item["hotkey"])

    editor.AddText("xm w90", "进程名")
    exeEdit := editor.AddEdit("x120 yp w420", item["exe"])

    editor.AddText("xm w90", "启动目标")
    targetEdit := editor.AddEdit("x120 yp w420", item["target"])

    browseBtn := editor.AddButton("x+8 yp w70 h28", "选择")
    browseBtn.OnEvent("Click", (*) => SelectWinSwitchTarget(targetEdit, exeEdit, nameEdit))

    saveBtn := editor.AddButton("xm w100 h30", "保存")
    saveBtn.OnEvent("Click", (*) => SaveWinSwitchItem(editor, index, nameEdit, hotkeyEdit, exeEdit, targetEdit))

    cancelBtn := editor.AddButton("x+8 w100 h30", "取消")
    cancelBtn.OnEvent("Click", (*) => editor.Destroy())

    editor.Show("w650 h250")
}

SelectWinSwitchTarget(targetEdit, exeEdit, nameEdit) {
    selectedFile := FileSelect("1", , "选择应用程序", "可执行文件 (*.exe)")

    if selectedFile = ""
        return

    targetEdit.Value := selectedFile
    SplitPath(selectedFile, &fileName, , , &nameNoExt)
    exeEdit.Value := fileName

    if nameEdit.Value = ""
        nameEdit.Value := nameNoExt
}

SaveWinSwitchItem(editor, index, nameEdit, hotkeyEdit, exeEdit, targetEdit) {
    global WinSwitchItems

    name := Trim(nameEdit.Value)
    hotkey := Trim(hotkeyEdit.Value)
    exe := Trim(exeEdit.Value)
    target := Trim(targetEdit.Value)

    if hotkey = "" || exe = "" || target = "" {
        MsgBox("热键、进程名、启动目标不能为空。", "配置不完整", "Icon!")
        return
    }

    item := Map("name", name, "hotkey", hotkey, "exe", exe, "target", target)

    if index > 0
        WinSwitchItems[index] := item
    else
        WinSwitchItems.Push(item)

    editor.Destroy()
    SaveWinSwitchAndRefresh()
}

SaveWinSwitchAndRefresh() {
    SaveConfig()

    try RegisterWinSwitchHotkeys()

    RefreshWinSwitchListView()
    TrayTip("窗口切换配置已保存", "AutoHotKey 脚本管理器", "Mute")
}

; ==================== 事件处理函数 ====================

; 更新托盘菜单的勾选状态
UpdateTrayMenuCheckState(moduleName) {
    global ModuleInfo, ModuleStates

    info := ModuleInfo[moduleName]
    menuText := info["name"]

    if ModuleStates[moduleName]
        A_TrayMenu.Check(menuText)
    else
        A_TrayMenu.Uncheck(menuText)
}

; 模块开关切换
OnModuleToggle(moduleName, checkboxCtrl) {
    global ModuleStates

    ModuleStates[moduleName] := checkboxCtrl.Value
    SaveConfig()

    if moduleName = "winSwitch"
        try RegisterWinSwitchHotkeys()

    if moduleName = "quickPhrase"
        try RegisterQuickPhraseHotkeys()

    ; 同时更新托盘菜单的勾选状态
    UpdateTrayMenuCheckState(moduleName)

    ; 提示
    status := ModuleStates[moduleName] ? "已启用" : "已禁用"
    info := ModuleInfo[moduleName]
    TrayTip(info["name"] . " " . status, "AutoHotKey 脚本管理器", "Mute")
}

; 全部启用
OnEnableAll() {
    global checkboxes

    EnableAllModules()
    try RegisterWinSwitchHotkeys()
    try RegisterQuickPhraseHotkeys()

    ; 更新 GUI UI
    for moduleName, cb in checkboxes {
        cb.Value := 1
        ; 同时更新托盘菜单
        UpdateTrayMenuCheckState(moduleName)
    }

    TrayTip("已启用所有模块", "AutoHotKey 脚本管理器", "Mute")
}

; 全部禁用
OnDisableAll() {
    global checkboxes

    result := MsgBox("确定要禁用所有模块吗？`n这将停止所有快捷键功能。", "确认", "YesNo Icon?")
    if result = "No"
        return

    DisableAllModules()
    try RegisterWinSwitchHotkeys()
    try RegisterQuickPhraseHotkeys()

    ; 更新 GUI UI
    for moduleName, cb in checkboxes {
        cb.Value := 0
        ; 同时更新托盘菜单
        UpdateTrayMenuCheckState(moduleName)
    }

    TrayTip("已禁用所有模块", "AutoHotKey 脚本管理器", "Mute")
}

; 显示模块详情
ShowModuleDetails(moduleName) {
    info := ModuleInfo[moduleName]

    ; 构建详情文本
    details := "模块名称: " . info["name"] . "`n`n"
    details .= "功能描述:`n" . info["description"] . "`n`n"
    details .= "快捷键列表:`n"

    for hotkey in info["hotkeys"] {
        details .= "  • " . hotkey . "`n"
    }

    MsgBox(details, info["name"] . " - 详细信息", "Icon?")
}

; 检测热键冲突
CheckHotkeyConflicts() {
    ; 收集所有已启用模块的热键
    hotkeyMap := Map()
    conflicts := []

    for moduleName in GetAllModules() {
        if !ModuleStates[moduleName]
            continue

        info := ModuleInfo[moduleName]

        for hotkeyDesc in info["hotkeys"] {
            ; 提取热键部分（冒号之前的部分）
            parts := StrSplit(hotkeyDesc, ":")
            if parts.Length < 1
                continue

            hotkey := Trim(parts[1])

            ; 跳过示例说明
            if InStr(hotkey, "→") or InStr(hotkey, "更多")
                continue

            ; 检查是否已存在
            if hotkeyMap.Has(hotkey) {
                conflicts.Push(hotkey . " (冲突模块: " . hotkeyMap[hotkey] . " 和 " . info["name"] . ")")
            } else {
                hotkeyMap[hotkey] := info["name"]
            }
        }
    }

    ; 显示结果
    if conflicts.Length = 0 {
        MsgBox("✓ 未检测到热键冲突！`n`n所有已启用模块的快捷键均不重复。", "冲突检测", "Icon64")
    } else {
        msg := "⚠ 检测到以下热键冲突：`n`n"
        for conflict in conflicts {
            msg .= "  • " . conflict . "`n"
        }
        msg .= "`n建议禁用其中一个模块以避免冲突。"
        MsgBox(msg, "冲突检测", "Icon!")
    }
}

; 导出配置
ExportConfig() {
    selectedFile := FileSelect("S16", A_Desktop . "\autohotkey-config.ini", "导出配置文件", "INI 配置文件 (*.ini)")

    if selectedFile = ""
        return

    try {
        FileCopy(ConfigFilePath, selectedFile, 1)
        MsgBox("配置导出成功！`n`n保存位置: " . selectedFile, "导出配置", "Icon64")
    } catch Error as err {
        MsgBox("配置导出失败！`n`n错误信息: " . err.Message, "错误", "IconX")
    }
}

; 导入配置
ImportConfig() {
    selectedFile := FileSelect("1", A_Desktop, "选择配置文件", "INI 配置文件 (*.ini)")

    if selectedFile = ""
        return

    result := MsgBox("确定要导入此配置吗？`n当前配置将被覆盖！`n`n文件: " . selectedFile, "确认导入", "YesNo Icon?")
    if result = "No"
        return

    try {
        FileCopy(selectedFile, ConfigFilePath, 1)
        LoadConfig()
        try RegisterWinSwitchHotkeys()

        ; 更新 UI
        global checkboxes
        for moduleName, cb in checkboxes {
            cb.Value := ModuleStates[moduleName] ? 1 : 0
        }

        MsgBox("配置导入成功！`n模块状态已更新。", "导入配置", "Icon64")
    } catch Error as err {
        MsgBox("配置导入失败！`n`n错误信息: " . err.Message, "错误", "IconX")
    }
}

; 查看帮助信息
ShowHelpInfo() {
    helpText := "AutoHotkey 脚本管理器 - 使用帮助`n"
        . "`n【模块功能】`n"
        . "• VIM 导航模式：CapsLock 改造为修饰键，提供类 VIM 快捷键`n"
        . "• F 功能键映射：F1-F9 快捷键映射系统`n"
        . "• Emoji 快速输入：快速输入常用 Emoji`n"
        . "• Markdown 标签快键：Markdown 格式快捷键`n"
        . "• 窗口快速切换：快速切换窗口`n"
        . "• 特殊符号输入：快速输入特殊符号`n"
        . "• 快捷短语输入：快速输入自定义短语`n"
        . "`n【快捷操作】`n"
        . "• 全部启用：启用所有模块`n"
        . "• 全部禁用：禁用所有模块`n"
        . "• 检测冲突：检测热键冲突`n"
        . "• 窗口切换配置：管理窗口快速切换设置`n"
        . "• 快捷短语配置：管理自定义快捷短语`n"
        . "• 导出/导入配置：备份和恢复设置`n"
        . "• 重载脚本：重新加载配置文件`n"

    MsgBox(helpText, "帮助信息", "Icon?")
}

; 重载脚本
ReloadScript() {
    result := MsgBox("确定要重载脚本吗？`n所有配置将重新加载。", "确认", "YesNo Icon?")
    if result = "Yes"
        Reload()
}

; ==================== 快捷短语配置管理 ====================

ShowQuickPhraseConfigGui() {
    global g_QuickPhraseGui, g_QuickPhraseListView

    if IsObject(g_QuickPhraseGui) {
        try {
            RefreshQuickPhraseListView()
            g_QuickPhraseGui.Show()
            return
        }
    }

    g_QuickPhraseGui := Gui("+Resize", "快捷短语配置")
    g_QuickPhraseGui.SetFont("s10", "Microsoft YaHei UI")
    g_QuickPhraseGui.MarginX := 16
    g_QuickPhraseGui.MarginY := 14

    g_QuickPhraseGui.AddText("w680", "维护快捷短语项，保存后即时生效")
    g_QuickPhraseListView := g_QuickPhraseGui.AddListView("xm w680 h260 Grid", ["热键", "短语内容"])

    btnAdd := g_QuickPhraseGui.AddButton("xm w100 h30", "新增")
    btnAdd.OnEvent("Click", (*) => ShowQuickPhraseItemEditor())

    btnEdit := g_QuickPhraseGui.AddButton("x+8 w100 h30", "编辑")
    btnEdit.OnEvent("Click", (*) => EditSelectedQuickPhraseItem())

    btnDelete := g_QuickPhraseGui.AddButton("x+8 w100 h30", "删除")
    btnDelete.OnEvent("Click", (*) => DeleteSelectedQuickPhraseItem())

    btnClose := g_QuickPhraseGui.AddButton("x+268 w100 h30", "关闭")
    btnClose.OnEvent("Click", (*) => g_QuickPhraseGui.Hide())

    g_QuickPhraseGui.OnEvent("Close", (*) => g_QuickPhraseGui.Hide())
    RefreshQuickPhraseListView()
    g_QuickPhraseGui.Show("w720 h380")
}

RefreshQuickPhraseListView() {
    global QuickPhraseItems, g_QuickPhraseListView

    if !IsObject(g_QuickPhraseListView)
        return

    g_QuickPhraseListView.Delete()
    for item in QuickPhraseItems {
        ; 如果短语过长，截断显示
        phraseDisplay := item["phrase"]
        if StrLen(phraseDisplay) > 50
            phraseDisplay := SubStr(phraseDisplay, 1, 50) . "..."

        g_QuickPhraseListView.Add(,
            item["hotkey"],
            phraseDisplay
        )
    }

    loop 2
        g_QuickPhraseListView.ModifyCol(A_Index, "AutoHdr")
}

EditSelectedQuickPhraseItem() {
    global g_QuickPhraseListView

    row := g_QuickPhraseListView.GetNext()
    if row = 0 {
        MsgBox("请先选择要编辑的快捷短语。", "提示", "Icon!")
        return
    }

    ShowQuickPhraseItemEditor(row)
}

DeleteSelectedQuickPhraseItem() {
    global QuickPhraseItems, g_QuickPhraseListView

    row := g_QuickPhraseListView.GetNext()
    if row = 0 {
        MsgBox("请先选择要删除的快捷短语。", "提示", "Icon!")
        return
    }

    result := MsgBox("确定删除此快捷短语吗？", "确认删除", "YesNo Icon?")
    if result = "No"
        return

    QuickPhraseItems.RemoveAt(row)
    SaveQuickPhraseAndRefresh()
}

ShowQuickPhraseItemEditor(index := 0) {
    global QuickPhraseItems, g_QuickPhraseGui

    isEdit := index > 0
    item := isEdit ? QuickPhraseItems[index] : Map("hotkey", "", "phrase", "")

    editor := Gui("+Owner" . g_QuickPhraseGui.Hwnd, isEdit ? "编辑快捷短语" : "新增快捷短语")
    editor.SetFont("s10", "Microsoft YaHei UI")
    editor.MarginX := 16
    editor.MarginY := 14

    editor.AddText("xm w90", "热键")
    hotkeyEdit := editor.AddEdit("x120 yp w420", item["hotkey"])

    editor.AddText("xm w90", "短语")
    phraseEdit := editor.AddEdit("x120 yp w420 h150", item["phrase"])

    editor.AddText("xm cGray", "热键格式示例: Ctrl+1, Alt+Shift+A, Win+Z 等")

    btnSave := editor.AddButton("xm w100 h30", "保存")
    btnSave.OnEvent("Click", (*) => SaveQuickPhraseItem(editor, hotkeyEdit, phraseEdit, index))

    btnCancel := editor.AddButton("x+10 w100 h30", "取消")
    btnCancel.OnEvent("Click", (*) => editor.Destroy())

    editor.Show("w550 h350")
}

SaveQuickPhraseItem(editor, hotkeyEdit, phraseEdit, index) {
    global QuickPhraseItems

    hotkey := Trim(hotkeyEdit.Value)
    phrase := Trim(phraseEdit.Value)

    if hotkey = "" {
        MsgBox("请输入热键！", "错误", "IconX")
        return
    }

    if phrase = "" {
        MsgBox("请输入短语内容！", "错误", "IconX")
        return
    }

    if index > 0 {
        ; 编辑模式
        QuickPhraseItems[index]["hotkey"] := hotkey
        QuickPhraseItems[index]["phrase"] := phrase
    } else {
        ; 新增模式
        QuickPhraseItems.Push(Map("hotkey", hotkey, "phrase", phrase))
    }

    SaveQuickPhraseAndRefresh()
    editor.Destroy()
}

SaveQuickPhraseAndRefresh() {
    global g_QuickPhraseGui, QuickPhraseItems, ModuleStates

    SaveQuickPhraseConfig()
    UpdateQuickPhraseModuleInfo()
    RefreshQuickPhraseListView()

    ; 如果快捷短语模块已启用，重新注册热键
    if ModuleStates["quickPhrase"] {
        try RegisterQuickPhraseHotkeys()
    }

    TrayTip("快捷短语配置已保存", "AutoHotKey 脚本管理器", "Mute")
}
