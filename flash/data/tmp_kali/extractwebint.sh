#!/sbin/sh
#
# extract web interface
# set permissions to sdcard
#
busybox=/tmp/busybox

$busybox tar -zxf /tmp/htdocs.tar.gz -C /sdcard/
$busybox chmod -R 0777 /sdcard/htdocs

$busybox cp -rf /tmp/files /sdcard/ 
$busybox chmod -R 0777 /sdcard/files
$busybox chmod -R 0777 /sdcard/kali-nh

rm -rf /data/local/kali-armhf/etc/dnsmasq.conf
cd /data/local/kali-armhf/etc/
ln -s /sdcard/files/dnsmasq.conf dnsmasq.conf

rm -rf /data/local/kali-armhf/etc/dhcp/dhcpd.conf
mkdir -p /data/local/kali-armhf/etc/dhcp/
cd /data/local/kali-armhf/etc/dhcp/
ln -s /sdcard/files/dhcpd.conf dhcpd.conf

cp /sdcard/files/powersploit-payload /data/local/kali-armhf/var/www/payload
chmod 755 /data/local/kali-armhf/var/www/payload

cd /data/local/kali-armhf/etc/hostapd
ln -s /sdcard/files/hostapd.conf hostapd.conf
