#!/bin/bash
set -ouex pipefail

dnf5 install -y --setopt=install_weak_deps=0 rsync && dnf clean all

rsync -rvK /ctx/system_files/ /

### Install packages
dnf -y install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
# dnf5 install -y --setopt=install_weak_deps=0 cloud-init  && dnf clean all
mkdir -p /etc/kernel/install.d \
 && ln -s /dev/null /etc/kernel/install.d/05-rpmostree.install
echo 'hostonly=no' > /etc/dracut.conf.d/99-hostonly.conf
echo 'hardlink=no' > /etc/dracut.conf.d/99-no-hardlink.conf
AKMODS_FLAVOR="coreos-stable"
KERNEL="6.18.7-200.fc43.x86_64"

## List versions of akmods available
# skopeo list-tags docker://ghcr.io/ublue-os/akmods-zfs | sort | grep "coreos-stable-43-6.18"  | head 


for pkg in kernel kernel-core kernel-modules kernel-modules-core; do
    rpm --erase $pkg --nodeps
done

# Fetch Common AKMODS & Kernel RPMS
skopeo copy --retry-times 3 docker://ghcr.io/ublue-os/akmods:"${AKMODS_FLAVOR}"-"$(rpm -E %fedora)"-"${KERNEL}" dir:/tmp/akmods
AKMODS_TARGZ=$(jq -r '.layers[].digest' </tmp/akmods/manifest.json | cut -d : -f 2)
tar -xvzf /tmp/akmods/"$AKMODS_TARGZ" -C /tmp/
mv /tmp/rpms/* /tmp/akmods/
# NOTE: kernel-rpms should auto-extract into correct location

# Install Kernel
rpm-ostree override replace \
    /tmp/kernel-rpms/kernel-[0-9]*.rpm \
    /tmp/kernel-rpms/kernel-core-*.rpm \
    /tmp/kernel-rpms/kernel-modules-*.rpm

# TODO: Figure out why akmods cache is pulling in akmods/kernel-devel
dnf5 -y install \
    /tmp/kernel-rpms/kernel-devel-*.rpm

dnf5 versionlock add kernel kernel-devel kernel-devel-matched kernel-core kernel-modules kernel-modules-core kernel-modules-extra

# Everyone
# NOTE: we won't use dnf5 copr plugin for ublue-os/akmods until our upstream provides the COPR standard naming
# sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo

skopeo copy --retry-times 3 docker://ghcr.io/ublue-os/akmods-zfs:"${AKMODS_FLAVOR}"-"$(rpm -E %fedora)"-"${KERNEL}" dir:/tmp/akmods-zfs
ZFS_TARGZ=$(jq -r '.layers[].digest' </tmp/akmods-zfs/manifest.json | cut -d : -f 2)
tar -xvzf /tmp/akmods-zfs/"$ZFS_TARGZ" -C /tmp/
mv /tmp/rpms/* /tmp/akmods-zfs/

# Declare ZFS RPMs
ZFS_RPMS=(
    /tmp/akmods-zfs/kmods/zfs/kmod-zfs-"${KERNEL}"-*.rpm
    /tmp/akmods-zfs/kmods/zfs/libnvpair[0-9]-*.rpm
    /tmp/akmods-zfs/kmods/zfs/libuutil[0-9]-*.rpm
    /tmp/akmods-zfs/kmods/zfs/libzfs[0-9]-*.rpm
    /tmp/akmods-zfs/kmods/zfs/libzpool[0-9]-*.rpm
    /tmp/akmods-zfs/kmods/zfs/python3-pyzfs-*.rpm
    /tmp/akmods-zfs/kmods/zfs/zfs-*.rpm
    pv
)

# Install
dnf5 -y install "${ZFS_RPMS[@]}"

# Depmod and autoload
depmod -a -v "${KERNEL}"
echo "zfs" >/usr/lib/modules-load.d/zfs.conf