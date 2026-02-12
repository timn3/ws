#!/bin/bash
set -ouex pipefail

dnf5 install -y --setopt=install_weak_deps=0 rsync && dnf clean all

rsync -rvK /ctx/system_files/ /

### Install packages
# dnf5 install -y --setopt=install_weak_deps=0 cloud-init  && dnf clean all

dnf5 install -y --setopt=install_weak_deps=0 --skip-unavailable cockpit cockpit-podman cockpit-storaged cockpit-ws cockpit-pcp cockpit-machines cockpit-selinux dnf5-plugins fastfetch firewalld git lm_sensors nfs-utils nss-mdns  pcp pcp-selinux samba sysstat tuned wget && dnf clean all

systemctl enable lm_sensors sysstat tuned fstrim.timer podman-auto-update.timer cockpit.socket

### Install netbird
sh /ctx/scripts/install_scripts/install-netbird.sh