import XCTest
@testable import OpenMPTSwift

final class OpenMPTPatternEditorTests: XCTestCase {
    
    func testPatternCellStructure() {
        // Test basic pattern cell creation
        let cell = OpenMPTPatternCell(
            note: .c4,
            instrument: 1,
            volume: 32,
            effect: 10,
            effectParam: 20
        )
        
        XCTAssertEqual(cell.note, .c4)
        XCTAssertEqual(cell.instrument, 1)
        XCTAssertEqual(cell.volume, 32)
        XCTAssertEqual(cell.effect, 10)
        XCTAssertEqual(cell.effectParam, 20)
        XCTAssertFalse(cell.isEmpty)
    }
    
    func testEmptyPatternCell() {
        let emptyCell = OpenMPTPatternCell()
        XCTAssertTrue(emptyCell.isEmpty)
        XCTAssertEqual(emptyCell.note, .none)
    }
    
    func testOpenMPTNoteConversion() {
        // Test MIDI note conversion
        let note = OpenMPTNote(midiNote: 60) // Middle C
        XCTAssertEqual(note, .c4)
        
        // Test note name display
        XCTAssertEqual(OpenMPTNote.c4.noteName, "C-4")
        XCTAssertEqual(OpenMPTNote.none.noteName, "---")
        XCTAssertEqual(OpenMPTNote.noteOff.noteName, "OFF")
        XCTAssertEqual(OpenMPTNote.noteCut.noteName, "CUT")
    }
    
    func testPatternErrorDescriptions() {
        let errors: [OpenMPTPatternError] = [
            .invalidPattern(5),
            .invalidChannel(2),
            .invalidRow(10),
            .editingNotSupported,
            .moduleNotLoaded,
            .readOnlyModule
        ]
        
        for error in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertFalse(error.errorDescription!.isEmpty)
        }
    }
}