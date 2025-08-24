#!/bin/bash

# Build script for creating LibOpenMPT.xcframework with full simulator support
# This script assumes you have the OpenMPT source code and have built the libraries

set -e

echo "Building LibOpenMPT XCFramework with universal simulator support..."

# Define paths (adjust these to your actual build output paths)
LIBOPENMPT_SOURCE_DIR="${LIBOPENMPT_SOURCE:-../openmpt}"
BUILD_DIR="build"
XCFRAMEWORK_OUTPUT="Frameworks/LibOpenMPT.xcframework"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Build libopenmpt for each architecture
echo -e "${YELLOW}Step 1: Building libopenmpt for each architecture${NC}"
echo "Note: You need to build libopenmpt from source for each target:"
echo ""
echo "1. iOS Device (arm64):"
echo "   xcodebuild -project ${LIBOPENMPT_SOURCE_DIR}/build/xcode/libopenmpt.xcodeproj \\"
echo "              -scheme libopenmpt-static \\"
echo "              -sdk iphoneos \\"
echo "              -arch arm64 \\"
echo "              -configuration Release \\"
echo "              ONLY_ACTIVE_ARCH=NO \\"
echo "              BUILD_DIR=${BUILD_DIR}/ios-arm64"
echo ""
echo "2. iOS Simulator (x86_64) for Intel Macs:"
echo "   xcodebuild -project ${LIBOPENMPT_SOURCE_DIR}/build/xcode/libopenmpt.xcodeproj \\"
echo "              -scheme libopenmpt-static \\"
echo "              -sdk iphonesimulator \\"
echo "              -arch x86_64 \\"
echo "              -configuration Release \\"
echo "              ONLY_ACTIVE_ARCH=NO \\"
echo "              BUILD_DIR=${BUILD_DIR}/ios-simulator-x86_64"
echo ""
echo "3. iOS Simulator (arm64) for Apple Silicon Macs:"
echo "   xcodebuild -project ${LIBOPENMPT_SOURCE_DIR}/build/xcode/libopenmpt.xcodeproj \\"
echo "              -scheme libopenmpt-static \\"
echo "              -sdk iphonesimulator \\"
echo "              -arch arm64 \\"
echo "              -configuration Release \\"
echo "              ONLY_ACTIVE_ARCH=NO \\"
echo "              EXCLUDED_ARCHS= \\"
echo "              BUILD_DIR=${BUILD_DIR}/ios-simulator-arm64"
echo ""
echo "4. macOS (arm64):"
echo "   xcodebuild -project ${LIBOPENMPT_SOURCE_DIR}/build/xcode/libopenmpt.xcodeproj \\"
echo "              -scheme libopenmpt-static \\"
echo "              -sdk macosx \\"
echo "              -arch arm64 \\"
echo "              -configuration Release \\"
echo "              ONLY_ACTIVE_ARCH=NO \\"
echo "              BUILD_DIR=${BUILD_DIR}/macos-arm64"

# Step 2: Create universal binary for simulator (combining x86_64 and arm64)
echo -e "\n${YELLOW}Step 2: Creating universal simulator binary${NC}"
echo "After building, create a universal simulator binary:"
echo ""
echo "lipo -create \\"
echo "     ${BUILD_DIR}/ios-simulator-x86_64/Release-iphonesimulator/libopenmpt.a \\"
echo "     ${BUILD_DIR}/ios-simulator-arm64/Release-iphonesimulator/libopenmpt.a \\"
echo "     -output ${BUILD_DIR}/ios-simulator-universal/libopenmpt.a"

# Step 3: Create XCFramework
echo -e "\n${YELLOW}Step 3: Creating XCFramework${NC}"
echo "Remove old framework if it exists:"
echo "rm -rf ${XCFRAMEWORK_OUTPUT}"
echo ""
echo "Create new XCFramework with all architectures:"
echo "xcodebuild -create-xcframework \\"
echo "    -library ${BUILD_DIR}/ios-arm64/Release-iphoneos/libopenmpt.a \\"
echo "    -headers ${LIBOPENMPT_SOURCE_DIR}/libopenmpt/ \\"
echo "    -library ${BUILD_DIR}/ios-simulator-universal/libopenmpt.a \\"
echo "    -headers ${LIBOPENMPT_SOURCE_DIR}/libopenmpt/ \\"
echo "    -library ${BUILD_DIR}/macos-arm64/Release/libopenmpt.a \\"
echo "    -headers ${LIBOPENMPT_SOURCE_DIR}/libopenmpt/ \\"
echo "    -output ${XCFRAMEWORK_OUTPUT}"

echo -e "\n${GREEN}Build instructions complete!${NC}"
echo ""
echo "IMPORTANT NOTES:"
echo "1. You need to have the OpenMPT source code cloned"
echo "2. You may need to install premake5 first: brew install premake"
echo "3. Generate Xcode project: premake5 --file=build/premake/premake.lua xcode4"
echo "4. The EXCLUDED_ARCHS= is crucial for arm64 simulator builds"
echo "5. Make sure to use the same deployment target for all builds"
echo ""
echo "Alternative: Use xcodebuild with xcconfig files for consistent settings"