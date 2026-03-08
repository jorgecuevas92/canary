FROM ubuntu:24.04

# Update the system and install dependencies
RUN apt update && apt upgrade -y && \
    apt install -y git cmake build-essential autoconf libtool ca-certificates curl zip unzip tar pkg-config ninja-build ccache

# Update CMake to the latest version
RUN apt remove --purge cmake -y && \
    hash -r && \
    apt install -y snapd && \
    snap install cmake --classic && \
    cmake --version

# Update GCC to the latest version
RUN apt update && \
    apt install -y gcc-14 g++-14 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-14 100 --slave /usr/bin/g++ g++ /usr/bin/g++-14 --slave /usr/bin/gcov gcov /usr/bin/gcov-14 && \
    update-alternatives --set gcc /usr/bin/gcc-14 && \
    gcc-14 --version && \
    g++-14 --version

# Install acl
RUN apt install -y acl

# Install vcpkg
RUN git clone https://github.com/microsoft/vcpkg && \
    cd vcpkg && \
    ./bootstrap-vcpkg.sh

# Install canary
COPY . /canary
RUN setfacl -R -m g:www-data:rx /canary && \
    cd /canary && \
    mv config.lua.dist config.lua && \
    mkdir build

# Build the canary project
RUN cmake -DCMAKE_TOOLCHAIN_FILE=~/vcpkg/scripts/buildsystems/vcpkg.cmake .. --preset linux-release -DTOGGLE_BIN_FOLDER=ON && \
    cmake --build linux-release

# Copy the canary binary to the root directory
RUN cp /canary/build/linux-release/bin/canary / && \
    chmod +x /canary