cmake_minimum_required(VERSION 3.10)

if (_XDX_CMAKE_18e05eed_78ad_4a50_bf0b_6b3eb2d3b6c9)
    return()
endif()

set(_xdx_root_dir ${CMAKE_CURRENT_LIST_DIR})

set(CMAKE_CXX_EXTENSIONS OFF)

macro(_xdx_status string_message)
    message(STATUS "=XDX= ${string_message}")
endmacro()

macro(_xdx_fatal string_message)
    message(FATAL_ERROR "!XDX! ${string_message}")
endmacro()

macro(_xdx_warning string_message)
    message(WARNING "~XDX~ ${string_message}")
endmacro()

set(_XDX_CMAKE_18e05eed_78ad_4a50_bf0b_6b3eb2d3b6c9 1)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

include(${_xdx_root_dir}/xdx/xdx_project.cmake)
include(${_xdx_root_dir}/xdx/xdx_settings.cmake)
include(${_xdx_root_dir}/xdx/xdx_remote_repo.cmake)
include(${_xdx_root_dir}/xdx/xdx_deps.cmake)

if (EXISTS ${CMAKE_SOURCES_DIR}/cmake/xdx_project_extend.cmake)
    include(${CMAKE_SOURCES_DIR}/cmake/xdx_project_extend.cmake)
endif()

if (XDX_ENABLE_TESTING)
    include(GoogleTest)
    find_package(GTest)
    if (NOT GTEST_FOUND)
        set(XDX_ENABLE_TESTING OFF CACHE BOOL "Enable and build tests" FORCE)
        _xdx_status("Google test framework not found. Disable them.")
    else()
        _xdx_status("Google test framework found. Testing enabled.")
        enable_testing()
    endif()
endif()
