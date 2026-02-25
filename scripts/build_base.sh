#!/bin/bash
set -ouex pipefail

dnf5 install -y --setopt=install_weak_deps=0 rsync && dnf clean all

rsync -rvK /ctx/system_files/ /

### Install packages
dnf -y install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
# dnf5 install -y --setopt=install_weak_deps=0 cloud-init  && dnf clean all

dnf5 install -y --setopt=install_weak_deps=0 --skip-unavailable cockpit cockpit-podman cockpit-storaged cockpit-ws cockpit-pcp cockpit-machines cockpit-selinux dnf5-plugins docker docker-compose fastfetch firewalld git lm_sensors nfs-utils nss-mdns pcp pcp-selinux podman podman-compose samba sscg sysstat tuned wget && dnf clean all

systemctl enable lm_sensors sysstat tuned fstrim.timer podman-auto-update.timer cockpit.socket

### Install netbird
sh /ctx/scripts/install_scripts/install-netbird.sh

# firewall-cmd --add-service=cockpit --permanent

dnf5 install -y https://zfsonlinux.org/fedora/zfs-release-3-0$(rpm -E "%{dist}").noarch.rpm
dnf5 install -y --setopt=install_weak_deps=0 --skip-unavailable kernel-devel 

dnf5 install -y zfs zfs-kmod zfs-dracut && dnf clean all
