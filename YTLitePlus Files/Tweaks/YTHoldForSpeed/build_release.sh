#!/bin/bash

# rootful (iphoneos-arm)
export PREFIX=$THEOS/toolchain/Xcode11.xctoolchain/usr/bin/
make clean
make package FINALPACKAGE=1

# rootless (iphoneos-arm64)
export -n PREFIX
make clean
make package FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=rootless