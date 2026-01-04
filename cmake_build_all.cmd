@call clenv bccenv
C:\winapp\Git\bin\bash.exe %~dpn0.sh %*
exit

for %%p in (x86-debug x86-release x64-debug x64-release x64-release-debug) do (
    echo Building %%p
    call cmake --build build/%%p -j 8 %*
    if errorlevel 1 (
        echo Building %%p FAILED!
        exit 8
    )
)
rem TODO: bcc
pushd src
echo Building bcc
if not "'%1 %2'" == "'--target clean'" (
    call build-bcc
) else (
    call build-bcc clean
)
if errorlevel 1 exit
popd
