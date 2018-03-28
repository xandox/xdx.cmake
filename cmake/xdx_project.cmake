macro(_xdx_make_include_suffix _res _ns)
    string(REPLACE "::" "/" ${_res} "${_ns}")
endmacro()

macro(xdx_project)
    set(_options)
    set(_arguments TYPE NAME NAMESPACE CONFIGURE_HEADER)
    set(_marguments HEADERS SOURCES TESTS PUBLIC_LINK PRIVATE_LINK)
    cmake_parse_arguments(_xdx "${_options}" "${_arguments}" "${_marguments}" ${ARGN})

    if (NOT _xdx_TYPE)
        message(FATAL_ERROR "Type not set.")
    endif()

    if (NOT _xdx_NAME)
        message(FATAL_ERROR "Name not set.")
    endif()

    _xdx_make_include_suffix(_xdx_INCLUDE_SUFFIX _xdx_NAMESPACE)

    set(_xdx_ID "${CMAKE_CURRENT_SOURCE_DIR}/include")
    set(_xdx_SD "${CMAKE_CURRENT_SOURCE_DIR}/src")
    set(_xdx_TD "${CMAKE_CURRENT_SOURCE_DIR}/tests")
    set(_xdx_ID_FULL "${_xdx_ID}/${_xdx_INCLUDE_SUFFIX}")

    unset(_xdx_headers_full)
    foreach (_header ${_xdx_HEADERS})
        list(APPEND _xdx_headers_full ${_xdx_ID_FULL}/${_header})
    endforeach()

    unset(_xdx_sources_full)
    foreach(_source ${_xdx_SOURCES})
        list(APPEND _xdx_sources_full ${_xdx_SD}/${_source})
    endforeach()

    unset(_xdx_tests_full)
    foreach(_source ${_xdx_TESTS})
        list(APPEND _xdx_tests_full ${_xdx_TD}/${_source})
    endforeach()

    if (_xdx_CONFIGURE_HEADER)
        set(_xdx_configure_header_full ${CMAKE_CURRENT_BINARY_DIR}/include/${_xdx_INCLUDE_SUFFIX}/${_xdx_CONFIGURE_HEADER})
        include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/configure.cmake")
        configure(${_xdx_configure_header_full})
        list(APPEND _xdx_headers_full ${_xdx_configure_header_full})
    endif()

    if (_xdx_TYPE STREQUAL "exe")
        add_executable(${_xdx_NAME} ${_xdx_sources_full})
    elseif(_xdx_TYPE STREQUAL "static")
        add_library(${_xdx_NAME} STATIC ${_xdx_sources_full})
    elseif(_xdx_TYPE STREQUAL "shared")
        add_library(${_xdx_NAME} SHARED ${_xdx_sources_full})
        string(REPLACE "-" "_" _xdx_export_header_name ${_xdx_NAME})
        generate_export_header(
            ${_xdx_NAME}
            BASE_NAME ${_xdx_export_header_name}
            DEFINE_NO_DEPRECATED
        )
        file(GENERATED
            OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/include/${_xdx_INCLUDE_SUFFIX}/exports.hpp
            INPUT ${CMAKE_CURRENT_BINARY_DIR}/${_xdx_export_header_name_export.h
        )
        target_include_directories(${_xdx_NAME} INTERFACE PUBLIC ${CMAKE_CURRENT_BINARY_DIR}/include)
        target_compile_definitions(${_xdx_NAME} PRIVATE ${_xdx_export_header_name}_EXPORT)
    elseif(_xdx_TYPE STREQUAL "interface")
        if (_xdx_sources_full)
            message(FATAL_ERROR "Interface target '${_xdx_NAME}' has SOURCES.")
        endif()

        unset(_xdx_interface_dummy_content)
        foreach(_header ${_xdx_HEADERS})
            set(_xdx_interface_dummy_content "${_xdx_interface_dummy_content}#include <${_xdx_INCLUDE_SUFFIX}/${_header}\n")
        endforeach()

        set(_xdx_sources_full ${CMAKE_CURRENT_BINARY_DIR}/${_xdx_NAME}.cpp)
        file(WRITE ${_xdx_sources_full} "${_xdx_interface_dummy_content}")
        add_library(${_xdx_NAME} STATIC ${_xdx_sources_full})
    else()
        message(FATAL_ERROR "Unknown project type: ${_xdx_TYPE}")
    endif()

    if (_xdx_CONFIGURE_HEADER)
        target_include_directories(${_xdx_NAME} PUBLIC ${CMAKE_CURRENT_BINARY_DIR}/include)
    endif()

    target_include_directories(${_xdx_NAME} PUBLIC ${_xdx_ID})
    target_compile_features(${_xdx_NAME} PUBLIC cxx_std_17)

    if (_xdx_PUBLIC_LINK)
        target_link_libraries(${_xdx_NAME} PUBLIC ${_xdx_PUBLIC_LINK})
    endif()

    if (_xdx_PRIVATE_LINK)
        target_link_libraries(${_xdx_NAME} PRIVATE ${_xdx_PRIVATE_LINK})
    endif()

    if (_xdx_tests_full)
        add_executable(${_xdx_NAME}-tests ${_xdx_tests_full})
        target_link_libraries(${_xdx_NAME}-tests GTest::GTest GTest::Main ${_apa_NAME})
        gtest_add_tests(${_xdx_NAME}-tests "" AUTO)
        if (MSVC)
            target_compile_options(${_xdx_NAME}-tests PRIVATE "/IGNORE:4251,4275")
        endif()
    endif()
endmacro()