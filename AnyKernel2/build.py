#!/usr/bin/env
import os
import urllib2
import urllib
import zipfile
import shutil
import errno
import ConfigParser
import re
import argparse
import datetime

class LatestSU:
    def __getPage(self, url, retRedirUrl=False):
        try:
            bOpener = urllib2.build_opener()
            bOpener.addheaders = [("User-agent",
                                   "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.146 Safari/537.36")]
            pResponse = bOpener.open(url)
            if retRedirUrl == True:
                return pResponse.geturl()
            else:
                pageData = pResponse.read()
                return pageData

        except urllib2.HTTPError, e:
            print('HTTPError = ' + str(e.code))
        except urllib2.URLError, e:
            print('URLError = ' + str(e.reason))

    def dlsupersu(self):
        # Beta
        getUrl = self.__getPage('http://download.chainfire.eu/743/SuperSU/BETA-SuperSU-v2.52.zip', True)
        # Stable
        #getUrl = self.__getPage('http://download.chainfire.eu/supersu', True)
        latestUrl = getUrl + '?retrieve_file=1'

        return latestUrl

def supersuBeta():

    # Progress bar http://stackoverflow.com/a/22776
    url = "http://forum.xda-developers.com/attachment.php?attachmentid=3565977&d=1449330539"

    file_name = os.path.join('supersu', 'supersu.zip')
    #file_name = url.split('/')[-1]
    u = urllib2.urlopen(url)
    f = open(file_name, 'wb')
    meta = u.info()
    file_size = int(meta.getheaders("Content-Length")[0])
    print "Downloading: %s Bytes: %s" % (file_name, file_size)

    file_size_dl = 0
    block_sz = 8192
    while True:
        buffer = u.read(block_sz)
        if not buffer:
            break

        file_size_dl += len(buffer)
        f.write(buffer)
        status = r"%10d  [%3.2f%%]" % (file_size_dl, file_size_dl * 100. / file_size)
        status = status + chr(8)*(len(status)+1)
        print status,

    f.close()

    pass


def supersu():

    ldclass = LatestSU()
    filename = os.path.join('supersu', 'supersu.zip')

    print('Downloading supersu.zip to supersu/supersu.zip ~4MB')
    urllib.urlretrieve(ldclass.dlsupersu(), filename)

def allapps():

    apps = {
        'BlueNMEA-2.1.3':'http://max.kellermann.name/download/blue-nmea/BlueNMEA-2.1.3.apk',
        'Hackerskeyboard-1.38.2':'https://f-droid.org/repo/org.pocketworkstation.pckeyboard_1038002.apk',
        'Drivedroid-0.9.19':'http://softwarebakery.com/apps/drivedroid/files/drivedroid-free-0.9.19.apk',
        'USBKeyboard':'https://github.com/pelya/android-keyboard-gadget/raw/master/USB-Keyboard.apk',
        'RFAnalyzer':'https://github.com/demantz/RFAnalyzer/raw/master/RFAnalyzer.apk',
        'Shodan':'https://github.com/PaulSec/Shodan.io-mobile-app/raw/master/io.shodan.app.apk',
        'RouterKeygen':'https://github.com/routerkeygen/routerkeygenAndroid/releases/download/v3.15.0/routerkeygen-3-15-0.apk',
        'cSploit-nightly':'http://rootbitch.cc/csploit/cSploit-nightly.apk'
    }

    try:
        for key, value in apps.iteritems():
            apkname = 'data/app/' + key + '.apk'

            if not os.path.isfile(apkname): # Check for existing apk download
                print('Downloading ' + value + ' to ' + apkname)
                urllib.urlretrieve (value, apkname)
                print(key + '.apk download OK')

        print('Finished downloading all apps')

    except urllib.URLError, e:
        print('URLError = ' + str(e.reason))

def ignore_function(ignore):
    def _ignore_(path, names):
        ignored_names = []
        if ignore in names:
            ignored_names.append(ignore)
        return set(ignored_names)
    return _ignore_



# Modified source from: http://stackoverflow.com/questions/14568647/create-zip-in-python
# and http://www.pythoncentral.io/how-to-recursively-copy-a-directory-folder-in-python/
def zip(src, dst, status):
    # Copy all folders/files (except ignored) to tmp_out folder for zipping
    try:
        pwd = os.path.dirname(os.path.realpath(__file__))
        if status == "anykernel":
            shutil.copytree(pwd, 'tmp_out', ignore=shutil.ignore_patterns('*.py', 'README*', 'placeholder','tmp_out', 'kernels', 'files', 'media',
                                                                      'devices.cfg', '.DS_Store', '.git', '.idea', 'aroma-update', 'kernel-nethunter*',
                                                                      'aroma', 'data', 'anykernel', 'wallpaper', 'noaroma-update', 'nano', 'terminfo',
                                                                      'lualibs', 'scripts', 'proxmark3', '*.so',
                                                                      'supersu', 'supersu', 'wallpaper', 'uninstaller', 'update-nethunter*'))
        elif status == "aroma":
            shutil.copytree(pwd, 'tmp_out', ignore=shutil.ignore_patterns('*.py', 'README*', 'placeholder','tmp_out', 'kernels',
                                                                      'devices.cfg', '.DS_Store', '.git', '.idea', 'kernel-nethunter*',
                                                                      'modules', 'anykernel.sh', 'dtb', 'uninstaller',
                                                                      'ramdisk', 'patch', 'anykernel', 'noaroma-update',
                                                                      'zImage*', 'aroma-update', 'update-nethunter*'))
        elif status == "uninstaller":
            shutil.copytree(pwd, 'tmp_out', ignore=shutil.ignore_patterns('*.py', 'README*', 'placeholder','tmp_out', 'tools', 'kernels',
                                                                      'devices.cfg', '.DS_Store', '.git', '.idea', 'supersu', 'kernel-nethunter*',
                                                                      'modules', 'anykernel.sh', 'dtb', 'uninstaller', 'files',
                                                                      'ramdisk', 'patch', 'anykernel', 'aroma-update', 'noaroma-update',
                                                                      'aroma', 'data', 'system', 'patch', 'ramdisk', 'wallpaper',
                                                                      'zImage*', 'aroma-update', 'update-nethunter*'))

    except OSError as e:
        if e.errno == errno.ENOTDIR:
            shutil.copy(pwd, 'tmp_out')
        else:
            print('Directory not copied. Error: %s' % e)
    try:
        zf = zipfile.ZipFile("%s.zip" % (dst), "w", zipfile.ZIP_DEFLATED)
        abs_src = os.path.abspath(src)
        for dirname, subdirs, files in os.walk(src):
            for filename in files:
                absname = os.path.abspath(os.path.join(dirname, filename))
                arcname = absname[len(abs_src) + 1:]
                print 'zipping %s as %s' % (os.path.join(dirname, filename),
                                            arcname)
                zf.write(absname, arcname)
        zf.close()
        shutil.rmtree('tmp_out')
    except IOError, e:
        print('Error' + str(e.reason))

def regexaroma(device):

    Config = ConfigParser.ConfigParser()
    Config.read('devices.cfg')

    file = 'META-INF/com/google/android/aroma-config'
    author = Config.get('DEVELOPER', 'author')
    version = Config.get('DEVELOPER', 'version')

    file_handle = open(file, 'r')
    file_string = file_handle.read()
    file_handle.close()

    d = datetime.datetime.now()
    date = "%s/%s/%s" % (d.day, d.month, d.year)

    author = 'ini_set("rom_author",          ' + str(author) + ');'
    version = 'ini_set("rom_version",          ' + str(version) + ');'
    device = 'ini_set("rom_device",          "' + str(device) + '");'
    date = 'ini_set("rom_date",          "' + str(date) + '");'

    file_string = (re.sub(ur'''ini_set\(\"rom_version\".*''', version, file_string))
    file_string = (re.sub(ur'''ini_set\(\"rom_author\".*''', author, file_string))
    file_string = (re.sub(ur'''ini_set\(\"rom_device\".*''', device, file_string))
    file_string = (re.sub(ur'''ini_set\(\"rom_date\".*''', date, file_string))

    file_handle = open(file, 'w')
    file_handle.write(file_string)
    file_handle.close()

def regexanykernel(device):

    i = 0

    Config = ConfigParser.ConfigParser()
    Config.read('devices.cfg')

    file = 'anykernel.sh'
    developer = Config.get('DEVELOPER', 'kernelstring')
    developer = 'kernel.string=' + developer

    # Get device names, convert to list, and get size
    devicestrings = Config.get(device, 'devicenames')
    devicestrings = devicestrings.split()
    size = len(devicestrings)

    # Get name of block to extract kernel to
    block = Config.get(device, 'block')
    block = 'block=' + block + ';'

    # Open file as read only and copy to string
    file_handle = open(file, 'r')
    file_string = file_handle.read()
    file_handle.close()

    # Replace kernel.string=name of developer in file_string
    file_string = (re.sub(ur'''kernel\.string=.*''', developer, file_string))
    file_string = (re.sub(ur'''block=.*''', block, file_string))

    # Replace device names
    for device in devicestrings:
        i += 1
        devicecode = 'device.name' + str(i) + '=' + device
        deviceregex = 'device\.name' + str(i) + '=.*'
        file_string = (re.sub(deviceregex, devicecode, file_string))

    if size < 5:
        for extranumbers in range(size, 5):
            # Else make device string empty
            extranumbers += 1
            devicecode = 'device.name' + str(extranumbers) + '=' + ""
            deviceregex = 'device\.name' + str(extranumbers) + '=.*'
            file_string = (re.sub(deviceregex, devicecode, file_string))


    file_handle = open(file, 'w')
    file_handle.write(file_string)
    file_handle.close()


def cleanup():
    # Remove any existing zImage
    if os.path.exists('zImage'):
        print('Removing previous zImage')
        os.remove('zImage')

    # Clean up
    if os.path.exists('anykernelzip'):
        shutil.rmtree('anykernelzip')

    # Check to see if an sepolicy exists in ramdisk, remove if it does
    if os.path.exists('ramdisk/sepolicy'):
        print('Removing previous sepolicy')
        os.remove('ramdisk/sepolicy')

    # Check to see if an dtb image exists, remove if it does
    if os.path.exists('dtb'):
        print('Removing previous dtb')
        os.remove('dtb')


def main():
    dir = 'META-INF/com/google/android/'
    i = datetime.datetime.now()
    current_time = "%s%s%s_%s%s%s" % (i.day, i.month, i.year, i.hour, i.minute, i.second)
    firmware_list = []
    initd_list = []
    module_list = []

    # Remove any existing builds that might be left
    cleanup()

    # Read devices.cfg, get device names
    try:
        Config = ConfigParser.ConfigParser()
        Config.read('devices.cfg')
        devicenames = Config.sections()
    except IOError:
        print('Error opening devices.cfg')

    help_device = 'Device names: \n'

    for device in devicenames:
        if device != 'DEVELOPER':
            help_device += device + '\n'

    parser = argparse.ArgumentParser(description='Nethunter zip builder')
    parser.add_argument('--device', '-d', action='store', help=help_device)
    parser.add_argument('--kitkat', '-kk', action='store_true', help='Android.4.4.4')
    parser.add_argument('--lollipop', '-l', action='store_true', help='Android 5')
    parser.add_argument('--marshmallow', '-m', action='store_true', help='Android 6')
    parser.add_argument('--forcedown', '-f', action='store_true', help='Force redownloading')
    parser.add_argument('--noaroma', '-n', action='store_true', help='Use a generic updater-script instead of Aroma')
    parser.add_argument('--uninstaller', '-u', action='store_true', help='Create an uninstaller')
    parser.add_argument('--kernel', '-k', action='store_true', help='Build kernel only')

    args = parser.parse_args()

    ######## FORCE DOWNLOAD ###########
    if args.forcedown:
        supersu()
        #supersuBeta()  # Enable this to downloaded latest supersu and comment above line
        allapps()
        exit(0) # https://github.com/offensive-security/kali-nethunter/issues/259 (unsure if I want to keep this)

    # Grab latestest SuperSU and all apps
    suzipfile = os.path.isfile('supersu/supersu.zip')

    # Check if device supports aroma in config file
    if args.device:
        aroma_enabled = Config.get(args.device, 'aroma')
        # Check for aroma
        if aroma_enabled == "True":
            aroma_enabled = True
        else:
            aroma_enabled = False
        # If Aroma set to false the set noaroma argument
        if not aroma_enabled and not args.noaroma and not args.kernel:
            print('Automatically setting to noaroma!')
            args.noaroma = True

    # Check to make sure we didn't go crazy selecting version numbers
    if args.kitkat or args.lollipop or args.marshmallow:
        version_picked = True
        i = 0
        check = [args.kitkat, args.lollipop, args.marshmallow]
        for version in check:
            if version:
                i += 1
        if i > 1:
            print('Select only one version: --kitkat, --lollipop, --marshmallow')
            exit(0)
    elif args.uninstaller:
        pass
    elif args.forcedown:
        pass
    else:
        print('Select a version: --kitkat, --lollipop, --marshmallow')
        exit(0)

    ####### BUILD DEVICE CONFIG #######
    if args.device in devicenames:
        device = args.device
        # Add developer information to Anykernel2
        regexanykernel(device)
    elif not args.device:
        print('No arguments supplied.  Try -h or --help')
        exit(0)
    else:
        print('Device %s not found devices.cfg' % args.device)
        exit(0)

    # Device and version set, lets copy kernel!  Probably could replace with function but eh.
    if device and args.kitkat or args.lollipop or args.marshmallow:
        if args.kitkat:
            version = "kitkat"
        elif args.lollipop:
            version = "lollipop"
        elif args.marshmallow:
            version = "marshmallow"

        # Check for existing modules (ko files), remove to make way for new modules
        module_list = [f for f in os.listdir("system/lib/modules")]
        for f in module_list:
            os.remove('system/lib/modules/' + f)

        # Marshmallow requires a modified sepolicy to work with SuperSU
        if version is 'marshmallow':
            sepolicy_location = 'kernels/marshmallow/' + device + '/sepolicy'
            if os.path.exists(sepolicy_location):
                shutil.copy2(sepolicy_location, 'ramdisk/sepolicy')
            else:
                print('SEPOLICY not found at: %s' % sepolicy_location)
                exit(0)

        # Copy kernel from version/device to root folder
        kernel_location = 'kernels/' + version + '/' + device + '/zImage'
        if os.path.exists(kernel_location):
            shutil.copy2(kernel_location, 'zImage')
        else:
            print('Kernel not found at: %s' % kernel_location)
            exit(0)

        # Copy any init.d scripts
        initd_location = 'kernels/' + version + '/' + device + '/init.d'
        if os.path.exists(initd_location):
            initd_list = [f for f in os.listdir(initd_location)]
            for f in initd_list:
                file = initd_location + '/' + f
                shutil.copy2(file, 'system/etc/init.d/' + f)

        # Copy modules if it exists
        module_location = 'kernels/' + version + '/' + device + '/modules'
        if os.path.exists(module_location):
            module_list = [f for f in os.listdir(module_location)]
            for f in module_list:
                file = module_location + '/' + f
                shutil.copy2(file, 'system/lib/modules/' + f)

        # Copy device specific firmware
        firmware_location = 'kernels/' + version + '/' + device + '/firmware'
        if os.path.exists(firmware_location):
            firmware_list = [f for f in os.listdir(firmware_location) if f.endswith(".bin" or ".fw")]
            for f in firmware_list:
                file = firmware_location + '/' + f
                print('Found firmware: %s' % file)
                shutil.copy2(file, 'system/etc/firmware/' + f)

        # Copy dtb.img if it exists
        dtb_location = 'kernels/' + version + '/' + device + '/dtb.img'
        if os.path.exists(dtb_location):
            print('DTB found at: %s' % dtb_location)
            shutil.copy2(dtb_location, 'dtb')


    ######## UNINSTALLER ###########
    if args.uninstaller:
        if os.path.exists(dir):
            shutil.rmtree(dir)
        shutil.copytree('uninstaller', dir)
        zipfilename = 'nethunter-uninstaller'
        zip('tmp_out', zipfilename, 'uninstaller')
        print('Created uninstaller: ', zipfilename + '.zip')
        exit(0)

    if os.path.isdir('supersu') and not suzipfile:
        supersu()
    elif not os.path.isdir('supersu') and not suzipfile:
        os.mkdir('supersu')
        supersu()

    if os.path.isdir('data/app'):
        allapps()
    elif not os.path.isdir('data/app'):
        os.mkdir('data/app')
        allapps()

    ####### Start AnyKernel2 installer ############
    zipfilename = 'anykernel2'

    if os.path.exists(dir):
        shutil.rmtree(dir)
    shutil.copytree('anykernel', dir)

    # Finished--copy files to tmp folder and zip
    zip('tmp_out', zipfilename, 'anykernel')
    if os.path.exists('anykernelzip'):
        shutil.rmtree('anykernelzip')

    ####### End AnyKernel2 installer ############

    ######## KERNEL ONLY ###########
    kernelzip = 'kernel-nethunter-' + device + '-' + version + '-' + str(current_time) + '.zip'

    if args.kernel and args.device and version_picked:
        shutil.move('anykernel2.zip', kernelzip)  # Create kernel only here!
        print('Created: %s.zip' % kernelzip)
        exit(0)
    elif args.kernel and not version_picked:
        print('Select a version: --kitkat, --lollipop, --marshmallow')
        exit(0)
    elif args.kernel and not device:
        print('Missing device name!  Please use --device or -d')
        exit(0)
    else:
        os.makedirs('anykernelzip')
        shutil.move('anykernel2.zip', 'anykernelzip/anykernel2.zip')  # Continue with build!


    ####### Start No-Aroma Installer ############
    if args.noaroma:
        if os.path.exists(dir):
            shutil.rmtree(dir)
        shutil.copytree('noaroma-update', dir)
    ####### End No-Aroma Installer ############
    else:
    ####### Start Aroma installer ###############
        if os.path.exists(dir):
            shutil.rmtree(dir)
        shutil.copytree('aroma-update', dir)
        regexaroma(device) # Add version/author to Aroma installer
    ###### End Aroma installer #########

    # Format for zip file is update-nethunter-devicename-version-DDMMYY_HHMMSS.zip
    zipfilename = 'update-nethunter-' + device + '-' + version + '-' + str(current_time)

    zip('tmp_out', zipfilename, 'aroma')

    print('Created: %s.zip' % zipfilename)

    # Remove device specific firmware that may have been copied over.
    if firmware_list:
        for f in firmware_list:
            os.remove('system/etc/firmware/' + f)

    # Remove any init.d files
    if initd_list:
        for f in initd_list:
            os.remove('system/etc/init.d/' + f)

    # Clean!
    cleanup()

if __name__ == "__main__":
    main()
