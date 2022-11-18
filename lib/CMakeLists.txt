cmake_minimum_required(VERSION 3.7)

project(lwip C)

set (BUILD_SHARED_LIBS ON)

set (LWIP_INCLUDE_DIRS
    "${LWIP_DIR}/src/include"
    "${LWIP_DIR}/port/include"
)
include(${LWIP_DIR}/port/Filelists.cmake)

set(LWIP_COMPILER_FLAGS_GNU_CLANG
    -Wall
    -pedantic
    -Werror
    -Wparentheses
    -Wsequence-point
    -Wswitch-default
    -Wextra
    -Wundef
    -Wshadow
    -Wpointer-arith
    -Wcast-qual
    -Wc++-compat
    -Wwrite-strings
    -Wold-style-definition
    -Wcast-align
    -Wmissing-prototypes
    -Wnested-externs
    -Wunreachable-code
    -Wuninitialized
    -Wmissing-prototypes
    -Waggregate-return
    -Wlogical-not-parentheses
)

if (LWIP_DEBUG)
    list(APPEND LWIP_COMPILER_FLAGS_GNU_CLANG
        -g
    )
endif()

if (NOT LWIP_HAVE_MBEDTLS)
    list(APPEND LWIP_COMPILER_FLAGS_GNU_CLANG
        -Wredundant-decls
    )
endif()

if(CMAKE_C_COMPILER_ID STREQUAL "GNU")
    list(APPEND LWIP_COMPILER_FLAGS_GNU_CLANG
        -Wlogical-op
        -Wtrampolines
    )

    if (NOT LWIP_HAVE_MBEDTLS)
        list(APPEND LWIP_COMPILER_FLAGS_GNU_CLANG
            -Wc90-c99-compat
        )
    endif()

    if(NOT CMAKE_C_COMPILER_VERSION VERSION_LESS 4.9)
        if(LWIP_USE_SANITIZERS)
            list(APPEND LWIP_COMPILER_FLAGS_GNU_CLANG
                -fsanitize=address
                -fsanitize=undefined
                -fno-sanitize=alignment
                -fstack-protector
                -fstack-check
            )
            set(LWIP_SANITIZER_LIBS asan ubsan)
        endif()
    endif()

    set(LWIP_COMPILER_FLAGS ${LWIP_COMPILER_FLAGS_GNU_CLANG})
endif()

if(CMAKE_C_COMPILER_ID STREQUAL "Clang")
    list(APPEND LWIP_COMPILER_FLAGS_GNU_CLANG
        -Wdocumentation
        -Wno-documentation-deprecated-sync
    )

    if(LWIP_USE_SANITIZERS)
        list(APPEND LWIP_COMPILER_FLAGS_GNU_CLANG
            -fsanitize=address
            -fsanitize=undefined
            -fno-sanitize=alignment
        )
        set(LWIP_SANITIZER_LIBS asan ubsan)
    endif()

    set(LWIP_COMPILER_FLAGS ${LWIP_COMPILER_FLAGS_GNU_CLANG})
endif()

if(CMAKE_C_COMPILER_ID STREQUAL "MSVC")
    set(LWIP_COMPILER_FLAGS /Wall /WX)
endif()

add_library(lwip ${lwipnoapps_SRCS} ${lwipportunix_SRCS})
set_target_properties(lwip PROPERTIES VERSION "0.0.0")
set_target_properties(lwip PROPERTIES SOVERSION "0")
target_compile_options(lwip PRIVATE ${LWIP_COMPILER_FLAGS})
target_compile_definitions(lwip PRIVATE ${LWIP_DEFINITIONS})
target_include_directories(lwip PRIVATE ${LWIP_INCLUDE_DIRS})
target_link_libraries(lwip ${LWIP_SANITIZER_LIBS})

find_library(LIBPTHREAD pthread)
target_link_libraries(lwip ${LIBPTHREAD})

# Generate pkg-config file
include(GNUInstallDirs)
CONFIGURE_FILE("${LWIP_DIR}/lib/lwip.pc.in" "${LWIP_DIR}/lib/lwip.pc" @ONLY)

# Install
install(TARGETS lwip LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})
install (
    DIRECTORY ${LWIP_DIR}/src/include/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/lwip
    FILES_MATCHING PATTERN "*.h*")
install (
    DIRECTORY ${LWIP_DIR}/port/include/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/lwip
    FILES_MATCHING PATTERN "*.h*")
install (FILES ${LWIP_DIR}/lib/lwip.pc
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig)
