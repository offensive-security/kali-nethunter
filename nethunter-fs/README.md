# NetHunter chroot builder

Build a basic NetHunter chroot

## Dependencies

This could be built on any debian based system but I recommend building on Kali.

```bash
apt-get install -y git-core gnupg flex bison gperf libesd0-dev build-essential \
zip curl libncurses5-dev zlib1g-dev libncurses5-dev gcc-multilib g++-multilib \
parted kpartx debootstrap pixz qemu-user-static abootimg cgpt vboot-kernel-utils \
vboot-utils bc lzma lzop automake autoconf m4 dosfstools rsync u-boot-tools \
schedtool git e2fsprogs device-tree-compiler ccache dos2unix debootstrap
```

## Running by itself

To create a full NetHunter system:
```bash
./build.sh -f
```
To create a minimal NetHunter filesystem:
```bash
./build.sh -m
```