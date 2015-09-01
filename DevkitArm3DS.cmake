set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR armv6k)
set(3DS TRUE) # To be used for multiplatform projects

# DevkitPro Paths are broken on windows, so we have to fix those
macro(msys_to_cmake_path MsysPath ResultingPath)
	if(WIN32)
		string(REGEX REPLACE "^/([a-zA-Z])/" "\\1:/" ${ResultingPath} "${MsysPath}")
	else()
		set(${ResultingPath} "${MsysPath}")
	endif()
endmacro()

msys_to_cmake_path("$ENV{DEVKITPRO}" DEVKITPRO)
if(NOT IS_DIRECTORY ${DEVKITPRO})
    message(FATAL_ERROR "Please set DEVKITPRO in your environment")
endif()

msys_to_cmake_path("$ENV{DEVKITARM}" DEVKITARM)
if(NOT IS_DIRECTORY ${DEVKITARM})
    message(FATAL_ERROR "Please set DEVKITARM in your environment")
endif()

include(CMakeForceCompiler)
# Prefix detection only works with compiler id "GNU"
# CMake will look for prefixed g++, cpp, ld, etc. automatically
if(WIN32)
    CMAKE_FORCE_C_COMPILER("${DEVKITARM}/bin/arm-none-eabi-gcc.exe" GNU)
    CMAKE_FORCE_CXX_COMPILER("${DEVKITARM}/bin/arm-none-eabi-g++.exe" GNU)
else()
    CMAKE_FORCE_C_COMPILER("${DEVKITARM}/bin/arm-none-eabi-gcc" GNU)
    CMAKE_FORCE_CXX_COMPILER("${DEVKITARM}/bin/arm-none-eabi-g++" GNU)
endif()

# You need the arm-none-eabi-gcc-* versions of ar and ranlib instead of arm-none-eabi- for LTO support in devkitARM
string(REPLACE arm-none-eabi-ar arm-none-eabi-gcc-ar CMAKE_AR ${CMAKE_AR} )
string(REPLACE arm-none-eabi-ranlib arm-none-eabi-gcc-ranlib CMAKE_RANLIB ${CMAKE_RANLIB} )

set(WITH_PORTLIBS ON CACHE BOOL "use portlibs ?")

if(WITH_PORTLIBS)
    set(CMAKE_FIND_ROOT_PATH ${DEVKITARM} ${DEVKITPRO} ${DEVKITPRO}/portlibs/3ds)
else()
    set(CMAKE_FIND_ROOT_PATH ${DEVKITARM} ${DEVKITPRO})
endif()

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

SET(BUILD_SHARED_LIBS OFF CACHE INTERNAL "Shared libs not available" )

add_definitions(-DARM11 -D_3DS)

set(ARCH "-march=armv6k -mtune=mpcore -mfloat-abi=hard ")
set(CMAKE_C_FLAGS " -mword-relocations ${ARCH}" CACHE STRING "C flags")
set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS}" CACHE STRING "C++ flags")
set(DKA_SUGGESTED_C_FLAGS "-fomit-frame-pointer -ffast-math")
set(DKA_SUGGESTED_CXX_FLAGS "${DKA_SUGGESTED_C_FLAGS} -fno-rtti -fno-exceptions -std=gnu++11")
set(CMAKE_EXE_LINKER_FLAGS "-specs=3dsx.specs" CACHE STRING "linker flags")

set(CMAKE_INSTALL_PREFIX ${DEVKITPRO}/portlibs/3ds
    CACHE PATH "Install libraries in the portlibs dir")

