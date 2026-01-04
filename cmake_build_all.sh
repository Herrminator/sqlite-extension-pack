#!/bin/bash
presets="x86-debug x86-release x64-debug x64-release x64-release-debug"
[ -z "${WINDIR}" ] && presets="linux-debug linux-release linux-release-debug"

for p in $presets; do
    echo "Building $p"
    cmake --build "build/$p" --parallel 8 -j 8 "$@"
    if [ "$?" != "0" ]; then
        echo "Building $p FAILED!"
        exit 8
    fi
done

[ -z "${WINDIR}" ] && exit

# TODO: bcc
pushd src
echo "Building bcc"
if [ "$1 $2" != "--target clean" ]; then
    MSYS_NO_PATHCONV=1 cmd /c "build-bcc"
else
    MSYS_NO_PATHCONV=1 cmd /c "build-bcc clean"
fi
popd
if [ "$1 $2" == "--target install" ]; then
   cp -R ./build/bcc ./Release
fi

