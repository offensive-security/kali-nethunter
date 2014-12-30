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

def read_file(filename):
	try:
		f = open(filename, "rb")
		byte = f.read(1)
		while byte != "":
			byte = f.read(1)
			if byte:
				findinlist(byte, locale)
	finally:
		f.close()

# HID Command Options
if (args.wincmd):
	wincmd(locale)
	read_file(filename = "/sdcard/files/hid-cmd.conf")
elif (args.win7cmd):
	win7cmd_elevated(locale)
	read_file(filename = "/sdcard/files/hid-cmd.conf")
elif (args.win8cmd):
	win8cmd_elevated(locale)
	read_file(filename = "/sdcard/files/hid-cmd.conf")
elif (args.win8_met):
	win8cmd_elevated(locale)
	read_file(filename = "/sdcard/files/rev-met")
elif (args.revtcp):
	wincmd(locale)
	read_file(filename = "/sdcard/files/rev-tcp")
elif (args.revtcpwin7):
	win7cmd_elevated(locale)
	read_file(filename = "/sdcard/files/rev-tcp")
elif (args.revtcpwin8):
	win8cmd_elevated(locale)
	read_file(filename = "/sdcard/files/rev-tcp")

# All finished - Hit enter
enterb()
