#!/bin/bash
set -ouex pipefail
dnf5 install -y 'dnf5-command(config-manager)'
#!/bin/bash
set -ouex pipefail

dnf5 install -y 'dnf5-command(config-manager)'
dnf5 config-manager addrepo --from-repofile \
  https://developer.download.nvidia.com/compute/cuda/repos/fedora43/x86_64/cuda-fedora43.repo

KVER="$(rpm -q --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}\n' kernel | tail -n1)"

dnf5 install -y \
  gcc-c++ dkms kernel-devel-"$KVER" \
  cuda-drivers \
  cuda-toolkit \
  nvidia-container-toolkit

# Build the module for the image's kernel (not the build host's `uname -r`)
dkms autoinstall -k "$KVER"

dnf5 clean all

# akmods --force --kernels "$(rpm -q --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' kernel-devel)" 


cat > /usr/lib/bootc/kargs.d/00-nvidia.toml <<'EOF'
kargs = [
  "nvidia-drm.modeset=1",
  "rd.driver.blacklist=nouveau,nova-core",
  "modprobe.blacklist=nouveau,nova-core",
  "initcall_blacklist=simpledrm_platform_driver_init",
]
EOF