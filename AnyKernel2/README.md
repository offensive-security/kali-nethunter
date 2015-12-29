AnyKernel 2.0 was written by osm0sis and this fork was heavily modified by Binkybear for building with Nethunter.

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
python build.py --forcedownload
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

* AnyKernel2 - What installs the kernel
* Aroma - The GUI based installer
* Edify - Scripting language for alternative to device that don't support Aroma

All devices are contained in devices.cfg.  If you want to add your own device you would add something like:

```sh
# Device Model for reference
[codename]
devicenames = codename codename2_if_it_has_one
block = /dev/block/WHATEVER/boot
aroma = True
```
Some devices have more then one codename like the OnePlus, or variants like the Nexus 7 2012/2013.  You should add multiple codenames to devicenames.  Getting the block location isn't to difficult, you can look at other kernels to see where they are installing there boot.img or you can also look at Cyanogenmod device repo in the BoardConfig.mk file.

Once you have a device added, you need to add a prebuilt kernel to the kernels folder.  It should be formatted as:

kernels/[version]/[codename]/zImage

If you have a zImage-dtb file from your finished kernel just rename it to zImage.

So really all you need is a zImage to build for a new device and the name/location of where to install.