#!/usr/bin/env bash

 # Copyright (C) 2018-present, Facebook, Inc.
 #
 # This program is free software; you can redistribute it and/or modify
 # it under the terms of the GNU General Public License as published by
 # the Free Software Foundation; version 2 of the License.
 #
 # This program is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 # GNU General Public License for more details.
 #
 # You should have received a copy of the GNU General Public License along
 # with this program; if not, write to the Free Software Foundation, Inc.,
 # 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

set -xeo pipefail
INSTALER="yay -Sy --noconfirm --needed "
NCPUS=$(cat /proc/cpuinfo  | grep processor | wc -l)
ROOT_DIR=$(pwd)
DEPS_DIR="${ROOT_DIR}/deps"

if [ ! -z "$FORCE_INSTALL" ]; then
    rm -rf ./deps
fi

if [ ! -z "$BUILD_EXAMPLE_THRIFT" ]; then
    BUILD_EXAMPLE_THRIFT=1
    export CMAKE_BUILD_EXAMPLE_THRIFT="$BUILD_EXAMPLE_THRIFT"
fi

if [ -z "$BUILD_EXAMPLE_GRPC" ]; then
    BUILD_EXAMPLE_GRPC=1
    export CMAKE_BUILD_EXAMPLE_GRPC="$BUILD_EXAMPLE_GRPC"
fi

mkdir deps || true

get_dev_tools() {
    $INSTALER \
		clang \
		cmake \
		bison \
		flex \
		bc \
		bcc
	echo lol
}

get_folly() {
    if [ -f "deps/folly_installed" ]; then
        return
    fi
    rm -rf deps/folly
	$INSTALER \
		gcc \
		automake \
		autoconf \
		autoconf-archive \
		libtool \
		boost \
		libevent \
		double-conversion \
		google-glog \
		gflags \
		lz4 \
		lzma \
		snappy \
		make \
		zlib \
		binutils \
		jemalloc \
		openssl \
		pkg-config \
		libunwind \
		libdwarf
#
#		libiberty \
    pushd .
	cd deps
	git clone https://github.com/facebook/folly --depth 1
	cd folly/build
  cmake -DCXX_STD=gnu++14 ..
  make -j $NCPUS
  sudo make install
  popd
  touch deps/folly_installed
}

get_required_libs() {
	echo "get_required_libs()"
    $INSTALER \
        gflags \
        libelf \
        libmnl \
        lzma \
        re2 \
        libsodium
}

get_gtest() {
    if [ -f "deps/googletest_installed" ]; then
        return
    fi
    rm -rf deps/googletest
    pushd .
    cd deps
    git clone --depth 1 https://github.com/google/googletest
    cd googletest
    mkdir build
    cd build
    cmake ..
    make && sudo make install
    popd
    touch deps/googletest_installed
}

get_mstch() {
    if [ -f "deps/mstch_installed" ]; then
        return
    fi
    rm -rf deps/mstch
    pushd .
    cd deps
    git clone --depth 1 https://github.com/no1msd/mstch
    mkdir -p mstch/build
    cd mstch/build
    cmake ..
    make -j $NCPUS
    sudo make install
    popd
    touch deps/mstch_installed
}

get_fizz() {
    if [ -f "deps/fizz_installed" ]; then
        return
    fi
    rm -rf deps/fizz
    pushd .
    cd deps
    git clone --depth 1 https://github.com/facebookincubator/fizz
    cd fizz
    mkdir build_ && cd build_
    cmake ../fizz/
    make -j $NCPUS
    sudo make install
    popd
    touch deps/fizz_installed
}

get_wangle() {
    if [ -f "deps/wangle_installed" ]; then
        return
    fi
    rm -rf deps/wangle
    pushd .
    cd deps
    git clone --depth 1 https://github.com/facebook/wangle
    cd wangle/wangle
    cmake .
    make -j $NCPUS
    sudo make install
    popd
    touch deps/wangle_installed
}

get_zstd() {
    if [ -f "deps/zstd_installed" ]; then
        return
    fi
    rm -rf deps/zstd
    pushd .
    cd deps
    git clone --depth 1 https://github.com/facebook/zstd --branch v1.3.7
    cd zstd
    make -j $NCPUS
    sudo make install
    popd
    touch deps/zstd_installed
}

get_fbthrift() {
    if [ -f "deps/fbthrift_installed" ]; then
        return
    fi
    rm -rf deps/fbthrift
    sudo apt-get install -y \
        libkrb5-dev \
        flex
    pushd .
    cd deps
    git clone --depth 1 https://github.com/facebook/fbthrift || true
    cd fbthrift/build
    cmake -DCXX_STD=gnu++14 ..
    make -j $NCPUS
    sudo make install
    popd
    touch deps/fbthrift_installed
}

get_rsocket() {
    if [ -f "deps/rsocket_installed" ]; then
        return
    fi
    rm -rf deps/rsocket-cpp
    pushd .
    cd deps
    git clone --depth 1 https://github.com/rsocket/rsocket-cpp || true
    mkdir -p rsocket-cpp/build
    cd rsocket-cpp/build
    cmake -DCXX_STD=gnu++14 ..
    make -j $NCPUS
    sudo make install
    popd
    touch deps/rsocket_installed
}

get_grpc() {
    if [ -f "deps/grpc_installed" ]; then
        return
    fi
    GO_INSTALLED=$(which go || true)
    if [ -z "$GO_INSTALLED" ]; then
        $INSTALER golang
    fi
    rm -rf deps/grpc
    pushd .
    cd deps
    git clone  --depth 1 https://github.com/grpc/grpc
    cd grpc
    git submodule update --init
	
	cd third_party/boringssl
	git checkout origin
	cd ../../
	
	mkdir build
    cd build
    cmake .. -DgRPC_BUILD_CSHARP_EXT=OFF -DgRPC_BUILD_TESTS=OFF
    make -j $NCPUS
    sudo make install

    cd ../third_party/protobuf
	./autogen.sh
	./configure
	make -j $NCPUS
	#make check
	sudo make install
    popd
    touch deps/grpc_installed
}

get_libbpf() {
    if [ -f "deps/libbpf_installed" ]; then
        return
    fi
    rm -rf deps/libbpf
    pushd .
    cd deps
    git clone --depth 1 https://github.com/libbpf/libbpf || true
    cd libbpf/src
    make
    DESTDIR=../install make install
    cd ..
    cp -r include/uapi install/usr/include/bpf/
    cd install/usr/include/bpf
    # override to use local bpf.h instead of system wide
    sed -i 's/#include <linux\/bpf.h>/#include <bpf\/uapi\/linux\/bpf.h>/g' ./bpf.h
    sed -i 's/#include <linux\/bpf.h>/#include <bpf\/uapi\/linux\/bpf.h>/g' ./libbpf.h
    popd
    touch deps/libbpf_installed
}



fix_gtest() {
    # oss version require this line for gtest to run/work
    local GTEST_INIT='

int main(int argc, char **argv) {
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
'
    local TEST_EXISTS=$(grep InitGoogleTest $1 | wc -l)
    if [ "$TEST_EXISTS" -gt 0 ]; then
        return
    fi
    echo "$GTEST_INIT" >> $1
}

katran_oss_tests_fixup() {
    fix_gtest ./katran/lib/tests/CHHelpersTest.cpp
    fix_gtest ./katran/lib/tests/IpHelpersTest.cpp
    fix_gtest ./katran/lib/tests/VipTest.cpp
    fix_gtest ./katran/lib/tests/KatranLbTest.cpp
    fix_gtest ./katran/lib/testing/Base64Test.cpp
}

build_katran() {
    pushd .
    rm -rf ./build
    mkdir build
    cd build
    cmake ..
    make -j $NCPUS
    popd
     ./build_bpf_modules_opensource.sh 
}

test_katran() {
    pushd .
    cd build/katran/lib/tests/
    ctest -v ./*
    cd ../testing/
    ctest -v ./*
    popd
}

get_dev_tools
# get_folly
get_required_libs
#get_gtest
#get_libbpf
if [ "$BUILD_EXAMPLE_THRIFT" -eq 1 ]; then
  get_mstch
  get_fizz
  get_wangle
  get_zstd
  get_rsocket
  get_fbthrift
fi
if [ "$BUILD_EXAMPLE_GRPC" -eq 1 ]; then
  get_grpc
fi
if [ -z "$INSTALL_DEPS_ONLY" ]; then
  katran_oss_tests_fixup
  build_katran
  test_katran
fi
