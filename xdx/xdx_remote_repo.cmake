macro(xdx_remote_repo)
    set(options)
    set(oneValueArgs
        PROJ
        # Prevent the following from being passed through
        CONFIGURE_COMMAND
        BUILD_COMMAND
        INSTALL_COMMAND
        TEST_COMMAND
    )
    set(multiValueArgs "")

    cmake_parse_arguments(_xdx_rr "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    set(OUTPUT_QUIET "OUTPUT_QUIET")
    _xdx_status("Downloading/updating ${_xdx_rr_PROJ}")

    set(_xdx_rr_DOWNLOAD_DIR ${CMAKE_BINARY_DIR}/${XDX_DEPS_DIR_NAME}/downloads/${_xdx_rr_PROJ})
    set(_xdx_rr_SOURCE_DIR ${CMAKE_SOURCE_DIR}/${XDX_DEPS_DIR_NAME}/${_xdx_rr_PROJ})
    set(_xdx_rr_BUILD_DIR ${CMAKE_BINARY_DIR}/${XDX_DEPS_DIR_NAME}/${_xdx_rr_PROJ})
    set(${_xdx_rr_PROJ}_SOURCE_DIR "${_xdx_rr_SOURCE_DIR}")

    #set(${DL_ARGS_PROJ}_SOURCE_DIR "${DL_ARGS_SOURCE_DIR}")
    #set(${DL_ARGS_PROJ}_BINARY_DIR "${DL_ARGS_BINARY_DIR}")

    # The way that CLion manages multiple configurations, it causes a copy of
    # the CMakeCache.txt to be copied across due to it not expecting there to
    # be a project within a project.  This causes the hard-coded paths in the
    # cache to be copied and builds to fail.  To mitigate this, we simply
    # remove the cache if it exists before we configure the new project.  It
    # is safe to do so because it will be re-generated.  Since this is only
    # executed at the configure step, it should not cause additional builds or
    # downloads.
    file(REMOVE "${_xdx_rr_DOWNLOAD_DIR}/CMakeCache.txt")

    # Create and build a separate CMake project to carry out the download.
    # If we've already previously done these steps, they will not cause
    # anything to be updated, so extra rebuilds of the project won't occur.
    # Make sure to pass through CMAKE_MAKE_PROGRAM in case the main project
    # has this set to something not findable on the PATH.
    configure_file("${_xdx_root_dir}/xdx/xdx_remote_repo.CMakeLists.cmake.in"
                   "${_xdx_rr_DOWNLOAD_DIR}/CMakeLists.txt")

    execute_process(COMMAND ${CMAKE_COMMAND} 
        -G "${CMAKE_GENERATOR}" .
        RESULT_VARIABLE result
        ${OUTPUT_QUIET}
        WORKING_DIRECTORY "${_xdx_rr_DOWNLOAD_DIR}"
    )

    if(result)
        _xdx_fatal("CMake step for ${_xdx_rr_PROJ} failed: ${result}")
    endif()


    execute_process(COMMAND ${CMAKE_COMMAND} --build .
                    RESULT_VARIABLE result
                    ${OUTPUT_QUIET}
                    WORKING_DIRECTORY "${_xdx_rr_DOWNLOAD_DIR}"
    )

    if(result)
        _xdx_fatal("Build step for ${_xdx_rr_PROJ} failed: ${result}")
    endif()

    add_subdirectory(${_xdx_rr_SOURCE_DIR})

    if (EXISTS ${_xdx_rr_SOURCE_DIR}/xdx_source_type.cmake)
        include(${_xdx_rr_SOURCE_DIR}/xdx_source_type.cmake)
    endif()

endmacro()
