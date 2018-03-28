cmake_minimum_required(VERSION 3.10)

if (_XDX_CMAKE_18e05eed_78ad_4a50_bf0b_6b3eb2d3b6c9)
    return()
endif()

macro(_xdx_status string_message)
    message(STATUS "=XDX= ${string_message}")
endmacro()

set(_XDX_CMAKE_18e05eed_78ad_4a50_bf0b_6b3eb2d3b6c9 1)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

include(${CMAKE_CURRENT_LIST_DIR}/xdx/xdx_project.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/xdx/xdx_settings.cmake)

if (XDX_ENABLE_TESTING)
    find_package(GTest)
    if (NOT GTEST_FOUND)
        set(XDX_ENABLE_TESTING OFF CACHE BOOL "Enable and build tests" FORCE)
        _xdx_status("Google test framework not found. Testing disabled.")
    else()
        _xdx_status("Google test framework found. Testing enabled.")
        enable_testing()
        include(GoogleTest)
    endif()
endif()
