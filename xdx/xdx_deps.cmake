include(ExternalProject)

macro(xdx_source_dependency _name)
    set(_options)
    set(_arguments REPOSITORY BRANCH TAG COMMIT)
    set(_marguments)
    cmake_parse_arguments(_xdx "${_options}" "${_arguments}" "${_marguments}" ${ARGN})

    unset(_xdx_GIT_TAG_ARG)

    if (_xdx_COMMIT)
        set(_xdx_GIT_TAG_ARG ${_xdx_COMMIT})
    elseif (_xdx_TAG)
        set(_xdx_GIT_TAG_ARG ${_xdx_TAG})
    elseif (_xdx_BRANCH)
        set(_xdx_GIT_TAG_ARG ${_xdx_BRANCH})
    else ()
        _xdx_warning("No BRANCH TAG of COMMIT set. Using branch 'master'")
        set(_xdx_GIT_TAG_ARG master)
    endif ()

    xdx_remote_repo(
        PROJ ${_name}
        GIT_REPOSITORY "${_xdx_REPOSITORY}"
        GIT_TAG "${_xdx_GIT_TAG_ARG}"
    )

endmacro()
