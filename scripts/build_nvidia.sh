dnf -y install gcc-c++ nvidia-driver dnf-plugins-core

dkms autoinstall -k $(rpm -qa kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}') 
dnf config-manager addrepo --from-repofile https://developer.download.nvidia.com/compute/cuda/repos/fedora43/x86_64/cuda-fedora43.repo
dnf install -y nvidia-container-toolkit 
dnf install -y cuda cuda-toolkit cuda-drivers
dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm 

dnf install -y nvidia-vaapi-driver libva-nvidia-driver libva-utils

akmods --force --kernels "$(rpm -q --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' kernel-devel)" 

dnf clean all

tee /usr/lib/bootc/kargs.d/00-nvidia.toml <<EOF
kargs = ["nvidia-drm.modeset=1 nouveau.modeset=0 rd.driver.blacklist=nouveau,nova-core modprobe.blacklist=nouveau,nova-core", "initcall_blacklist=simpledrm_platform_driver_init"]
EOF