#!/sbin/sh
#
# Set the wallpaper based on device
#
chmod 777 /data/system/users/0/wallpaper
rm /data/system/users/0/wallpaper

# NEXUS 10

if [ $(getprop ro.product.device) == "manta" ]; then
	cp /tmp/mantawallpaper /data/system/users/0/wallpaper
	chmod 777 /data/system/users/0/wallpaper
	chown system:system /data/system/users/0/wallpaper
fi

# NEXUS 9

if [ $(getprop ro.product.device) == "flounder" ]; then
	cp /tmp/mantawallpaper /data/system/users/0/wallpaper
	chmod 777 /data/system/users/0/wallpaper
	chown system:system /data/system/users/0/wallpaper
fi

# NEXUS 7 2013

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

# NEXUS 4

if [ $(getprop ro.product.device) == "mako" ]; then
	cp /tmp/hammerheadwallpaper /data/system/users/0/wallpaper
	chmod 777 /data/system/users/0/wallpaper
	chown system:system /data/system/users/0/wallpaper
fi

# NEXUS 5

if [ $(getprop ro.product.device) == "hammerhead" ]; then
	cp /tmp/hammerheadwallpaper /data/system/users/0/wallpaper
	chmod 777 /data/system/users/0/wallpaper
	chown system:system /data/system/users/0/wallpaper
fi

# NEXUS 7 2012

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

# NEXUS 9

if [ $(getprop ro.product.device) == "flounder" ]; then
	cp /tmp/flounderwallpaper /data/system/users/0/wallpaper
	chmod 777 /data/system/users/0/wallpaper
	chown system:system /data/system/users/0/wallpaper
fi

# NEXUS 6

if [ $(getprop ro.product.device) == "shamu" ]; then
	cp /tmp/shamuwallpaper /data/system/users/0/wallpaper
	chmod 777 /data/system/users/0/wallpaper
	chown system:system /data/system/users/0/wallpaper
fi

# ONE PLUS ONE - USES SAME SCREEN RESOLUTION AS NEXUS 5

if [ $(getprop ro.product.device) == "bacon" ] || [ $(getprop ro.product.device) == "A0001" ] || [ $(getprop ro.product.device) == "One" ] || [ $(getprop ro.product.device) == "OnePlus" ] || [ $(getprop ro.product.device) == "One A0001" ]; then
	cp /tmp/hammerheadwallpaper /data/system/users/0/wallpaper
	chmod 777 /data/system/users/0/wallpaper
	chown system:system /data/system/users/0/wallpaper
fi