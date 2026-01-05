@call dnenv
pushd src
ctest --preset "msvc-x86-debug" %*
if errorlevel 1 exit
ctest --preset "msvc-x86-release" %*
if errorlevel 1 exit
popd
