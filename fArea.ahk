#Include "./config.ahk"

; ==================== 全局状态 ====================
global FStatus := false          ; 功能层开关
global CapsLockPresses := 0      ; CapsLock 连击计数
global FLayerIndicatorGui := ""  ; 指示器 GUI 句柄
global FLayerIndicatorText := "" ; 指示器文本控件引用

; ==================== 发送功能键辅助 ====================
SendFunctionKey(functionKey) {
    if !GetKeyState("Alt")
        Send("{" functionKey "}")
    else
        Send("+{" functionKey "}")
}

SendFunctionOrFallback(functionKey, fallbackKey, useText := false) {
    global FStatus

    if FStatus {
        Send("{" functionKey "}")
        return
    }

    if useText
        SendText(fallbackKey)
    else
        Send("{" fallbackKey "}")
}

; ==================== 指示器 GUI 管理 ====================
; 创建指示器 GUI（仅首次调用时创建，后续只更新文案和位置）
EnsureIndicatorExists() {
    global FLayerIndicatorGui, FLayerIndicatorText
    if IsObject(FLayerIndicatorGui)
        return

    FLayerIndicatorGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x80000", "")
    FLayerIndicatorGui.SetFont("s14 Bold", "Microsoft YaHei UI")
    FLayerIndicatorGui.BackColor := "0x222222"
    FLayerIndicatorText := FLayerIndicatorGui.AddText("cFFFFFF x10 y5 w220 h30", "")
    ; 设置点击穿透
    hWnd := FLayerIndicatorGui.Hwnd
    DllCall("SetWindowLong", "Ptr", hWnd, "Int", -20, "Ptr", 0x80020)
    DllCall("SetLayeredWindowAttributes", "Ptr", hWnd, "Int", 0, "UChar", 230, "UInt", 1)
}

; 更新指示器：开启时跟随鼠标显示，关闭时隐藏
UpdateFLayerIndicator() {
    global FStatus, FLayerIndicatorGui, FLayerIndicatorText

    ; 关闭时隐藏
    if !FStatus {
        try FLayerIndicatorGui.Hide()
        return
    }

    EnsureIndicatorExists()

    ; 更新文案和背景色
    FLayerIndicatorText.Text := "功能层 ● 开启"
    FLayerIndicatorGui.BackColor := "0x1a3a5c"

    ; 跟随鼠标位置
    MouseGetPos(&x, &y)
    FLayerIndicatorGui.Show("x" (x + 20) " y" (y + 20) " NoActivate")
}

; ==================== 双击 CapsLock 检测 ====================
; 捕获 CapsLock 按下（~ 表示不阻断原本行为）
~CapsLock:: {
    global CapsLockPresses
    if CapsLockPresses > 0 {
        CapsLockPresses += 1
        return
    }
    CapsLockPresses := 1
    SetTimer(CheckCapsLockDoubleClick, -400) ; 400ms 判定窗口
}

CheckCapsLockDoubleClick() {
    global CapsLockPresses
    if CapsLockPresses = 2 {
        ToggleFLayer()
    }
    CapsLockPresses := 0
}

; 切换功能层状态
ToggleFLayer() {
    global FStatus
    FStatus := !FStatus

    ; 更新指示器
    UpdateFLayerIndicator()

    ; 托盘提示
    TrayTip("功能层 " . (FStatus ? "已开启" : "已关闭"), "双击 CapsLock 切换", "Mute")

    ; 重建托盘菜单以更新功能层状态文案
    try RebuildTrayMenu()
}

; 重建托盘菜单（供功能层切换时调用）
RebuildTrayMenu() {
    InitTrayMenu()
}

; ==================== 热键定义（受模块开关控制） ====================
#HotIf ModuleStates["fArea"]

; ----- CapsLock + 数字/符号 -> F1-F12 (始终生效) -----
CapsLock & 1:: SendFunctionKey("F1")
CapsLock & 2:: SendFunctionKey("F2")
CapsLock & 3:: SendFunctionKey("F3")
CapsLock & 4:: SendFunctionKey("F4")
CapsLock & 5:: SendFunctionKey("F5")
CapsLock & 6:: SendFunctionKey("F6")
CapsLock & 7:: SendFunctionKey("F7")
CapsLock & 8:: SendFunctionKey("F8")
CapsLock & 9:: SendFunctionKey("F9")
CapsLock & 0:: SendFunctionKey("F10")
CapsLock & -:: SendFunctionKey("F11")
CapsLock & +:: SendFunctionKey("F12")

; ----- 单键模式：功能层开启且无修饰键时，数字键直接发 F1-F12 -----
#HotIf ModuleStates["fArea"] && FStatus && !GetKeyState("LCtrl") && !GetKeyState("RCtrl") && !GetKeyState("LAlt") && !GetKeyState("RAlt") && !GetKeyState("LShift") && !GetKeyState("RShift") && !GetKeyState("LWin") && !GetKeyState("RWin")

1:: SendFunctionOrFallback("F1", "Numpad1")
2:: SendFunctionOrFallback("F2", "Numpad2")
3:: SendFunctionOrFallback("F3", "Numpad3")
4:: SendFunctionOrFallback("F4", "Numpad4")
5:: SendFunctionOrFallback("F5", "Numpad5")
6:: SendFunctionOrFallback("F6", "Numpad6")
7:: SendFunctionOrFallback("F7", "Numpad7")
8:: SendFunctionOrFallback("F8", "Numpad8")
9:: SendFunctionOrFallback("F9", "Numpad9")
0:: SendFunctionOrFallback("F10", "Numpad0")
-:: SendFunctionOrFallback("F11", "NumpadSub")

#HotIf
=:: SendFunctionOrFallback("F12", "=", true)

#HotIf  ; 结束条件