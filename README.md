# OpenMPTSwift

A Swift Package Manager library providing iOS/macOS integration for [libopenmpt](https://lib.openmpt.org/libopenmpt/), enabling high-quality playback of tracker music formats.

## Supported Formats

OpenMPTSwift supports a wide range of tracker formats including:

- **IT** (Impulse Tracker)
- **XM** (Extended Module) 
- **S3M** (Scream Tracker 3)
- **MOD** (Protracker/Noisetracker)
- **MPTM** (OpenMPT)
- And many more legacy formats

## Features

- 🎵 **High-quality audio rendering** using libopenmpt
- 🍎 **iOS/macOS native** integration with AVAudioEngine
- ⚡ **Real-time playback** with position tracking
- 📱 **Mobile-optimized** API design
- 🎛️ **Module information** access (instruments, samples, patterns)
- 🔄 **Seeking support** for interactive playback
- 📦 **Swift Package Manager** integration

## Requirements

- iOS 14.0+ / macOS 11.0+
- Xcode 13.0+
- Swift 5.5+

## Installation

Add OpenMPTSwift to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/OpenMPTSwift.git", from: "1.0.0")
]
```

## Quick Start

### Basic Playback

```swift
import OpenMPTSwift

class MusicPlayer: OpenMPTPlayerDelegate {
    private var player: OpenMPTPlayer?
    
    func loadAndPlayModule() {
        do {
            player = try OpenMPTPlayer()
            player?.delegate = self
            
            // Load module from file
            let moduleData = try Data(contentsOf: moduleURL)
            try player?.loadModule(from: moduleData)
            
            // Start playback
            try player?.play()
            
        } catch {
            print("Error: \\(error)")
        }
    }
    
    // MARK: - OpenMPTPlayerDelegate
    
    func playerDidStartPlaying(_ player: OpenMPTPlayer) {
        print("Playback started")
    }
    
    func playerDidUpdatePosition(_ player: OpenMPTPlayer, position: PlaybackPosition) {
        print("Position: Order \\(position.order), Row \\(position.row)")
    }
}
```

### Module Information

```swift
if let info = player?.moduleInfo {
    print("Title: \\(info.title)")
    print("Artist: \\(info.artist)") 
    print("Duration: \\(info.duration) seconds")
    print("Instruments: \\(info.instrumentCount)")
    print("Samples: \\(info.sampleCount)")
}

// Get instrument and sample names
let instruments = player?.getInstrumentNames() ?? []
let samples = player?.getSampleNames() ?? []
```

### Low-level Module Access

```swift
let module = OpenMPTModule()
try module.loadModule(from: data)

// Manual audio rendering
let sampleRate: Int32 = 48000
let frameCount = 1024
let audioSamples = try module.renderAudio(sampleRate: sampleRate, frameCount: frameCount)

// Position control
let newPosition = module.setPosition(seconds: 30.0)
let currentPos = module.getCurrentPosition()
```

## Architecture

OpenMPTSwift consists of three layers:

### 1. libopenmpt (C++)
The core audio rendering engine, distributed as an XCFramework binary.

### 2. OpenMPTCore (C++ Bridge)
C-compatible wrapper around libopenmpt for Swift interop.

### 3. OpenMPTSwift (Swift API)
High-level Swift API providing:
- `OpenMPTModule`: Low-level module access
- `OpenMPTPlayer`: High-level audio player with AVAudioEngine integration

## Building libopenmpt for iOS

> **Note**: Pre-built XCFrameworks will be provided in releases. This section is for advanced users who want to build from source.

To build libopenmpt for iOS:

1. **Clone OpenMPT repository**:
   ```bash
   git clone https://github.com/OpenMPT/openmpt.git
   cd openmpt
   ```

2. **Generate Xcode project**:
   ```bash
   premake5 --file=build/premake/premake.lua --group=libopenmpt --os=macosx xcode4
   ```

3. **Configure for iOS**:
   - Open generated Xcode project
   - Set Base SDK to "Latest iOS"
   - Set Architectures to "Standard architectures"

4. **Build for all architectures**:
   - Build for arm64 (iOS device)
   - Build for x86_64 (iOS simulator)

5. **Create XCFramework**:
   ```bash
   xcodebuild -create-xcframework \\
     -library path/to/arm64/libopenmpt.a \\
     -library path/to/x86_64/libopenmpt.a \\
     -output libopenmpt.xcframework
   ```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

OpenMPTSwift is available under the BSD license. See the LICENSE file for more info.

libopenmpt is available under the BSD license. See [libopenmpt licensing](https://lib.openmpt.org/libopenmpt/md__home_manx_dev_openmpt_libopenmpt_LICENSE.html) for details.

## Credits

- **libopenmpt** by the OpenMPT team
- **Swift wrapper** by Łukasz Pomianek
- Based on the original **Impulse Tracker** by Jeffrey Lim