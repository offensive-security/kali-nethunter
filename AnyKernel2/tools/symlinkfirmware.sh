#!/sbin/sh
# Save /system space by hosting firmware in /data/local/nhsystem/firmware
# Then symlinking
DATA="/data/local/nhsystem/firmware"
SYSTEM="/system/etc/firmware/"

# Make sure we are mounted
/sbin/busybox mount /data
/sbin/busybox mount /system

# Make folder
mkdir -p $DATA

# Copy firmware
cp -rf /tmp/anykernel/system/etc/firmware/* $DATA

# Create symbolic links
ln -s $DATA/* $SYSTEM