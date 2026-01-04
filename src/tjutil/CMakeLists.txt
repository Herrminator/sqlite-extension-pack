cmake_minimum_required(VERSION 4.0)
project(sqlite3-tjutil)

option(SQLITE3_32  "Create 32-bit binaries" ON)

add_library(sqlite3-tjutil SHARED  tjutil.c) # $<$<BOOL:BORLAND>:tjutil-bcc-llvm.def>)

if(BORLAND)
    set_source_files_properties(tjutil-bcc-llvm.def PROPERTIES EXTERNAL_OBJECT TRUE)
    set_target_properties(sqlite3-tjutil PROPERTIES COMPILE_OPTIONS "-pr" LINK_FLAGS "-pr")
    # set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_CURRENT_SOURCE_DIR}/tjutil-bcc-llvm.def")
elseif(SQLITE3_32)
    set_target_properties(sqlite3-tjutil PROPERTIES COMPILE_OPTIONS "-m32" LINK_FLAGS "-m32")
endif(BORLAND)


# https://github.com/shader-slang/slang/issues/5896#issuecomment-2552730762
set_target_properties(sqlite3-tjutil PROPERTIES
  ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/" # $<CONFIG>/
  LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/"
  RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/"
)

if(WIN32)
    target_link_libraries(sqlite3-tjutil wsock32 ws2_32)
endif(WIN32)

# sqlite3 searches verbatim. I.e. `select load_extension('foo')` will try "foo" and "foo.so" or "foo.dll", not "libfoo.so".
set(CMAKE_SHARED_LIBRARY_PREFIX "")

install(TARGETS sqlite3-tjutil)

add_test(NAME test_extension_tjutil
    COMMAND sqlite3 ":memory:" ".read '${CMAKE_SOURCE_DIR}/tests/test-tjutil.sql'"
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/tests"
)
set_tests_properties(test_extension_tjutil PROPERTIES ENVIRONMENT "HELLO=Hello World!")
