import XCTest
@testable import OpenMPTSwift

final class OpenMPTExtendedAPITests: XCTestCase {
    
    func testRenderParameterConstants() {
        // Test that render parameter constants have expected values
        XCTAssertEqual(OpenMPTRenderParam.masterGain.rawValue, 0)
        XCTAssertEqual(OpenMPTRenderParam.stereoSeparation.rawValue, 1)
        XCTAssertEqual(OpenMPTRenderParam.interpolationFilterLength.rawValue, 2)
        XCTAssertEqual(OpenMPTRenderParam.volumeRampingStrength.rawValue, 3)
    }
    
    func testPatternCommandConstants() {
        // Test that pattern command constants have expected values
        XCTAssertEqual(OpenMPTPatternCommand.note.rawValue, 0)
        XCTAssertEqual(OpenMPTPatternCommand.instrument.rawValue, 1)
        XCTAssertEqual(OpenMPTPatternCommand.volume.rawValue, 2)
        XCTAssertEqual(OpenMPTPatternCommand.effect.rawValue, 3)
        XCTAssertEqual(OpenMPTPatternCommand.effectParam.rawValue, 4)
    }
    
    func testNoteExtensions() {
        // Test chromatic scale
        XCTAssertEqual(OpenMPTNote.chromatic4.count, 12)
        XCTAssertEqual(OpenMPTNote.chromatic4[0], .c4)
        XCTAssertEqual(OpenMPTNote.chromatic4[11], .b4)
        
        // Test musical note detection
        XCTAssertTrue(OpenMPTNote.c4.isMusicalNote)
        XCTAssertFalse(OpenMPTNote.none.isMusicalNote)
        XCTAssertFalse(OpenMPTNote.noteOff.isMusicalNote)
        XCTAssertFalse(OpenMPTNote.noteCut.isMusicalNote)
        
        // Test semitone calculation
        XCTAssertEqual(OpenMPTNote.c4.semitone, 0)
        XCTAssertEqual(OpenMPTNote.cs4.semitone, 1)
        XCTAssertEqual(OpenMPTNote.b4.semitone, 11)
        
        // Test octave calculation
        XCTAssertEqual(OpenMPTNote.c4.octave, 4)
        XCTAssertEqual(OpenMPTNote.c5.octave, 5)
    }
    
    func testPatternCellConvenience() {
        // Test convenience constructors
        let noteCell = OpenMPTPatternCell.note(.c4)
        XCTAssertEqual(noteCell.note, .c4)
        XCTAssertEqual(noteCell.instrument, 0)
        
        let noteInstrCell = OpenMPTPatternCell.noteInstrument(.d4, instrument: 5)
        XCTAssertEqual(noteInstrCell.note, .d4)
        XCTAssertEqual(noteInstrCell.instrument, 5)
        XCTAssertEqual(noteInstrCell.volume, 0)
        
        let fullCell = OpenMPTPatternCell.noteInstrumentVolume(.e4, instrument: 3, volume: 40)
        XCTAssertEqual(fullCell.note, .e4)
        XCTAssertEqual(fullCell.instrument, 3)
        XCTAssertEqual(fullCell.volume, 40)
        
        // Test convenience properties
        XCTAssertTrue(noteCell.hasNote)
        XCTAssertFalse(noteCell.hasInstrument)
        XCTAssertFalse(noteCell.hasVolume)
        XCTAssertFalse(noteCell.hasEffect)
        
        XCTAssertTrue(noteInstrCell.hasNote)
        XCTAssertTrue(noteInstrCell.hasInstrument)
        XCTAssertFalse(noteInstrCell.hasVolume)
        
        let effectCell = OpenMPTPatternCell(note: .none, effect: 10, effectParam: 20)
        XCTAssertFalse(effectCell.hasNote)
        XCTAssertTrue(effectCell.hasEffect)
    }
    
    func testExtendedModuleFunctions() {
        let module = OpenMPTModule()
        
        // Test functions with unloaded module (should return safe defaults)
        XCTAssertEqual(module.getNumOrders(), -1)
        XCTAssertEqual(module.getOrderPattern(order: 0), -1)
        XCTAssertEqual(module.getNumSubsongs(), -1)
        XCTAssertEqual(module.getSelectedSubsong(), -1)
        XCTAssertFalse(module.selectSubsong(0))
        
        XCTAssertEqual(module.getRenderParam(0), -1)
        XCTAssertFalse(module.setRenderParam(0, value: 1))
        XCTAssertEqual(module.getControl("test"), "")
        XCTAssertFalse(module.setControl("test", value: "value"))
        
        XCTAssertEqual(module.getPatternName(pattern: 0), "")
        XCTAssertEqual(module.getPatternRowsPerBeat(pattern: 0), -1)
        XCTAssertEqual(module.getPatternRowsPerMeasure(pattern: 0), -1)
        
        XCTAssertTrue(module.getAllPatternNames().isEmpty)
        XCTAssertTrue(module.getOrderSequence().isEmpty)
        
        // Test read-only nature
        XCTAssertFalse(module.isPatternEditingSupported)
    }
    
    func testControlConstants() {
        // Test that control constants are defined
        XCTAssertFalse(OpenMPTControl.playAtEnd.isEmpty)
        XCTAssertFalse(OpenMPTControl.seekSyncSamples.isEmpty)
        XCTAssertFalse(OpenMPTControl.loadSkipSamples.isEmpty)
        XCTAssertFalse(OpenMPTControl.renderStereoSeparationPercent.isEmpty)
        XCTAssertFalse(OpenMPTControl.dspMegabass.isEmpty)
    }
    
    func testMetadataConstants() {
        // Test that metadata constants are defined
        XCTAssertFalse(OpenMPTMetadata.type.isEmpty)
        XCTAssertFalse(OpenMPTMetadata.title.isEmpty)
        XCTAssertFalse(OpenMPTMetadata.artist.isEmpty)
        XCTAssertFalse(OpenMPTMetadata.tracker.isEmpty)
        XCTAssertFalse(OpenMPTMetadata.warnings.isEmpty)
    }
    
    func testParameterEnumConformance() {
        // Test that parameter enums can be used with module functions
        let module = OpenMPTModule()
        
        // These will return -1 or false since module isn't loaded, but should not crash
        let masterGain = module.getRenderParam(Int(OpenMPTRenderParam.masterGain.rawValue))
        XCTAssertEqual(masterGain, -1)
        
        let success = module.setRenderParam(Int(OpenMPTRenderParam.stereoSeparation.rawValue), value: 2)
        XCTAssertFalse(success)
    }
}