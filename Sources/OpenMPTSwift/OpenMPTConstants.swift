//
//  OpenMPTConstants.swift
//  OpenMPTSwift
//
//  Constants and parameters for OpenMPT functionality
//

import Foundation

/// Render parameters that can be used with getRenderParam/setRenderParam
public enum OpenMPTRenderParam: Int32, Sendable {
    /// Mastergain (0...4, default 1) - Controls overall gain
    case masterGain = 0
    
    /// Stereo separation (0...4, default 1) - Controls stereo separation
    case stereoSeparation = 1
    
    /// Interpolation filter length (1, 2, 4, 8, default 8) - Controls interpolation quality
    case interpolationFilterLength = 2
    
    /// Volume ramping strength (-1...10, default -1) - Controls volume ramping
    case volumeRampingStrength = 3
    
    /// Raw value for use with libopenmpt functions
    public var rawValue: Int32 {
        switch self {
        case .masterGain: return 0
        case .stereoSeparation: return 1
        case .interpolationFilterLength: return 2
        case .volumeRampingStrength: return 3
        }
    }
}

/// Pattern command indices for pattern cell data access
public enum OpenMPTPatternCommand: Int32, Sendable {
    /// Note command (0-119 for notes, 254=off, 255=cut)
    case note = 0
    
    /// Instrument number (1-255, 0=none)
    case instrument = 1
    
    /// Volume column command (0=none, 1-64=volume)
    case volume = 2
    
    /// Effect command (A-Z, various effects)
    case effect = 3
    
    /// Effect parameter (0-255, parameter for effect)
    case effectParam = 4
    
    /// Raw value for use with libopenmpt functions
    public var rawValue: Int32 {
        switch self {
        case .note: return 0
        case .instrument: return 1
        case .volume: return 2
        case .effect: return 3
        case .effectParam: return 4
        }
    }
}

/// Common control strings for use with getControl/setControl
public struct OpenMPTControl {
    /// Playback controls
    public static let playAtEnd = "play.at_end"
    public static let playRepeats = "play.repeats"
    
    /// Seeking controls
    public static let seekSyncSamples = "seek.sync_samples"
    
    /// Loading controls
    public static let loadSkipSamples = "load.skip_samples"
    public static let loadSkipPatterns = "load.skip_patterns"
    public static let loadSkipPlugins = "load.skip_plugins"
    
    /// Rendering controls
    public static let renderStereoSeparationPercent = "render.stereoseparation_percent"
    public static let renderInterpolationFilterLength = "render.interpolationfilter_length"
    public static let renderVolumeRampingStrength = "render.volumeramping_strength"
    
    /// DSP controls
    public static let dspMegabass = "dsp.megabass"
    public static let dspNoisereduction = "dsp.noisereduction"
    public static let dsp4tapEQ = "dsp.4tap_eq"
}

/// Common metadata keys
public struct OpenMPTMetadata {
    /// Basic information
    public static let type = "type"
    public static let title = "title"
    public static let artist = "artist"
    public static let date = "date"
    public static let comment = "message"
    
    /// Technical information
    public static let tracker = "tracker"
    public static let container = "container"
    public static let warnings = "warnings"
    
    /// Extended information
    public static let typeLong = "type_long"
    public static let originaltype = "originaltype"
    public static let originaltypeLong = "originaltype_long"
}

/// Note values for easier reference
public extension OpenMPTNote {
    /// All chromatic notes for octave 4 (middle octave)
    static let chromatic4: [OpenMPTNote] = [
        .c4, .cs4, .d4, .ds4, .e4, .f4, .fs4, .g4, .gs4, .a4, .as4, .b4
    ]
    
    /// Check if note is a musical note (not special command)
    var isMusicalNote: Bool {
        switch self {
        case .none, .noteOff, .noteCut:
            return false
        default:
            return true
        }
    }
    
    /// Get semitone within octave (0-11)
    var semitone: Int {
        guard isMusicalNote else { return -1 }
        return Int(rawValue) % 12
    }
    
    /// Get octave number
    var octave: Int {
        guard isMusicalNote else { return -1 }
        return (Int(rawValue) / 12) - 1
    }
}

/// Pattern cell convenience extensions
public extension OpenMPTPatternCell {
    /// Create a cell with just a note
    static func note(_ note: OpenMPTNote) -> OpenMPTPatternCell {
        return OpenMPTPatternCell(note: note)
    }
    
    /// Create a cell with note and instrument
    static func noteInstrument(_ note: OpenMPTNote, instrument: UInt8) -> OpenMPTPatternCell {
        return OpenMPTPatternCell(note: note, instrument: instrument)
    }
    
    /// Create a cell with note, instrument, and volume
    static func noteInstrumentVolume(_ note: OpenMPTNote, instrument: UInt8, volume: UInt8) -> OpenMPTPatternCell {
        return OpenMPTPatternCell(note: note, instrument: instrument, volume: volume)
    }
    
    /// Check if cell has any note data
    var hasNote: Bool {
        return note != .none
    }
    
    /// Check if cell has instrument data
    var hasInstrument: Bool {
        return instrument > 0
    }
    
    /// Check if cell has volume data
    var hasVolume: Bool {
        return volume > 0
    }
    
    /// Check if cell has effect data
    var hasEffect: Bool {
        return effect > 0 || effectParam > 0
    }
}