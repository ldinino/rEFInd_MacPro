@echo off
color 0a
:: <nul set /p prints text without moving to the next line
<nul set /p "=Elevating to admin"

:: Use ping for a ~1 second delay (timeout is sometimes noisy)
ping -n 2 127.0.0.1 >nul
<nul set /p "=."

ping -n 2 127.0.0.1 >nul
<nul set /p "=."

ping -n 2 127.0.0.1 >nul
<nul set /p "=."

REM This section will elevate to admin
:init
 setlocal DisableDelayedExpansion
 set cmdInvoke=1
 set winSysFolder=System32
 set "batchPath=%~0"
 for %%k in (%0) do set batchName=%%~nk
 set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
 setlocal EnableDelayedExpansion

:checkPrivileges
  NET FILE 1>NUL 2>NUL
  if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
  if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)
  ECHO.

  ECHO Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
  ECHO args = "ELEV " >> "%vbsGetPrivileges%"
  ECHO For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
  ECHO args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
  ECHO Next >> "%vbsGetPrivileges%"

  if '%cmdInvoke%'=='1' goto InvokeCmd 

  ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
  goto ExecElevation

:InvokeCmd
  ECHO args = "/c """ + "!batchPath!" + """ " + args >> "%vbsGetPrivileges%"
  ECHO UAC.ShellExecute "%SystemRoot%\%winSysFolder%\cmd.exe", args, "", "runas", 1 >> "%vbsGetPrivileges%"

:ExecElevation
 "%SystemRoot%\%winSysFolder%\WScript.exe" "%vbsGetPrivileges%" %*
 exit /B

:gotPrivileges
 setlocal & cd /d %~dp0
 if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)
REM This section will elevate to admin
cls

:: <nul set /p prints text without moving to the next line
<nul set /p "=Changing boot manager to rEFInd"

:: Use ping for a ~1 second delay (timeout is sometimes noisy)
ping -n 2 127.0.0.1 >nul
<nul set /p "=."

ping -n 2 127.0.0.1 >nul
<nul set /p "=."

ping -n 2 127.0.0.1 >nul
<nul set /p "=."

ping -n 2 127.0.0.1 >nul
<nul set /p "=."

cls

bcdedit /set "{bootmgr}" path \EFI\refind\refind_x64.efi

echo Done. rEFInd is now the default boot manager. Restarting now...

pause
shutdown /r /t 0