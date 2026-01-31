cmake_minimum_required(VERSION 4.0)
project(sqlite3-tjutil)

option(SQLITE3_32  "Create 32-bit binaries" ON)

add_library(sqlite3-tjutil SHARED  tjutil.c) # $<$<BOOL:BORLAND>:tjutil-bcc-llvm.def>)

if(BORLAND)
    set_source_files_properties(tjutil-bcc-llvm.def PROPERTIES EXTERNAL_OBJECT TRUE)
    set_target_properties(sqlite3-tjutil PROPERTIES COMPILE_OPTIONS "-pr" LINK_FLAGS "-pr")
endif(BORLAND)


# sqlite3 searches verbatim. I.e. `select load_extension('foo')` will try "foo" and "foo.so" or "foo.dll", not "libfoo.so".
# set(CMAKE_SHARED_LIBRARY_PREFIX  "")

sqlite_set_target_architecture(sqlite3-tjutil)
sqlite_set_target_output(sqlite3-tjutil)

if(WIN32)
    target_link_libraries(sqlite3-tjutil wsock32 ws2_32)
endif(WIN32)

install(TARGETS sqlite3-tjutil)

add_test(NAME test_extension_tjutil
    COMMAND sqlite3 ":memory:" ".read '${CMAKE_SOURCE_DIR}/tests/test-tjutil.sql'"
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/tests"
)
set_tests_properties(test_extension_tjutil PROPERTIES ENVIRONMENT "HELLO=Hello World!;LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}")
