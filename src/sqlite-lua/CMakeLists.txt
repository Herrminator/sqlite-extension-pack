cmake_minimum_required(VERSION 4.0)
project(sqlite3-lua)

option(SQLITE3_32  "Create 32-bit binaries" ON)
option(SQLITE3_LUA_FETCH "Fetch Lua sources from GitHub and patch" ON)

if(SQLITE3_LUA_FETCH)
    include(FetchContent)

    FetchContent_Declare(lua
        GIT_REPOSITORY https://github.com/lua/lua.git
        GIT_TAG "v5.5.0"
    )
    FetchContent_Declare(sqlite-lua
        GIT_REPOSITORY https://github.com/abiliojr/sqlite-lua.git
    )
    FetchContent_MakeAvailable(lua)
    FetchContent_MakeAvailable(sqlite-lua)
    set(SQLITE3_LUA_SOURCE "${lua_SOURCE_DIR}")
    set(SQLITE3_SQLITE_LUA_SOURCE "${sqlite-lua_SOURCE_DIR}")
else()
   # Legacy directory layout
    set(SQLITE3_LUA_SOURCE "lua")
    set(SQLITE3_SQLITE_LUA_SOURCE ".")
endif(SQLITE3_LUA_FETCH)

file(GLOB lua_sources "${SQLITE3_LUA_SOURCE}/*.c")
list(FILTER lua_sources EXCLUDE REGEX ".*onelua\\.c")

add_library(sqlite3-lua SHARED  "${SQLITE3_SQLITE_LUA_SOURCE}/src/lua.c" ${lua_sources})
target_include_directories(sqlite3-lua PRIVATE ${SQLITE3_LUA_SOURCE})

sqlite_set_target_architecture(sqlite3-lua)
sqlite_set_target_output(sqlite3-lua)

install(TARGETS sqlite3-lua)

add_test(NAME test_extension_lua
    COMMAND sqlite3 ":memory:" ".read '${CMAKE_SOURCE_DIR}/tests/test-lua.sql'"
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/tests"
)
