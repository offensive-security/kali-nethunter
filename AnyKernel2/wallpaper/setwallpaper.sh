#!/sbin/sh
#
# Set the wallpaper based on device
#
chmod 777 /data/system/users/0/wallpaper
rm /data/system/users/0/wallpaper

# NEXUS 10

if [ $(getprop ro.product.device) == "manta" ]; then
	cp /tmp/wallpaper/mantawallpaper /data/system/users/0/wallpaper
	chmod 777 /data/system/users/0/wallpaper
	chown system:system /data/system/users/0/wallpaper
fi

# NEXUS 9

if [ $(getprop ro.product.device) == "flounder" ]; then
	cp /tmp/wallpaper/mantawallpaper /data/system/users/0/wallpaper
	chmod 777 /data/system/users/0/wallpaper
	chown system:system /data/system/users/0/wallpaper
fi

# NEXUS 7 2013

if [ $(getprop ro.product.device) == "flo" ]; then
	cp /tmp/wallpaper/flowallpaper /data/system/users/0/wallpaper
	chmod 777 /data/system/users/0/wallpaper
	chown system:system /data/system/users/0/wallpaper
fi

if [ $(getprop ro.product.device) == "deb" ]; then
	cp /tmp/wallpaper/flowallpaper /data/system/users/0/wallpaper
	chmod 777 /data/system/users/0/wallpaper
	chown system:system /data/system/users/0/wallpaper
fi

# NEXUS 4

if [ $(getprop ro.product.device) == "mako" ]; then
	cp /tmp/wallpaper/hammerheadwallpaper /data/system/users/0/wallpaper
	chmod 777 /data/system/users/0/wallpaper
	chown system:system /data/system/users/0/wallpaper
fi

# NEXUS 5

if [ $(getprop ro.product.device) == "hammerhead" ]; then
	cp /tmp/wallpaper/hammerheadwallpaper /data/system/users/0/wallpaper
	chmod 777 /data/system/users/0/wallpaper
	chown system:system /data/system/users/0/wallpaper
fi

# NEXUS 7 2012

if [ $(getprop ro.product.device) == "grouper" ]; then
	cp /tmp/wallpaper/grouperwallpaper /data/system/users/0/wallpaper
	chmod 777 /data/system/users/0/wallpaper
	chown system:system /data/system/users/0/wallpaper
fi

if [ $(getprop ro.product.device) == "tilapia" ]; then
	cp /tmp/wallpaper/grouperwallpaper /data/system/users/0/wallpaper
	chmod 777 /data/system/users/0/wallpaper
	chown system:system /data/system/users/0/wallpaper
fi

# NEXUS 9

if [ $(getprop ro.product.device) == "flounder" ]; then
	cp /tmp/wallpaper/flounderwallpaper /data/system/users/0/wallpaper
	chmod 777 /data/system/users/0/wallpaper
	chown system:system /data/system/users/0/wallpaper
fi

# NEXUS 6

if [ $(getprop ro.product.device) == "shamu" ]; then
	cp /tmp/wallpaper/shamuwallpaper /data/system/users/0/wallpaper
	chmod 777 /data/system/users/0/wallpaper
	chown system:system /data/system/users/0/wallpaper
fi

# ONE PLUS TWO

if [ $(getprop ro.product.device) == "OnePlus2" ] || [ $(getprop ro.product.device) == "oneplus2" ] || [ $(getprop ro.product.device) == "A2001" ] || [ $(getprop ro.product.device) == "A2003" ] || [ $(getprop ro.product.device) == "A2005" ]; then
	cp /tmp/hammerheadwallpaper /data/system/users/0/wallpaper
	chmod 777 /data/system/users/0/wallpaper
	chown system:system /data/system/users/0/wallpaper
fi

# ONE PLUS ONE - USES SAME SCREEN RESOLUTION AS NEXUS 5

if [ $(getprop ro.product.device) == "bacon" ] || [ $(getprop ro.product.device) == "A0001" ] || [ $(getprop ro.product.device) == "One" ] || [ $(getprop ro.product.device) == "OnePlus" ] || [ $(getprop ro.product.device) == "One A0001" ]; then
	cp /tmp/wallpaper/hammerheadwallpaper /data/system/users/0/wallpaper
	chmod 777 /data/system/users/0/wallpaper
	chown system:system /data/system/users/0/wallpaper
fi

# ALL OTHER DEVICES
#dumpsys window displays | /tmp/busybox/grep/grep init  
#dumpsys window | /tmp/busybox grep -i "Unrestricted"