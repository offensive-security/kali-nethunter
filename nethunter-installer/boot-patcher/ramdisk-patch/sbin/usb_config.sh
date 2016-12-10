#!/system/bin/sh

conf_store=/data/local/usb_config
android_usb=/sys/class/android_usb/android0

print() {
	echo "$*"
	log -t "usb_config.sh" "$*"
}

abort() {
	>&2 echo "Error: $*"
	log -p e -t "usb_config.sh" "$*"
	exit 1
}

save_file() {
	[ -f "$android_usb/$1" ] || return 1
	sfd=$(dirname "$conf_store/$1")
	[ -d "$sfd" ] || mkdir -p "$sfd"
	[ -d "$sfd" ] || return 1
	cat "$android_usb/$1" > "$conf_store/$1"
}

save_usb_config() {
	mkdir -p "$conf_store"
	[ -d "$conf_store" ] || abort "Could not create '$conf_store' directory"
	print "Saving current usb configuration to '$conf_store'"
	save_file idVendor
	save_file idProduct
	save_file bDeviceClass
	save_file bDeviceSubClass
	save_file bDeviceProtocol
	save_file iManufacturer
	save_file iProduct
	save_file f_mass_storage/inquiry_string
	save_file f_mass_storage/lun/cdrom
	save_file f_mass_storage/lun/ro
	save_file f_mass_storage/lun/nofua
	save_file functions
	getprop sys.usb.config > "$conf_store/sys.usb.config"
}

reset_file() {
	[ -f "$android_usb/$1" ] || return 1
	[ -f "$conf_store/$1"  ] || return 1
	cat "$conf_store/$1" > "$android_usb/$1"
}

reset_usb_config() {
	[ -d "$conf_store" ] || abort "Could not find '$conf_store' directory"
	print "Resetting usb configuration to values in '$conf_store'"
	echo 0 > "$android_usb/enable"
	reset_file idVendor
	reset_file idProduct
	reset_file bDeviceClass
	reset_file bDeviceSubClass
	reset_file bDeviceProtocol
	reset_file iManufacturer
	reset_file iProduct
	reset_file f_mass_storage/inquiry_string
	reset_file f_mass_storage/lun/cdrom
	reset_file f_mass_storage/lun/ro
	reset_file f_mass_storage/lun/nofua
	reset_file functions
	cfg=$(cat "$conf_store/sys.usb.config")
	setprop sys.usb.config "$cfg"
}

case "$1" in
	save)  save_usb_config  ;;
	reset) reset_usb_config ;;
	*) abort "Invalid argument - must call with \$1 as 'save' or 'reset'" ;;
esac
