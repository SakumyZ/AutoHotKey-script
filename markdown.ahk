; --------------------
; Markdown 快速操作脚本
; --------------------

#Include "./config.ahk"

; ==================== 热键定义（受模块开关控制） ====================
#HotIf ModuleStates["markdown"]

^1:: Markdown_title(1)
^2:: Markdown_title(2)
^3:: Markdown_title(3)
^4:: Markdown_title(4)
^5:: Markdown_title(5)
^6:: Markdown_title(6)

#HotIf  ; 结束条件

Markdown_title(numHashes) {
    Clipboard := ""
    SendInput("{Home}")
    SendInput("+{End}")
    Sleep(200)
    SendInput("^c")
    ClipWait(1)
    text := Clipboard
    ;Msgbox text=%text%
    ;;pos := RegExMatch(clipboard, "^#{1,6}\s")
    text := RegExReplace(text, "^#{1,6}\s(.*)", "$1")
    SendInput("{Del}")
    SendInput("{Home}" . Format("{# {1}}", numHashes) . " " . text . "{End}")
}
