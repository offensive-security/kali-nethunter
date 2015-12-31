# Kali Nethunter

Kali Linux NetHunter is a Android penetration testing platform for Nexus and OnePlus devices built on top of Kali Linux, which includes some special and unique features. Of course, you have all the usual Kali tools in NetHunter as well as the ability to get a full VNC session from your phone to a graphical Kali chroot, however the strength of NetHunter does not end there. We've incorporated some amazing features into the NetHunter OS which are both powerful and unique.

From pre-programmed HID Keyboard (Teensy) attacks, to BadUSB Man In The Middle attacks, to one-click MANA Evil Access Point setups, access to the Offensive Security Exploit Database... And yes, NetHunter natively supports wireless 802.11 frame injection with a variety of supported USB NICs.

For information and guides, visit the [Nethunter app wiki](https://github.com/offensive-security/nethunter-app/wiki)

## What is Nethunter?

Kali Linux Nethunter is not a ROM but is meant to be installed over an existing stock/factory image of Android.  It can be installed over some Cyanogenmod based ROMs.  It is heavily based on using custom kernels and only supports a select number of devices.

## Instructions

There are two seperate main parts Kali Linux Nethunter:

```bash
 |
 |- AnyKernel2 = This is where we build the update.zip installer for recovery mode
 |
 |- nethunter-fs = This is where we build the chroot.  You do not need to build unless you want a custom version
```

Each folder contains specific instructions on how to build for each device but here are the basic steps.

* Download 3rd party apps in AnyKernel2  folder (python build.py -f)
* Follow build instructions in AnyKernel2 README.md

Thu Dec 31 09:07:15 EST 2015
