; ---------------
; VIM 操作映射脚本
; ---------------
SetCapsLockState, AlwaysOff

/*
* CapsLock + k 上移 ⬆
*/
CapsLock & k::
  if getkeystate("shift") = 1
    Send, ^{Up}
  else if getkeystate("alt") = 0
    Send, {Up}
  else
    Send, +{Up}
return
/*
* CapsLock + j 下移 ⬇
*/
CapsLock & j::
  if getkeystate("shift") = 1
    Send, ^{Down}
  else if getkeystate("alt") = 0
    Send, {Down}
  else
    Send, +{Down}
return

/*
* CapsLock + h 左移 ⬅
*/
CapsLock & h::
  if getkeystate("shift") = 1
    Send, ^{Left}
  else if getkeystate("alt") = 0
    Send, {Left}
  else
    Send, +{Left}
return

/*
* CapsLock + l 右移 ➡
*/
CapsLock & l::
  if getkeystate("shift") = 1
    Send, ^{Right}
  else if getkeystate("alt") = 0
    Send, {Right}
  else
    Send, +{Right}
return
/*
* CapsLock + a 移动到行首
*/
CapsLock & a::
  Send {Home}
return

/*
* CapsLock + I Home
*/
CapsLock & i::
  if getkeystate("shift") = 1
    Send, ^{Home}
  else if getkeystate("alt") = 0
    Send, {Home}
  else
    Send, +{Home}
return

/*
* CapsLock + M End
*/
CapsLock & m::
  if getkeystate("shift") = 1
    Send, ^{End}
  else if getkeystate("alt") = 0
    Send, {End}
  else
    Send, +{End}
return

/*
* CapsLock + U PageUp
*/
CapsLock & u::
  if getkeystate("alt") = 0
    Send, ^{PgUp}
  else
    Send, {PgUp}
return

/*
* CapsLock + N PageEnd
*/
CapsLock & n::
  if getkeystate("alt") = 0
    Send, ^{PgDn}
  else
    Send, {PgDn}
return

/*
* CapsLock + Back
*/
CapsLock & Backspace::
  if getkeystate("alt") = 0
    Send, {Delete}
  else
    Send, +{Delete}
return
