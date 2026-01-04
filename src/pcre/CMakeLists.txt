cmake_minimum_required(VERSION 4.0)
project(sqlite3-pcre)

option(SQLITE3_32  "Create 32-bit binaries" ON)
option(SQLITE3_PCRE_FETCH "Fetch pcre sources from GitHub and patch" ON)

if(SQLITE3_PCRE_FETCH)
    include(FetchContent)

    FetchContent_Declare(sqlite3-pcre GIT_REPOSITORY https://github.com/ralight/sqlite3-pcre.git)
    FetchContent_MakeAvailable(sqlite3-pcre)
    set(SQLITE3_PCRE_SOURCE "${sqlite3-pcre_SOURCE_DIR}")
else()
    set(SQLITE3_PCRE_SOURCE "sqlite3-pcre")
endif(SQLITE3_PCRE_FETCH)

add_compile_definitions(PCRE_STATIC)

add_library(sqlite3-pcre SHARED  "${SQLITE3_PCRE_SOURCE}/pcre.c") # $<$<BOOL:BORLAND>:tjutil-bcc-llvm.def>)

if(UNIX)
    find_library(pcre pcre)
endif(UNIX)

if(NOT pcre)
    # https://stackoverflow.com/a/3769269/10545609
    set(PCRE_SUPPORT_JIT ON CACHE BOOL "Support JIT")
    set(PCRE_SUPPORT_UTF ON CACHE BOOL "Support UTF-8")
    set(PCRE_SUPPORT_UNICODE_PROPERTIES ON CACHE BOOL "Support Unicode properties")
    set(PCRE_NEWLINE "ANY" CACHE STRING "What to recognize as a newline (one of CR, LF, CRLF, ANY, ANYCRLF).")
    set(BUILD_SHARED_LIBS OFF CACHE BOOL "Don't build shared pcre libs") 
    set(PCRE_BUILD_PCRECPP OFF CACHE BOOL "Don't build the C++ libs")
    if(NOT CMAKE_VERBOSE_MAKEFILE)
        set(PCRE_SHOW_REPORT OFF CACHE BOOL "Don't show the report")
    endif(NOT CMAKE_VERBOSE_MAKEFILE)

    if(SQLITE3_PCRE_FETCH)
        FetchContent_Declare(pcre-git
            GIT_REPOSITORY https://github.com/nektro/pcre-8.45.git
            PATCH_COMMAND git apply "${CMAKE_CURRENT_SOURCE_DIR}/pcre-git.patch"
        )
        FetchContent_MakeAvailable(pcre-git)
        # file(RENAME pcre-git/config.h pcre-git/config.h.ren) # PATCH_COMMAND should take care of that
        set(PCRE_SOURCE "${pcre-git_BINARY_DIR}")
    else()
        set(PCRE_SOURCE "pcre-git")
        add_subdirectory(${PCRE_SOURCE})
    endif(SQLITE3_PCRE_FETCH)

    # if(SQLITE3_32)
    #     set(PCRE_BUILD_PCREGREP OFF CACHE BOOL "Don't build pcregrep executable for 32-bit")
    # endif(SQLITE3_32)

    # somehow, this doesn't get picked up from generated config.h??? Mybe because of my changes to pcre-git/CMakeLists.txt ???
    # TODO: HACK ALERT! pcre-git/config.h renamed!
    # add_compile_definitions(SUPPORT_JIT)
    # and this one, we need in sqlite3-pcre, too
    include_directories(${PCRE_SOURCE})
    if(SQLITE3_32)
        set_target_properties(pcre pcreposix pcretest pcregrep pcre_jit_test PROPERTIES COMPILE_OPTIONS "-m32" LINK_FLAGS "-m32")
    endif(SQLITE3_32)
    set_target_properties(pcre pcreposix pcretest pcregrep PROPERTIES # NOT: pcre_jit_test
      ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/" # $<CONFIG>/
      LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/"
      RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/"
    )
    set_property(TARGET pcretest pcregrep pcre_jit_test APPEND_STRING PROPERTY LINK_FLAGS " -Wl,--stack,16000000") # GCC or compatible required anyway...
    target_link_libraries(sqlite3-pcre PRIVATE pcre)

else()
    find_path(pcre_include pcre.h)
    include_directories(${pcre_include})
    target_link_libraries(sqlite3-pcre PRIVATE ${pcre})
endif()

if(SQLITE3_32)
    set_target_properties(sqlite3-pcre PROPERTIES COMPILE_OPTIONS "-m32" LINK_FLAGS "-m32")
endif(SQLITE3_32)

# https://github.com/shader-slang/slang/issues/5896#issuecomment-2552730762
if(WIN32)
    set(CMAKE_SHARED_LIBRARY_PREFIX "")
endif(WIN32)

set_target_properties(sqlite3-pcre PROPERTIES
  ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/" # $<CONFIG>/
  LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/"
  RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/"
)

install(TARGETS sqlite3-pcre)

add_test(NAME test_extension_pcre
    COMMAND sqlite3 ":memory:" ".read '${CMAKE_SOURCE_DIR}/tests/test-pcre.sql'"
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/tests"
)
