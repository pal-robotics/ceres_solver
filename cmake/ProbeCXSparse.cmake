# CXSparse.
if(CXSPARSE)
  # Don't search with REQUIRED as we can continue without CXSparse.
  find_package(CXSparse)
  if(CXSPARSE_FOUND)
    # By default, if CXSparse and all dependencies are found, Ceres is
    # built with CXSparse support.
    message("-- Found CXSparse version: ${CXSPARSE_VERSION}, "
      "building with CXSparse.")
  else()
    # Disable use of CXSparse if it cannot be found and continue.
    message("-- Did not find CXSparse, Building without CXSparse.")
    # Retain the help string associated with the CXSPARSE option
    # when updating it to disable use of CXSparse.
    get_property(HELP_STRING CACHE CXSPARSE PROPERTY HELPSTRING)
    set(CXSPARSE OFF CACHE BOOL "${HELP_STRING}" FORCE)
    add_definitions(-DCERES_NO_CXSPARSE)
  endif()
else()
  message("-- Building without CXSparse.")
  add_definitions(-DCERES_NO_CXSPARSE)
  # Mark as advanced (remove from default GUI view) the CXSparse search
  # variables in case user enabled CXSPARSE, FindCXSparse did not find it, so
  # made search variables visible in GUI for user to set, but then user disables
  # CXSPARSE instead of setting them.
  mark_as_advanced(FORCE CXSPARSE_INCLUDE_DIR
                         CXSPARSE_LIBRARY)
endif()
