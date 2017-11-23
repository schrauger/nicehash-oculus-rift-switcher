# nicehash-oculus-rift-switcher
Automatically start/stop nicehash mining when the Oculus Rift headset is plugged in or unplugged.

These two vbs files are meant to be run when the Oculus Rift USB cable is plugged in or unplugged. When the computer detects the headset being plugged in, the script will kill the nicehash miner and reset the MSI Afterburner profile to standard settings.

When the headset is unplugged, it will change the Afterburner settings to Profile 2, then start NiceHash miner.

## Purpose
I run a miner when I'm not actively using my gaming pc, and it's currently in a semi-headless state. It's hooked up to my TV, but the keyboard and mouse are put away. Therefore, it's easier to remotely login to the computer via TeamViewer if I need to change anything. Since that can be a hassle just to start playing virtual reality, I created this script to change between my two primary modes without needing to login.

I keep the Oculus Rift unplugged so that the screen doesn't stay on all the time. As it's an OLED screen, it does have a life expectency. I keep a cover on the headset to protect the lenses from dust and sunlight, but the cover triggers the sensor that detects if it's being actively worn or not. Therefore, I unplug the USB cable of the headset in order to prevent the screen from displaying anything while the cover is on.

Windows Event Manager does not log USB events, so I can't simply make a task that runs based on detection of the headset. 

Instead, I use the program USBDeview. It can be set to run a script when a device is plugged in and another when one is unplugged.

## Setup
These setup instructions may not be exact to your needs, but it should be sufficient to explain everything needed.

This presumes you already have MSI Afterburner installed and configured.

1. Download the two scripts from this repository.
2. Download [USBDeview](http://www.nirsoft.net/utils/usb_devices_view.html)
3. Set USBDeview to startup on reboot.
  * Make a shortcut in `C:\Users\YOURUSER\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\`
4. In USBDeview, go to `Options->Advanced Options`. Enable the options to execute a command for inserting and unplugging a USB device. Put in the path and script name for the two scripts you downloaded. Then add `"%vid_hex%" "%pid_hex"` after as parameters.
  * `cscript C:\Users\YOURUSER\Desktop\usb-plugged-in.vbs "%vid_hex%" "%pid_hex%"`
  * `cscript C:\Users\YOURUSER\Desktop\usb-plugged-out.vbs "%vid_hex%" "%pid_hex%"`
5. In MSI Afterburner, save your desired overclock settings for nicehash in profile #2.
6. Also in Afterburner, reset the settings to default, then save that in profile #5.
  * I couldn't find a command line argument to reset overclock settings to default, so I simply used profile 5 with defaults saved there instead.

Depending on where your miner and afterburner programs are located, you may have to modify the script.

You may need to set usbdeview to run as an administrator.
