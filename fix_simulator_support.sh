#!/bin/bash

# Temporary fix for simulator support on Apple Silicon Macs
# This creates a universal simulator binary directory structure

set -e

XCFRAMEWORK_PATH="Frameworks/LibOpenMPT.xcframework"

echo "Fixing simulator support for Apple Silicon Macs..."

# Check if we have the necessary files
if [ ! -f "${XCFRAMEWORK_PATH}/ios-x86_64-simulator/libopenmpt.a" ]; then
    echo "Error: x86_64 simulator library not found"
    exit 1
fi

# Step 1: Create ios-arm64_x86_64-simulator directory
echo "Creating universal simulator directory..."
mkdir -p "${XCFRAMEWORK_PATH}/ios-arm64_x86_64-simulator/Headers"

# Step 2: Copy the x86_64 library (temporary - should be replaced with proper universal binary)
echo "Copying simulator library..."
cp "${XCFRAMEWORK_PATH}/ios-x86_64-simulator/libopenmpt.a" \
   "${XCFRAMEWORK_PATH}/ios-arm64_x86_64-simulator/libopenmpt.a"

# Step 3: Copy headers
echo "Copying headers..."
cp -r "${XCFRAMEWORK_PATH}/ios-x86_64-simulator/Headers/" \
      "${XCFRAMEWORK_PATH}/ios-arm64_x86_64-simulator/Headers/"

# Step 4: Update Info.plist to include both architectures
echo "Updating Info.plist..."
cat > "${XCFRAMEWORK_PATH}/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>AvailableLibraries</key>
	<array>
		<dict>
			<key>BinaryPath</key>
			<string>libopenmpt.a</string>
			<key>HeadersPath</key>
			<string>Headers</string>
			<key>LibraryIdentifier</key>
			<string>ios-arm64_x86_64-simulator</string>
			<key>LibraryPath</key>
			<string>libopenmpt.a</string>
			<key>SupportedArchitectures</key>
			<array>
				<string>arm64</string>
				<string>x86_64</string>
			</array>
			<key>SupportedPlatform</key>
			<string>ios</string>
			<key>SupportedPlatformVariant</key>
			<string>simulator</string>
		</dict>
		<dict>
			<key>BinaryPath</key>
			<string>libopenmpt.a</string>
			<key>HeadersPath</key>
			<string>Headers</string>
			<key>LibraryIdentifier</key>
			<string>ios-arm64</string>
			<key>LibraryPath</key>
			<string>libopenmpt.a</string>
			<key>SupportedArchitectures</key>
			<array>
				<string>arm64</string>
			</array>
			<key>SupportedPlatform</key>
			<string>ios</string>
		</dict>
		<dict>
			<key>BinaryPath</key>
			<string>libopenmpt.a</string>
			<key>HeadersPath</key>
			<string>Headers</string>
			<key>LibraryIdentifier</key>
			<string>macos-arm64</string>
			<key>LibraryPath</key>
			<string>libopenmpt.a</string>
			<key>SupportedArchitectures</key>
			<array>
				<string>arm64</string>
			</array>
			<key>SupportedPlatform</key>
			<string>macos</string>
		</dict>
	</array>
	<key>CFBundlePackageType</key>
	<string>XFWK</string>
	<key>XCFrameworkFormatVersion</key>
	<string>1.0</string>
</dict>
</plist>
EOF

echo ""
echo "⚠️  WARNING: This is a TEMPORARY fix!"
echo "The simulator binary still only contains x86_64 architecture."
echo "For proper Apple Silicon simulator support, you need to:"
echo "1. Build libopenmpt for arm64 simulator from source"
echo "2. Create a universal binary with: lipo -create x86_64.a arm64.a -output universal.a"
echo "3. Use the build_xcframework.sh script for proper rebuilding"
echo ""
echo "This fix allows the package to be imported but may still fail at runtime on Apple Silicon simulators."
echo "Run ./build_xcframework.sh for instructions on proper fix."