﻿; 注意：程序必须先安装到 install 目录下，本文件与 install 在同级目录下。

; HM NIS Edit Wizard helper defines
!define PRODUCT_NAME "ChineseChessControl"
!define PRODUCT_VERSION "v2.0.8"
!define PRODUCT_PUBLISHER "Kang Lin (kl222@126.com)"
!define PRODUCT_WEB_SITE "https://github.com/KangLin/${PRODUCT_NAME}"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\${PRODUCT_NAME}.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKCU"

SetCompressor lzma

;InstType "Full"
;InstType "Lite"
;InstType "Minimal"

; MUI 1.67 compatible ------
!include "MUI2.nsh"
!include "x64.nsh"

;Include installation of redistributable files.
!include ".\InstallRedistributables.nsh"

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON "install\Chess.ICO"
!define MUI_UNICON "install\Chess.ICO"

; Language Selection Dialog Settings
!define MUI_LANGDLL_REGISTRY_ROOT "${PRODUCT_UNINST_ROOT_KEY}"
!define MUI_LANGDLL_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
!define MUI_LANGDLL_REGISTRY_VALUENAME "NSIS:Language"

; Welcome page
!insertmacro MUI_PAGE_WELCOME
; License page
!insertmacro MUI_PAGE_LICENSE "install\LICENSE.md"
; Components page
!insertmacro MUI_PAGE_COMPONENTS
; Directory page
!insertmacro MUI_PAGE_DIRECTORY
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES
; Finish page
!define MUI_FINISHPAGE_SHOWREADME
!define MUI_FINISHPAGE_SHOWREADME_Function InstallChineseChessControl
!define MUI_FINISHPAGE_SHOWREADME_TEXT "Install chinese chess control"
!insertmacro MUI_PAGE_FINISH
; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; Language files
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "SimpChinese"

LangString LANG_PRODUCT_NAME ${LANG_ENGLISH} "Chinese chess control"
LangString LANG_PRODUCT_NAME ${LANG_SIMPCHINESE} "中国象棋控件"

LangString LANG_UNINSTALL_CONFIRM ${LANG_ENGLISH} "Thank you very much! $(^Name) has been successfully removed."
LangString LANG_UNINSTALL_CONFIRM ${LANG_SIMPCHINESE} "非常感谢您的使用！ $(^Name) 已成功地从您的计算机中移除。"

LangString LANG_REMOVE_COMPONENT ${LANG_ENGLISH} "You sure you want to completely remove $ (^ Name), and all of its components?"
LangString LANG_REMOVE_COMPONENT ${LANG_SIMPCHINESE} "你确实要完全移除 $(^Name) ，其及所有的组件？"

LangString LANG_DIRECTORY_PERMISSION ${LANG_ENGLISH} "Don't directory permission"
LangString LANG_DIRECTORY_PERMISSION ${LANG_SIMPCHINESE} "无目录访问权限"

; MUI end ------

Name "$(LANG_PRODUCT_NAME) ${PRODUCT_VERSION}"
Caption "$(LANG_PRODUCT_NAME) ${PRODUCT_VERSION}"
OutFile "${PRODUCT_NAME}_Setup_msvc@MSVC_VERSION@_@BUILD_ARCH@_${PRODUCT_VERSION}.exe"
InstallDir "$PROGRAMFILES\${PRODUCT_NAME}"
;InstallDirRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_DIR_REGKEY}" ""

ShowInstDetails show
ShowUnInstDetails show
RequestExecutionLevel admin

; Install vc runtime
Function InstallVC
   Push $R0
   ClearErrors
   ReadRegDword $R0 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{FF66E9F6-83E7-3A3E-AF14-8DE9A809A6A4}" "Version"

   ; check register
   IfErrors 0 VSRedistInstalled
   Exec "$INSTDIR\bin\vcredist_x86.exe /q /norestart"
   StrCpy $R0 "-1"

VSRedistInstalled:
  ;MessageBox MB_OK  "Vcredist_x86.exe is installed"
  Exch $R0
  Delete "$INSTDIR\bin\vcredist_x86.exe"
FunctionEnd

Function InstallVC64
    Push $R0
    ClearErrors
    ReadRegDword $R0 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{FF66E9F6-83E7-3A3E-AF14-8DE9A809A6A4}" "Version"
    
    ; check register
    IfErrors 0 VSRedistInstalled
    Exec "$INSTDIR\bin\vcredist_x64.exe /q /norestart"
    StrCpy $R0 "-1"
    
    VSRedistInstalled:
    ;MessageBox MB_OK  "Vcredist_x64.exe is installed"
    Exch $R0
    Delete "$INSTDIR\bin\vcredist_x64.exe"
FunctionEnd

Function InstallRuntime
    IfFileExists "$INSTDIR\bin\vcredist_x64.exe" 0 +2
    call InstallVC64
    IfFileExists "$INSTDIR\bin\vcredist_x86.exe" 0 +2
    call InstallVC

    IntFmt $MSVC_VERSION "%u" @MSVC_VERSION@
    call InstallRedistributables
FunctionEnd

Function DirectoryPermissionErrorBox
   StrCpy $1 "${LANG_DIRECTORY_PERMISSION}"
     MessageBox MB_ICONSTOP $1 
       Abort
FunctionEnd

Var UNINSTALL_PROG
Var OLD_PATH
Function .onInit  
  !insertmacro MUI_LANGDLL_DISPLAY
  ClearErrors
  ReadRegStr $UNINSTALL_PROG ${PRODUCT_UNINST_ROOT_KEY} ${PRODUCT_UNINST_KEY} "UninstallString"
  IfErrors  done

  ;https://blog.csdn.net/u012896330/article/details/55517461
  CopyFiles $UNINSTALL_PROG $TEMP
  StrCpy $OLD_PATH $UNINSTALL_PROG -10
  ExecWait '"$TEMP/uninst.exe" /S _?=$OLD_PATH' $0
  DetailPrint "uninst.exe returned $0"
  Delete "$TEMP/uninst.exe"

done:
FunctionEnd

Section "${PRODUCT_NAME}" SEC01
  SetOutPath "$INSTDIR"
  IfFileExists "$INSTDIR\*.*" +2 0
  call DirectoryPermissionErrorBox
  SetOverwrite ifnewer
  File /r "install\*"
  ;SetShellVarContext all
  
  ;SetShellVarContext current
  call InstallRuntime
SectionEnd

Section -AdditionalIcons
  CreateDirectory "$SMPROGRAMS\${PRODUCT_NAME}"

  CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\Uninstall.lnk" "$INSTDIR\uninst.exe"
  IfFileExists "$INSTDIR\bin\ChineseChessApp.exe" 0 +2
    CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\ChineseChess.lnk" "$INSTDIR\bin\ChineseChessApp.exe"
  IfFileExists "$INSTDIR\bin\ChineseChessMfcApp.exe" 0 +2
    CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\ChineseChessMfcApp.lnk" "$INSTDIR\bin\ChineseChessMfcApp.exe"
  WriteIniStr "$INSTDIR\${PRODUCT_NAME}.url" "InternetShortcut" "URL" "${PRODUCT_WEB_SITE}"
  CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\Website.lnk" "$INSTDIR\${PRODUCT_NAME}.url"
SectionEnd

Section -Post
  WriteUninstaller "$INSTDIR\uninst.exe"

  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_DIR_REGKEY}" "Path" "$INSTDIR\"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
SectionEnd

; Section descriptions
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC01} "$(LANG_PRODUCT_NAME)"
!insertmacro MUI_FUNCTION_DESCRIPTION_END

Function InstallChineseChessControl
    ExecWait 'regsvr32.exe /c "$INSTDIR\bin\ChineseChessActiveX.ocx"' $0
    DetailPrint 'regsvr32.exe /s /c "$INSTDIR\bin\ChineseChessActiveX.ocx" returned $0'
    ; MessageBox MB_OK 'regsvr32.exe /s /c "$INSTDIR\bin\ChineseChessActiveX.ocx" returned $0'
FunctionEnd

Function un.onUninstSuccess
  ;HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "$(LANG_UNINSTALL_CONFIRM)"
FunctionEnd

Function un.onInit
  !insertmacro MUI_UNGETLANGUAGE
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "$(LANG_REMOVE_COMPONENT)" IDYES +2
  Abort
FunctionEnd

Section Uninstall
  ExecWait 'regsvr32.exe /s /u "$INSTDIR\bin\ChineseChessActiveX.ocx"' $0
  ;SetShellVarContext all
  RMDir /r "$SMPROGRAMS\${PRODUCT_NAME}"
  SetOutPath "$SMPROGRAMS"
  Delete "$DESKTOP\$(LANG_PRODUCT_NAME).lnk"
  RMDIR /r "$INSTDIR"
  ;SetShellVarContext current
  
  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  ;DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_DIR_REGKEY}"
  DeleteRegValue  ${PRODUCT_UNINST_ROOT_KEY} "Software\Microsoft\Windows\CurrentVersion\Run" "${PRODUCT_NAME}"
  
  ;SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment"
  ;SetAutoClose true
SectionEnd
