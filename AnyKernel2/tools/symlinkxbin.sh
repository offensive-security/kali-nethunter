#!/sbin/sh
# Symlink xbin
DATA="/data/local/nhsystem/xbin"
SYSTEM="/system/xbin"

# Make sure we are mounted
/sbin/busybox mount /data
/sbin/busybox mount /system

# Make folder
mkdir -p $DATA

# Copy xbin files
cp -rf /tmp/anykernel/system/xbin/* $DATA

# Create symbolic links
ln -s $DATA/* $SYSTEM