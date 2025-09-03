import XCTest
@testable import OpenMPTSwift

final class OpenMPTPatternIntegrationTests: XCTestCase {
    
    func testPatternReadingAPI() {
        // Test that pattern reading functions don't crash
        let module = OpenMPTModule()
        
        // Test with unloaded module
        let rows = module.getPatternRows(pattern: 0)
        XCTAssertEqual(rows, -1) // Should return -1 for unloaded module
        
        let cell = module.getPatternCell(pattern: 0, channel: 0, row: 0)
        XCTAssertNil(cell) // Should return nil for unloaded module
    }
    
    func testPatternEditingErrorHandling() {
        let module = OpenMPTModule()
        let testCell = OpenMPTPatternCell(note: .c4, instrument: 1)
        
        // Test editing operations on unloaded module
        XCTAssertThrowsError(try module.setPatternCell(pattern: 0, channel: 0, row: 0, cell: testCell)) { error in
            XCTAssertEqual(error as? OpenMPTPatternError, .moduleNotLoaded)
        }
        
        XCTAssertThrowsError(try module.setPatternNote(pattern: 0, channel: 0, row: 0, note: .c4)) { error in
            XCTAssertEqual(error as? OpenMPTPatternError, .invalidRow(0))
        }
        
        XCTAssertThrowsError(try module.clearPatternCell(pattern: 0, channel: 0, row: 0)) { error in
            XCTAssertEqual(error as? OpenMPTPatternError, .moduleNotLoaded)
        }
        
        XCTAssertThrowsError(try module.insertPatternRow(pattern: 0, row: 0)) { error in
            XCTAssertEqual(error as? OpenMPTPatternError, .moduleNotLoaded)
        }
        
        XCTAssertThrowsError(try module.deletePatternRow(pattern: 0, row: 0)) { error in
            XCTAssertEqual(error as? OpenMPTPatternError, .moduleNotLoaded)
        }
    }
    
    func testPatternAPIDocumentationExample() {
        // This test demonstrates the expected API usage
        let module = OpenMPTModule()
        
        // In a real scenario, you would load a module first:
        // let moduleData = Data(...)
        // try module.loadModule(from: moduleData)
        
        // Then you could read pattern information:
        // let rowCount = module.getPatternRows(pattern: 0)
        // let cell = module.getPatternCell(pattern: 0, channel: 0, row: 0)
        
        // And attempt editing operations (which will fail with read-only error):
        // try module.setPatternNote(pattern: 0, channel: 0, row: 0, note: .c4)
        
        // For now, just test that the API exists
        XCTAssertNotNil(module.getPatternRows)
        XCTAssertNotNil(module.getPatternCell)
        XCTAssertNotNil(module.setPatternCell)
        XCTAssertNotNil(module.setPatternNote)
        XCTAssertNotNil(module.clearPatternCell)
    }
}