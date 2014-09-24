#!/sbin/sh
#
# Set the wallpaper based on device
#
chmod 777 /data/system/users/0/wallpaper
rm /data/system/users/0/wallpaper

if [ $(getprop ro.product.device) == "manta" ]; then
	cp /tmp/mantawallpaper /data/system/users/0/wallpaper
	chmod 777 /data/system/users/0/wallpaper
	chown system:system /data/system/users/0/wallpaper
fi

if [ $(getprop ro.product.device) == "flo" ]; then
	cp /tmp/flowallpaper /data/system/users/0/wallpaper
	chmod 777 /data/system/users/0/wallpaper
	chown system:system /data/system/users/0/wallpaper
fi

if [ $(getprop ro.product.device) == "deb" ]; then
	cp /tmp/flowallpaper /data/system/users/0/wallpaper
	chmod 777 /data/system/users/0/wallpaper
	chown system:system /data/system/users/0/wallpaper
fi

if [ $(getprop ro.product.device) == "hammerhead" ]; then
	cp /tmp/hammerheadwallpaper /data/system/users/0/wallpaper
	chmod 777 /data/system/users/0/wallpaper
	chown system:system /data/system/users/0/wallpaper
fi

if [ $(getprop ro.product.device) == "grouper" ]; then
	cp /tmp/grouperwallpaper /data/system/users/0/wallpaper
	chmod 777 /data/system/users/0/wallpaper
	chown system:system /data/system/users/0/wallpaper
fi

if [ $(getprop ro.product.device) == "tilapia" ]; then
	cp /tmp/grouperwallpaper /data/system/users/0/wallpaper
	chmod 777 /data/system/users/0/wallpaper
	chown system:system /data/system/users/0/wallpaper
fi
