#!/bin/bash
set -ouex pipefail
rsync -rvK /ctx/container_files/ /

## Install Gitea
# Create tmpfiles.d configuration to set up /var directories at runtime
cat > /usr/lib/tmpfiles.d/gitea.conf << 'EOF'
# Create Gitea directories at runtime
d /var/gitea-data   0755 1000 1000 -
d /var/gitea-config 0755 1000 1000 -
EOF