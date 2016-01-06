Nethunter boot image patcher is based on AnyKernel 2.0 by osm0sis.
It was modified heavily by Binkybear and jcadduono for better compatibility when installing Nethunter.

This will generate an installer for Nethunter that can be flashed in TWRP.
# Instructions

Example building for the Nexus 5 (hammerhead):
```sh
python build.py -d hammerhead --lollipop
```
Building an installer without aroma:
```sh
python build.py -d hammerhead --lollipop --noaroma
```
Building the kernel only (useful for testing if kernel works):
```sh
python build.py -d hammerhead --marshmallow -k
```
Force download all third party apps:
```sh
python build.py --forcedown
```
Building the uninstaller:
```sh
python build.py --uninstaller
```
Show help:
```bash
python build.py -h
```

# How to add a new/unsupported device

There are really two/three components here:

* Boot-Patcher - This script patches the boot image (replacing the kernel) to support Nethunter
* Aroma - The GUI based installer
* Edify - A scripting language alternative for devices that don't support Aroma

All devices are contained in devices.cfg.  If you want to add your own device you would add something like:

```sh
# Device Model for reference
[codename]
author = "Your Name"
version = "1.0"
kernelstring = "Name of your kernel"
devicenames = codename codename2_if_it_has_one
block = /dev/block/WHATEVER/boot
aroma = True
```
Some devices have more then one codename like the OnePlus, or variants like the Nexus 7 2012/2013.  You should add multiple codenames to devicenames.  Getting the block location isn't to difficult, you can look at other kernels to see where they are installing there boot.img or you can also look at Cyanogenmod device repo in the BoardConfig.mk file.

Once you have a device added, you need to add a prebuilt kernel to the kernels folder.  It should be formatted as:

kernels/[version]/[codename]/zImage

If you have a zImage-dtb file from your finished kernel just rename it to zImage.

Some devices might require a separate zImage from dtb. You can place a dtb.img file in the same location as the zImage, and it will be automatically added to the installer.

So really all you need is a zImage and sometimes a dtb.img to build for a new device, as well as the name/location of where to install.
