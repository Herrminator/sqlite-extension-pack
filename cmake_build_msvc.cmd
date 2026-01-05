@call dnenv bccenv
for %%p in (msvc-x86-debug msvc-x86-release) do (
    echo Building %%p
    call cmake --build build/%%p --parallel 8 -j 8 %*
    if errorlevel 1 (
        echo Building %%p FAILED!
        exit 8
    )
)
rem TODO: bcc
pushd src
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
