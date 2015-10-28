#!/system/bin/sh

TMPDIR=/data/local/tmp
mkdir -p $TMPDIR
UPSTREAM_NS=8.8.8.8
INTERFACE=rndis0

# Check required tools
if ! busybox ls > /dev/null;then
    echo No busybox found
    exit 1
fi
if ! dnsmasq -v > /dev/null;then
    echo No dnsmasq found
    exit 1
fi
if ! busybox test -e /sys/class/android_usb/android0/f_rndis;then
    echo "Device doesn't support RNDIS"
    exit 1
fi
if ! iptables -V;then
    echo iptables not found
    exit 1
fi


# We have to disable the usb interface before reconfiguring it
echo 0 > /sys/devices/virtual/android_usb/android0/enable
echo rndis > /sys/devices/virtual/android_usb/android0/functions
echo 224 > /sys/devices/virtual/android_usb/android0/bDeviceClass
echo 6863 > /sys/devices/virtual/android_usb/android0/idProduct
echo 1 > /sys/devices/virtual/android_usb/android0/enable

# Check whether it has applied the changes
cat /sys/devices/virtual/android_usb/android0/functions
cat /sys/devices/virtual/android_usb/android0/enable

# Wait until the interface actually exists
while ! busybox ifconfig $INTERFACE > /dev/null 2>&1;do
    echo Waiting for interface $INTERFACE
    busybox sleep 1
done

# Configure interface, firewall and packet forwarding
busybox ifconfig $INTERFACE inet 10.0.0.1 netmask 255.255.255.0 up
iptables -I FORWARD -i $INTERFACE -j ACCEPT
iptables -t nat -A POSTROUTING -j MASQUERADE
echo 1 > /proc/sys/net/ipv4/ip_forward

# dnsmasq -H /data/local/tmp/hosts -i $INTERFACE -R -S 8.8.8.8 -F 10.0.0.100,10.0.0.200 -x $TMPDIR/dnsmasq.pid
dnsmasq -C /sdcard/files/dnsmasq.conf -x $TMPDIR/dnsmasq.pid -i $INTERFACE
