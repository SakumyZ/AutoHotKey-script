; ---------------
; VIM 操作映射脚本
; ---------------

#Include "./config.ahk"

SetCapsLockState("AlwaysOff")

SendMotionKey(keyName) {
    if GetKeyState("Shift")
        Send("^{" keyName "}")
    else if !GetKeyState("Alt")
        Send("{" keyName "}")
    else
        Send("+{" keyName "}")
}

SendCtrlUnlessAlt(keyName) {
    if !GetKeyState("Alt")
        Send("^{" keyName "}")
    else
        Send("{" keyName "}")
}

SendDeleteKey() {
    if !GetKeyState("Alt")
        Send("{Delete}")
    else
        Send("+{Delete}")
}

; ==================== 热键定义（受模块开关控制） ====================
#HotIf ModuleStates["vim"]

/*
* CapsLock + k 上移 ⬆
*/
CapsLock & k:: {
    SendMotionKey("Up")
}
/*
* CapsLock + j 下移 ⬇
*/
CapsLock & j:: {
    SendMotionKey("Down")
}

/*
* CapsLock + h 左移 ⬅
*/
CapsLock & h:: {
    SendMotionKey("Left")
}

/*
* CapsLock + l 右移 ➡
*/
CapsLock & l:: {
    SendMotionKey("Right")
}
/*
* CapsLock + a 移动到行首
*/
CapsLock & a:: {
    Send("{Home}")
}

/*
* CapsLock + I Home
*/
CapsLock & i:: {
    SendMotionKey("Home")
}

/*
* CapsLock + M End
*/
CapsLock & m:: {
    SendMotionKey("End")
}

/*
* CapsLock + U PageUp
*/
CapsLock & u:: {
    SendCtrlUnlessAlt("PgUp")
}

/*
* CapsLock + N PageEnd
*/
CapsLock & n:: {
    SendCtrlUnlessAlt("PgDn")
}

/*
* CapsLock + Back
*

#HotIf  ; 结束条件/
CapsLock & Backspace::{
  SendDeleteKey()
}
*/
