#!/bin/sh

GIT_ACCOUNT=offensive-security
GIT_REPOSITORY=nethunter-devices

ABORT() {
	[ "$1" ] && echo "Error: $*"
	exit 1
}

cd "$(dirname "$0")" || ABORT "Failed to enter script directory!"

if [ ! "$(basename "$(pwd)")" = "nethunter-installer" ]; then
	ABORT "You must run this script from the nethunter-installer directory!"
fi

if [ -d devices ]; then
	echo "The devices directory already exists, choose an option:"
	echo "   U) Update devices to latest commit (default)"
	echo "   D) Delete devices folder and start over"
	echo "   C) Cancel"
	printf "Your choice? (U/d/c): "
	read -r choice
	case $choice in
		U*|u*|"")
			echo "Updating devices (fetch & rebase)..."
			cd devices || ABORT "Failed to enter devices directory!"
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
read -r choice
case $choice in
	y*|Y*)
		clonebranch=experimental ;;
	*)
		clonebranch=master ;;
esac

printf "Would you like to grab the full history of devices? (y/N): "
read -r choice
case $choice in
	y*|Y*) ;;
	*)
		clonecmd="$clonecmd --depth 1" ;;
esac

printf "Would you like to use SSH authentication (faster, but requires a GitHub account with SSH keys)? (y/N): "
read -r choice
case $choice in
	y*|Y*)
		cloneurl="git@github.com:${GIT_ACCOUNT}/${GIT_REPOSITORY}" ;;
	*)
		cloneurl="https://github.com/${GIT_ACCOUNT}/${GIT_REPOSITORY}.git" ;;
esac

clonecmd="$clonecmd --branch $clonebranch $cloneurl devices"
echo "Running command: $clonecmd"

$clonecmd || ABORT "Failed to git clone devices!"

exit 0
