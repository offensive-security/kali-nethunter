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
parser.add_argument('--sv', help='Select SV keyboard mapping', action='store_true')
parser.add_argument('--wincmd', '-w', help='Windows CMD', action='store_true')
parser.add_argument('--win7cmd', '-w7', help='Windows 7 CMD elevated', action='store_true')
parser.add_argument('--win8cmd','-w8', help='Windows 8 CMD elevated', action='store_true')
parser.add_argument('--win8_met','-w8met', help='Reverse Windows 8 CMD', action='store_true')
parser.add_argument('--revtcp','-rtcp', help='Reverse TCP Windows 8 CMD', action='store_true')
parser.add_argument('--revtcpwin7','-w7tcp', help='Reverse TCP Windows 7 CMD', action='store_true')
parser.add_argument('--revtcpwin8','-w8tcp', help='Reverse TCP Windows 8 CMD', action='store_true')

args = parser.parse_args()

# LANGUAGE OPTIONS

if (args.us):
	locale='us'
elif (args.fr):
	locale='fr'
elif (args.de):
	locale='de'
elif (args.es):
	locale='es'
elif (args.es):
	locale='sv'

# HID Command Options

if (args.wincmd):
	f = open("/sdcard/files/hid-cmd.conf", "rb")
    wincmd(locale)
elif (args.win7cmd):
	f = open("/sdcard/files/hid-cmd.conf", "rb")
	win7cmd_elevated(byte, locale)
elif (args.win8cmd):
	f = open("/sdcard/files/hid-cmd.conf", "rb")
	win8cmd_elevated(byte, locale)
elif (args.win8_met):
	f = open("/sdcard/files/rev-met", "rb")
	win8cmd_elevated(byte, locale)
elif (args.revtcp):
	f = open("/sdcard/files/rev-tcp", "rb")
	wincmd(locale)
elif (args.revtcpwin7):
	f = open("/sdcard/files/rev-tcp", "rb")
	win7cmd_elevated(byte, locale)
elif (args.revtcpwin8):
	f = open("/sdcard/files/rev-tcp", "rb")
	win8cmd_elevated(byte, locale)

try:
    byte = f.read(1)
    while byte != "":
        byte = f.read(1)
	findinlist(byte, locale)

finally:
    f.close()

#Hit enter
enterb()



