bb=/data/local/bin/busybox
kill -9 `ps | $bb grep php | $bb grep -v grep | $bb awk '{print $2}'`  2>/dev/null
/system/xbin/fcgiserver &
