############################################################
# Dockerfile to build a Kali Linux Nethunter Chroot
############################################################

# Set the base image to Kali
FROM kalilinux/kali-linux-docker

# Maintainer for this script (shoutout to steev for making Docker image!)
MAINTAINER binkybear@nethunter.com

RUN echo "deb http://http.kali.org/kali kali-rolling main contrib non-free" > /etc/apt/sources.list && \
echo "deb-src http://http.kali.org/kali kali-rolling main contrib non-free" >> /etc/apt/sources.list

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y update && apt-get -y dist-upgrade && apt-get clean
RUN apt-get install -y git-core gnupg flex bison gperf build-essential \
zip curl libncurses5-dev zlib1g-dev \
libncurses5-dev gcc-multilib g++-multilib sudo \
parted kpartx debootstrap pixz qemu-user-static abootimg cgpt vboot-kernel-utils \
libesd0-dev bc lzma lzop automake autoconf m4 dosfstools rsync u-boot-tools nano \
schedtool git e2fsprogs device-tree-compiler ccache dos2unix binfmt-support

ENV KALI_WORKSPACE /root/nethunter-fs
RUN mkdir -p ${KALI_WORKSPACE}
COPY . ${KALI_WORKSPACE}
WORKDIR ${KALI_WORKSPACE}

CMD ["/root/nethunter-fs/build.sh", "-f"]
