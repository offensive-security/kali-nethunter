bb=/data/local/bin/busybox
kill -9 `ps | $bb grep lighttpd | $bb grep -v grep | $bb awk '{print $2}'`  2>/dev/null
lighttpd -f /system/etc/lighttpd/lighttpd.conf
sleep 3
am start -a android.intent.action.VIEW -d http://127.0.0.1:8080