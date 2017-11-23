' First things first. Require 2 parameters.
if WScript.Arguments.Count <> 2 then

    WScript.Echo "Require VendorID and ProductID (both hex). We care about 2833 0330. Quitting."
    WScript.Quit
end if

' Check if it's the device we care about. If not, quit.
strVID = WScript.Arguments(0)
strPID = WScript.Arguments(1)
if strVID <> "2833" OR strPID <> "0330" then
    WScript.Echo "Not our device. Quitting."
    Wscript.Quit
end if

' Now that we know it's our device, do stuff to prevent multiple scripts from running at once.
' Create a global variable by creating a registry key.

Dim TypeLib
  
Set TypeLib = CreateObject("Scriptlet.TypeLib")
  
strOurGuid = TypeLib.Guid

Const HKEY_LOCAL_MACHINE = &H80000002
strComputer = "."
Set objRegistry = GetObject("winmgmts:\\" & strComputer & "\root\default:StdRegProv")
strKeyPath = "SOFTWARE\Script Center\USB Plugged In"
strValueName = "removed"

' Check the registry key
objRegistry.GetStringValue HKEY_LOCAL_MACHINE, strKeyPath, strValueName, strValue
If IsNull(strValue) Then
    ' No key exists. Likely this script has never been run before.
    Wscript.Echo "No value detected"
    objRegistry.CreateKey HKEY_LOCAL_MACHINE, strKeyPath
    strValue = strOurGuid
    objRegistry.SetStringValue HKEY_LOCAL_MACHINE, strKeyPath, strValueName, strValue
Else
    If strValue <> "ready" Then
        ' Another script is already running. Quit.
        Wscript.Echo "Another script is already running. Quitting."
        Wscript.Quit

    Else
        ' No other script is running. Lock the key down so that this one takes priority.
        Wscript.Echo "This script will now run."
        ' Wscript.Echo strValue
        strValue = strOurGuid 
        objRegistry.SetStringValue HKEY_LOCAL_MACHINE, strKeyPath, strValueName, strValue

        ' technically, another script might actually be running. so, wait 1 second, then read the registry value again. if it matches our key, we're good. otherwise, we lose and must quit.
        WScript.Sleep 1000
        objRegistry.GetStringValue HKEY_LOCAL_MACHINE, strKeyPath, strValueName, strValue
        if not StrComp(strValue, strOurGuid, vbTextCompare) then
            Wscript.Echo "We lost the race. Quitting."
            Wscript.Quit
        end if
    End If
End If


Dim oShell : Set oShell = CreateObject("WScript.Shell")


' Kill mining apps (shouldn't be running, but just in case, since we don't want them running twice)
oShell.Run "taskkill /f /im MSIAfterburner.exe", , True
oShell.Run "taskkill /f /im ""NiceHash Miner 2.exe"" ", , True
oShell.Run "taskkill /f /im excavator.exe", , True
oShell.Run "taskkill /f /im xmr-stak-cpu.exe", , True


' Set gpu overclock to mining. start miner.
oShell.Run """C:\Program Files (x86)\MSI Afterburner\MSIAfterburner.exe"" -profile2"
oShell.Run """C:\Program Files\NiceHash Miner 2\NiceHash Miner 2.exe"""

' WScript.Echo "Press [ENTER] to continue..."

' ' Read dummy input. This call will not return until [ENTER] is pressed.
' WScript.StdIn.ReadLine

' WScript.Echo "Done."

' Script is done. Set the global value to allow another script.
strValue = "ready"
objRegistry.SetStringValue HKEY_LOCAL_MACHINE, strKeyPath, strValueName, strValue
