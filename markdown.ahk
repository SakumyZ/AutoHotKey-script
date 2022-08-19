; --------------------
; Markdown 快速操作脚本
; --------------------
^1::
^2::
^3::
^4::
^5::
^6::
  numHashes := SubStr(A_ThisHotkey, 2) ; '^6'->'6'
  Markdown_title(numHashes)
return

Markdown_title(numHashes) {
  Clipboard := ""
  SendInput {Home}
  SendInput {SHIFT}+{End}
  sleep 200
  SendInput ^c
  ClipWait, 1
  text := Clipboard
  ;Msgbox text=%text%
  ;;pos := RegExMatch(clipboard, "^#{1,6}\s")
  text := RegExReplace(text, "^#{1,6}\s(.*)", "$1")
  SendInput {Del}
  SendInput, {Home}{# %numHashes%} %text%{End}
}