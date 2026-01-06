@echo off
for %%c in ("msvc-x86-debug" "msvc-x86-release") do (
    call :configure vcenv32 %%c %*
)

for %%c in ("msvc-x64-debug" "msvc-x64-release") do (
    call :configure vcenv %%c %*
)
goto :eof

:configure
    setlocal
    echo Configuring %2
    call %1 cmake -Ssrc --preset %2 %3 %4 %5 %6 %7 %8 %9
    if errorlevel 1 exit
    endlocal
