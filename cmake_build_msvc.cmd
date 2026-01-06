@echo off
for %%p in (msvc-x86-debug msvc-x86-release) do (
    call :build_msvc vcenv32 %%p
)

for %%p in (msvc-x64-debug msvc-x64-release) do (
    call :build_msvc vcenv %%p
)

rem TODO: bcc in cmake
pushd src
call bccenv
echo Building bcc
rem TODO:
rem set SQLITE_LUA_SOURCE=%~dp0build\vsc-x86-release\_deps\sqlite-lua-src
rem set LUA_SOURCE=%~dp0build\vsc-x86-release\_deps\lua-src
if not "'%1 %2'" == "'--target clean'" (
    call build-bcc
) else (
    call build-bcc clean
)
if errorlevel 1 exit
popd

goto :eof

:build_msvc
    echo Building %2
    if not exist build/%2 (
        Please configure %2
        exit 8
    )
    call %1 cmake --build build/%2 --parallel 8 -j 8 %3 %4 %5 %6 %7 %8
    if errorlevel 1 (
        echo Building %2 FAILED!
        exit 8
    )
