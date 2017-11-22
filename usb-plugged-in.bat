@ECHO OFF


if exist "C:\Temp\usb-plugged-in-lock%1%2.txt" goto alreadyrunning

set /a randomnum=%RANDOM%
echo %randomnum%>C:\Temp\usb-plugged-in-lock%1%2.txt
REM title usb-plugged-in-%randomnum%.bat
timeout 2
set /p testisme= <C:\Temp\usb-plugged-in-lock%1%2.txt
echo %testisme%
echo %randomnum%
if not %testisme%==%randomnum% goto alreadyrunning

del C:\Temp\usb-plugged-in-lock%1%2.txt

set /a randomnum=%RANDOM%
echo %randomnum%>C:\Temp\usb-plugged-in-lock%1%2.txt
REM title usb-plugged-in-%randomnum%.bat
timeout 2
set /p testisme= <C:\Temp\usb-plugged-in-lock%1%2.txt
echo %testisme%
echo %randomnum%
if not %testisme%==%randomnum% goto alreadyrunning

set tasklist=%windir%\System32\tasklist.exe
set taskkill=%windir%\System32\taskkill.exe

goto :MAIN

goto :alreadyrunning

:STOPPROC
    set wasStopped=0
    set procFound=0
    set notFound_result=ERROR:
    set procName=%1
    for /f "usebackq" %%A in (`%taskkill% /F /IM %procName%`) do (
      if NOT %%A==%notFound_result% (set procFound=1)
    )
    if %procFound%==0 (
      echo The process was not running.
      goto :EOF
    )
    set wasStopped=1
    set ignore_result=INFO:
:CHECKDEAD
    "%windir%\system32\timeout.exe" 3 /NOBREAK
    for /f "usebackq" %%A in (`%tasklist% /nh /fi "imagename eq %procName%"`) do (
      if not %%A==%ignore_result% (goto :CHECKDEAD)
    )
    goto :EOF


:MAIN 

IF %1=="2833" (
  IF %2=="0330" (
    call :STOPPROC "MSIAfterburner.exe"
    timeout 2
    Start "" "C:\Program Files (x86)\MSI Afterburner\MSIAfterburner.exe" -profile5
    timeout 2
    call :STOPPROC "NiceHash Miner 2.exe"
    call :STOPPROC excavator.exe
    Start "" "C:\Program Files (x86)\MSI Afterburner\MSIAfterburner.exe" -profile5
    timeout 5
    call :STOPPROC "MSIAfterburner.exe"
    timeout 5
    del C:\Temp\usb-plugged-in-lock%1%2.txt
    exit
  )
) 

del C:\Temp\usb-plugged-in-lock%1%2.txt

:alreadyrunning
echo 'already running'
