cmake_minimum_required (VERSION 3.0)
project (libdecap-proj)

add_library(decap STATIC
    XdpDecap.cpp
    XdpDecap.h
    XdpDecapStructs.h
)

target_link_libraries(decap
    bpfadapter
	"${Glog_LIBRARIES}"
)

add_subdirectory(testing)
