@echo off
pushd src
call :test vcenv32 ctest --preset "msvc-x86-debug" %*
call :test vcenv32 ctest --preset "msvc-x86-release" %*
call :test vcenv   ctest --preset "msvc-x64-debug" %*
call :test vcenv   ctest --preset "msvc-x64-release" %*
popd
goto :eof

:test
    call %*
    if errorlevel 1 (
        echo FAILED: %*
        exit %errorlevel%
    )
