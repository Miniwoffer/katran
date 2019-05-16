cmake_minimum_required (VERSION 3.1)
project (libkatran-proj)


# for clang's compile_commands.json
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(CMAKE_CXX_COMPILER_ID "Clang")

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=gnu++14")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Werror")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-sign-compare -Wno-bool-compare")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-error=unused-variable -Woverloaded-virtual -Wnon-virtual-dtor")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-maybe-uninitialized -Wdeprecated-declarations")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-error=deprecated-declarations")

# system libs

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/")

#find_package(GTest REQUIRED)
#find_package(Glog REQUIRED)
#find_package(LibElf REQUIRED)
#find_package(LibMnl REQUIRED)
#find_package(GFlags REQUIRED)
#find_package(Folly REQUIRED)

set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)
#find_package(Libunwind REQUIRED)
#find_package(LibLZMA REQUIRED)

#find_package(LibZ REQUIRED)

find_library(Glog_LIBRARIES libglog.so glog)
find_library(LibElf_LIBRARIES libelf.a elf)
find_library(LibMnl_LIBRARIES libmnl.so mnl)
find_library(GFlags_LIBRARIES libgflags.a gflags)
find_library(GTest_LIBRARIES gtest)
find_library(Folly_LIBRARIES libfolly.a folly)
find_library(Libunwind_LIBRARIES libunwind.so unwind)
find_library(LibLZMA_LIBRARIES liblzma.so lzma)
find_library(LibZ_LIBRARIES libz.a z)
find_library(LIBDC libdouble-conversion.a double-conversion)
find_library(BPF libbpf.a PATHS ${LIBBPF_PATH} NO_DEFAULT_PATH)
add_library(murmur3 STATIC
    MurmurHash3.h
    MurmurHash3.cpp
)

add_library(chhelpers STATIC
    CHHelpers.h
    CHHelpers.cpp
)

target_link_libraries(chhelpers murmur3)

add_library(iphelpers STATIC
    IpHelpers.h
    IpHelpers.cpp
)

target_link_libraries(iphelpers
	"${Folly_LIBRARIES}"
	"${Libunwind_LIBRARIES}"
	"${libLZMA_LIBRARIES}"
	"${Glog_LIBRARIES}"
	"${GFlags_LIBRARIES}"
    "${LIBDC}"
	Threads::Threads
)

add_library(bpfadapter STATIC
    BpfAdapter.cpp
    BpfLoader.cpp
    BpfAdapter.h
    BpfLoader.h
    linux_includes/bpf.h
    linux_includes/bpf_common.h
    linux_includes/bpf_helpers.h
)

set(BPFADAPTER_DEPS
	Threads::Threads
    "${BPF}"
	"${Libunwind_LIBRARIES}"
	"${libLZMA_LIBRARIES}"
	"${Glog_LIBRARIES}"
	"${LibElf_LIBRARIES}"
	"${LibZ_LIBRARIES}"
	"${LibMnl_LIBRARIES}"
	"${Folly_LIBRARIES}"
    "${LIBDC}"
)

target_link_libraries(bpfadapter "${BPFADAPTER_DEPS}")
add_library(katranlb STATIC
    KatranLb.h
    KatranLb.cpp
    KatranLbStructs.h
    BalancerStructs.h
    Vip.h
    Vip.cpp
)

target_link_libraries(katranlb
    bpfadapter
    chhelpers
    iphelpers
	"${GFlags_LIBARIES}"
)

add_library(mac_helpers STATIC
    MacHelpers.h
    MacHelpers.cpp
)

target_link_libraries(mac_helpers
	"${Folly_LIBRARIES}"
)

add_executable(xdproot xdproot.cpp)
target_link_libraries(xdproot
    bpfadapter
	"${GFlags_LIBRARIES}"
)

add_executable(maglev_integration_test maglev_integration_test.cpp)
target_link_libraries(maglev_integration_test
    chhelpers
	Threads::Threads
	"${GFlags_LIBRARIES}"
)

add_subdirectory(testing)
add_subdirectory(tests)
