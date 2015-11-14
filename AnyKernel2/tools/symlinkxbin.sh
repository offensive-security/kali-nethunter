#!/sbin/sh
# Save /system space by symliking xbin

DATA="/data/local/nhsystem/xbin"
SYSTEM="/system/xbin"

# Make sure we are mounted
/sbin/busybox mount /data
/sbin/busybox mount /system

mkdir -p $DATA

# HID-KEYBOARD (discovered symlinks don't work in chroot)
cp -rf /tmp/anykernel/system/xbin/hid-keyboard $SYSTEM
chmod 755 $SYSTEM/hid-keyboard
#ln -s $DATA/hid-keyboard $SYSTEM/hid-keyboard
