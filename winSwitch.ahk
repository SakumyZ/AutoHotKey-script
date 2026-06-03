#Include "./config.ahk"

; 应用程序路径现在从 config.ahk 的全局变量读取
; VscodePath, EdgePath, WeComPath 在配置加载时初始化

SwitchWindow(ahkExe, launchTarget) {
    windowSelector := "ahk_exe " ahkExe

    ; AHK v2 中对不存在的窗口执行 WinActivate 会直接抛错。
    ; 先判断窗口是否存在，再决定是切换还是启动。
    if WinExist(windowSelector) {
        if WinActive(windowSelector)
            WinMinimize(windowSelector)
        else
            WinActivate(windowSelector)

        return
    }

    Run(launchTarget)
}

; ==================== 热键定义（受模块开关控制） ====================
#HotIf ModuleStates["winSwitch"]

; 按 Alt + 1 切换 VScode 如果未启动，则启动
!1:: {
    SwitchWindow("Code.exe", VscodePath)
}

; 按 Alt + 2 切换 Edge 如果未启动，则启动
!2:: {
    SwitchWindow("msedge.exe", EdgePath)
}

; 按 Alt + 3 切换 企业微信 如果未启动，则启动
!3:: {
    SwitchWindow("WXWork.exe", WeComPath)
}

#HotIf  ; 结束条件
