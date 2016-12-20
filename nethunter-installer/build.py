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
		for d in subdirs[:]:
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
	failed = False
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
	except urllib2.HTTPError, e:
		print('HTTPError = ' + str(e.code))
		failed = True
	except urllib2.URLError, e:
		print('')
		print('URLError = ' + str(e.reason))
		failed = True
	except:
		print('')
		failed = True
	else:
		print('')
		print('Download OK: ' + file_name)

	f.close()

	if failed:
		# We should delete partially downloaded file so the next try doesn't skip it!
		if os.path.isfile(file_name):
			os.remove(file_name)
		# Better debug what file cannot be downloaded.
		abort('There was a problem downloading the file "' + file_name  + '"')

def supersu(forcedown, beta):
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

	suzip = os.path.join('update', 'supersu.zip')

	# Remove previous supersu.zip if force redownloading
	if os.path.isfile(suzip):
		if forcedown:
			os.remove(suzip)
		else:
			print('Found SuperSU zip at: ' + suzip)

	if not os.path.isfile(suzip):
		if beta:
			surl = getdlpage('https://download.chainfire.eu/supersu-beta')
		else:
			surl = getdlpage('https://download.chainfire.eu/1016/SuperSU/UPDATE-SuperSU-v2.79-20161211114519.zip')

		if surl:
			download(surl + '?retrieve_file=1', suzip)
		else:
			abort('Could not retrieve download URL for SuperSU')

def allapps(forcedown):
	apps = {
		'Hackerskeyboard':'https://f-droid.org/repo/org.pocketworkstation.pckeyboard_1038002.apk',
		'Drivedroid':'https://softwarebakery.com/apps/drivedroid/files/drivedroid-free-0.10.28.apk',
		'OpenVPN':'https://f-droid.org/repo/de.blinkt.openvpn_141.apk',
		'USBKeyboard':'https://github.com/pelya/android-keyboard-gadget/raw/master/USB-Keyboard.apk',
		'RFAnalyzer':'https://github.com/demantz/RFAnalyzer/raw/master/RFAnalyzer.apk',
		'Shodan':'https://github.com/PaulSec/Shodan.io-mobile-app/raw/master/io.shodan.app.apk',
		'RouterKeygen':'https://github.com/routerkeygen/routerkeygenAndroid/releases/download/v3.15.0/routerkeygen-3-15-0.apk',
		'cSploit':'https://github.com/cSploit/android/releases/download/v1.6.6-rc.2/cSploit-release.apk'
	}

	app_path = os.path.join('update', 'data', 'app')

	if forcedown:
		print('Force redownloading all apps')

	for key, value in apps.iteritems():
		apk_name = key + '.apk'
		apk_path = os.path.join(app_path, apk_name)

		# For force redownload, remove previous APK
		if os.path.isfile(apk_path):
			if forcedown:
				os.remove(apk_path)
			else:
				print('Found %s at: %s' % (apk_name, apk_path))

		# Only download apk if we don't have it already
		if not os.path.isfile(apk_path):
			download(value, apk_path)

	print('Finished downloading all apps')

def rootfs(forcedown, fs_size):
	# global Arch
	Arch = 'armhf'

	fs_file = 'kalifs-' + Arch + '-' + fs_size + '.tar.xz'
	fs_path = os.path.join('rootfs', fs_file)

	fs_host = 'https://images.offensive-security.com/'
	fs_url = fs_host + 'kalifs-' + fs_size + '.tar.xz'

	# Uncomment to use build.nethunter.com kalifs builds (experimental)
	# fs_host = 'https://build.nethunter.com/'
	# fs_url = fs_host + 'kalifs/kalifs-latest/' + fs_file

	if forcedown:
		# For force redownload, remove previous rootfs
		print('Force redownloading Kali %s %s rootfs' % (Arch, fs_size))
		if os.path.isfile(fs_path):
			os.remove(fs_path)

	# Only download Kali rootfs if we don't have it already
	if os.path.isfile(fs_path):
		print('Found Kali %s %s rootfs at: %s' % (Arch, fs_size, fs_path))
	else:
		download(fs_url, fs_path)

def addrootfs(fs_size, dst):
	# global Arch
	Arch = 'armhf'

	fs_file = 'kalifs-' + Arch + '-' + fs_size + '.tar.xz'
	fs_path = os.path.join('rootfs', fs_file)

	try:
		zf = zipfile.ZipFile(dst, 'a', zipfile.ZIP_DEFLATED)
		print('Adding Kali rootfs archive to the installer zip...')
		zf.write(os.path.abspath(fs_path), fs_file)
		print('  Added: ' + fs_file)
		zf.close()
	except IOError, e:
		print('IOError = ' + e.reason)
		abort('Unable to add to the zip file')

def zip(src, dst):
	try:
		zf = zipfile.ZipFile(dst, 'w', zipfile.ZIP_DEFLATED)
		print('Creating ZIP file: ' + dst)
		abs_src = os.path.abspath(src)
		for dirname, subdirs, files in os.walk(src):
			for filename in files:
				absname = os.path.abspath(os.path.join(dirname, filename))
				arcname = absname[len(abs_src) + 1:]
				zf.write(absname, arcname)
				print('  Added: ' + arcname)
		zf.close()
	except IOError, e:
		print('IOError = ' + e.reason)
		abort('Unable to create the ZIP file')

def readkey(key, default=''):
	global Config
	global Device
	try:
		return Config.get(Device, key)
	except:
		return default

def configfile(file_name, values):
	# Open file as read only and copy to string
	file_handle = open(file_name, 'r')
	file_string = file_handle.read()
	file_handle.close()

	# Replace values of variables
	for key, value in values.iteritems():
		# Quote value if not already quoted
		if value and not (value[0] == value[-1] and (value[0] == '"' or value[0] == "'")):
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
	print('Kernel: Copying common files...')
	copytree('common', out_path)

	print('Kernel: Copying ' + Arch + ' arch specific common files...')
	copytree(os.path.join('common', 'arch', Arch), out_path)

	print('Kernel: Copying boot-patcher files...')
	copytree('boot-patcher', out_path)

	print('Kernel: Copying ' + Arch + ' arch specific boot-patcher files...')
	copytree(os.path.join('boot-patcher', 'arch', Arch), out_path)

	if Device == 'generic':
		# Set up variables in the kernel installer script
		print('Kernel: Configuring installer script for generic %s devices' % Arch)
		configfile(os.path.join(out_path, 'META-INF', 'com', 'google', 'android', 'update-binary'), {
			'generic':Arch
		})
		# There's nothing left to configure
		return

	# Set up variables in the kernel installer script
	print('Kernel: Configuring installer script for ' + Device)
	configfile(os.path.join(out_path, 'META-INF', 'com', 'google', 'android', 'update-binary'), {
		'kernel_string':readkey('kernelstring', 'NetHunter kernel'),
		'kernel_author':readkey('author', 'Unknown'),
		'kernel_version':readkey('version', '1.0'),
		'device_names':readkey('devicenames')
	})

	# Set up variables in boot-patcher.sh
	print('Kernel: Configuring boot-patcher script for ' + Device)
	configfile(os.path.join(out_path, 'boot-patcher.sh'), {
		'boot_block':readkey('block'),
		'ramdisk_compression':readkey('ramdisk', 'gzip')
	})

	device_path = os.path.join('devices', OS, Device)

	# Copy kernel image from version/device to boot-patcher folder
	kernel_images = [
		'zImage', 'zImage-dtb',
		'Image', 'Image-dtb',
		'Image.gz', 'Image.gz-dtb',
		'Image.lz4', 'Image.lz4-dtb'
	]
	kernel_found = False
	for kernel_image in kernel_images:
		kernel_location = os.path.join(device_path, kernel_image)
		if os.path.exists(kernel_location):
			print('Found kernel image at: ' + kernel_location)
			shutil.copy(kernel_location, os.path.join(out_path, kernel_image))
			kernel_found = True
			break
	if not kernel_found:
		abort('Unable to find kernel image at: ' + device_path)
		exit(0)

	# Copy dtb.img if it exists
	dtb_location = os.path.join(device_path, 'dtb.img')
	if os.path.exists(dtb_location):
		print('Found DTB image at: ' + dtb_location)
		shutil.copy(dtb_location, os.path.join(out_path, 'dtb.img'))

	# Copy any init.d scripts
	initd_path = os.path.join(device_path, 'init.d')
	if os.path.exists(initd_path):
		print('Found additional init.d scripts at: ' + initd_path)
		copytree(initd_path, os.path.join(out_path, 'system', 'etc', 'init.d'))

	# Copy any patch.d scripts
	patchd_path = os.path.join(device_path, 'patch.d')
	if os.path.exists(patchd_path):
		print('Found additional patch.d scripts at: ' + patchd_path)
		copytree(patchd_path, os.path.join(out_path, 'patch.d'))

	# Copy any ramdisk files
	ramdisk_path = os.path.join(device_path, 'ramdisk')
	if os.path.exists(ramdisk_path):
		print('Found additional ramdisk files at: ' + ramdisk_path)
		copytree(ramdisk_path, os.path.join(out_path, 'ramdisk-patch'))

	# Copy any modules
	modules_path = os.path.join(device_path, 'modules')
	if os.path.exists(modules_path):
		print('Found additional kernel modules at: ' + modules_path)
		copytree(modules_path, os.path.join(out_path, 'modules'))

	# Copy any device specific firmware
	firmware_path = os.path.join(device_path, 'firmware')
	if os.path.exists(firmware_path):
		print('Found additional firmware binaries at: ' + firmware_path)
		copytree(firmware_path, os.path.join(out_path, 'system', 'etc', 'firmware'))

	# Copy any /data/local folder files
	local_path = os.path.join(device_path, 'local')
	if os.path.exists(local_path):
		print('Found additional /data/local files at: ' + local_path)
		copytree(local_path, os.path.join(out_path, 'data', 'local'))

def setupupdate():
	global Arch

	out_path = 'tmp_out'

	# Blindly copy directories
	print('NetHunter: Copying common files...')
	copytree('common', out_path)

	print('NetHunter: Copying ' + Arch + ' arch specific common files...')
	copytree(os.path.join('common', 'arch', Arch), out_path)

	print('NetHunter: Copying update files...')
	copytree('update', out_path)

	print('NetHunter: Copying ' + Arch + ' arch specific update files...')
	copytree(os.path.join('update', 'arch', Arch), out_path)

	# Set up variables in update-binary script
	print('NetHunter: Configuring installer script for ' + Device)
	configfile(os.path.join(out_path, 'META-INF', 'com', 'google', 'android', 'update-binary'), {
		'supersu':readkey('supersu')
	})

def cleanup(domsg):
	if os.path.exists('tmp_out'):
		if domsg:
			print('Removing temporary build directory')
		shutil.rmtree('tmp_out')

def done():
	cleanup(False)
	exit(0)

def abort(err):
	print('Error: ' + err)
	cleanup(True)
	exit(0)

def setuparch():
	global Arch
	global LibDir

	if Arch == 'armhf' or Arch == 'i386':
		LibDir = os.path.join('system', 'lib')
	elif Arch == 'arm64' or Arch == 'amd64':
		LibDir = os.path.join('system', 'lib64')
	else:
		abort('Unknown device architecture: ' + Arch)

def main():
	global Config
	global Device
	global Arch
	global OS
	global LibDir
	global IgnoredFiles
	global TimeStamp

	supersu_beta = False

	devices_cfg = os.path.join('devices', 'devices.cfg')
	IgnoredFiles = ['arch', 'placeholder', '.DS_Store', '.git*', '.idea']
	t = datetime.datetime.now()
	TimeStamp = "%04d%02d%02d_%02d%02d%02d" % (t.year, t.month, t.day, t.hour, t.minute, t.second)

	# Remove any existing builds that might be left
	cleanup(True)

	# Read devices.cfg, get device names
	try:
		Config = ConfigParser.ConfigParser()
		Config.read(devices_cfg)
		devicenames = Config.sections()
	except:
		abort('Could not read %s! Maybe you need to run ./bootstrap.sh?' % devices_cfg)

	help_device = 'Allowed device names: \n'
	for device in devicenames:
		help_device += '    %s\n' % device

	parser = argparse.ArgumentParser(description='Kali NetHunter recovery flashable zip builder')
	parser.add_argument('--device', '-d', action='store', help=help_device)
	parser.add_argument('--kitkat', '-kk', action='store_true', help='Android 4.4.4')
	parser.add_argument('--lollipop', '-l', action='store_true', help='Android 5')
	parser.add_argument('--marshmallow', '-m', action='store_true', help='Android 6')
	parser.add_argument('--nougat', '-n', action='store_true', help='Android 7')
	parser.add_argument('--forcedown', '-f', action='store_true', help='Force redownloading')
	parser.add_argument('--uninstaller', '-u', action='store_true', help='Create an uninstaller')
	parser.add_argument('--kernel', '-k', action='store_true', help='Build kernel installer only')
	parser.add_argument('--nokernel', '-nk', action='store_true', help='Build without the kernel installer')
	parser.add_argument('--nosu', '-ns', action='store_true', help='Build without SuperSU installer')
	parser.add_argument('--nobrand', '-nb', action='store_true', help='Build without wallpaper or boot animation')
	parser.add_argument('--nofreespace', '-nf', action='store_true', help='Build without free space check')
	parser.add_argument('--generic', '-g', action='store', metavar='ARCH', help='Build a generic installer (modify ramdisk only)')
	parser.add_argument('--rootfs', '-fs', action='store', metavar='SIZE', help='Build with Kali chroot rootfs (full or minimal)')
	parser.add_argument('--release', '-r', action='store', metavar='VERSION', help='Specify NetHunter release version')

	args = parser.parse_args()

	if args.kernel and args.nokernel:
		abort('You seem to be having trouble deciding whether you want the kernel installer or not')
	if args.device and args.generic:
		abort('The device and generic switches are mutually exclusive')

	if args.device:
		if args.device in devicenames:
			Device = args.device
		else:
			abort('Device %s not found in %s' % (args.device, devices_cfg))
	elif args.generic:
		Arch = args.generic
		Device = 'generic'
		setuparch()
	elif args.forcedown:
		if not args.nosu:
			supersu(True, supersu_beta)
		allapps(True)
		done()
	elif not args.uninstaller:
		abort('No valid arguments supplied. Try -h or --help')

	# If we found a device, set architecture and parse android OS release
	if args.device:
		Arch = readkey('arch', 'armhf')
		setuparch()

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
		if args.nougat:
			OS = 'nougat'
			i += 1
		if i == 0:
			abort('Missing Android version. Available options: --kitkat, --lollipop, --marshmallow, --nougat')
		elif i > 1:
			abort('Select only one Android version: --kitkat, --lollipop, --marshmallow, --nougat')

		if args.rootfs and not (args.rootfs == 'full' or args.rootfs == 'minimal'):
			abort('Invalid Kali rootfs size. Available options: --rootfs full, --rootfs minimal')

	# Build an uninstaller zip if --uninstaller is specified
	if args.uninstaller:
		if args.release:
			file_name = 'uninstaller-nethunter-' + args.release + '.zip'
		else:
			file_name = 'uninstaller-nethunter-' + TimeStamp + '.zip'

		zip('uninstaller', file_name)

		print('Created uninstaller: ' + file_name)

	# If no device or generic arch is specified, we are done
	if not (args.device or args.generic):
		done()

	# We don't need the apps or SuperSU if we are only building the kernel installer
	if not args.kernel:
		allapps(args.forcedown)
		# Download SuperSU unless we don't want it
		if not args.nosu:
			supersu(args.forcedown, supersu_beta)

	# Download Kali rootfs if we are building a zip with the chroot environment included
	if args.rootfs:
		rootfs(args.forcedown, args.rootfs)

	# Set file name tag depending on the options chosen	
	file_tag = Device
	if args.device:
		file_tag += '-' + OS
	else:
		file_tag += '-' + Arch
	if args.nobrand and not args.kernel:
		file_tag += '-nobrand'
	if args.rootfs:
		file_tag += '-kalifs-' + args.rootfs
	if args.release:
		file_tag += '-' + args.release
	else:
		file_tag += '-' + TimeStamp

	# Don't include wallpaper or boot animation if --nobrand is specified
	if args.nobrand:
		IgnoredFiles.append('wallpaper')
		IgnoredFiles.append('bootanimation.zip')

	# Don't include free space script if --nofreespace is specified
	if args.nofreespace:
		IgnoredFiles.append('freespace.sh')

	# Don't set up the kernel installer if --nokernel is specified
	if not args.nokernel:
		setupkernel()

		# Build a kernel installer zip and exit if --kernel is specified
		if args.kernel:
			file_name = 'kernel-nethunter-' + file_tag + '.zip'

			zip(os.path.join('tmp_out', 'boot-patcher'), file_name)

			print('Created kernel installer: ' + file_name)
			done()

	# Don't include SuperSU if --nosu is specified
	if args.nosu:
		IgnoredFiles.append('supersu.zip')

	# Set up the update zip
	setupupdate()

	file_prefix = ''
	if not args.rootfs:
		file_prefix += 'update-'

	file_name = file_prefix + 'nethunter-' + file_tag + '.zip'

	zip('tmp_out', file_name)

	# Add the Kali rootfs archive if --rootfs is specified
	if args.rootfs:
		addrootfs(args.rootfs, file_name)

	print('Created NetHunter installer: ' + file_name)
	done()

if __name__ == "__main__":
	main()
