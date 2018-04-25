
macro(xdx_umbrella)
    set(_options)
    set(_arguments NAME)
    set(_marguments SUBDIRS)
    cmake_parse_arguments(_xdx "${_options}" "${_arguments}" "${_marguments}" ${ARGN})

    project(${_xdx_NAME} CXX)

    foreach (_sd ${_xdx_SUBDIRS})
        add_subdirectory(${_sd})
    endforeach()
endmacro()

macro(__xdx_required var message)
    if (NOT ${var})
        _xdx_fatal("${message}")
    endif()
endmacro()

macro(xdx_project_begin)
    set(_xdx_ps_OPTIONS)
    set(_xdx_ps_ARGUMENTS TYPE NAME NAMESPACE)
    set(_xdx_ps_MARGUMENTS)
    cmake_parse_arguments(_xdx_project "${_xdx_ps_OPTIONS}" "${_xdx_ps_ARGUMENTS}" "${_xdx_ps_MARGUMENTS}" ${ARGN})
    
    set(__xdx_known_project_types exe static_lib shared_lib interface test)

    __xdx_required(_xdx_project_TYPE "Project type not set")
    __xdx_required(_xdx_project_NAME "Project name not set")

    _xdx_status("New '${_xdx_project_TYPE}' project: '${_xdx_project_NAME}'")

    list(FIND __xdx_known_project_types "${_xdx_project_TYPE}" __xdx_type_index)

    if (__xdx_type_index EQUAL -1)
        _xdx_fatal("Unknown project type: '${_xdx_project_TYPE}'")
    endif()

    project(${_xdx_ps_NAME} CXX)

    string(REPLACE "::" "/" _xdx_project_INCLUDE_PREFIX "${_xdx_project_NAMESPACE}")

    set(_xdx_project_SOURCE_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/include")
    set(_xdx_project_BINARY_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/include")
    set(_xdx_project_SOURCE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src")
    set(_xdx_project_BINARY_SOURCE_DIR "${CMAKE_CURRENT_BINARY_DIR}/src")
    set(_xdx_project_SOURCE_TESTS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/tests")
    set(_xdx_project_BINARY_TESTS_DIR "${CMAKE_CURRENT_BINARY_DIR}/tests")
endmacro()

macro(xdx_exe_begin)
    xdx_project_begin(TYPE exe ${ARGN})
endmacro()

macro(xdx_static_lib_begin)
    xdx_project_begin(TYPE static_lib ${ARGN})
endmacro()

macro(xdx_shared_lib_begin)
    xdx_project_begin(TYPE shared_lib ${ARGN})
endmacro()

macro(xdx_interface_begin)
    xdx_project_begin(TYPE interface ${ARGN})
endmacro()

macro(xdx_test_begin)
    xdx_project_begin(TYPE test ${ARGN})
endmacro()

macro(__xdx_add_exe_target)
    add_executable(${_xdx_project_NAME} ${_xdx_project_SOURCES})
endmacro()

macro(__xdx_add_file_to_list listname filename content)
    if (NOT EXISTS filename)
        if (XDX_GENERATE_MISSING_FILES)
            file(WRITE ${filename} ${content})
        endif()
    endif()
    list(APPEND ${listname} ${filename})
endmacro()

function(__xdx_generate_tests_content result)
    string(REPLACE "::" "_" prefix "${_xdx_project_NAMESPACE}")
    set(content "#include <gtest/gtest.h>")
    set(content "${content}TEST(${prefix}_tests, empty_test) {}\n\n")
    set(${result} "${content}")
endfunction()

function(__xdx_generate_source_content result filename)
    get_filename_component(source_dir ${filename} DIRECTORY) 
    get_filename_component(source_name_we ${filename} NAME_WE)
    set(content "#include <${_xdx_project_INCLUDE_PREFIX}/")
    if (NOT "${source_dir}" STREQUAL "")
        set(content "${content}${__xdx_source_dir}/")
    endif()

    set(content "${content}${source_name_we}.hpp>\n\n")
    set(content "${content}namespace ${_xdx_project_NAMESPACE} {\n\n")
    set(content "${content}}\n")
    set(${result} "${content}")
endfunction()

function(__xdx_generate_header_content result)
    set(content "#pragma once")
    set(content "${content}namespace ${_xdx_project_NAMESPACE} {\n\n")
    set(content "${content}}\n")
    set(${result} "${content}")
endfunction()


macro(xdx_project_add_sources)
    foreach(sf ${ARGN})
        __xdx_generate_source_content(__xdx_source_file_content ${sf})
        __xdx_add_file_to_list(_xdx_project_SOURCES ${_xdx_project_SOURCE_SOURCE_DIR}/${sf} "${__xdx_source_file_content}")
    endforeach()
    unset(__xdx_source_file_content)
endmacro()

macro(xdx_project_add_headers)
    foreach(sf ${ARGN})
        __xdx_generate_header_content(__xdx_header_file_content)
        __xdx_add_file_to_list(_xdx_project_HEADERS ${_xdx_project_SOURCE_INCLUDE_DIR}/${_xdx_project_INCLUDE_PREFIX}/${sf} "${__xdx_header_file_content}")
    endforeach()
    unset(__xdx_header_file_content)
endmacro()

macro(xdx_project_add_tests)
    foreach(sf ${ARGN})
        __xdx_generate_tests_content(__xdx_test_file_content)
        __xdx_add_file_to_list(_xdx_project_TESTS_SOURCES ${_xdx_project_SOURCE_TESTS_DIR}/${sf} "${__xdx_test_file_content}")
    endforeach()
    unset(__xdx_test_file_content)
endmacro()

macro(xdx_project_configure filename)
    include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/configure.cmake")
    configure(${_xdx_project_BINARY_INCLUDE_DIR}/${_xdx_INCLUDE_PREFIX}/${filename})
    list(APPEND _xdx_project_HEADERS ${_xdx_project_BINARY_INCLUDE_DIR}/${_xdx_INCLUDE_PREFIX}/${filename})
endmacro()

macro(xdx_project_add_public_links)
    list(APPEND _xdx_project_PUBLIC_LINKS ${ARGN})
endmacro()

macro(xdx_project_add_private_links)
    list(APPEND _xdx_project_PRIVATE_LINKS ${ARGN})
endmacro()

macro(__xdx_add_tests_to_target)
    if (XDX_ENABLE_TESTING AND _xdx_project_TESTS_SOURCES)
        add_executable(${_xdx_project_NAME}.tests ${_xdx_project_TESTS_SOURCES})
        target_link_libraries(${_xdx_project_NAME}.tests PRIVATE GTest::GTest GTest::Main ${_xdx_project_NAME})
        gtest_add_tests(${_xdx_project_NAME}.tests "" AUTO)
        if (MSVC)
            target_compile_options(${_xdx_project_NAME}.tests PRIVATE "/IGNORE:4251,4275")
        endif()
    endif()
endmacro()

macro(__xdx_add_static_lib_target)
    add_library(${_xdx_project_NAME} STATIC ${_xdx_project_SOURCES})
    __xdx_add_tests_to_target()
    target_include_directories(${_xdx_project_NAME} PUBLIC ${_xdx_project_SOURCE_INCLUDE_DIR})
    target_include_directories(${_xdx_project_NAME} PUBLIC ${_xdx_project_BINARY_INCLUDE_DIR})
endmacro()

macro(__xdx_add_shared_lib_target)
    add_library(${_xdx_project_NAME} SHARED ${_xdx_project_SOURCES})

    string(REPLACE "-" "_" _xdx_export_header_name ${_xdx_project_NAME})
    generate_export_header(
        ${_xdx_project_NAME}
        BASE_NAME ${_xdx_export_header_name}
        DEFINE_NO_DEPRECATED
    )
    file(GENERATED
        OUTPUT ${_xdx_project_BINARY_INCLUDE_DIR}/${_xdx_project_INCLUDE_PREFIX}/exports.hpp
        INPUT ${CMAKE_CURRENT_BINARY_DIR}/${_xdx_export_header_name}_export.h
    )
    target_compile_definitions(${_xdx_project_NAME} PRIVATE ${_xdx_export_header_name}_EXPORT)
    target_include_directories(${_xdx_project_NAME} PUBLIC ${_xdx_project_SOURCE_INCLUDE_DIR})
    target_include_directories(${_xdx_project_NAME} PUBLIC ${_xdx_project_BINARY_INCLUDE_DIR})

    __xdx_add_tests_to_target()
endmacro()

macro(__xdx_add_interface_target)
        if (_xdx_project_SOURCES)
            _xdx_fatal("Interface target '${_xdx_project_NAME}' has SOURCES.")
        endif()

        unset(_xdx_interface_dummy_content)
        foreach(_header ${_xdx_project_HEADERS})
            set(_xdx_interface_dummy_content "${_xdx_interface_dummy_content}#include <${_xdx_project_INCLUDE_SUFFIX}/${_header}>\n")
        endforeach()

        set(_xdx_project_SOURCES ${CMAKE_CURRENT_BINARY_DIR}/${_xdx_project_NAME}.cpp)
        file(WRITE ${_xdx_project_SOURCES} "${_xdx_interface_dummy_content}")
        __xdx_add_static_lib_target()
endmacro()

macro(__xdx_add_test_target)
    if (NOT XDX_ENABLE_TESTING)
        _xdx_status("Testing is disabled. Project '${_xdx_project_NAME}' will not be configured")
        return()
    endif()
    __xdx_add_exe_target()
    target_link_libraries(${_xdx_project_NAME} PRIVATE GTest::GTest GTest::Main)
    gtest_add_tests(${__xdx_project_NAME} "" AUTO)
    if (MSVC)
        target_compile_options(${_xdx_project_NAME} PRIVATE "/IGNORE:4251,4275")
    endif()
endmacro()

macro(xdx_project_end)
    if (_xdx_project_TYPE STREQUAL "exe")
        __xdx_add_exe_target()
    elseif(_xdx_project_TYPE STREQUAL "static_lib")
        __xdx_add_static_lib_target()
    elseif(_xdx_project_TYPE STREQUAL "shared_lib")
        __xdx_add_shared_lib_target()
    elseif(_xdx_project_TYPE STREQUAL "interface")
        __xdx_add_interface_target()
    elseif(_xdx_project_TYPE STREQUAL "test")
        __xdx_add_test_target()
    else()
        _xdx_fatal("Unknown project type: '${_xdx_project_TYPE}'")
    endif()

    target_compile_features(${_xdx_project_NAME} PUBLIC ${XDX_CPP_STANDARD})
    if (${CMAKE_CXX_COMPILER_ID} MATCHES "GNU") 
        target_link_libraries(${_xdx_project_NAME} PUBLIC stdc++fs)
    endif()
    target_link_libraries(${_xdx_project_NAME} PUBLIC ${__xdx_project_PUBLIC_LINKS})
    target_link_libraries(${_xdx_project_NAME} PRIVATE ${__xdx_project_PRIVATE_LINKS})
endmacro()

macro(xdx_static_lib_end)
    xdx_project_end(${ARGN})
endmacro()

macro(xdx_shared_lib_end)
    xdx_project_end(${ARGN})
endmacro()

macro(xdx_interface_end)
    xdx_project_end(${ARGN})
endmacro()

macro(xdx_test_end)
    xdx_project_end(${ARGN})
endmacro()
