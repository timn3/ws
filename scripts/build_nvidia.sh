#!/bin/bash
set -ouex pipefail
dnf5 install -y 'dnf5-command(config-manager)'

dnf5 -y install \
    gcc-c++ \
    dnf-plugins-core \
    dkms \
    akmods
    # nvidia-driver \

dnf5 remove -y xorg-x11-drv-nvidia xorg-x11-drv-nvidia-libs xorg-x11-drv-nvidia-cuda 2>/dev/null || true    

dkms autoinstall -k $(rpm -qa kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}') 
# dnf5 config-manager addrepo --from-repofile https://developer.download.nvidia.com/compute/cuda/repos/fedora43/x86_64/cuda-fedora43.repo


dnf5 config-manager addrepo --from-repofile https://developer.download.nvidia.com/compute/cuda/repos/fedora43/x86_64/cuda-fedora43.repo

mkdir -p /tmp/nvidia-rpms
dnf5 download -y --resolve --destdir=/tmp/nvidia-rpms \
  --setopt=cuda-fedora43-x86_64.gpgcheck=0 \
  cuda cuda-toolkit cuda-drivers nvidia-container-toolkit

dnf5 install -y --allowerasing --skip-broken --nogpgcheck /tmp/nvidia-rpms/*.rpm

# dnf5 clean packages
# dnf5 makecache --refresh

# dnf5 install -y --allowerasing --skip-broken --setopt=cuda-fedora43-x86_64.gpgcheck=0 --setopt=keepcache=false --setopt=max_parallel_downloads=1 \
#     cuda \
#     cuda-toolkit \
#     cuda-drivers \
#     nvidia-container-toolkit 
dnf5 install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm 

dnf5 install -y --skip-unavailable --allowerasing --skip-broken \
    nvidia-vaapi-driver \
    libva-nvidia-driver \
    libva-utils \
    xorg-x11-drv-nvidia-cuda \
    nvidia-container-toolkit \

akmods --force --kernels "$(rpm -q --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' kernel-devel)" 

dnf5 clean all

tee /usr/lib/bootc/kargs.d/00-nvidia.toml <<EOF
kargs = ["nvidia-drm.modeset=1 nouveau.modeset=0 rd.driver.blacklist=nouveau,nova-core modprobe.blacklist=nouveau,nova-core", "initcall_blacklist=simpledrm_platform_driver_init"]
EOF