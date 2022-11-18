# This file is indended to be included in end-user CMakeLists.txt
# include(/path/to/Filelists.cmake)
# It assumes the variable LWIP_DIR is defined pointing to the
# root path of lwIP/contrib sources.
#
# This file is NOT designed (on purpose) to be used as cmake
# subdir via add_subdirectory()
# The intention is to provide greater flexibility to users to
# create their own targets using the *_SRCS variables.

if(NOT ${CMAKE_VERSION} VERSION_LESS "3.10.0")
    include_guard(GLOBAL)
endif()

set(lwipportunix_SRCS
    ${LWIP_DIR}/port/sys_arch.c
    ${LWIP_DIR}/port/netif/fifo.c
    ${LWIP_DIR}/port/netif/list.c
    ${LWIP_DIR}/port/netif/sio.c
    ${LWIP_DIR}/port/netif/tapif.c
)
