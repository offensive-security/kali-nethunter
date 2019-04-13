#!/usr/bin/env python
import os
import requests
import zipfile
import fnmatch
import shutil
import ConfigParser
import re
import argparse
import datetime
import hashlib

dl_headers = {
	"User-Agent":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.51 Safari/537.36",
	"Accept-Encoding":"identity"
}

dl_supersu = {
	'beta': ['https://download.chainfire.eu/supersu-beta', False],
	'stable': ['https://download.chainfire.eu/1220/SuperSU/SR5-SuperSU-v2.82-SR5-20171001224502.zip', '62ee48420cacedee53b89503aa43b5449d07946fe7174ee03fc118c23f65ea988a94e5ba76dff5afd61c19fe9b23260c4cee8e293839babdf1b263ffaabb92f3'],
}

dl_apps = {
	'AndProx':
		['https://github.com/AndProx/AndProx/releases/download/v2.0.4/andprox-2.0.4.apk', 'acb121fd5440a324b6c0fb2bfea67838d5aaa01be8a5b7742a56dfff2026ee91afbae71d4a633fa4d374fe26b72b914d77644b41517e8d2dbf7d64fb1aa95a51'],
	'cSploit':
		['https://github.com/cSploit/android/releases/download/v1.6.6-rc.2/cSploit-release.apk', 'b841c4376836bcc9d23fbc18b40eed70e08018e8eebc6d2d0abad59da63e4b325ffe4d8a4bd36107af63ed20a59c6648d6c4bd1264044267c86693744b15fa75'],
	'Drivedroid':
		['https://drivedroid-versions.s3-eu-west-1.amazonaws.com/files/drivedroid-free-0.10.50.apk', '455354369d34dd59cdf71e50c02fd1dc969925f803fbc1c498467ac1b3b50b7a3b23dd22a3e60a5dbe61d7106c99106f92ef6a86c56775f01e42dfcd1837c198'],
	'Hackerskeyboard':
		['https://f-droid.org/repo/org.pocketworkstation.pckeyboard_1039003.apk', '8c861c7540e6eeb006070d0f2d80134e75637066591d705b987e164c3fe87521ed694ac844c945eb74449aff8723ff039f793b2e3743aac73865f74bb248edf5'],
	'Hijacker':
		['https://github.com/chrisk44/Hijacker/releases/download/v1.5-beta.8/Hijacker-release-v1.5-beta.8.apk', 'f9aad94faa8a78833dcc1da2702455fe106383a95cc46a25559ff398e3adb828828c5545d8754d982511a2718ea842c56c7ee8566c5973c65d88858e5b1288c1'],
	'Intercepter-NG':
		['https://github.com/intercepter-ng/intercepter-ng.github.io/raw/master/Intercepter-NG.2.1.apk', '66a12b8ff1022635071283acbbd4f41bceae092cfdc88cbc0f0c77a175c8f5ba5d7fc1703474e7ea6c24b5630b6c2c970ae62641f7924ec47b72956f47afd979'],
	'OpenVPN':
		['https://f-droid.org/repo/de.blinkt.openvpn_159.apk', 'a47200c972a6e98649f6a8f87e02c5b924b1c7915ef86698f1339a1ec82af3eab82e7ecf442a3b2f5ab5ded91b59b0943315133413b50a2c473d5f9ba8050695'],
	'RFAnalyzer':
		['https://github.com/demantz/RFAnalyzer/raw/version_1_13/RFAnalyzer.apk', '7793438b6fbe7288a0ca86de900f5f4e607168de8c97229d08d901c2424b0192bf9dc894f66439f59510c10fa26a26319a1b0d8ea276f6af927cebf677138230'],
	'RouterKeygen':
		['https://github.com/routerkeygen/routerkeygenAndroid/releases/download/v4.0.2/routerkeygen-4-0-2.apk', '0135bbeb371f616c3577e6932e67b6c22c5aff335c7d7570bf5d26f106eadb0cbf4eea12503726cb806d18794e1adc6f3cc934ea41ca5ef62a8c77a4702947da'],
	'Shodan':
		['https://github.com/PaulSec/Shodan.io-mobile-app/raw/v0.0.3-new/io.shodan.app.apk', 'a2ff39d8e7a86d8e0a14368fd278fb03212999b309bc102d39f76ff69ca2a373d3d62a95cea6dbee761ae81ff3daaf83846e49e8ccbf0760276d825493d08652'],
	'USBKeyboard': # Feb 3, 2015
		['https://github.com/pelya/android-keyboard-gadget/raw/7ea69c684aa1/USB-Keyboard.apk', '18bced7b339a67c48fe31698cb54063bce8f3dd9f7d7f23d9e5c619697e8da5ab08312cf9a2fa0e3f445a584485db23d1e4c27e3ffc1448551bbaf486ccb11e9'],
}

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

def download(url, file_name, verify_sha):
	try:
		u = requests.get(url, stream=True, headers=dl_headers)
		u.raise_for_status()
	except requests.exceptions.RequestException as e:
		abort(str(e))

	download_ok = False

	if u.headers.get('Content-Length'):
		file_size = int(u.headers['Content-Length'])
		print('Downloading: %s (%s bytes)' % (os.path.basename(file_name), file_size))
	else:
		file_size = 0
		print('Downloading: %s (unknown size)' % os.path.basename(file_name))

	sha = hashlib.sha512()
	f = open(file_name, 'wb')
	try:
		dl_bytes = 0
		for chunk in u.iter_content(chunk_size=8192):
			if not chunk:
				continue # Ignore empty chunks
			f.write(chunk)
			sha.update(chunk)
			dl_bytes += len(chunk)
			if file_size:
				status = r"%10d  [%3.2f%%]" % (dl_bytes, dl_bytes * 100. / file_size)
			else:
				status = r"%10d" % dl_bytes

			status = status + chr(8) * (len(status) + 1)
			print status,
		print
		download_ok = True
	except requests.exceptions.RequestException as e:
		print
		print('Error: ' + str(e))
	except KeyboardInterrupt:
		print
		print('Download cancelled')

	f.flush()
	os.fsync(f.fileno())
	f.close()

	if download_ok:
		sha = sha.hexdigest()
		print('SHA512: ' + sha)
		if verify_sha:
			print('Expect: ' + verify_sha)
			if sha == verify_sha:
				print('Hash matches: OK')
			else:
				download_ok = False
				print('Hash mismatch!')
		else:
			print('Warning: No SHA512 hash specified for verification!')

	if download_ok:
		print('Download OK: ' + file_name)
	else:
		# We should delete partially downloaded file so the next try doesn't skip it!
		if os.path.isfile(file_name):
			os.remove(file_name)
		# Better debug what file cannot be downloaded.
		abort('There was a problem downloading the file "' + file_name  + '"')

def supersu(forcedown, beta):
	global dl_supersu

	def getdlpage(url):
		try:
			u = requests.head(url, headers=dl_headers)
			return u.url;
		except requests.exceptions.ConnectionError as e:
			print('Connection error: ' + str(e))
		except requests.exceptions.RequestException as e:
			print('Error: ' + str(e))

	suzip = os.path.join('update', 'supersu.zip')

	# Remove previous supersu.zip if force redownloading
	if os.path.isfile(suzip):
		if forcedown:
			os.remove(suzip)
		else:
			print('Found SuperSU zip at: ' + suzip)

	if not os.path.isfile(suzip):
		if beta:
			surl = getdlpage(dl_supersu['beta'][0])
		else:
			surl = getdlpage(dl_supersu['stable'][0])

		if surl:
			if beta:
				download(surl + '?retrieve_file=1', suzip, dl_supersu['beta'][1])
			else:
				download(surl + '?retrieve_file=1', suzip, dl_supersu['stable'][1])
		else:
			abort('Could not retrieve download URL for SuperSU')

def allapps(forcedown):
	global dl_apps

	app_path = os.path.join('update', 'data', 'app')

	if forcedown:
		print('Force redownloading all apps')

	for key, value in dl_apps.iteritems():
		apk_name = key + '.apk'
		apk_path = os.path.join(app_path, apk_name)
		apk_url = value[0]
		apk_hash = value[1] if len(value) == 2 else False

		# For force redownload, remove previous APK
		if os.path.isfile(apk_path):
			if forcedown:
				os.remove(apk_path)
			else:
				print('Found %s at: %s' % (apk_name, apk_path))

		# Only download apk if we don't have it already
		if not os.path.isfile(apk_path):
			download(apk_url, apk_path, apk_hash)

	print('Finished downloading all apps')

def rootfs(forcedown, fs_size, nightly):
	global Arch

	# temporary hack until arm64 support is completed
	##if Arch == 'arm64':
	##	fs_arch = 'armhf'
	##else:
       	##      fs_arch = Arch
       	fs_arch = Arch

	fs_file = 'kalifs-' + fs_arch + '-' + fs_size + '.tar.xz'
	fs_path = os.path.join('rootfs', fs_file)

	if nightly:
		fs_host = 'https://build.nethunter.com/kalifs/kalifs-latest/'
	else:
		fs_host = 'https://images.offensive-security.com/'

	fs_url = fs_host + fs_file

	if forcedown:
		# For force redownload, remove previous rootfs
		print('Force redownloading Kali %s %s rootfs' % (fs_arch, fs_size))
		if os.path.isfile(fs_path):
			os.remove(fs_path)

	# Only download Kali rootfs if we don't have it already
	if os.path.isfile(fs_path):
		print('Found Kali %s %s rootfs at: %s' % (fs_arch, fs_size, fs_path))
	else:
		print("Downloading from host: %s" % fs_host)
		download(fs_url, fs_path, False) # We should add SHA512 retrieval function...

def addrootfs(fs_size, dst):
	global Arch

	# temporary hack until arm64 support is completed
        ## Update 2019-01-25: Disable workaround to use proper arm64 rootfs as it should be fully working now, Re4son
	##if Arch == 'arm64':
        ##		fs_arch = 'armhf'
	##else:
	##	fs_arch = Arch
	fs_arch = Arch

	fs_file = 'kalifs-' + fs_arch + '-' + fs_size + '.tar.xz'
	fs_path = os.path.join('rootfs', fs_file)

	try:
		zf = zipfile.ZipFile(dst, 'a', zipfile.ZIP_DEFLATED)
		print('Adding Kali rootfs archive to the installer zip...')
		zf.write(os.path.abspath(fs_path), fs_file)
		print('  Added: ' + fs_file)
		zf.close()
	except IOError as e:
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
	except IOError as e:
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
		'Image.lz4', 'Image.lz4-dtb',
		'Image.fit'
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

	# Copy any device specific system binaries, libs, or init.d scripts
	system_path = os.path.join(device_path, 'system')
	if os.path.exists(system_path):
		print('Found additional /system files at: ' + system_path)
		copytree(system_path, os.path.join(out_path, 'system'))

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
	exit(1)

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
	parser.add_argument('--oreo', '-o', action='store_true', help='Android 8')
	parser.add_argument('--pie', '-p', action='store_true', help='Android 9')
	parser.add_argument('--forcedown', '-f', action='store_true', help='Force redownloading')
	parser.add_argument('--uninstaller', '-u', action='store_true', help='Create an uninstaller')
	parser.add_argument('--kernel', '-k', action='store_true', help='Build kernel installer only')
	parser.add_argument('--nokernel', '-nk', action='store_true', help='Build without the kernel installer')
	parser.add_argument('--nobrand', '-nb', action='store_true', help='Build without wallpaper or boot animation')
	parser.add_argument('--nofreespace', '-nf', action='store_true', help='Build without free space check')
	parser.add_argument('--supersu', '-su', action='store_true', help='Build with SuperSU installer included')
	parser.add_argument('--nightly', '-ni', action='store_true', help='Use nightly mirror for Kali rootfs download (experimental)')
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
		if args.supersu:
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
		if args.oreo:
			OS = 'oreo'
			i += 1
		if args.pie:
			OS = 'pie'
			i += 1
		if i == 0:
			abort('Missing Android version. Available options: --kitkat, --lollipop, --marshmallow, --nougat, --oreo, --pie')
		elif i > 1:
			abort('Select only one Android version: --kitkat, --lollipop, --marshmallow, --nougat, --oreo, --pie')

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
		# Download SuperSU if we want it
		if args.supersu:
			supersu(args.forcedown, supersu_beta)

	# Download Kali rootfs if we are building a zip with the chroot environment included
	if args.rootfs:
		rootfs(args.forcedown, args.rootfs, args.nightly)

	# Set file name tag depending on the options chosen
	file_tag = Device
	if args.device:
		file_tag += '-' + OS
	else:
		file_tag += '-' + Arch
	if args.nobrand and not args.kernel:
		file_tag += '-nobrand'
	if args.supersu:
		file_tag += '-rooted'
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

	# Don't include SuperSU unless --supersu is specified
	if not args.supersu:
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
