# OpenMPTSwift Usage Guide

This guide explains how to use the public Swift APIs exposed by OpenMPTSwift. It focuses on the two main entry points:

- `OpenMPTModule` for low-level access to libopenmpt functionality
- `OpenMPTPlayer` for a zero-configuration playback pipeline powered by `AVAudioEngine`

## Loading modules

```swift
import OpenMPTSwift

let data = try Data(contentsOf: moduleURL)
let module = OpenMPTModule()
try module.loadModule(from: data)
```

Once loaded you can query high-level information:

```swift
if let info = module.moduleInfo {
    print("Title: \(info.title)")
    print("Channels: \(info.channelCount)")
    print("Patterns: \(info.patternCount)")
    print("Duration: \(info.duration) seconds")
}
```

## Rendering audio frames

`OpenMPTModule` exposes direct rendering for custom audio pipelines:

```swift
let sampleRate: Int32 = 48_000
let frameCount = 1024
let interleavedStereo = try module.renderAudio(sampleRate: sampleRate, frameCount: frameCount)
```

Each render call returns an interleaved stereo buffer (`[L, R, L, R, ...]`) sized to the number of frames actually produced. Calls will throw `OpenMPTError.notLoaded` if no module is prepared, so guard your playback code accordingly.

## Seeking and position tracking

```swift
let newPositionSeconds = module.setPosition(seconds: 42.0)
let current = module.getCurrentPosition()
print("Order: \(current?.order ?? 0) Row: \(current?.row ?? 0)")
```

Position helpers also support order/row based seeking via `setPosition(order:row:)` from the pattern editing extension.

## Working with instruments and samples

The wrapper exposes lightweight helpers to inspect module contents:

```swift
let instrumentNames = module.getInstrumentNames()
let sampleNames = module.getSampleNames()
```

These functions return fallback names when a value is missing so UI code can present stable labels.

## Using the high-level player

`OpenMPTPlayer` handles `AVAudioEngine` setup, real-time rendering, and periodic position updates on the main actor.

```swift
class PlayerHost: OpenMPTPlayerDelegate {
    private var player: OpenMPTPlayer?

    func start() throws {
        player = try OpenMPTPlayer() // Defaults to 48 kHz stereo
        player?.delegate = self

        let data = try Data(contentsOf: moduleURL)
        try player?.loadModule(from: data)
        try player?.play()
    }

    // MARK: - OpenMPTPlayerDelegate
    func playerDidStartPlaying(_ player: OpenMPTPlayer) {
        print("Playback started")
    }

    func playerDidStopPlaying(_ player: OpenMPTPlayer) {
        print("Playback stopped")
    }

    func playerDidUpdatePosition(_ player: OpenMPTPlayer, position: PlaybackPosition) {
        print("Position: order \(position.order) row \(position.row)")
    }

    func playerDidEncounterError(_ player: OpenMPTPlayer, error: OpenMPTError) {
        print("Error: \(error.localizedDescription)")
    }
}
```

Key behaviors:

- `play()` throws when called without a loaded module.
- The player maintains a `Timer` that posts `playerDidUpdatePosition` callbacks roughly every 100 ms.
- Calling `seek(to:)` updates playback position and immediately reports the new location to the delegate.

## Pattern inspection and editing

`OpenMPTPatternEditor` extends `OpenMPTModule` with pattern-centric helpers. libopenmpt itself is read-only, so setters will throw `OpenMPTPatternError.readOnlyModule` when editing is not permitted.

Common queries:

```swift
let patternCount = module.getNumOrders()
let pattern0Rows = module.getPatternRows(pattern: 0)
let orderSequence = module.getOrderSequence()
let patternNames = module.getAllPatternNames()
```

Reading specific cells:

```swift
if let cell = module.getPatternCell(pattern: 0, channel: 0, row: 0) {
    print("Note: \(cell.note.noteName) Instrument: \(cell.instrument)")
}
```

Attempting edits with validation:

```swift
do {
    try module.setPatternNote(pattern: 0, channel: 0, row: 0, note: .c4)
} catch let error as OpenMPTPatternError {
    print("Pattern edit failed: \(error.localizedDescription)")
}
```

Advanced helpers like `insertPatternRow`, `deletePatternRow`, `selectSubsong(_:)`, `setRenderParam(_:value:)`, and `setControl(_:value:)` mirror the corresponding libopenmpt calls while providing Swift error handling.

## Error handling checklist

- `OpenMPTError.notLoaded` signals that no module has been provided yet.
- `OpenMPTError.renderFailed` indicates that rendering returned an error; audio callbacks automatically zero buffers when this happens.
- Pattern errors differentiate invalid indices (`invalidPattern`, `invalidChannel`, `invalidRow`) from read-only limitations.

## Threading notes

`OpenMPTPlayer` is annotated with `@MainActor`, while its audio rendering closure runs off the main thread. The internal `UncheckedSendable` wrapper allows the module and audio engine to be accessed from the render callback while ensuring delegate callbacks and timer updates execute on the main actor for UI safety.

## Next steps

For platform-specific build notes (including simulator support) see `SIMULATOR_SUPPORT.md` and the `build_xcframework.sh` script comments. The `Package.swift` manifest lists the binary target layout used by Swift Package Manager.
