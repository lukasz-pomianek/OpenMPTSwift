//
//  OpenMPTSwiftTests.swift
//  OpenMPTSwift
//
//  Unit tests for OpenMPTSwift
//

import XCTest
@testable import OpenMPTSwift

final class OpenMPTSwiftTests: XCTestCase {
    
    func testModuleCreation() {
        let module = OpenMPTModule()
        XCTAssertFalse(module.isLoaded)
        XCTAssertNil(module.moduleInfo)
    }
    
    @MainActor
    func testPlayerCreation() throws {
        let player = try OpenMPTPlayer()
        XCTAssertNil(player.moduleInfo)
        XCTAssertNil(player.currentPosition)
    }
    
    func testInvalidDataHandling() {
        let module = OpenMPTModule()
        let invalidData = Data([0x00, 0x01, 0x02, 0x03]) // Not a valid module
        
        XCTAssertThrowsError(try module.loadModule(from: invalidData)) { error in
            XCTAssertTrue(error is OpenMPTError)
        }
    }
    
    func testEmptyDataHandling() {
        let module = OpenMPTModule()
        let emptyData = Data()
        
        XCTAssertThrowsError(try module.loadModule(from: emptyData)) { error in
            XCTAssertTrue(error is OpenMPTError)
        }
    }
    
    // TODO: Add tests with actual module files once libopenmpt binary is available
    // func testValidModuleLoading() { ... }
    // func testAudioRendering() { ... }
    // func testPositionTracking() { ... }
}