#!/usr/bin/python
import argparse
import sys
sys.path.append("/sdcard/files/modules/")
from keyseed import *

parser = argparse.ArgumentParser(description='Nethunter HID language/launcher')
parser.add_argument('--us', help='Select US keyboard mapping', action='store_true')
parser.add_argument('--fr', help='Select FR keyboard mapping', action='store_true')
parser.add_argument('--es', help='Select ES keyboard mapping', action='store_true')
parser.add_argument('--de', help='Select DE keyboard mapping', action='store_true')
parser.add_argument('--wincmd', '-w', help='Windows CMD', action='store_true')
parser.add_argument('--win7cmd', '-w7', help='Windows 7 CMD', action='store_true')
parser.add_argument('--win8cmd','-w8', help='Windows 8 CMD', action='store_true')

args = parser.parse_args()

if (args.us):
	locale='us'
elif (args.fr):
	locale='fr'
elif (args.de):
	locale='de'
elif (args.es):
	locale='es'

if (args.wincmd):
    wincmd(locale)
elif (args.win7cmd):
	win7cmd_elevated(byte, locale)
elif (args.win8cmd):
	win8cmd_elevated(byte, locale)

# open up payload file
f = open("/sdcard/files/hid-cmd.conf", "rb")
try:
    byte = f.read(1)
    while byte != "":
        byte = f.read(1)
	findinlist(byte, locale)

finally:
    f.close()

#Hit enter
enterb()



