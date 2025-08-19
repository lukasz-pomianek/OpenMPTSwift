//
//  OpenMPTPlayer.swift
//  OpenMPTSwift
//
//  iOS-optimized audio player using AVAudioEngine
//

import Foundation
@preconcurrency import AVFoundation

/// Delegate protocol for playback events
@MainActor
public protocol OpenMPTPlayerDelegate: AnyObject {
    func playerDidStartPlaying(_ player: OpenMPTPlayer)
    func playerDidStopPlaying(_ player: OpenMPTPlayer)
    func playerDidUpdatePosition(_ player: OpenMPTPlayer, position: PlaybackPosition)
    func playerDidEncounterError(_ player: OpenMPTPlayer, error: OpenMPTError)
}

/// Wrapper to make non-Sendable types work across actor boundaries
struct UncheckedSendable<Value>: @unchecked Sendable {
    let value: Value
    
    init(_ value: Value) {
        self.value = value
    }
}

/// High-level audio player for tracker modules using AVAudioEngine
@MainActor
public final class OpenMPTPlayer {
    public weak var delegate: OpenMPTPlayerDelegate?
    
    private let moduleWrapper: UncheckedSendable<OpenMPTModule>
    private let audioEngineWrapper: UncheckedSendable<AVAudioEngine>
    private var sourceNode: AVAudioSourceNode?
    private let audioFormatWrapper: UncheckedSendable<AVAudioFormat>
    private var isPlaying = false
    private var positionTimer: Timer?
    
    private var module: OpenMPTModule {
        moduleWrapper.value
    }
    
    private var audioEngine: AVAudioEngine {
        audioEngineWrapper.value
    }
    
    private var audioFormat: AVAudioFormat {
        audioFormatWrapper.value
    }
    
    public var moduleInfo: ModuleInfo? {
        return module.moduleInfo
    }
    
    public var currentPosition: PlaybackPosition? {
        return module.getCurrentPosition()
    }
    
    public init(sampleRate: Double = 48000) throws {
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2) else {
            throw OpenMPTError.loadFailed("Failed to create audio format")
        }
        self.audioFormatWrapper = UncheckedSendable(format)
        self.moduleWrapper = UncheckedSendable(OpenMPTModule())
        self.audioEngineWrapper = UncheckedSendable(AVAudioEngine())
        
        try setupAudioSession()
        setupAudioEngine()
    }
    
    deinit {
        // The audioEngine will be cleaned up automatically
        // We can't call stop() here due to actor isolation
    }
    
    /// Load a tracker module from file data
    /// - Parameter data: Raw module file data
    /// - Throws: OpenMPTError if loading fails
    public func loadModule(from data: Data) throws {
        stop() // Stop any current playback
        try module.loadModule(from: data)
    }
    
    /// Start playback
    /// - Throws: OpenMPTError if playback cannot be started
    public func play() throws {
        guard module.isLoaded else {
            throw OpenMPTError.notLoaded
        }
        
        guard !isPlaying else { return }
        
        try startAudioEngine()
        isPlaying = true
        startPositionUpdates()
        
        delegate?.playerDidStartPlaying(self)
    }
    
    /// Stop playback
    public func stop() {
        guard isPlaying else { return }
        
        stopAudioEngine()
        isPlaying = false
        stopPositionUpdates()
        
        delegate?.playerDidStopPlaying(self)
    }
    
    /// Seek to specific time position
    /// - Parameter seconds: Time in seconds
    public func seek(to seconds: Double) {
        _ = module.setPosition(seconds: seconds)
        
        if let position = module.getCurrentPosition() {
            delegate?.playerDidUpdatePosition(self, position: position)
        }
    }
    
    /// Get list of instrument names
    /// - Returns: Array of instrument names
    public func getInstrumentNames() -> [String] {
        return module.getInstrumentNames()
    }
    
    /// Get list of sample names  
    /// - Returns: Array of sample names
    public func getSampleNames() -> [String] {
        return module.getSampleNames()
    }
    
    // MARK: - Private Methods
    
    private func setupAudioSession() throws {
        #if os(iOS) || os(tvOS) || os(watchOS)
        let session = AVAudioSession.sharedInstance()
        
        try session.setCategory(.playback, mode: .default, options: [.allowBluetooth])
        try session.setActive(true)
        #endif
        // macOS doesn't need AVAudioSession setup
    }
    
    private func setupAudioEngine() {
        let sourceNode = AVAudioSourceNode { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            guard let self = self else {
                // Silence
                let bufferList = UnsafeMutableAudioBufferListPointer(audioBufferList)
                for buffer in bufferList {
                    memset(buffer.mData, 0, Int(buffer.mDataByteSize))
                }
                return noErr
            }
            
            return self.renderAudio(frameCount: frameCount, audioBufferList: audioBufferList)
        }
        
        self.sourceNode = sourceNode
        audioEngine.attach(sourceNode)
        audioEngine.connect(sourceNode, to: audioEngine.mainMixerNode, format: audioFormat)
    }
    
    private func startAudioEngine() throws {
        if !audioEngine.isRunning {
            try audioEngine.start()
        }
    }
    
    private func stopAudioEngine() {
        audioEngine.stop()
    }
    
    @MainActor
    private func notifyError(_ error: OpenMPTError) {
        delegate?.playerDidEncounterError(self, error: error)
    }
    
    nonisolated private func renderAudio(frameCount: UInt32, audioBufferList: UnsafeMutablePointer<AudioBufferList>) -> OSStatus {
        let bufferList = UnsafeMutableAudioBufferListPointer(audioBufferList)
        
        guard let buffer = bufferList[0].mData?.assumingMemoryBound(to: Float.self) else {
            return kAudioUnitErr_InvalidParameter
        }
        
        do {
            let samples = try moduleWrapper.value.renderAudio(
                sampleRate: Int32(audioFormatWrapper.value.sampleRate), 
                frameCount: Int(frameCount)
            )
            
            // Copy samples to output buffer
            let sampleCount = min(samples.count, Int(frameCount) * 2)
            for i in 0..<sampleCount {
                buffer[i] = samples[i]
            }
            
            // Fill remaining with silence if needed
            if sampleCount < Int(frameCount) * 2 {
                for i in sampleCount..<(Int(frameCount) * 2) {
                    buffer[i] = 0.0
                }
            }
            
        } catch {
            // Fill with silence on error
            for i in 0..<(Int(frameCount) * 2) {
                buffer[i] = 0.0
            }
            
            // Report error to main actor
            let errorToReport = error as? OpenMPTError ?? .renderFailed
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                self.notifyError(errorToReport)
            }
        }
        
        return noErr
    }
    
    private func startPositionUpdates() {
        positionTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self, let position = self.module.getCurrentPosition() else { return }
                self.delegate?.playerDidUpdatePosition(self, position: position)
            }
        }
    }
    
    private func stopPositionUpdates() {
        positionTimer?.invalidate()
        positionTimer = nil
    }
}