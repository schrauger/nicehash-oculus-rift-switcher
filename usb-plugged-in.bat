@ECHO OFF

REM only allow a single copy of the script at a time. usbdeview tends to fire this script multiple times.
if exist "C:\Temp\usb-plugged-in-lock%1%2.txt" goto alreadyrunning

set /a randomnum=%RANDOM%
echo %randomnum%>C:\Temp\usb-plugged-in-lock%1%2.txt

REM scripts can fire so close that they both create a file. therefore, use random numbers to overwrite the file, and wait. then read the file. if it's not the same random number this script saved, exit to let the other script run.
timeout 2
set /p testisme= <C:\Temp\usb-plugged-in-lock%1%2.txt
echo %testisme%
echo %randomnum%
if not %testisme%==%randomnum% goto alreadyrunning

del C:\Temp\usb-plugged-in-lock%1%2.txt

REM stupidly, batch random numbers aren't all that random. a script run twice within the same millisecond or so can get the same random number. after waiting 2 seconds from the previous step, though, each script seems to divert enough that a second call to a random number gets different results. therefore, run the same step again, saving the number to a lock file and reading it.
set /a randomnum=%RANDOM%
echo %randomnum%>C:\Temp\usb-plugged-in-lock%1%2.txt
timeout 2
set /p testisme= <C:\Temp\usb-plugged-in-lock%1%2.txt
echo %testisme%
echo %randomnum%
if not %testisme%==%randomnum% goto alreadyrunning

REM by this point, the script should be the only copy running.

set tasklist=%windir%\System32\tasklist.exe
set taskkill=%windir%\System32\taskkill.exe

goto :MAIN

:STOPPROC
REM this subroutine loops until the requested program is fully terminated.
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
REM if the vendor and device id are the rift, run our actions.
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
