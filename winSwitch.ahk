VscodePath := "D:\SoftWare\Develop\Microsoft VS Code\Code.exe"
EdgePath := "explorer.exe shell:Appsfolder\Microsoft.MicrosoftEdge_8wekyb3d8bbwe!MicrosoftEdge"
WeComPath := "D:\SoftWare\Communication\WeCom\WXWork\WXWork.exe"

SwitchWindow(ahkExe, path) {
  ; 如果软件已启动，则切换
  IfWinActive, ahk_exe %ahkExe%
    WinMinimize, ahk_exe %ahkExe%
  else {
    WinActivate, ahk_exe %ahkExe%
  }
  ; 如果软件未启动，则启动软件
  IfWinNotExist, ahk_exe %ahkExe%
    Run %path%
  return
}

; 按 Alt + 1 切换 VScode 如果未启动，则启动
!1::
  SwitchWindow("Code.exe", VscodePath)
return

; 按 Alt + 2 切换 Edge 如果未启动，则启动
!2::
  SwitchWindow("msedge.exe", EdgePath)
return

; 按 Alt + 3 切换 企业微信 如果未启动，则启动
!3::
  SwitchWindow("WXWork.exe", WeComPath)
return