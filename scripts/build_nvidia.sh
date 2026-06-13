#!/bin/bash
set -ouex pipefail
dnf5 config-manager -h
dnf5 install -y 'dnf5-command(config-manager)'

dnf5 -y install \
    gcc-c++ \
    nvidia-driver \
    dnf-plugins-core \
    dkms
    

dkms autoinstall -k $(rpm -qa kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}') 
dnf5 config-manager addrepo --from-repofile https://developer.download.nvidia.com/compute/cuda/repos/fedora43/x86_64/cuda-fedora43.repo
dnf5 install -y nvidia-container-toolkit 
dnf5 install -y cuda cuda-toolkit cuda-drivers
dnf5 install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm 

dnf5 install -y nvidia-vaapi-driver libva-nvidia-driver libva-utils

akmods --force --kernels "$(rpm -q --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' kernel-devel)" 

dnf5 clean all

tee /usr/lib/bootc/kargs.d/00-nvidia.toml <<EOF
kargs = ["nvidia-drm.modeset=1 nouveau.modeset=0 rd.driver.blacklist=nouveau,nova-core modprobe.blacklist=nouveau,nova-core", "initcall_blacklist=simpledrm_platform_driver_init"]
EOF