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
elseif(SQLITE3_32)
    set_target_properties(${official_extensions} PROPERTIES COMPILE_OPTIONS "-m32" LINK_FLAGS "-m32")
endif(BORLAND)


# https://github.com/shader-slang/slang/issues/5896#issuecomment-2552730762
set_target_properties(${official_extensions} PROPERTIES
  ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/" # $<CONFIG>/
  LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/"
  RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/"
)

set(CMAKE_SHARED_LIBRARY_PREFIX "")

install(TARGETS ${official_extensions})

foreach(test rot13 stmt series)
    add_test(NAME test_extension_${test} COMMAND sqlite3 ":memory:" ".read '${CMAKE_SOURCE_DIR}/tests/test-${test}.sql'"
        WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/tests"
    )
endforeach()
