# iOS Simulator Support for Apple Silicon Macs

## Current Issue

The package currently fails on Apple Silicon Mac simulators because the XCFramework only includes:
- ✅ `ios-arm64` - Physical iOS devices (iPhone/iPad)  
- ✅ `ios-x86_64-simulator` - Intel Mac simulators
- ❌ `ios-arm64-simulator` - Apple Silicon Mac simulators (M1/M2/M3)

When developers with Apple Silicon Macs try to build for iOS Simulator, Xcode looks for arm64 simulator architecture but only finds x86_64, causing the build to fail.

## Solution Options

### Option 1: Build Universal Simulator Binary (Recommended)

Create a fat binary that includes both x86_64 and arm64 for simulators:

1. **Build libopenmpt for arm64 simulator:**
```bash
xcodebuild -project path/to/libopenmpt.xcodeproj \
           -scheme libopenmpt-static \
           -sdk iphonesimulator \
           -arch arm64 \
           -configuration Release \
           EXCLUDED_ARCHS= \
           ONLY_ACTIVE_ARCH=NO
```

2. **Create universal simulator binary:**
```bash
lipo -create \
     ios-simulator-x86_64/libopenmpt.a \
     ios-simulator-arm64/libopenmpt.a \
     -output ios-simulator-universal/libopenmpt.a
```

3. **Rebuild XCFramework:**
```bash
xcodebuild -create-xcframework \
    -library ios-arm64/libopenmpt.a \
    -headers path/to/headers \
    -library ios-simulator-universal/libopenmpt.a \
    -headers path/to/headers \
    -library macos-arm64/libopenmpt.a \
    -headers path/to/headers \
    -output LibOpenMPT.xcframework
```

### Option 2: Separate Simulator Slices

Keep x86_64 and arm64 simulators as separate slices in the XCFramework:

```bash
xcodebuild -create-xcframework \
    -library ios-arm64/libopenmpt.a \
    -headers path/to/headers \
    -library ios-x86_64-simulator/libopenmpt.a \
    -headers path/to/headers \
    -library ios-arm64-simulator/libopenmpt.a \
    -headers path/to/headers \
    -library macos-arm64/libopenmpt.a \
    -headers path/to/headers \
    -output LibOpenMPT.xcframework
```

## Quick Test

To verify simulator support after fixing:

```bash
# Check architectures in the universal binary
lipo -info Frameworks/LibOpenMPT.xcframework/ios-simulator-universal/libopenmpt.a

# Should output:
# Architectures in the fat file: libopenmpt.a are: x86_64 arm64
```

## Building from Source

### Prerequisites
- Xcode 14+ with iOS SDK
- premake5 (`brew install premake`)
- OpenMPT source code

### Steps

1. **Clone OpenMPT:**
```bash
git clone https://github.com/OpenMPT/openmpt.git
cd openmpt
```

2. **Generate Xcode project:**
```bash
premake5 --file=build/premake/premake.lua xcode4
```

3. **Build for each architecture** using the provided `build_xcframework.sh` script

## Package.swift Considerations

The Package.swift file correctly references the binary target:

```swift
.binaryTarget(
    name: "LibOpenMPT",
    path: "Frameworks/LibOpenMPT.xcframework"
)
```

No changes needed here - the XCFramework format automatically selects the correct slice based on the build target.

## Testing

After fixing, test on:
1. Physical iOS device (arm64)
2. Intel Mac with iOS Simulator (x86_64)  
3. Apple Silicon Mac with iOS Simulator (arm64)

## Distribution

For public release, ensure the XCFramework includes:
- `ios-arm64` (devices)
- `ios-arm64_x86_64-simulator` (universal simulator) OR separate slices
- `macos-arm64` (if supporting macOS)
- `macos-x86_64` (optional, for Intel Mac support)

## Common Errors

**Error:** "No such module 'LibOpenMPT'"
- **Cause:** Missing architecture for current build target
- **Fix:** Rebuild XCFramework with all required architectures

**Error:** "Building for iOS Simulator, but the linked library was built for iOS"  
- **Cause:** Using device binary for simulator
- **Fix:** Build specifically for iphonesimulator SDK

**Error:** "Could not find module 'LibOpenMPT' for target 'arm64-apple-ios-simulator'"
- **Cause:** Missing arm64 simulator slice
- **Fix:** Add arm64 simulator support as described above