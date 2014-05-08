# LAPACK (& BLAS).
if(LAPACK)
  find_package(LAPACK QUIET)
  if(LAPACK_FOUND)
    message("-- Found LAPACK library: ${LAPACK_LIBRARIES}")
  else()
    message("-- Did not find LAPACK library, disabling LAPACK support.")
  endif()

  find_package(BLAS QUIET)
  if(BLAS_FOUND)
    message("-- Found BLAS library: ${BLAS_LIBRARIES}")
  else()
    message("-- Did not find BLAS library, disabling LAPACK support.")
  endif()

  if(NOT (LAPACK_FOUND AND BLAS_FOUND))
    # Retain the help string associated with the LAPACK option
    # when updating it to disable use of LAPACK.
    get_property(HELP_STRING CACHE LAPACK PROPERTY HELPSTRING)
    set(LAPACK OFF CACHE BOOL "${HELP_STRING}" FORCE)
    add_definitions(-DCERES_NO_LAPACK)
  endif(NOT (LAPACK_FOUND AND BLAS_FOUND))
else()
  message("-- Building without LAPACK.")
  add_definitions(-DCERES_NO_LAPACK)
endif()
