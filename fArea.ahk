#Include "./config.ahk"

FStatus := false
EscPresses := 0

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

; ---------------
;  F区 操作映射脚本
; ---------------

; ==================== 热键定义（受模块开关控制） ====================
#HotIf ModuleStates["fArea"]

/*
* CapsLock F1
*/
CapsLock & 1:: {
    SendFunctionKey("F1")
}

/*
* CapsLock F2
*/
CapsLock & 2:: {
    SendFunctionKey("F2")
}

/*
* CapsLock F3
*/
CapsLock & 3:: {
    SendFunctionKey("F3")
}

/*
* CapsLock F4
*/
CapsLock & 4:: {
    SendFunctionKey("F4")
}

/*
* CapsLock F5
*/
CapsLock & 5:: {
    SendFunctionKey("F5")
}

/*
* CapsLock F6
*/
CapsLock & 6:: {
    SendFunctionKey("F6")
}

/*
* CapsLock F7
*/
CapsLock & 7:: {
    SendFunctionKey("F7")
}

/*
* CapsLock F8
*/
CapsLock & 8:: {
    SendFunctionKey("F8")
}

/*
* CapsLock F9
*/
CapsLock & 9:: {
    SendFunctionKey("F9")
}

/*
* CapsLock 0
*/
CapsLock & 0:: {
    SendFunctionKey("F10")
}

/*
* CapsLock -
*/
CapsLock & -:: {
    SendFunctionKey("F11")
}

/*
* CapsLock +
*/
CapsLock & +:: {
    SendFunctionKey("F12")
}

; ---------------
;  F区 单键操作模式
; ---------------

; 按下两次 ESC 键开启 单键F区操作模式

~Esc:: {
    global EscPresses
    if EscPresses > 0 ; SetTimer 已经启动, 所以我们记录键击.
    {
        EscPresses += 1
        return
    }
    ; 否则, 这是新开始系列中的首次按下. 把次数设为 1 并启动
    ; 计时器：
    EscPresses := 1
    SetTimer(KeyEscDbClick, -400) ; 在 400 毫秒内等待更多的键击.
}

KeyEscDbClick() {
    global EscPresses, FStatus
    if EscPresses = 1 ; 此键按下了一次.
    {
        return
    }
    else if EscPresses = 2 ; 此键按下了两次.
    {
        FStatus := !FStatus
    }

    EscPresses := 0
}

#HotIf ModuleStates["fArea"] && !GetKeyState("Alt", "P") && !GetKeyState("Ctrl", "P") && !GetKeyState("Shift", "P") && !GetKeyState("LWin", "P") && !GetKeyState("RWin", "P")

1:: {
    SendFunctionOrFallback("F1", "Numpad1")
}

2:: {
    SendFunctionOrFallback("F2", "Numpad2")
}

3:: {
    SendFunctionOrFallback("F3", "Numpad3")
}

4:: {
    SendFunctionOrFallback("F4", "Numpad4")
}

5:: {
    SendFunctionOrFallback("F5", "Numpad5")
}

6:: {
    SendFunctionOrFallback("F6", "Numpad6")
}

7:: {
    SendFunctionOrFallback("F7", "Numpad7")
}

8:: {
    SendFunctionOrFallback("F8", "Numpad8")
}

9:: {
    SendFunctionOrFallback("F9", "Numpad9")
}

0:: {
    SendFunctionOrFallback("F10", "Numpad0")
}

-:: {
    SendFunctionOrFallback("F11", "NumpadSub")
}

#HotIf  ; 结束条件
=:: {
    SendFunctionOrFallback("F12", "=", true)
}
