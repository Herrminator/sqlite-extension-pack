cmake_minimum_required(VERSION 4.0)
project(sqlite3-official-extensions)

set(official_extensions sqlite3-stmt sqlite3-rot13 sqlite3-series)
option(SQLITE3_32  "Create 32-bit binaries" ON)

add_library(sqlite3-stmt SHARED  stmt.c) # $<$<BOOL:BORLAND>:stmt-bcc-llvm.def>)
add_library(sqlite3-rot13 SHARED  rot13.c) # $<$<BOOL:BORLAND>:stmt-bcc-llvm.def>)
add_library(sqlite3-series SHARED  series.c) # $<$<BOOL:BORLAND>:series-bcc-llvm.def>)

if(BORLAND)
    set_source_files_properties(stmt-bcc-llvm.def rot13-bcc-llvm.def series-bcc-llvm.def  PROPERTIES EXTERNAL_OBJECT TRUE)
    set_target_properties(${official_extensions} PROPERTIES COMPILE_OPTIONS "-pr" LINK_FLAGS "-pr")
    # set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_CURRENT_SOURCE_DIR}/tjutil-bcc-llvm.def")
endif(BORLAND)

sqlite_set_target_architecture(${official_extensions})
sqlite_set_target_output(${official_extensions})

install(TARGETS ${official_extensions})

foreach(test rot13 stmt series)
    add_test(NAME test_extension_${test} COMMAND sqlite3 ":memory:" ".read '${CMAKE_SOURCE_DIR}/tests/test-${test}.sql'"
        WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/tests"
    )
    set_tests_properties(test_extension_${test} PROPERTIES ENVIRONMENT "LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}")
endforeach()
