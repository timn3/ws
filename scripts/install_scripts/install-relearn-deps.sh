#!/usr/bin/env bash
set -euo pipefail

echo ">>> Installing RELeARN dependencies..."
dnf5 install -y \
 openmpi-devel \
 fmt \
 fmt-ptrn \
 fmt-ptrn-devel \
 ccache \
 cmake \
 gcc \
 gcc-c++ \
 ninja-build \
 boost-devel \
 openmpi \
 openmpi-devel \
 environment-modules \
 highfive-devel

echo ">>> RELeARN dependencies installation completed."