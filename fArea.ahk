FStatus := false

; ---------------
;  F区 操作映射脚本
; ---------------

/*
* CapsLock F1
*/
CapsLock & 1::
  if getkeystate("alt") = 0
    Send, {F1}
  else
    Send, +{F1}
return

/*
* CapsLock F2
*/
CapsLock & 2::
  if getkeystate("alt") = 0
    Send, {F2}
  else
    Send, +{F2}
return

/*
* CapsLock F3
*/
CapsLock & 3::
  if getkeystate("alt") = 0
    Send, {F3}
  else
    Send, +{F3}
return

/*
* CapsLock F4
*/
CapsLock & 4::
  if getkeystate("alt") = 0
    Send, {F4}
  else
    Send, +{F4}
return

/*
* CapsLock F5
*/
CapsLock & 5::
  if getkeystate("alt") = 0
    Send, {F5}
  else
    Send, +{F5}
return

/*
* CapsLock F6
*/
CapsLock & 6::
  if getkeystate("alt") = 0
    Send, {F6}
  else
    Send, +{F6}
return

/*
* CapsLock F7
*/
CapsLock & 7::
  if getkeystate("alt") = 0
    Send, {F7}
  else
    Send, +{F7}
return

/*
* CapsLock F8
*/
CapsLock & 8::
  if getkeystate("alt") = 0
    Send, {F8}
  else
    Send, +{F8}
return

/*
* CapsLock F9
*/
CapsLock & 9::
  if getkeystate("alt") = 0
    Send, {F9}
  else
    Send, +{F9}
return

/*
* CapsLock 0
*/
CapsLock & 0::
  if getkeystate("alt") = 0
    Send, {F10}
  else
    Send, +{F10}
return

/*
* CapsLock -
*/
CapsLock & -::
  if getkeystate("alt") = 0
    Send, {F11}
  else
    Send, +{F11}
return

/*
* CapsLock +
*/
CapsLock & +::
  if getkeystate("alt") = 0
    Send, {F12}
  else
    Send, +{F12}
return

; ---------------
;  F区 单键操作模式
; ---------------

; 按下两次 ESC 键开启 单键F区操作模式

~ESC::
  if esc_presses > 0 ; SetTimer 已经启动, 所以我们记录键击.
  {
    esc_presses += 1
    return
  }
  ; 否则, 这是新开始系列中的首次按下. 把次数设为 1 并启动
  ; 计时器：
  esc_presses = 1
  SetTimer, KeyEscDbClick, 400 ; 在 400 毫秒内等待更多的键击.
return

KeyEscDbClick:
  SetTimer, KeyEscDbClick, off
  if esc_presses = 1 ; 此键按下了一次.
  {
    return
  }
  else if esc_presses = 2 ; 此键按下了两次.
  {
    FStatus := !FStatus
  }

  esc_presses = 0
return

1::
  if (FStatus)
  {
    Send, {F1}
  }
  else
  {
    Send, {Numpad1}
  }
return

2::
  if (FStatus)
  {
    Send, {F2}
  }
  else
  {
    Send, {Numpad2}
  }
return

3::
  if (FStatus)
  {
    Send, {F3}
  }
  else
  {
    Send, {Numpad3}
  }
return

4::
  if (FStatus)
  {
    Send, {F4}
  }
  else
  {
    Send, {Numpad4}
  }
return

5::
  if (FStatus)
  {
    Send, {F5}
  }
  else
  {
    Send, {Numpad5}
  }
return

6::
  if (FStatus)
  {
    Send, {F6}
  }
  else
  {
    Send, {Numpad6}
  }
return

7::
  if (FStatus)
  {
    Send, {F7}
  }
  else
  {
    Send, {Numpad7}
  }
return

8::
  if (FStatus)
  {
    Send, {F8}
  }
  else
  {
    Send, {Numpad8}
  }
return

9::
  if (FStatus)
  {
    Send, {F9}
  }
  else
  {
    Send, {Numpad9}
  }
return

0::
  if (FStatus)
  {
    Send, {F10}
  }
  else
  {
    Send, {Numpad0}
  }
return

-::
  if (FStatus)
  {
    Send, {F11}
  }
  else
  {
    Send, {NumpadSub}
  }
return

=::
  if (FStatus)
  {
    Send, {F12}
  }
  else
  {
    Send, {Text}=
  }
return

