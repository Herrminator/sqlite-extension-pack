function(sqlite_need_arch arch)
    set(machine_flag "")
    # https://github.com/axr/solar-cmake/blob/master/TargetArch.cmake
    if(arch STREQUAL "x64")
        set(check_me "#if ! (defined(__x86_64__) || defined(_WIN64))\n#error 64 Bit compiler required\n#endif\nint main() { return 0; }")
    else()
        # Micke$ofts compiler doesn't have a compile / link falg to switch modes.
        # Instead, you have start a new environment with all the PATHs properly set ;(
        # "CMAKE_GENERATOR_PLATFORM" is not accepted for NMake generators ;(
        if(NOT MSVC)
            set(machine_flag "-m32")
        endif()
        set(check_me "#if defined(__x86_64__) || defined(_WIN64)\n#error 32 Bit compiler required\n#endif\nint main() { return 0; }")
    endif()

    try_compile(success
        SOURCE_FROM_CONTENT "msvc_arch_test.c" "${check_me}"
        CMAKE_FLAGS "-DCOMPILE_DEFINITIONS=${machine_flag}" LINK_OPTIONS "${machine_flag}"
        OUTPUT_VARIABLE out
    )
    if(NOT success)
        message(FATAL_ERROR "The settings require ${CMAKE_C_COMPILER_ID} to be in ${arch}-mode. Please set your environment accordingly...")
    endif()
endfunction(sqlite_need_arch)

function(sqlite_set_target_architecture)
    if(SQLITE3_32 AND NOT MSVC)
        set_target_properties(${ARGV} PROPERTIES COMPILE_OPTIONS "-m32" LINK_FLAGS "-m32")
    endif()
endfunction()

function(sqlite_set_target_output)
    # sqlite3 searches verbatim. I.e. `select load_extension('foo')` will try "foo" and "foo.so" or "foo.dll", not "libfoo.so".
    set(CMAKE_SHARED_LIBRARY_PREFIX "" PARENT_SCOPE)

    # https://github.com/shader-slang/slang/issues/5896#issuecomment-2552730762
    set_target_properties(${ARGV} PROPERTIES # NOT: pcre_jit_test
      ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/" # $<CONFIG>/
      LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/"
      RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/"
    )
endfunction()