#!/bin/bash
presets="x86-debug x86-release x64-debug x64-release x64-release-debug"

[ "$1" == "-f" ] && rm -rf ./build

# TODO: bcc

for p in $presets; do
    echo Configuring $p
    cmake -Ssrc --preset "$p" || exit
done
