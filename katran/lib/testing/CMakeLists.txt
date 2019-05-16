cmake_minimum_required (VERSION 3.1)
project(libkatran_testing)
find_library(BOOST_SYSTEM libboost_system.a boost_system)

add_library(base64_helpers STATIC
    Base64Helpers.h
    Base64Helpers.cpp
)

target_link_libraries(base64_helpers
    "${Glog_LIBRARIES}"
    "${GFlags_LIBRARIES}"
    "${Folly_LIBRARIES}"
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
    "${Folly_LIBRARIES}"
    "${Glog_LIBRARIES}"
    "${BOOST_SYSTEM}"
)

add_library(xdptester STATIC
    XdpTester.h
    XdpTester.cpp
    KatranTestFixtures.h
    KatranOptionalTestFixtures.h
)

target_link_libraries(xdptester
    "${Folly_LIBRARIES}"
    "${Glog_LIBRARIES}"
    Threads::Threads
    pcap_parser
    bpfadapter
)

add_executable(katran_tester katran_tester.cpp)

target_link_libraries(katran_tester
    "${GFlags_LIBRARIES}"
    Threads::Threads
    xdptester
    katranlb
)

enable_testing()

add_executable(base64helpers-tests Base64Test.cpp)
target_link_libraries(base64helpers-tests	
	"${GTest_LIBRARIES}"
    "${Glog_LIBRARIES}"
    "${GFlags_LIBRARIES}"
    "${Libunwind_LIBRARIES}"
    "${LibLZMA_LIBRARIES}"
	Threads::Threads
    base64_helpers
)
add_test(Base64Tests base64helpers-tests)
