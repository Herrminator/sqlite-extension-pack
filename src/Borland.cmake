if(BORLAND)
    # BCC102 does *NOT* work, BCC5x compile works. But only by tweaking ilink32.cfg to include the default lib path.
    include_directories(
        "$ENV{BCC_HOME}/include"
        "$ENV{BCC_HOME}/include/windows/crt"
        "$ENV{BCC_HOME}/include/windows/sdk"
        "$ENV{BCC_HOME}/include/dinkumware64"
    )
    link_directories(
        "$ENV{BCC_HOME}/lib"
        "$ENV{BCC_HOME}/lib/psdk"
    )
    # The problem now is linking
    # That doesn't help here: It's always overwritten. So we'd have to use command line -D defines. (Or presets?)
    set(CMAKE_LINKER $ENV{BCC_HOME}/bin/ilink32.exe)
    # and, we cannot distinguish between *real* objects and external ones (in our case, the .def file)
    set(CMAKE_C_CREATE_SHARED_MODULE "<CMAKE_LINKER> <FLAGS> <CMAKE_C_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>")
    # We would need something like
    # $(LINK) /Tpd $**, $@, nul: , C0d32.OBJ CW32mt.LIB IMPORT32.LIB WS2_32.LIB , tjutil\tjutil-bcc.def
    # Syntax: ILINK32 objfiles, exefile, mapfile, libfiles, deffile, resfiles
    set(CMAKE_C_CREATE_SHARED_MODULE
          "<CMAKE_LINKER> <FLAGS> <CMAKE_C_LINK_FLAGS> <LINK_FLAGS>  <OBJECTS>, <TARGET>, /dev/null, <LINK_LIBRARIES>, <DEF_FILE>")


endif(BORLAND)

