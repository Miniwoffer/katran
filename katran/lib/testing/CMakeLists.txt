cmake_minimum_required (VERSION 3.1)
project(libkatran_testing)
find_library(BOOST_SYSTEM libboost_system.a boost_system)

add_library(base64_helpers STATIC
    Base64Helpers.h
    Base64Helpers.cpp
)

target_link_libraries(base64_helpers
	"${GLOG_LIBRARIES}"
	"${GFLAGS_LIBRARIES}"
	"${FOLLY_LIBRARIES}"
    "${BOOST_SYSTEM}"
)

add_library(pcap_parser STATIC
    PcapParser.h
    PcapParser.cpp
    PcapStructs.h
)

target_link_libraries(pcap_parser
    base64_helpers	
    Threads::Threads
    "${FOLLY_LIBRARIES}"
    "${GLOG_LIBRARIES}"
    "${BOOST_SYSTEM}"
)

add_library(xdptester STATIC
    XdpTester.h
    XdpTester.cpp
    KatranTestFixtures.h
    KatranOptionalTestFixtures.h
)

target_link_libraries(xdptester
	"${FOLLY_LIBRARIES}"
	"${GLOG_LIBRARIES}"
    Threads::Threads
    pcap_parser
    bpfadapter
)

add_executable(katran_tester katran_tester.cpp)

target_link_libraries(katran_tester
	"${GFLAGS_LIBRARIES}"
    Threads::Threads
    xdptester
    katranlb
)

enable_testing()

add_executable(base64helpers-tests Base64Test.cpp)
target_link_libraries(base64helpers-tests	
	"${GTEST_LIBRARIES}"
	"${GLOG_LIBRARIES}"
	"${GFLAGS_LIBRARIES}"
    "${Libunwind_LIBRARIES}"
    "${LIBLZMA_LIBRARIES}"
	Threads::Threads
    base64_helpers
)
add_test(Base64Tests base64helpers-tests)
