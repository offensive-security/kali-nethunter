#!/sbin/sh
# Save /system space by hosting modules in /data/local/nhsystem/modules
# Then symlinking
DATA="/data/local/nhsystem/modules"
SYSTEM="/system/lib/modules/"

# Make sure we are mounted
/sbin/busybox mount /data
/sbin/busybox mount /system

# Make folder
mkdir -p $DATA
mkdir -p $SYSTEM

# Copy firmware
cp -rf /tmp/anykernel/system/lib/modules/* $DATA

# Create symbolic links
ln -s $DATA/* $SYSTEM
chmod -R 755 $DATA
