# See https://catalog.ngc.nvidia.com/orgs/nvidia/containers/jetson-linux-flash-x86?version=r36.4

ARG SW_VERSION=r36.4
ARG L4T_RELEASE_PACKAGE
ARG SAMPLE_FS_PACKAGE

FROM nvcr.io/nvidia/jetson-linux-flash-x86:${SW_VERSION}


ARG SW_VERSION=r38.4
ARG L4T_RELEASE_PACKAGE
ARG SAMPLE_FS_PACKAGE

# Install lbzip2 for parallel decompression
RUN apt-get update && apt-get install -y lbzip2 && rm -rf /var/lib/apt/lists/*

# Need to enable binfmt for ARM emulation on some hosts like WSL2
RUN sudo update-binfmts --enable

ADD ${L4T_RELEASE_PACKAGE} /opt/l4t.tbz2
ADD ${SAMPLE_FS_PACKAGE} /opt/fs_root.tbz2

# Set working directory
WORKDIR /workspace

# Extract and prepare L4T packages
# Note that although l4t_flash_prerequisites.sh is likely unneeded in this container,
# we run it in case a different upstream base image is used that may be missing some dependencies.
RUN tar -I lbzip2 -xf /opt/l4t.tbz2 && \
    cd Linux_for_Tegra/rootfs/ && \
    tar -I lbzip2 -xpf /opt/fs_root.tbz2 && \
    cd .. && \
    ./tools/l4t_flash_prerequisites.sh && \
    ./apply_binaries.sh

