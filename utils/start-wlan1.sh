#!/bin/bash
#
# Check for wlan 1, if not up call it, then put in monitor mode
#
adaptor=$(ip addr | grep wlan1)

monitor_mode(){
monstat=$(grep "wlan1mon" /proc/net/dev)

echo -e "\e[92mStarting monitor mode\e[0m"

if [ -n "$monstat" ] ; then
	echo "Monitor mode already started."
else
	airmon-ng start wlan1
fi	
}

if [ -z "$adaptor" ]; then # First check for wlan 1
    ifconfig wlan1 up # Not up, so bring it
    sleep 2
    echo "Attempting to bring wlan1 up" # Still not seeing wlan 1, try again
    if [ -z "$adaptor" ]; then
    	echo "Still not detecting wlan1, please try plugging it in again."
    	sleep 5
    	clear
    	echo -e "\e[31mWLAN1: NOT FOUND\e[0m"
    	echo ""
    fi
else
	echo -e "\e[92mWLAN1: FOUND\e[0m"
	monitor_mode
fi