#!/bin/sh

ABORT() {
	[ "$1" ] && echo "Error: $*"
	exit 1
}

cd "$(dirname "$0")"

if [ ! "$(basename "$(pwd)")" = "nethunter-installer" ]; then
	ABORT "You must run this script from the nethunter-installer directory!"
fi

if [ -d devices ]; then
	echo "The devices directory already exists, choose an option:"
	echo "   U) Update devices to latest commit (default)"
	echo "   D) Delete devices folder and start over"
	echo "   C) Cancel"
	printf "Your choice? (U/d/c): "
	read choice
	case $choice in
		U*|u*|"")
			echo "Updating devices (fetch & rebase)..."
			cd devices
			git fetch && git rebase || ABORT "Failed to update devices!"
			exit 0
			;;
		D*|d)
			echo "Deleting devices folder..."
			rm -rf devices ;;
		*)
			ABORT ;;
	esac
fi

clonecmd="git clone"

printf "Would you like to use the experimental devices branch? (y/N): "
read choice
case $choice in
	y*|Y*)
		clonecmd="$clonecmd --branch experimental" ;;
	*) ;;
esac

printf "Would you like to grab the full history of devices? (y/N): "
read choice
case $choice in
	y*|Y*) ;;
	*)
		clonecmd="$clonecmd --depth 1" ;;
esac

clonecmd="$clonecmd https://github.com/offensive-security/nethunter-devices.git devices"
echo "Running command: $clonecmd"

$clonecmd || ABORT "Failed to git clone devices!"

exit 0
