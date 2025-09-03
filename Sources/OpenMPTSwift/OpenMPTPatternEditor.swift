//
//  OpenMPTPatternEditor.swift
//  OpenMPTSwift
//
//  Pattern editing extensions for OpenMPTModule
//  Provides real-time pattern modification capabilities
//

import Foundation
import CLibOpenMPT

/// Note values for pattern cells
public enum OpenMPTNote: UInt8, CaseIterable, Sendable {
    case none = 0
    case c4 = 60     // Middle C
    case cs4 = 61    // C# 4
    case d4 = 62     // D 4
    case ds4 = 63    // D# 4
    case e4 = 64     // E 4
    case f4 = 65     // F 4
    case fs4 = 66    // F# 4
    case g4 = 67     // G 4
    case gs4 = 68    // G# 4
    case a4 = 69     // A 4
    case as4 = 70    // A# 4
    case b4 = 71     // B 4
    case c5 = 72     // C 5
    case noteOff = 254
    case noteCut = 255
    
    /// Convert MIDI note number to OpenMPT note
    public init(midiNote: UInt8) {
        if midiNote == 0 {
            self = .none
        } else if midiNote <= 120 {
            self = Self(rawValue: midiNote) ?? .none
        } else if midiNote == 254 {
            self = .noteOff
        } else if midiNote == 255 {
            self = .noteCut
        } else {
            self = .none
        }
    }
    
    /// Get note name for display
    public var noteName: String {
        switch self {
        case .none: return "---"
        case .noteOff: return "OFF"
        case .noteCut: return "CUT"
        default:
            let noteNames = ["C-", "C#", "D-", "D#", "E-", "F-", "F#", "G-", "G#", "A-", "A#", "B-"]
            let octave = (Int(rawValue) / 12) - 1  // Adjust so that MIDI 60 (C4) gives octave 4
            let noteIndex = Int(rawValue) % 12
            return "\(noteNames[noteIndex])\(octave)"
        }
    }
}

/// Pattern cell data structure
public struct OpenMPTPatternCell: Sendable {
    public let note: OpenMPTNote
    public let instrument: UInt8  // 0 = none, 1-255 = instrument number
    public let volume: UInt8      // 0 = none, 1-64 = volume
    public let effect: UInt8      // Effect command
    public let effectParam: UInt8 // Effect parameter
    
    public init(note: OpenMPTNote = .none, instrument: UInt8 = 0, volume: UInt8 = 0, effect: UInt8 = 0, effectParam: UInt8 = 0) {
        self.note = note
        self.instrument = instrument
        self.volume = volume
        self.effect = effect
        self.effectParam = effectParam
    }
    
    /// Check if cell is empty
    public var isEmpty: Bool {
        return note == .none && instrument == 0 && volume == 0 && effect == 0 && effectParam == 0
    }
}

/// Pattern editing errors
public enum OpenMPTPatternError: Error, LocalizedError, Equatable, Sendable {
    case invalidPattern(Int)
    case invalidChannel(Int)
    case invalidRow(Int)
    case editingNotSupported
    case moduleNotLoaded
    case readOnlyModule
    
    public var errorDescription: String? {
        switch self {
        case .invalidPattern(let pattern):
            return "Invalid pattern number: \(pattern)"
        case .invalidChannel(let channel):
            return "Invalid channel number: \(channel)"
        case .invalidRow(let row):
            return "Invalid row number: \(row)"
        case .editingNotSupported:
            return "Pattern editing is not supported for this module"
        case .moduleNotLoaded:
            return "No module loaded"
        case .readOnlyModule:
            return "libopenmpt is read-only - pattern editing is not supported"
        }
    }
}

/// Pattern editing capabilities for OpenMPTModule
extension OpenMPTModule {
    
    // MARK: - Pattern Information
    
    /// Get number of rows in a specific pattern
    /// - Parameter pattern: Pattern number (0-based)
    /// - Returns: Number of rows, or -1 if pattern is invalid
    public func getPatternRows(pattern: Int) -> Int {
        guard isLoaded, let module = module else { return -1 }
        return Int(openmpt_module_get_pattern_rows(module, Int32(pattern)))
    }
    
    /// Get pattern name
    /// - Parameter pattern: Pattern number (0-based)
    /// - Returns: Pattern name, or empty string if invalid
    public func getPatternName(pattern: Int) -> String {
        guard isLoaded, let module = module else { return "" }
        if let cString = openmpt_module_get_pattern_name(module, Int32(pattern)) {
            let name = String(cString: cString)
            openmpt_free_string(cString)
            return name
        }
        return ""
    }
    
    /// Get rows per beat for a specific pattern
    /// - Parameter pattern: Pattern number (0-based)
    /// - Returns: Rows per beat, or -1 if pattern is invalid
    public func getPatternRowsPerBeat(pattern: Int) -> Int {
        guard isLoaded, let module = module else { return -1 }
        return Int(openmpt_module_get_pattern_rows_per_beat(module, Int32(pattern)))
    }
    
    /// Get rows per measure for a specific pattern
    /// - Parameter pattern: Pattern number (0-based)
    /// - Returns: Rows per measure, or -1 if pattern is invalid
    public func getPatternRowsPerMeasure(pattern: Int) -> Int {
        guard isLoaded, let module = module else { return -1 }
        return Int(openmpt_module_get_pattern_rows_per_measure(module, Int32(pattern)))
    }
    
    /// Get pattern cell data
    /// - Parameters:
    ///   - pattern: Pattern number (0-based)
    ///   - channel: Channel number (0-based)
    ///   - row: Row number (0-based)
    /// - Returns: Pattern cell data, or nil if invalid coordinates
    public func getPatternCell(pattern: Int, channel: Int, row: Int) -> OpenMPTPatternCell? {
        guard isLoaded, let module = module else { return nil }
        
        var cellData = openmpt_pattern_cell()
        let result = openmpt_module_get_pattern_cell(module, Int32(pattern), Int32(channel), Int32(row), &cellData)
        
        guard result == 1 else { return nil }
        
        return OpenMPTPatternCell(
            note: OpenMPTNote(midiNote: cellData.note),
            instrument: cellData.instrument,
            volume: cellData.volume,
            effect: cellData.effect,
            effectParam: cellData.effect_param
        )
    }
    
    // MARK: - Pattern Editing
    
    /// Set pattern cell data
    /// - Parameters:
    ///   - pattern: Pattern number (0-based)
    ///   - channel: Channel number (0-based)  
    ///   - row: Row number (0-based)
    ///   - cell: New cell data
    /// - Throws: OpenMPTPatternError if coordinates are invalid
    public func setPatternCell(pattern: Int, channel: Int, row: Int, cell: OpenMPTPatternCell) throws {
        guard isLoaded, let module = module else {
            throw OpenMPTPatternError.moduleNotLoaded
        }
        
        // Validate coordinates
        let patternCount = Int(openmpt_module_get_num_patterns(module))
        let channelCount = Int(openmpt_module_get_num_channels(module))
        let rowCount = getPatternRows(pattern: pattern)
        
        guard pattern >= 0 && pattern < patternCount else {
            throw OpenMPTPatternError.invalidPattern(pattern)
        }
        guard channel >= 0 && channel < channelCount else {
            throw OpenMPTPatternError.invalidChannel(channel)
        }
        guard row >= 0 && row < rowCount else {
            throw OpenMPTPatternError.invalidRow(row)
        }
        
        var cellData = openmpt_pattern_cell(
            note: cell.note.rawValue,
            instrument: cell.instrument,
            volume: cell.volume,
            effect: cell.effect,
            effect_param: cell.effectParam
        )
        
        let result = openmpt_module_set_pattern_cell(module, Int32(pattern), Int32(channel), Int32(row), &cellData)
        
        if result != 1 {
            throw OpenMPTPatternError.readOnlyModule
        }
    }
    
    /// Set only the note in a pattern cell
    /// - Parameters:
    ///   - pattern: Pattern number (0-based)
    ///   - channel: Channel number (0-based)
    ///   - row: Row number (0-based) 
    ///   - note: New note value
    /// - Throws: OpenMPTPatternError if coordinates are invalid
    public func setPatternNote(pattern: Int, channel: Int, row: Int, note: OpenMPTNote) throws {
        guard var existingCell = getPatternCell(pattern: pattern, channel: channel, row: row) else {
            throw OpenMPTPatternError.invalidRow(row)
        }
        
        existingCell = OpenMPTPatternCell(
            note: note,
            instrument: existingCell.instrument,
            volume: existingCell.volume,
            effect: existingCell.effect,
            effectParam: existingCell.effectParam
        )
        
        try setPatternCell(pattern: pattern, channel: channel, row: row, cell: existingCell)
    }
    
    /// Set only the instrument in a pattern cell
    /// - Parameters:
    ///   - pattern: Pattern number (0-based)
    ///   - channel: Channel number (0-based)
    ///   - row: Row number (0-based)
    ///   - instrument: Instrument number (1-255, 0 = none)
    /// - Throws: OpenMPTPatternError if coordinates are invalid
    public func setPatternInstrument(pattern: Int, channel: Int, row: Int, instrument: UInt8) throws {
        guard var existingCell = getPatternCell(pattern: pattern, channel: channel, row: row) else {
            throw OpenMPTPatternError.invalidRow(row)
        }
        
        existingCell = OpenMPTPatternCell(
            note: existingCell.note,
            instrument: instrument,
            volume: existingCell.volume,
            effect: existingCell.effect,
            effectParam: existingCell.effectParam
        )
        
        try setPatternCell(pattern: pattern, channel: channel, row: row, cell: existingCell)
    }
    
    /// Clear a pattern cell (set all values to empty)
    /// - Parameters:
    ///   - pattern: Pattern number (0-based)
    ///   - channel: Channel number (0-based)
    ///   - row: Row number (0-based)
    /// - Throws: OpenMPTPatternError if coordinates are invalid
    public func clearPatternCell(pattern: Int, channel: Int, row: Int) throws {
        try setPatternCell(pattern: pattern, channel: channel, row: row, cell: OpenMPTPatternCell())
    }
    
    /// Clear an entire row across all channels
    /// - Parameters:
    ///   - pattern: Pattern number (0-based)
    ///   - row: Row number (0-based)
    /// - Throws: OpenMPTPatternError if coordinates are invalid
    public func clearPatternRow(pattern: Int, row: Int) throws {
        guard isLoaded, let module = module else {
            throw OpenMPTPatternError.moduleNotLoaded
        }
        
        let channelCount = Int(openmpt_module_get_num_channels(module))
        
        for channel in 0..<channelCount {
            try clearPatternCell(pattern: pattern, channel: channel, row: row)
        }
    }
    
    // MARK: - Advanced Pattern Operations
    
    /// Insert a new row at the specified position, shifting existing rows down
    /// - Parameters:
    ///   - pattern: Pattern number (0-based)
    ///   - row: Row number where to insert (0-based)
    /// - Throws: OpenMPTPatternError if coordinates are invalid
    public func insertPatternRow(pattern: Int, row: Int) throws {
        guard isLoaded, let module = module else {
            throw OpenMPTPatternError.moduleNotLoaded
        }
        
        let result = openmpt_module_insert_pattern_row(module, Int32(pattern), Int32(row))
        
        if result != 1 {
            throw OpenMPTPatternError.readOnlyModule
        }
    }
    
    /// Delete a row at the specified position, shifting existing rows up
    /// - Parameters:
    ///   - pattern: Pattern number (0-based)
    ///   - row: Row number to delete (0-based)
    /// - Throws: OpenMPTPatternError if coordinates are invalid
    public func deletePatternRow(pattern: Int, row: Int) throws {
        guard isLoaded, let module = module else {
            throw OpenMPTPatternError.moduleNotLoaded
        }
        
        let result = openmpt_module_delete_pattern_row(module, Int32(pattern), Int32(row))
        
        if result != 1 {
            throw OpenMPTPatternError.readOnlyModule
        }
    }
    
    // MARK: - Order and Sequence Functions
    
    /// Get number of orders in the module
    /// - Returns: Number of orders, or -1 if module not loaded
    public func getNumOrders() -> Int {
        guard isLoaded, let module = module else { return -1 }
        return Int(openmpt_module_get_num_orders(module))
    }
    
    /// Get pattern number for a specific order
    /// - Parameter order: Order position (0-based)
    /// - Returns: Pattern number, or -1 if invalid
    public func getOrderPattern(order: Int) -> Int {
        guard isLoaded, let module = module else { return -1 }
        return Int(openmpt_module_get_order_pattern(module, Int32(order)))
    }
    
    /// Set playback position by order and row
    /// - Parameters:
    ///   - order: Order position (0-based)
    ///   - row: Row within pattern (0-based)
    /// - Returns: Actual position set in seconds
    public func setPosition(order: Int, row: Int) -> TimeInterval {
        guard isLoaded, let module = module else { return 0.0 }
        return openmpt_module_set_position_order_row(module, Int32(order), Int32(row))
    }
    
    // MARK: - Subsong Support
    
    /// Get number of subsongs in the module
    /// - Returns: Number of subsongs, or -1 if module not loaded
    public func getNumSubsongs() -> Int {
        guard isLoaded, let module = module else { return -1 }
        return Int(openmpt_module_get_num_subsongs(module))
    }
    
    /// Get currently selected subsong
    /// - Returns: Selected subsong index, or -1 if module not loaded
    public func getSelectedSubsong() -> Int {
        guard isLoaded, let module = module else { return -1 }
        return Int(openmpt_module_get_selected_subsong(module))
    }
    
    /// Select a subsong for playback
    /// - Parameter subsong: Subsong index (0-based)
    /// - Returns: True if successful, false otherwise
    public func selectSubsong(_ subsong: Int) -> Bool {
        guard isLoaded, let module = module else { return false }
        return openmpt_module_select_subsong(module, Int32(subsong)) == 1
    }
    
    // MARK: - Render Parameters and Control
    
    /// Get render parameter value
    /// - Parameter parameter: Parameter identifier
    /// - Returns: Parameter value, or -1 if invalid
    public func getRenderParam(_ parameter: Int) -> Int {
        guard isLoaded, let module = module else { return -1 }
        return Int(openmpt_module_get_render_param(module, Int32(parameter)))
    }
    
    /// Set render parameter value
    /// - Parameters:
    ///   - parameter: Parameter identifier
    ///   - value: New parameter value
    /// - Returns: True if successful, false otherwise
    public func setRenderParam(_ parameter: Int, value: Int) -> Bool {
        guard isLoaded, let module = module else { return false }
        return openmpt_module_set_render_param(module, Int32(parameter), Int32(value)) == 1
    }
    
    /// Get control value
    /// - Parameter control: Control name
    /// - Returns: Control value string, or empty string if invalid
    public func getControl(_ control: String) -> String {
        guard isLoaded, let module = module else { return "" }
        if let cString = openmpt_module_ctl_get(module, control) {
            let value = String(cString: cString)
            openmpt_free_string(cString)
            return value
        }
        return ""
    }
    
    /// Set control value
    /// - Parameters:
    ///   - control: Control name
    ///   - value: Control value
    /// - Returns: True if successful, false otherwise
    public func setControl(_ control: String, value: String) -> Bool {
        guard isLoaded, let module = module else { return false }
        return openmpt_module_ctl_set(module, control, value) == 1
    }
    
    // MARK: - Convenience Functions
    
    /// Get all pattern names in the module
    /// - Returns: Array of pattern names
    public func getAllPatternNames() -> [String] {
        guard isLoaded, let module = module else { return [] }
        let patternCount = Int(openmpt_module_get_num_patterns(module))
        var names: [String] = []
        
        for i in 0..<patternCount {
            names.append(getPatternName(pattern: i))
        }
        
        return names
    }
    
    /// Get complete order sequence
    /// - Returns: Array of pattern numbers in order sequence
    public func getOrderSequence() -> [Int] {
        guard isLoaded, let module = module else { return [] }
        let orderCount = Int(openmpt_module_get_num_orders(module))
        var sequence: [Int] = []
        
        for i in 0..<orderCount {
            sequence.append(Int(openmpt_module_get_order_pattern(module, Int32(i))))
        }
        
        return sequence
    }
    
    /// Check if pattern editing is supported (always returns false for libopenmpt)
    /// - Returns: False, as libopenmpt is read-only
    public var isPatternEditingSupported: Bool {
        return false
    }
}