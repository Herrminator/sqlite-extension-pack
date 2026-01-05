if(MSVC)
    # BCC102 does *NOT* work, BCC5x compile works. But only by tweaking ilink32.cfg to include the default lib path.
    include_directories(
        ${CMAKE_SOURCE_DIR}
    )

    set(CPACK_SYSTEM_NAME "x86") # well, it depends (on how vcvarsall.bat is called)
    set(CMAKE_VS_USE_DEBUG_LIBRARIES BOOL )
    # set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreadedDLL") # NOT "...DebugDLL", so it will run on machines without compiler

endif(MSVC)
