#!/bin/bash
# build_ijk.sh

CONFIG="Release"
SDK_VER="iphoneos"
SIMULATORSFILE="build/Release-iphonesimulator/MSBAIPlayerSimulators.framework/MSBAIPlayerSimulators"
IPHONEOSFILE="../../Frameworks/player/MSBPlayer.framework/MSBPlayer"

xcodebuild clean -project MSBPlayer.xcodeproj -sdk iphoneos -configuration $CONFIG
xcodebuild       -project MSBPlayer.xcodeproj -sdk iphoneos -configuration $CONFIG
if [[ $? -eq 0 ]];then
echo ""
else
exit 1
fi

xcodebuild clean -project MSBAIPlayerSimulators.xcodeproj -sdk iphonesimulator -configuration $CONFIG
xcodebuild       -project MSBAIPlayerSimulators.xcodeproj -sdk iphonesimulator -configuration $CONFIG
if [[ $? -eq 0 ]];then
echo ""
else
exit 1
fi

lipo -create $SIMULATORSFILE $IPHONEOSFILE -output $IPHONEOSFILE
rm -rf build/
