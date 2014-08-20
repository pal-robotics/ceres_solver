# Ceres Solver - A fast non-linear least squares minimizer
# Copyright 2010, 2011, 2012 Google Inc. All rights reserved.
# http://code.google.com/p/ceres-solver/
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# * Neither the name of Google Inc. nor the names of its contributors may be
#   used to endorse or promote products derived from this software without
#   specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# Author: keir@google.com (Keir Mierle)
# With modifications from Paul Mathieu (paul.mathieu@pal-robotics.com)

cmake_minimum_required(VERSION 2.8.3)

project(ceres_solver C CXX)

# Make CMake aware of the cmake folder for local FindXXX scripts.
set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

# Important: Always bump the second number (e.g. 1.3.x to 1.4.0) for any
# release that changes the ABI. The ABI changes for almost any modification to
# include/ceres (e.g. the public API). If you are unsure about whether
# something is an ABI change, please ask on the list.
#
# For versions without ABI changes, bump the smallest number in CERES_VERSION,
# but leave the CERES_ABI_VERSION unchanged.
set(CERES_VERSION_MAJOR 1)
set(CERES_VERSION_MINOR 8)
set(CERES_VERSION_PATCH 0)
set(CERES_VERSION
    ${CERES_VERSION_MAJOR}.${CERES_VERSION_MINOR}.${CERES_VERSION_PATCH})
set(CERES_ABI_VERSION 1.8.0)

option(MINIGLOG "Use a stripped down version of glog." ON)
option(GFLAGS "Enable Google Flags." FALSE)
option(SUITESPARSE "Enable SuiteSparse." ON)
option(CXSPARSE "Enable CXSparse." ON)
option(LAPACK "Enable use of LAPACK." ON)
# Template specializations for the Schur complement based solvers. If
# compile time, binary size or compiler performance is an issue, you
# may consider disabling this.
option(SCHUR_SPECIALIZATIONS "Enable fixed-size schur specializations." ON)
option(CUSTOM_BLAS
       "Use handcoded BLAS routines (usually faster) instead of Eigen."
       ON)
# Multithreading using OpenMP
option(OPENMP "Enable threaded solving in Ceres (requires OpenMP)" ON)

# Line search minimizer is useful for large scale problems or when
# sparse linear algebra libraries are not available. If compile time,
# binary size or compiler performance is an issue, consider disabling
# this.
option(LINE_SEARCH_MINIMIZER "Enable the line search minimizer." ON)
option(BUILD_TESTING "Enable tests" ON)
option(BUILD_DOCUMENTATION "Build User's Guide (html)" OFF)
option(BUILD_EXAMPLES "Build examples" OFF)
option(BUILD_SHARED_LIBS "Build Ceres as a shared library." OFF)
if(MSVC)
  option(MSVC_USE_STATIC_CRT
    "MS Visual Studio: Use static C-Run Time Library in place of shared." OFF)
endif()

find_package(catkin REQUIRED)
find_package(Eigen REQUIRED)

include(cmake/ProbeLAPACK.cmake)
include(cmake/ProbeSuiteSparse.cmake)
include(cmake/ProbeCXSparse.cmake)
include(cmake/ProbeGflags.cmake)
include(cmake/ProbeGlog.cmake)

# A few Ceres flags
if(NOT SCHUR_SPECIALIZATIONS)
  add_definitions(-DCERES_RESTRICT_SCHUR_SPECIALIZATION)
  message("-- Disabling Schur specializations (faster compiles)")
endif(NOT SCHUR_SPECIALIZATIONS)

if(NOT LINE_SEARCH_MINIMIZER)
  add_definitions(-DCERES_NO_LINE_SEARCH_MINIMIZER)
  message("-- Disabling line search minimizer")
endif(NOT LINE_SEARCH_MINIMIZER)

if(NOT CUSTOM_BLAS)
  add_definitions(-DCERES_NO_CUSTOM_BLAS)
  message("-- Disabling custom blas")
endif(NOT CUSTOM_BLAS)

include(cmake/ProbeOpenMP.cmake)

include(CheckIncludeFileCXX)
check_include_file_cxx(unordered_map UNORDERED_MAP_IN_STD_NAMESPACE)
If (UNORDERED_MAP_IN_STD_NAMESPACE)
  add_definitions(-DCERES_STD_UNORDERED_MAP)
else()
  check_include_file_cxx("tr1/unordered_map" UNORDERED_MAP_IN_TR1_NAMESPACE)
  if(UNORDERED_MAP_IN_TR1_NAMESPACE)
    add_definitions(-DCERES_TR1_UNORDERED_MAP)
  else()
    message("-- Unable to find <unordered_map> or <tr1/unordered_map>. ")
    message("-- Replacing unordered_map/set with map/set (warning: slower!)")
    add_definitions(-DCERES_NO_UNORDERED_MAP)
  endif()
endif()

include_directories(
  include
  internal
  internal/ceres
  ${GLOG_INCLUDE_DIRS}
  ${EIGEN_INCLUDE_DIRS})

if(SUITESPARSE)
  include_directories(${SUITESPARSE_INCLUDE_DIRS})
endif()

if(CXSPARSE)
  include_directories(${CXSPARSE_INCLUDE_DIRS})
endif()

if(GFLAGS)
  include_directories(${GFLAGS_INCLUDE_DIRS})
endif()

# Change the default build type from Debug to Release, while still
# supporting overriding the build type.
#
# The CACHE STRING logic here and elsewhere is needed to force CMake
# to pay attention to the value of these variables.
if(NOT CMAKE_BUILD_TYPE)
  message("-- No build type specified; defaulting to CMAKE_BUILD_TYPE=Release.")
  set(CMAKE_BUILD_TYPE Release CACHE STRING
    "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel."
    FORCE)
else(NOT CMAKE_BUILD_TYPE)
  if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    message("\n=================================================================================")
    message("\n-- Build type: Debug. Performance will be terrible!")
    message("-- Add -DCMAKE_BUILD_TYPE=Release to the CMake command line to get an optimized build.")
    message("\n=================================================================================")
  endif(CMAKE_BUILD_TYPE STREQUAL "Debug")
endif(NOT CMAKE_BUILD_TYPE)

# Set the default Ceres flags to an empty string.
set(CERES_CXX_FLAGS)

if(CMAKE_BUILD_TYPE STREQUAL "Release")
  if(CMAKE_COMPILER_IS_GNUCXX)
    # Linux
    if(CMAKE_SYSTEM_NAME MATCHES "Linux")
      if(NOT GCC_VERSION VERSION_LESS 4.2)
        SET (CERES_CXX_FLAGS "${CERES_CXX_FLAGS} -march=native -mtune=native")
      endif(NOT GCC_VERSION VERSION_LESS 4.2)
    endif(CMAKE_SYSTEM_NAME MATCHES "Linux")
    # Mac OS X
    if(CMAKE_SYSTEM_NAME MATCHES "Darwin")
      SET (CERES_CXX_FLAGS "${CERES_CXX_FLAGS} -msse3")
      # Use of -fast only applicable for Apple's GCC
      # Assume this is being used if GCC version < 4.3 on OSX
      execute_process(COMMAND ${CMAKE_C_COMPILER}
        ARGS ${CMAKE_CXX_COMPILER_ARG1} -dumpversion
        OUTPUT_VARIABLE GCC_VERSION
        OUTPUT_STRIP_TRAILING_WHITESPACE)
      if(GCC_VERSION VERSION_LESS 4.3)
        SET (CERES_CXX_FLAGS "${CERES_CXX_FLAGS} -fast")
      endif(GCC_VERSION VERSION_LESS 4.3)
    endif(CMAKE_SYSTEM_NAME MATCHES "Darwin")
  endif()
  if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    # Use of -O4 requires use of gold linker & LLVM-gold plugin, which might
    # well not be present / in use and without which files will compile, but
    # not link ('file not recognized') so explicitly check for support
    include(CheckCXXCompilerFlag)
    check_cxx_compiler_flag("-O4" HAVE_LTO_SUPPORT)
    if(HAVE_LTO_SUPPORT)
      message(STATUS "Enabling link-time optimization (-O4)")
      set(CERES_CXX_FLAGS "${CERES_CXX_FLAGS} -O4")
    else()
      message(STATUS "Compiler/linker does not support link-time optimization (-O4), disabling.")
    endif()
  endif()
endif(CMAKE_BUILD_TYPE STREQUAL "Release")

SET (CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} ${CERES_CXX_FLAGS}")

# After the tweaks for the compile settings, disable some warnings on MSVC.
if(MSVC)
  # Disable signed/unsigned int conversion warnings.
  add_definitions("/wd4018")
  # Disable warning about using struct/class for the same symobl.
  add_definitions("/wd4099")
  # Disable warning about the insecurity of using "std::copy".
  add_definitions("/wd4996")
  # Disable performance warning about int-to-bool conversion.
  add_definitions("/wd4800")
  # Disable performance warning about fopen insecurity.
  add_definitions("/wd4996")
  # Disable warning about int64 to int32 conversion. Disabling
  # this warning may not be correct; needs investigation.
  # TODO(keir): Investigate these warnings in more detail.
  add_definitions("/wd4244")
  # It's not possible to use STL types in DLL interfaces in a portable and
  # reliable way. However, that's what happens with Google Log and Google Flags
  # on Windows. MSVC gets upset about this and throws warnings that we can't do
  # much about. The real solution is to link static versions of Google Log and
  # Google Test, but that seems tricky on Windows. So, disable the warning.
  add_definitions("/wd4251")

  # Google Flags doesn't have their DLL import/export stuff set up correctly,
  # which results in linker warnings. This is irrelevant for Ceres, so ignore
  # the warnings.
  set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /ignore:4049")

  # Update the C/CXX flags for MSVC to use either the static or shared
  # C-Run Time (CRT) library based on the user option: MSVC_USE_STATIC_CRT.
  list(APPEND C_CXX_FLAGS
    CMAKE_CXX_FLAGS
    CMAKE_CXX_FLAGS_DEBUG
    CMAKE_CXX_FLAGS_RELEASE
    CMAKE_CXX_FLAGS_MINSIZEREL
    CMAKE_CXX_FLAGS_RELWITHDEBINFO)

  foreach(FLAG_VAR ${C_CXX_FLAGS})
    if(MSVC_USE_STATIC_CRT)
      # Use static CRT.
      if(${FLAG_VAR} MATCHES "/MD")
        string(REGEX REPLACE "/MD" "/MT" ${FLAG_VAR} "${${FLAG_VAR}}")
      endif(${FLAG_VAR} MATCHES "/MD")
    else()
      # Use shared, not static, CRT.
      if(${FLAG_VAR} MATCHES "/MT")
        string(REGEX REPLACE "/MT" "/MD" ${FLAG_VAR} "${${FLAG_VAR}}")
      endif(${FLAG_VAR} MATCHES "/MT")
    endif()
  endforeach()

  # Tuple sizes of 10 are used by Gtest.
  add_definitions("-D_VARIADIC_MAX=10")
endif()

if(UNIX)
  # GCC is not strict enough by default, so enable most of the warnings.
  set(CMAKE_CXX_FLAGS
    "${CMAKE_CXX_FLAGS} -Werror -Wall -Wextra -Wno-unknown-pragmas -Wno-sign-compare -Wno-unused-parameter -Wno-missing-field-initializers")
endif()

# Use a larger inlining threshold for Clang, since it hobbles Eigen,
# resulting in an unreasonably slow version of the blas routines. The
# -Qunused-arguments is needed because CMake passes the inline
# threshold to the linker and clang complains about it and dies.
if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  set(CMAKE_CXX_FLAGS
      "${CMAKE_CXX_FLAGS} -Qunused-arguments -mllvm -inline-threshold=600")
  # Older versions of Clang (<= 2.9) do not support the 'return-type-c-linkage'
  # option, so check for its presence before adding it to the default flags set.
  include(CheckCXXCompilerFlag)
  check_cxx_compiler_flag("-Wno-return-type-c-linkage"
                          HAVE_RETURN_TYPE_C_LINKAGE)
  if(HAVE_RETURN_TYPE_C_LINKAGE)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-return-type-c-linkage")
  endif()
endif()

# Xcode 4.5.x used Clang 4.1 (Apple version), this has a bug that prevents
# compilation of Ceres.
if(APPLE AND CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  execute_process(COMMAND ${CMAKE_CXX_COMPILER}
    ARGS ${CMAKE_CXX_COMPILER_ARG1} -dumpversion
    OUTPUT_VARIABLE CLANG_VERSION
    OUTPUT_STRIP_TRAILING_WHITESPACE)
  # Use version > 4.0 & < 4.2 to catch all 4.1(.x) versions.
  if(CLANG_VERSION VERSION_GREATER 4.0 AND
      CLANG_VERSION VERSION_LESS 4.2)
    message(FATAL_ERROR "You are attempting to build Ceres on OS X using Xcode "
      "4.5.x (Clang version: ${CLANG_VERSION}). This version of Clang has a "
      "bug that prevents compilation of Ceres, please update to "
      "Xcode >= 4.6.3.")
  endif(CLANG_VERSION VERSION_GREATER 4.0 AND
    CLANG_VERSION VERSION_LESS 4.2)
endif(APPLE AND CMAKE_CXX_COMPILER_ID STREQUAL "Clang")

# Catkin part

set(libs ceres)
if(MINIGLOG)
  list(APPEND libs miniglog)
  set(MINIGLOG_INCL ${CMAKE_CURRENT_SOURCE_DIR}/internal/ceres/miniglog)
else()
  list(APPEND deps GLOG)
endif()
if(SUITESPARSE AND SUITESPARSE_FOUND)
  list(APPEND deps SUITESPARSE)
endif()
if(CXSPARSE AND CXSPARSE_FOUND)
  list(APPEND deps CXSPARSE)
endif()
if(BLAS_FOUND AND LAPACK_FOUND)
  list(APPEND deps BLAS LAPACK)
endif()

catkin_package(
  INCLUDE_DIRS include ${MINIGLOG_INCL}
  LIBRARIES ${libs}
  DEPENDS ${deps}
)


add_subdirectory(internal/ceres)

if(BUILD_DOCUMENTATION)
  message("-- Documentation building is enabled")

  # Generate the User's Guide (html).
  # The corresponding target is UserGuide, but is included in ALL.
  add_subdirectory(docs)
endif()

if(BUILD_EXAMPLES)
  message("-- Build the examples.")
  add_subdirectory(examples)
else()
  message("-- Do not build any example.")
endif()

# Setup installation of Ceres public headers.
install(DIRECTORY include/ceres/
  DESTINATION ${CATKIN_PACKAGE_INCLUDE_DESTINATION})

if(MINIGLOG)
  # Install miniglog header if being used as logging #includes appear in
  # installed public Ceres headers.
  install(FILES internal/ceres/miniglog/glog/logging.h
    DESTINATION ${CATKIN_PACKAGE_INCLUDE_DESTINATION}/internal/miniglog/glog)
endif()

# Set relative install paths, which are appended to CMAKE_INSTALL_PREFIX to
# generate the absolute install paths.
if(WIN32)
  set(RELATIVE_CMAKECONFIG_INSTALL_DIR CMake)
else()
  set(RELATIVE_CMAKECONFIG_INSTALL_DIR share/Ceres)
endif()
