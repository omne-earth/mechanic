
#!/bin/bash
set -ueox pipefail
source "${PWD}/cuda/.config"

# install development tools
sudo dnf distro-sync
sudo dnf install -y @c-development @development-tools gc g++ cmake ccache curl-devel

# install cuda repo
sudo dnf config-manager addrepo --from-repofile=https://developer.download.nvidia.com/compute/cuda/repos/fedora41/x86_64/cuda-fedora41.repo --overwrite
sudo dnf distro-sync

# install nvidia drivers and cuda toolkit
sudo dnf -y install nvidia-driver-cuda nvidia-driver-libs nvidia-driver-cuda-libs nvidia-persistenced
sudo dnf -y install cuda

# setup cuda environment
if [ ! -f "${CUDA}" ]; then
    sudo sh -c "echo 'export PATH=\$PATH:/usr/local/cuda/bin' >> ${CUDA}"
    sudo chmod +x "${CUDA}"
fi
