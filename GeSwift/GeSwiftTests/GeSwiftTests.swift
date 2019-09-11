//
//  GeSwiftTests.swift
//  GeSwiftTests
//
//  Created by weipinzhiyuan on 2019/5/15.
//  Copyright © 2019 my. All rights reserved.
//

import XCTest

class GeSwiftTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testSubStringTo() {
        let subString = "1234567890".ge.subString(to: 8)
        print("case ---- testSubStringTo, value:\(1234567890), result:\(subString!)")
    }
    
    func testSubStringFrom() {
        let subString = "1234567890".ge.subString(to: 8)
        print("case ---- testSubStringFrom, value:\(1234567890), result:\(subString!)")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
