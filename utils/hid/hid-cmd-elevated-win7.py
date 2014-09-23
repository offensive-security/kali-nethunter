#!/usr/bin/python
import sys
sys.path.append("/sdcard/files/modules/")
from keyseed import *

# pop up cmd
win7cmd_elevated()

# open up payload file

f = open("/sdcard/files/hid-cmd.conf", "rb")
try:
    byte = f.read(1)
    while byte != "":
        byte = f.read(1)
	findinlist(byte)

finally:
    f.close()


#Hit enter
enterb()

