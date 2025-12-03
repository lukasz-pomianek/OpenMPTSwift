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
- 🎚️ **Zero-configuration** high-level player that just works

## Requirements

- iOS 17.0+ / macOS 15.0+
- Xcode 16.0+
- Swift 6.0+

## Installation

Add OpenMPTSwift to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/lpomianek/OpenMPTSwift.git", from: "1.0.0")
]
```

> The minimum deployment targets follow the Swift 6 manifest. If you need earlier platform support, pin to an older release or
> use a custom fork with adjusted deployment targets.

## API Overview

### `OpenMPTModule`

Low-level wrapper that exposes libopenmpt directly. Use it to:

- Load module data and query metadata via `moduleInfo`
- Render interleaved stereo audio with `renderAudio(sampleRate:frameCount:)`
- Inspect instruments and samples via `getInstrumentNames()` / `getSampleNames()`
- Seek playback using seconds or order/row helpers from the pattern editing extensions

### `OpenMPTPlayer`

High-level player that wires up `AVAudioEngine` for you. It provides:

- A simple `loadModule(from:)` + `play()` flow with automatic engine setup
- Delegate callbacks for lifecycle (`playerDidStartPlaying`, `playerDidStopPlaying`) and position updates
- Safe error reporting on the main actor when the render callback encounters problems

### `OpenMPTPatternEditor`

Extension methods on `OpenMPTModule` that mirror libopenmpt's pattern APIs for reading cells, manipulating orders, and working
with subsongs and render parameters. libopenmpt itself is read-only—write attempts will surface `OpenMPTPatternError.readOnlyModule`.

## Usage

See [`docs/USAGE.md`](docs/USAGE.md) for end-to-end examples that cover loading modules, rendering audio, responding to player
events, and working with patterns.

## Quick Start

### Basic Playback

OpenMPTPlayer provides a complete, zero-configuration audio player that handles all AVAudioEngine setup automatically:

```swift
import OpenMPTSwift

class MusicPlayer: OpenMPTPlayerDelegate {
    private var player: OpenMPTPlayer?
    
    func loadAndPlayModule() {
        do {
            // Creates player with fully configured AVAudioEngine
            player = try OpenMPTPlayer()
            player?.delegate = self
            
            // Load module from file
            let moduleData = try Data(contentsOf: moduleURL)
            try player?.loadModule(from: moduleData)
            
            // Start playback - everything is ready to go!
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
- `OpenMPTModule`: Low-level module access for custom audio pipelines
- `OpenMPTPlayer`: Complete zero-configuration audio player with:
  - Automatic AVAudioEngine setup and configuration
  - Real-time audio rendering with proper threading
  - Position tracking and seeking capabilities
  - Delegate-based event handling

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