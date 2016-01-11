#!/sbin/sh
# Save /system space by hosting firmware in /data/local/nhsystem/firmware
# Then symlinking

#DATA="/data/local/nhsystem/firmware"
FIRMWARE="/system/etc/firmware"

# Make sure we are mounted
#/sbin/busybox mount /data
/sbin/busybox mount /system

# Make folder
#mkdir -p $DATA

# Copy firmware
cp -rf /tmp/boot-patcher/system/etc/firmware/* $FIRMWARE/

# Symbolic links aren't working, we have to copy firmware!
#
#ln -s $DATA/* $SYSTEM
