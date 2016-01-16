#!/usr/bin/python
import os
import urllib2
import zipfile
import fnmatch
import shutil
import ConfigParser
import re
import argparse
import datetime

def copytree(src, dst):
	def shouldcopy(f):
		global IgnoredFiles
		for pattern in IgnoredFiles:
			if fnmatch.fnmatch(f, pattern):
				return
		return True

	for sdir, subdirs, files in os.walk(src):
		for d in subdirs:
			if not shouldcopy(d):
				subdirs.remove(d)
		ddir = sdir.replace(src, dst, 1)
		if not os.path.exists(ddir):
			os.makedirs(ddir)
			shutil.copystat(sdir, ddir)
		for f in files:
			if shouldcopy(f):
				sfile = os.path.join(sdir, f)
				dfile = os.path.join(ddir, f)
				if os.path.exists(dfile):
					os.remove(dfile)
				shutil.copy2(sfile, ddir)

def download(url, file_name):
	# Progress bar http://stackoverflow.com/a/22776
	f = open(file_name, 'wb')
	try:
		u = urllib2.urlopen(url)
		meta = u.info()
		file_size = int(meta.getheaders('Content-Length')[0])
		print 'Downloading: %s (%s bytes)' % (os.path.basename(file_name), file_size)
		file_size_dl = 0
		block_sz = 8192
		while True:
			file_buf = u.read(block_sz)
			if not file_buf:
				break
			file_size_dl += len(file_buf)
			f.write(file_buf)
			status = r"%10d  [%3.2f%%]" % (file_size_dl, file_size_dl * 100. / file_size)
			status = status + chr(8) * (len(status) + 1)
			print status,
		print('')
		print('Download OK: ' + file_name)
	except urllib2.HTTPError, e:
		print('HTTPError = ' + str(e.code))
	except urllib2.URLError, e:
		print('URLError = ' + str(e.reason))
	f.close()

def supersu(beta):
	def getdlpage(url):
		try:
			bOpener = urllib2.build_opener()
			bOpener.addheaders = [("User-agent", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.146 Safari/537.36")]
			pResponse = bOpener.open(url)
			return pResponse.geturl()

		except urllib2.HTTPError, e:
			print('HTTPError = ' + str(e.code))
		except urllib2.URLError, e:
			print('URLError = ' + str(e.reason))

	def extractsu(suzip):
		arch = {
			'armv7':os.path.join('boot-patcher', 'arch', 'armhf'),
			'arm64':os.path.join('boot-patcher', 'arch', 'arm64'),
			'x64':os.path.join('boot-patcher', 'arch', 'amd64')
		}
		libdir = {
			'armv7':'lib',
			'arm64':'lib64',
			'x64':'lib64'
		}

		try:
			with zipfile.ZipFile(suzip, 'r') as zf:
				for key, value in arch.iteritems():
					fin = key + '/supolicy'
					fout = os.path.join(value, 'system', 'xbin', 'supolicy')
					print('Extracting ' + fin + ' to ' + fout)
					shutil.copyfileobj(zf.open(fin), open(fout, 'wb'))
					fin = key + '/libsupol.so'
					fout = os.path.join(value, 'system', libdir[key], 'libsupol.so')
					print('Extracting ' + fin + ' to ' + fout)
					shutil.copyfileobj(zf.open(fin), open(fout, 'wb'))
		except:
			print('Unable to extract sepolicy patch from SuperSU zip')
			done()

	suzip = os.path.join('update', 'supersu', 'supersu.zip')

	# Remove previous supersu.zip
	if os.path.isfile(suzip):
		os.remove(suzip)

	if beta:
		surl = getdlpage('http://download.chainfire.eu/896/SuperSU/BETA-SuperSU-v2.66-20160103015024.zip')
	else:
		surl = getdlpage('http://download.chainfire.eu/supersu')

	if surl:
		download(surl + '?retrieve_file=1', suzip)
	else:
		done()

	# Extract supolicy and libsupol.so from SuperSU zip
	extractsu(suzip)

def allapps(checkforce):
	apps = {
		'BlueNMEA':'http://max.kellermann.name/download/blue-nmea/BlueNMEA-2.1.3.apk',
		'Hackerskeyboard':'https://f-droid.org/repo/org.pocketworkstation.pckeyboard_1038002.apk',
		'Drivedroid':'http://softwarebakery.com/apps/drivedroid/files/drivedroid-free-0.9.29.apk',
		'USBKeyboard':'https://github.com/pelya/android-keyboard-gadget/raw/master/USB-Keyboard.apk',
		'RFAnalyzer':'https://github.com/demantz/RFAnalyzer/raw/master/RFAnalyzer.apk',
		'Shodan':'https://github.com/PaulSec/Shodan.io-mobile-app/raw/master/io.shodan.app.apk',
		'RouterKeygen':'https://github.com/routerkeygen/routerkeygenAndroid/releases/download/v3.15.0/routerkeygen-3-15-0.apk',
		'cSploit-nightly':'http://rootbitch.cc/csploit/cSploit-nightly.apk'
	}

	app_path = os.path.join('update', 'data', 'app')

	if checkforce:
		print('Force redownloading all apps')

	try:
		for key, value in apps.iteritems():
			apkname = os.path.join(app_path, key + '.apk')

			# For force redownload, remove previous APK
			if checkforce and os.path.isfile(apkname):
				os.remove(apkname)

			# Only download apk if we don't have it already
			if not os.path.isfile(apkname):
				download(value, apkname)

		print('Finished downloading all apps')

	except:
		print('There was a problem downloading the apps')
		done()


def zip(src, dst):
	try:
		zf = zipfile.ZipFile(dst, 'w', zipfile.ZIP_DEFLATED)
		abs_src = os.path.abspath(src)
		for dirname, subdirs, files in os.walk(src):
			for filename in files:
				absname = os.path.abspath(os.path.join(dirname, filename))
				arcname = absname[len(abs_src) + 1:]
				print 'Zipping %s as %s' % (os.path.join(dirname, filename), arcname)
				zf.write(absname, arcname)
		zf.close()
	except IOError, e:
		print('Error: ' + str(e.reason))
		done()

def configfile(file_name, values):
	# Open file as read only and copy to string
	file_handle = open(file_name, 'r')
	file_string = file_handle.read()
	file_handle.close()

	# Replace values of variables
	for key, value in values.iteritems():
		# Quote value if not already quoted
		if not (value[0] == value[-1] and (value[0] == '"' or value[0] == "'")):
			value = '"%s"' % value

		file_string = (re.sub('^' + re.escape(key) + '=.*$', key + '=' + value, file_string, flags=re.M))

	# Open file as writable and save the updated values
	file_handle = open(file_name, 'w')
	file_handle.write(file_string)
	file_handle.close()

def setupkernel():
	global Config
	global Device
	global OS
	global LibDir

	out_path = os.path.join('tmp_out', 'boot-patcher')

	# Blindly copy directories
	print('Copying common files...')
	copytree('common', out_path)

	print('Copying ' + Arch + ' arch specific common files...')
	copytree(os.path.join('common', 'arch', Arch), out_path)

	print('Copying boot-patcher files...')
	copytree('boot-patcher', out_path)

	print('Copying ' + Arch + ' arch specific boot-patcher files...')
	copytree(os.path.join('boot-patcher', 'arch', Arch), out_path)

	# Set up variables in boot-patcher update-binary
	configfile(os.path.join(out_path, 'META-INF', 'com', 'google', 'android', 'update-binary'), {
		'kernel_string':Config.get(Device, 'kernelstring'),
		'kernel_author':Config.get(Device, 'author'),
		'kernel_version':Config.get(Device, 'version'),
		'device_names':Config.get(Device, 'devicenames')
	})

	# Set up variables in boot-patcher.sh
	configfile(os.path.join(out_path, 'boot-patcher.sh'), {
		'boot_block':Config.get(Device, 'block')
	})

	# Copy zImage from version/device to boot-patcher folder
	kernel_path = os.path.join('kernels', OS, Device)
	if os.path.exists(os.path.join(kernel_path, 'zImage')):
		shutil.copy(os.path.join(kernel_path, 'zImage'), os.path.join(out_path, 'zImage'))
	elif os.path.exists(os.path.join(kernel_path, 'zImage-dtb')):
		shutil.copy(os.path.join(kernel_path, 'zImage-dtb'), os.path.join(out_path, 'zImage'))
	else:
		print('Unable to find kernel zImage or zImage-dtb at: ' + kernel_path)
		exit(0)

	# Copy dtb.img if it exists
	dtb_location = os.path.join(kernel_path, 'dtb.img')
	if os.path.exists(dtb_location):
		print('Found DTB image at: ' + dtb_location)
		shutil.copy(dtb_location, os.path.join(out_path, 'dtb'))

	# Copy any init.d scripts
	initd_path = os.path.join(kernel_path, 'init.d')
	if os.path.exists(initd_path):
		print('Found additional init.d scripts at: ' + initd_path)
		copytree(initd_path, os.path.join(out_path, 'system', 'etc', 'init.d'))

	# Copy any modules
	modules_path = os.path.join(kernel_path, 'modules')
	if os.path.exists(modules_path):
		print('Found additional kernel modules at: ' + modules_path)
		copytree(modules_path, os.path.join(out_path, LibDir, 'modules'))

	# Copy any device specific firmware
	firmware_path = os.path.join(kernel_path, 'firmware')
	if os.path.exists(firmware_path):
		print('Found additional firmware binaries at: ' + firmware_path)
		copytree(firmware_path, os.path.join(out_path, 'system', 'etc', 'firmware'))

def setupupdate():
	global Arch

	out_path = 'tmp_out'

	# Blindly copy directories
	print('Copying common files...')
	copytree('common', out_path)

	print('Copying ' + Arch + ' arch specific common files...')
	copytree(os.path.join('common', 'arch', Arch), out_path)

	print('Copying update files...')
	copytree('update', out_path)

	print('Copying ' + Arch + ' arch specific update files...')
	copytree(os.path.join('update', 'arch', Arch), out_path)

def cleanup():
	if os.path.exists('tmp_out'):
		print('Removing temporary output directory')
		shutil.rmtree('tmp_out')

def done():
	cleanup()
	exit(0)

def main():
	global Config
	global Device
	global Arch
	global OS
	global LibDir
	global IgnoredFiles
	global TimeStamp

	IgnoredFiles = ['arch', 'placeholder', '.DS_Store', '.git*', '.idea']
	t = datetime.datetime.now()
	TimeStamp = "%04d%02d%02d_%02d%02d%02d" % (t.year, t.month, t.day, t.hour, t.minute, t.second)

	# Remove any existing builds that might be left
	cleanup()

	# Read devices.cfg, get device names
	try:
		Config = ConfigParser.ConfigParser()
		Config.read('devices.cfg')
		devicenames = Config.sections()
	except IOError:
		print('Error opening devices.cfg')
		exit(0)

	help_device = 'Allowed device names: \n'
	for device in devicenames:
		help_device += '    %s\n' % device

	parser = argparse.ArgumentParser(description='Kali NetHunter recovery flashable zip builder')
	parser.add_argument('--device', '-d', action='store', help=help_device)
	parser.add_argument('--kitkat', '-kk', action='store_true', help='Android 4.4.4')
	parser.add_argument('--lollipop', '-l', action='store_true', help='Android 5')
	parser.add_argument('--marshmallow', '-m', action='store_true', help='Android 6')
	parser.add_argument('--forcedown', '-f', action='store_true', help='Force redownloading')
	parser.add_argument('--uninstaller', '-u', action='store_true', help='Create an uninstaller')
	parser.add_argument('--kernel', '-k', action='store_true', help='Build kernel only')
	parser.add_argument('--nokernel', '-nk', action='store_true', help='Build without the kernel')
	parser.add_argument('--release', '-r', action='store', help='Specify NetHunter release version')

	args = parser.parse_args()

	if args.kernel and args.nokernel:
		print('You seem to be having trouble deciding whether you want the kernel installer or not')
		done()

	if args.forcedown:
		supersu(True) # True = SuperSU beta, False = SuperSU stable
		allapps(True)
		done()

	if args.device:
		if args.device in devicenames:
			Device = args.device
		else:
			print('Device %s not found devices.cfg' % args.device)
			done()
	elif not (args.device or args.uninstaller):
		print('No valid arguments supplied. Try -h or --help')
		done()

	# If we found a device, set architecture and parse android OS release
	if Device:
		Arch = Config.get(Device, 'arch')

		if Arch == 'armhf':
			LibDir = os.path.join('system', 'lib')
		elif Arch == 'arm64' or Arch == 'amd64':
			LibDir = os.path.join('system', 'lib64')
		else:
			print('Unknown device architecture: ' + Arch)
			done()

		i = 0
		if args.kitkat:
			OS = 'kitkat'
			i += 1
		if args.lollipop:
			OS = 'lollipop'
			i += 1
		if args.marshmallow:
			OS = 'marshmallow'
			i += 1
		if i == 0:
			print('Select a version: --kitkat, --lollipop, --marshmallow')
			done()
		elif i > 1:
			print('Select only one version: --kitkat, --lollipop, --marshmallow')
			done()

	# Build an uninstaller zip if --uninstaller is specified
	if args.uninstaller:
		if args.release:
			file_name = 'uninstaller-nethunter-' + args.release + '.zip'
		else:
			file_name = 'uninstaller-nethunter-' + TimeStamp + '.zip'

		zip('uninstaller', file_name)

		print('Created uninstaller: ' + file_name)

	# If no device is specified, we are done
	if not Device:
		done()

	# Download SuperSU if we can't find it
	if not os.path.isfile(os.path.join('update', 'supersu', 'supersu.zip')):
		supersu(True)

	# We only need the apps if we are building the full update installer
	if not args.kernel:
		allapps(False)

	# Don't set up the kernel installer if --nokernel is specified
	if not args.nokernel:
		setupkernel()

		# Build a kernel installer zip and exit if --kernel is specified
		if args.kernel:
			if args.release:
				file_name = 'kernel-nethunter-' + Device + '-' + OS + '-' + args.release + '.zip'
			else:
				file_name = 'kernel-nethunter-' + Device + '-' + OS + '-' + TimeStamp + '.zip'

			zip(os.path.join('tmp_out', 'boot-patcher'), file_name)

			print('Created kernel installer: ' + file_name)
			done()

	# Set up the update zip
	setupupdate()

	if args.release:
		file_name = 'update-nethunter-' + Device + '-' + OS + '-' + args.release + '.zip'
	else:
		file_name = 'update-nethunter-' + Device + '-' + OS + '-' + TimeStamp + '.zip'

	zip('tmp_out', file_name)

	print('Created full installer: ' + file_name)
	done()

if __name__ == "__main__":
	main()
