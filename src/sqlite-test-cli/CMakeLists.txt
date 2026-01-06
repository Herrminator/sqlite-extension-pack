cmake_minimum_required(VERSION 4.0)
project(sqlite3-cli)

option(SQLITE3_32  "Create 32-bit binaries" ON)

get_filename_component(dflt_src "../../../src/latest" ABSOLUTE)

set(SQLITE3_AUTOCONF "${dflt_src}/autoconf" CACHE STRING "Directory for SQLite autconf sources") # https://sqlite.org/download.html
set(SQLITE3_AMALGAM  "${dflt_src}/amalgam"  CACHE STRING "Directory for SQLite amalgamation sources")

if(NOT IS_DIRECTORY ${SQLITE3_AUTOCONF} OR NOT IS_DIRECTORY ${SQLITE3_AMALGAM})
    # TODO: Download ourselves?
    message(FATAL_ERROR "Cannot find SQLite 3 sources at '${SQLITE3_AUTOCONF}' and '${SQLITE3_AMALGAM}'.
Please download and install both or -DSQLITE3_AUTOCONF=... and -DSQLITE3_AMALGAM=... !")
endif()

include_directories(${SQLITE3_AMALGAM})
add_executable(sqlite3 ${SQLITE3_AMALGAM}/sqlite3.c ${SQLITE3_AMALGAM}/shell.c) # $<$<BOOL:BORLAND>:tjutil-bcc-llvm.def>)
if(NOT MSVC)
    target_link_libraries(sqlite3 m)
endif()

if(SQLITE3_32)
    set(opts_file "${PROJECT_SOURCE_DIR}/sqlite3.x86.options")
    set(test_arch "32-bit")
elseif(LINUX)
    set(opts_file "${PROJECT_SOURCE_DIR}/sqlite3.linux.options")
    set(test_arch "64-bit")
else()
    set(opts_file "${PROJECT_SOURCE_DIR}/sqlite3.x64.options")
    set(test_arch "64-bit")
endif()

if(EXISTS ${opts_file})
    # use ./mkopt.sh to generate this from a production sqlite3 installation
    file(STRINGS ${opts_file} options)
    while(options)
        list(POP_FRONT options opt)
        target_compile_definitions(sqlite3 PRIVATE ${opt})
    endwhile()
    if(NOT LINUX AND NOT MSVC)
        target_compile_options(sqlite3 PRIVATE -Wno-macro-redefined)
    endif()
endif()

sqlite_set_target_architecture(sqlite3)
sqlite_set_target_output(sqlite3)

install(TARGETS sqlite3)

add_test(NAME test_extension_cli COMMAND sqlite3 "-version")
set_tests_properties(test_extension_cli PROPERTIES PASS_REGULAR_EXPRESSION "^3\\.[0-9]+\\.?.*\\(${test_arch}\\)\n$")
add_test(NAME test_extension_cli_shell COMMAND sqlite3 ":memory" ".shell set PATH")
