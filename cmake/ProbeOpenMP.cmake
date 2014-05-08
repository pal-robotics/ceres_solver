if(OPENMP)
  # Clang does not (yet) support OpenMP.
  if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    # Retain the help string associated with the OPENMP option
    # when updating it to disable use of OPENMP.
    get_property(HELP_STRING CACHE OPENMP PROPERTY HELPSTRING)
    set(OPENMP OFF CACHE BOOL "${HELP_STRING}" FORCE)
    message("-- Compiler is Clang, disabling OpenMP.")
    add_definitions(-DCERES_NO_THREADS)
  ELSE (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    # Find quietly s/t as we can continue without OpenMP if it is not found.
    find_package(OpenMP QUIET)
    if(OPENMP_FOUND)
      message("-- Building with OpenMP.")
      add_definitions(-DCERES_USE_OPENMP)
      set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
      if(UNIX)
        # At least on Linux, we need pthreads to be enabled for mutex to
        # compile.  This may not work on Windows or Android.
        find_package(Threads REQUIRED)
        add_definitions(-DCERES_HAVE_PTHREAD)
        add_definitions(-DCERES_HAVE_RWLOCK)
      endif()
    else()
      message("-- Failed to find OpenMP, disabling.")
      # Retain the help string associated with the OPENMP option
      # when updating it to disable use of OPENMP.
      get_property(HELP_STRING CACHE OPENMP PROPERTY HELPSTRING)
      set(OPENMP OFF CACHE BOOL "${HELP_STRING}" FORCE)
      add_definitions(-DCERES_NO_THREADS)
    endif()
  endif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
else()
  message("-- Building without OpenMP (disabling multithreading).")
  add_definitions(-DCERES_NO_THREADS)
endif()
