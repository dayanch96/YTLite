#!/bin/bash
# This makes me sad 🙁

set -e

if [[ $(arch) != i386 ]]; then
	echo "Not working on ARM. Try Rosetta instead?"
	exit 1
fi

PROJECT_DIR=$(realpath $(dirname $0))

THEOS_OBJ_DIR=$PROJECT_DIR/.theos/obj
THEOS_STAGING_DIR=$PROJECT_DIR/.theos/_
FRAMEWORK_OUTPUT_DIR=$THEOS_OBJ_DIR/install/Library/Frameworks

echo
echo Building modern
echo
make clean
sudo xcode-select -switch /Applications/Xcode-13.4.0.app/Contents/Developer
make package \
	FINALPACKAGE=1
cp $FRAMEWORK_OUTPUT_DIR/Alderis.framework/Alderis Alderis-ios14

echo
echo Building legacy
echo
make clean
mkdir -p $THEOS_OBJ_DIR
mv Alderis-ios14 $THEOS_OBJ_DIR
sudo xcode-select -switch /Applications/Xcode-11.7.app/Contents/Developer
make package \
	BUILD_LEGACY_ARM64E=1 \
	THEOS_PLATFORM_SDK_ROOT=/Applications/Xcode-11.7.app/Contents/Developer \
	FINALPACKAGE=1
cp $FRAMEWORK_OUTPUT_DIR/Alderis.framework/Alderis $THEOS_OBJ_DIR/Alderis-ios12

echo
cp $THEOS_OBJ_DIR/Alderis-ios{12,14} $THEOS_STAGING_DIR/Library/Frameworks/Alderis.framework
sudo xcode-select -switch /Applications/Xcode-13.4.0.app/Contents/Developer
echo Alderis-ios12:
otool -h $THEOS_STAGING_DIR/Library/Frameworks/Alderis.framework/Alderis-ios12
echo
echo Alderis-ios14:
otool -h $THEOS_STAGING_DIR/Library/Frameworks/Alderis.framework/Alderis-ios14
echo
echo libcolorpicker.dylib:
otool -h $THEOS_STAGING_DIR/usr/lib/libcolorpicker.dylib

echo
echo Packaging
echo
rm $THEOS_STAGING_DIR/Library/Frameworks/Alderis.framework/Alderis
ln -s Alderis-ios12 $THEOS_STAGING_DIR/Library/Frameworks/Alderis.framework/Alderis
$THEOS/bin/dm.pl -b -Zlzma -z9 .theos/_ packages/
