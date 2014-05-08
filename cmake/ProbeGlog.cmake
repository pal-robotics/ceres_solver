# MiniGLog.
if(MINIGLOG)
  set(GLOG_LIBRARIES miniglog)
  message("-- Using minimal Glog substitute (library): ${GLOG_LIBRARIES}")
  set(GLOG_INCLUDE_DIRS internal/ceres/miniglog)
  message("-- Using minimal Glog substitute (include): ${GLOG_INCLUDE_DIRS}")

  # Mark as advanced (remove from default GUI view) the glog search
  # variables in case user disables MINIGLOG, FindGlog did not find it, so
  # made search variables visible in GUI for user to set, but then user enables
  # MINIGLOG instead of setting them.
  mark_as_advanced(FORCE GLOG_INCLUDE_DIR
                         GLOG_LIBRARY)
else()
  handle_legacy_include_dependency_hint(GLOG_INCLUDE GLOG_INCLUDE_DIR_HINTS)
  handle_legacy_library_dependency_hint(GLOG_LIB GLOG_LIBRARY_DIR_HINTS)

  # Don't search with REQUIRED so that configuration continues if not found and
  # we can output an error messages explaining MINIGLOG option.
  find_package(Glog)
  if(GLOG_FOUND)
    message("-- Found Google Log header in: ${GLOG_INCLUDE_DIRS}")
  else()
    message(FATAL_ERROR "Can't find Google Log. Please set GLOG_INCLUDE_DIR & "
      "GLOG_LIBRARY or enable MINIGLOG option to use minimal glog "
      "implementation.")
  endif()
endif()
