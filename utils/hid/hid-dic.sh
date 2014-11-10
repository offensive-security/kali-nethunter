#!/system/bin/sh

case $1 in
1) INPUT=/opt/dic/wordlist.txt;;
2) INPUT=/opt/dic/pinlist.txt;;
esac

hidkey=/usr/bin/hid-keyboard
while IFS= read -r -n1 char
do
        # Type one character at a time
        echo "$char" | $hidkey /dev/hidg0 keyboard
if [ "$char" == $'\n' ]; then
        # For each new line = return key
        echo enter | $hidkey /dev/hidg0 keyboard
fi
done < "$INPUT"