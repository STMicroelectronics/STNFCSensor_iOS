//
//  SmarTagNDefParserV1Tests.swift
//  SmarTAGTests
//
//  Created by Giovanni Visentini on 26/01/2018.
//

import XCTest
@testable import SmarTAG

class SmarTagNDefParserV1Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExceptionThrowIfVersionIsDifferentFrom1(){
        let version0 = Data(bytes: [0])
        XCTAssertThrowsError(try SmarTagNDefParserV1(rawData:version0) ) { (error) -> Void in
            XCTAssertEqual(error as? SmarTagError, SmarTagError.InvalidVersion)
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
