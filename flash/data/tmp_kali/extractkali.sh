#!/sbin/sh
#
# extract kali - remove any previous folders
#
if [ -d "/data/local/kali-armhf" ]; then
	rm -rf /data/local/kali-armhf
fi
tar -jxvf /data/local/kalifs.tar.bz2 -C /data/local
rm /data/local/kalifs.tar.bz2