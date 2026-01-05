@call dnenv
cmake -Ssrc --preset "msvc-x86-debug" %*
if errorlevel 1 exit
cmake -Ssrc --preset "msvc-x86-release" %*
if errorlevel 1 exit
