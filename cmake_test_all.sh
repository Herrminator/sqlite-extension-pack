#!/bin/bash
presets="x86-debug x86-release x64-debug x64-release x64-release-debug"
[ -z "${WINDIR}" ] && presets="linux-debug linux-release linux-release-debug"


[ "$1" == "-f" ] && rm -rf ./build

# TODO: bcc

self="$(realpath "$(dirname $0)")"
ldlp="$LD_LIBRARY_PATH"

pushd src
for p in $presets; do
    # HACK ALERT: this shold be done by ctest...
    [ -z "${WINDIR}" ] && export LD_LIBRARY_PATH="${self}/build/${p}:${ldlp}"

    echo Testing $p
    ctest --preset "$p" "$@" || exit
done
popd
