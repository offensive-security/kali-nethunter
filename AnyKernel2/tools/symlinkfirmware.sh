#!/sbin/sh
# Save /system space by hosting firmware in /data/local/nhsystem/firmware
# Then symlinking
DATA="/data/local/nhsystem/firmware"
SYSTEM="/system/etc/firmware/"

# Make sure we are mounted
/sbin/busybox mount /data
/sbin/busybox mount /system

# Make folder
#mkdir -p $DATA

# Copy firmware
cp -rf /tmp/anykernel/system/etc/firmware/* $SYSTEM

# Symbolic links aren't working, we have to copy firmware!
#
#ln -s $DATA/* $SYSTEM