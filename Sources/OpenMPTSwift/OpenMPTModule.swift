//
//  OpenMPTModule.swift
//  OpenMPTSwift
//
//  Swift API for libopenmpt module playback
//

import Foundation
import CLibOpenMPT

/// Errors that can occur when working with OpenMPT modules
public enum OpenMPTError: Error, LocalizedError {
    case invalidData
    case loadFailed(String)
    case notLoaded
    case renderFailed
    
    public var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Invalid module data provided"
        case .loadFailed(let reason):
            return "Failed to load module: \(reason)"
        case .notLoaded:
            return "No module loaded"
        case .renderFailed:
            return "Failed to render audio"
        }
    }
}

/// Information about a tracker module
public struct ModuleInfo {
    public let title: String
    public let artist: String
    public let type: String
    public let duration: TimeInterval
    public let instrumentCount: Int
    public let sampleCount: Int
    public let patternCount: Int
    public let channelCount: Int
}

/// Information about the current playback position
public struct PlaybackPosition {
    public let seconds: TimeInterval
    public let order: Int
    public let pattern: Int
    public let row: Int
    public let speed: Int
    public let tempo: Int
}

/// Swift wrapper for libopenmpt module playback
public final class OpenMPTModule {
    internal var module: OpaquePointer?
    private var _moduleInfo: ModuleInfo?
    
    public var isLoaded: Bool {
        return module != nil
    }
    
    public var moduleInfo: ModuleInfo? {
        return _moduleInfo
    }
    
    public init() {}
    
    deinit {
        if let module = module {
            openmpt_module_destroy(module)
        }
    }
    
    /// Load a tracker module from data
    /// - Parameter data: Raw module file data
    /// - Throws: OpenMPTError if loading fails
    public func loadModule(from data: Data) throws {
        // Clean up existing module
        if let existingModule = module {
            openmpt_module_destroy(existingModule)
            module = nil
            _moduleInfo = nil
        }
        
        let loadedModule = try data.withUnsafeBytes { bytes in
            guard let baseAddress = bytes.baseAddress else {
                throw OpenMPTError.invalidData
            }
            
            var error: Int32 = 0
            var errorMessage: UnsafePointer<Int8>? = nil
            
            let module = openmpt_module_create_from_memory2(
                baseAddress,
                bytes.count,
                nil, // logfunc
                nil, // loguser
                nil, // errfunc
                nil, // erruser
                &error,
                &errorMessage,
                nil  // ctls
            )
            
            guard module != nil else {
                throw OpenMPTError.loadFailed("openmpt_module_create_from_memory2 returned null")
            }
            
            return module!
        }
        
        self.module = loadedModule
        self._moduleInfo = extractModuleInfo()
        
        // Set up default playback settings
        _ = openmpt_module_set_repeat_count(loadedModule, -1) // Loop infinitely
    }
    
    /// Get current playback position
    /// - Returns: Current playback position information
    public func getCurrentPosition() -> PlaybackPosition? {
        guard let module = module else { return nil }
        
        return PlaybackPosition(
            seconds: openmpt_module_get_position_seconds(module),
            order: Int(openmpt_module_get_current_order(module)),
            pattern: Int(openmpt_module_get_current_pattern(module)), 
            row: Int(openmpt_module_get_current_row(module)),
            speed: Int(openmpt_module_get_current_speed(module)),
            tempo: Int(openmpt_module_get_current_tempo2(module))
        )
    }
    
    /// Set playback position to specific time
    /// - Parameter seconds: Time in seconds to seek to
    /// - Returns: Actual position set (may differ due to quantization)
    public func setPosition(seconds: Double) -> Double {
        guard let module = module else { return 0.0 }
        return openmpt_module_set_position_seconds(module, seconds)
    }
    
    /// Render audio frames
    /// - Parameters:
    ///   - sampleRate: Sample rate for rendering (e.g., 48000)
    ///   - frameCount: Number of stereo frames to render
    /// - Returns: Array of interleaved stereo samples (left, right, left, right, ...)
    /// - Throws: OpenMPTError if rendering fails
    public func renderAudio(sampleRate: Int32, frameCount: Int) throws -> [Float] {
        guard let module = module else {
            throw OpenMPTError.notLoaded
        }
        
        var interleavedSamples = Array<Float>(repeating: 0.0, count: frameCount * 2)
        
        let renderedFrames = interleavedSamples.withUnsafeMutableBufferPointer { buffer in
            return openmpt_module_read_interleaved_float_stereo(
                module,
                sampleRate,
                frameCount,
                buffer.baseAddress!
            )
        }
        
        // Trim to actual rendered frames
        let actualSampleCount = Int(renderedFrames) * 2
        return Array(interleavedSamples.prefix(actualSampleCount))
    }
    
    /// Get instrument names
    /// - Returns: Array of instrument names
    public func getInstrumentNames() -> [String] {
        guard let module = module, let info = _moduleInfo else { return [] }
        
        var names: [String] = []
        for i in 1...info.instrumentCount { // OpenMPT uses 1-based indexing
            if let cString = openmpt_module_get_instrument_name(module, Int32(i)),
               let name = String(cString: cString, encoding: .utf8) {
                names.append(name)
            } else {
                names.append("Instrument \(i)")
            }
        }
        return names
    }
    
    /// Get sample names  
    /// - Returns: Array of sample names
    public func getSampleNames() -> [String] {
        guard let module = module, let info = _moduleInfo else { return [] }
        
        var names: [String] = []
        for i in 1...info.sampleCount { // OpenMPT uses 1-based indexing
            if let cString = openmpt_module_get_sample_name(module, Int32(i)),
               let name = String(cString: cString, encoding: .utf8) {
                names.append(name)
            } else {
                names.append("Sample \(i)")
            }
        }
        return names
    }
    
    // MARK: - Private Methods
    
    private func extractModuleInfo() -> ModuleInfo? {
        guard let module = module else { return nil }
        
        let title = getString("title") ?? "Unknown"
        let artist = getString("artist") ?? "Unknown"
        let type = getString("type") ?? "Unknown"
        
        return ModuleInfo(
            title: title,
            artist: artist,
            type: type,
            duration: openmpt_module_get_duration_seconds(module),
            instrumentCount: Int(openmpt_module_get_num_instruments(module)),
            sampleCount: Int(openmpt_module_get_num_samples(module)),
            patternCount: Int(openmpt_module_get_num_patterns(module)),
            channelCount: Int(openmpt_module_get_num_channels(module))
        )
    }
    
    private func getString(_ key: String) -> String? {
        guard let module = module else { return nil }
        
        if let cString = openmpt_module_get_metadata(module, key),
           let string = String(cString: cString, encoding: .utf8) {
            return string.isEmpty ? nil : string
        }
        return nil
    }
}