#!/bin/bash
set -ouex pipefail

dnf install --best --allowerasing --skip-unavailable -y akmod-nvidia bcache-tools btop bwm-ng gdb gcc-c++ guvcview gvfs kernel-headers libaacs libguestfs libinput-utils libva-utils lm_sensors nss-mdns nvidia-container-toolkit nvidia-vaapi-driver openrgb-udev-rules thermald xorg-x11-drv-nvidia-cuda

### AMD
dnf -y swap mesa-va-drivers mesa-va-drivers-freeworld
dnf -y swap mesa-vdpau-drivers mesa-vdpau-drivers-freeworld

dnf clean all 

systemctl set-default graphical.target 

rm -rf /var/run*

# Build kmods
sh /ctx/scripts/install_scripts/kmod.sh