#!/bin/bash
set -ouex pipefail

dnf5 install -y --setopt=install_weak_deps=0 rsync && dnf clean all

rsync -rvK /ctx/system_files/ /

### Install packages
dnf5 install -y --setopt=install_weak_deps=0 --skip-unavailable \
    btop \
    cockpit \
    cockpit-podman \
    cockpit-storaged \
    cockpit-ws \
    cockpit-pcp \
    cockpit-machines \
    cockpit-selinux \
    distrobox \
    dnf5-plugins \
    docker \
    docker-compose \
    fastfetch \
    firewalld \
    git \
    lm_sensors \
    nfs-utils \
    nss-mdns \
    pcp \
    pcp-selinux \
    podman \
    podman-compose \
    samba \
    sscg \
    sysstat \
    tuned \
    wget \
    syncthing

dnf5 install -y --setopt=install_weak_deps=0 --skip-unavailable \
    bcache-tools \
    bwm-ng \
    gdb \
    gcc-c++ \
    guvcview \
    gvfs \
    nvidia-container-toolkit \
    nvidia-vaapi-driver \
    openrgb-udev-rules \
    thermald \
    xorg-x11-drv-nvidia-cuda

dnf5 clean all

systemctl enable lm_sensors sysstat tuned fstrim.timer podman-auto-update.timer cockpit.socket

### Install netbird
sh /ctx/scripts/install_scripts/install-netbird.sh

### Install zellij
sh /ctx/scripts/install_scripts/install-zellij.sh

### Install ollama
curl -fsSL https://ollama.com/install.sh | sh

### Build initramfs
KERNEL_SUFFIX=""
QUALIFIED_KERNEL="$(rpm -qa | grep -P 'kernel-(|'"$KERNEL_SUFFIX"'-)(\d+\.\d+\.\d+)' | sed -E 's/kernel-(|'"$KERNEL_SUFFIX"'-)//')"
export DRACUT_NO_XATTR=1
/usr/bin/dracut --no-hostonly --kver "$QUALIFIED_KERNEL" --reproducible -v --add ostree -f "/lib/modules/$QUALIFIED_KERNEL/initramfs.img"
chmod 0600 "/lib/modules/$QUALIFIED_KERNEL/initramfs.img"
