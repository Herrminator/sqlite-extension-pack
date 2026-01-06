if(MSVC)
    include_directories(
        ${CMAKE_SOURCE_DIR}
    )

    set(CPACK_SYSTEM_NAME "x86") # well, it depends (on how vcvarsall.bat is called)
    # set(CMAKE_VS_USE_DEBUG_LIBRARIES BOOL OFF) # set to OFF if you want the debug exe to run on machines without Visual Studio
    # set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreadedDLL") # NOT "...DebugDLL", so it will run on machines without compiler

endif(MSVC)
