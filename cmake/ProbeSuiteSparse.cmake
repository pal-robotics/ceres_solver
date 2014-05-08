# SuiteSparse.
if(SUITESPARSE AND NOT LAPACK)
  # If user has disabled LAPACK, but left SUITESPARSE ON, turn it OFF,
  # LAPACK controls whether Ceres will be linked, directly or indirectly
  # via SuiteSparse to LAPACK.
  message("-- Disabling SuiteSparse as use of LAPACK has been disabled, "
    "turn ON LAPACK to enable (optional) building with SuiteSparse.")
  # Retain the help string associated with the SUITESPARSE option
  # when updating it to disable use of SuiteSparse.
  get_property(HELP_STRING CACHE SUITESPARSE PROPERTY HELPSTRING)
  set(SUITESPARSE OFF CACHE BOOL "${HELP_STRING}" FORCE)
endif(SUITESPARSE AND NOT LAPACK)
if(SUITESPARSE)
  # By default, if SuiteSparse and all dependencies are found, Ceres is
  # built with SuiteSparse support.

  # Check for SuiteSparse and dependencies.
  find_package(SuiteSparse)
  if(SUITESPARSE_FOUND)
    # On Ubuntu the system install of SuiteSparse (v3.4.0) up to at least
    # Ubuntu 13.10 cannot be used to link shared libraries.
    if(BUILD_SHARED_LIBS AND
        SUITESPARSE_IS_BROKEN_SHARED_LINKING_UBUNTU_SYSTEM_VERSION)
      message(FATAL_ERROR "You are attempting to build Ceres as a shared "
        "library on Ubuntu using a system package install of SuiteSparse "
        "3.4.0. This package is broken and does not support the "
        "construction of shared libraries (you can still build Ceres as "
        "a static library).  If you wish to build a shared version of Ceres "
        "you should uninstall the system install of SuiteSparse "
        "(libsuitesparse-dev) and perform a source install of SuiteSparse "
        "(we recommend that you use the latest version), "
        "see: http://homes.cs.washington.edu/~sagarwal"
        "/ceres-solver/dev/building.html for more information.")
    endif(BUILD_SHARED_LIBS AND
      SUITESPARSE_IS_BROKEN_SHARED_LINKING_UBUNTU_SYSTEM_VERSION)

    # By default, if all of SuiteSparse's dependencies are found, Ceres is
    # built with SuiteSparse support.
    message("-- Found SuiteSparse ${SUITESPARSE_VERSION}, "
            "building with SuiteSparse.")
  else()
    # Disable use of SuiteSparse if it cannot be found and continue.
    message("-- Did not find all SuiteSparse dependencies, disabling "
      "SuiteSparse support.")
    # Retain the help string associated with the SUITESPARSE option
    # when updating it to disable use of SuiteSparse.
    get_property(HELP_STRING CACHE SUITESPARSE PROPERTY HELPSTRING)
    set(SUITESPARSE OFF CACHE BOOL "${HELP_STRING}" FORCE)
    add_definitions(-DCERES_NO_SUITESPARSE)
  endif()
else()
  message("-- Building without SuiteSparse.")
  add_definitions(-DCERES_NO_SUITESPARSE)
endif()
