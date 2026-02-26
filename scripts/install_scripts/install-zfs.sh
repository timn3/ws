#!/usr/bin/env bash
set -euo pipefail

dnf5 install -y https://zfsonlinux.org/fedora/zfs-release-3-0$(rpm -E "%{dist}").noarch.rpm
dnf5 install -y --setopt=install_weak_deps=0 --skip-unavailable \
    kernel-devel kernel-headers

dnf5 config-manager setopt zfs*.enabled=0
dnf5 config-manager setopt zfs-latest.enabled=1

dnf5 install -y kmod-zfs zfs

dnf5 clean all

