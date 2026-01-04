@call clenv bccenv
set CC=%BCC_HOME%\bin\bcc32.exe
set CXX=%BCC_HOME%\bin\bcc32.exe

if "'%1'" == "'-f'" del /s /q build > NUL:

cmake -DCMAKE_BUILD_TYPE:STRING=Debug ^
    -G "Borland Makefiles" ^
    -DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=TRUE ^
    -SC:/Users/johlet/Develop/SQLite/extensions/src ^
    -Bc:/Users/johlet/Develop/SQLite/extensions/build 

:    "-DCMAKE_LINKER=%BCC_HOME%/bin/ilink32.exe" ^
:    "-DCMAKE_C_CREATE_SHARED_MODULE=<CMAKE_LINKER> <FLAGS> <CMAKE_C_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>"

rem "-DCMAKE_C_CREATE_SHARED_MODULE=<CMAKE_LINKER> <FLAGS> <CMAKE_C_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>"
rem results in:
rem C:\Users\johlet\Develop\BCC5\bin\ilink32.exe FLAGS -tWM -lS:1048576 -lSc:4098 -lH:1048576 -lHc:8192
rem -v -pr $(sqlite3-tjutil_OBJECTS) $(sqlite3-tjutil_EXTERNAL_OBJECTS) -o ..\bcc\sqlite3-tjutil.dll   -LC:\Users\johlet\Develop\BCC5\lib  -LC:\Users\johlet\Develop\BCC5\lib\psdk  wsock32.lib ws2_32.lib import32.lib
rem     --no-warn-unused-cli

rem original:
rem   "<CMAKE_${lang}_COMPILER> ${_tR} ${_tD} ${CMAKE_START_TEMP_FILE}-e<TARGET> <LINK_FLAGS> <LINK_LIBRARIES> <OBJECTS>${CMAKE_END_TEMP_FILE}"
rem results in:
rem   C:\Users\johlet\Develop\BCC5\Bin\bcc32.exe -tWR -tW- -tWD @&&|
rem  -e..\bcc\sqlite3-tjutil.dll -tWM -lS:1048576 -lSc:4098 -lH:1048576 -lHc:8192 -v -pr   -LC:\Users\johlet\Develop\BCC5\lib  -LC:\Users\johlet\Develop\BCC5\lib\psdk  wsock32.lib ws2_32.lib import32.lib  $(sqlite3-tjutil_OBJECTS) $(sqlite3-tjutil_EXTERNAL_OBJECTS)
rem  |

