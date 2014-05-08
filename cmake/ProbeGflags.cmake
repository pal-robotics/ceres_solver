# GFlags.
if(GFLAGS)
  handle_legacy_include_dependency_hint(GFLAGS_INCLUDE GFLAGS_INCLUDE_DIR_HINTS)
  handle_legacy_library_dependency_hint(GFLAGS_LIB GFLAGS_LIBRARY_DIR_HINTS)

  # Don't search with REQUIRED as we can continue without gflags.
  find_package(Gflags)
  if(GFLAGS_FOUND)
    message("-- Found Google Flags header in: ${GFLAGS_INCLUDE_DIRS}")
  else()
    message("-- Did not find Google Flags (gflags), Building without gflags "
      "- no tests or tools will be built!")
    # Retain the help string associated with the GFLAGS option
    # when updating it to disable use of gflags.
    get_property(HELP_STRING CACHE GFLAGS PROPERTY HELPSTRING)
    set(GFLAGS OFF CACHE BOOL "${HELP_STRING}" FORCE)
    add_definitions(-DCERES_NO_GFLAGS)
  endif()
else()
  message("-- Google Flags disabled; no tests or tools will be built!")
  add_definitions(-DCERES_NO_GFLAGS)
  # Mark as advanced (remove from default GUI view) the gflags search
  # variables in case user enabled GFLAGS, FindGflags did not find it, so
  # made search variables visible in GUI for user to set, but then user disables
  # GFLAGS instead of setting them.
  mark_as_advanced(FORCE GFLAGS_INCLUDE_DIR
                         GFLAGS_LIBRARY)
endif()
