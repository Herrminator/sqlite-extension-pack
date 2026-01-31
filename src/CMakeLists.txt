cmake_minimum_required(VERSION 4.0)

project(sqlite-extensions VERSION 3.51.1)

include(CTest)

include(./sqlite_util.cmake)
include(./MSVC.cmake)
include(./Borland.cmake)

add_subdirectory(sqlite-test-cli)

include_directories(${SQLITE3_AUTOCONF})

add_library(sqlite3-extension-functions SHARED  extension-functions.c extension-soundex.c) # $<$<BOOL:BORLAND>:extension-functions-bcc.def>)
add_library(extension-functions SHARED  extension-functions.c extension-soundex.c)         # TODO: No symlinks on Windows w/o admin rights ;(
add_compile_definitions(
    SQLITE_EXTENSIONS_SOUNDEX
    SQLITE_EXTENSIONS_METAPHONE
    SQLITE_EXTENSIONS_LEVENSHTEIN
    SQLITE_EXTENSIONS_JARO_WINKLER
)

if(SQLITE3_32)
    sqlite_need_arch("x86")
else()
    sqlite_need_arch("x64")
endif()


if(BORLAND)
    set_source_files_properties(extension-functions-bcc.def PROPERTIES EXTERNAL_OBJECT TRUE)
    set_target_properties(sqlite3-extension-functions extension-functions PROPERTIES COMPILE_OPTIONS "-pr" LINK_FLAGS "-pr")
    # set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_CURRENT_SOURCE_DIR}/tjutil-bcc-llvm.def")
elseif(SQLITE3_32)
    if (WIN32)
        set(CPACK_SYSTEM_NAME "x86")
    endif(WIN32)
else()
    set(CPACK_SYSTEM_NAME "x64")
endif(BORLAND)
if (WIN32)
    set(CPACK_GENERATOR NSIS 7Z)
endif(WIN32)


sqlite_set_target_architecture(sqlite3-extension-functions extension-functions)
sqlite_set_target_output(sqlite3-extension-functions extension-functions)

install(TARGETS sqlite3-extension-functions extension-functions)

add_test(NAME test_extension_functions
    COMMAND sqlite3 ":memory:" ".read '${CMAKE_SOURCE_DIR}/tests/test-extension-functions.sql'"
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/tests"
)
set_tests_properties(test_extension_functions PROPERTIES ENVIRONMENT "LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}")

add_subdirectory(tjutil)
add_subdirectory(official)
add_subdirectory(sqlite-lua)
if(NOT BORLAND) # SQLiteSpy has its own regexp
    add_subdirectory(pcre)
endif(NOT BORLAND)

if(WIN32)
    set(CPACK_NSIS_INSTALL_ROOT "$PROFILE\\\\Develop\\\\SQLite")
    set(CPACK_NSIS_DISPLAY_NAME "${CMAKE_PROJECT_NAME}-${CMAKE_PROJECT_VERSION}")
    set(CPACK_NSIS_DEFINES "RequestExecutionLevel user") # https://stackoverflow.com/a/26223567/10545609
    set(CPACK_PACKAGE_FILE_NAME "${CMAKE_PROJECT_NAME}-${CMAKE_PROJECT_VERSION}-${CMAKE_BUILD_TYPE}-${CPACK_SYSTEM_NAME}")
    set(CPACK_PACKAGE_INSTALL_DIRECTORY "extensions\\\\${CMAKE_BUILD_TYPE}\\\\${CPACK_SYSTEM_NAME}\\\\") # Mind the trailing "\\\\", https://nsis.sourceforge.io/Docs/Chapter4.html#ainstalldir
    set(CPACK_PACKAGE_INSTALL_REGISTRY_KEY "${CMAKE_PROJECT_NAME}-${CMAKE_PROJECT_VERSION}-${CMAKE_BUILD_TYPE}-${CPACK_SYSTEM_NAME}")
endif(WIN32)

include(CPack)
