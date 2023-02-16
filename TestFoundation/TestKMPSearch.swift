//
//  TestKMPSearch.swift
//  GeSwiftTests
//
//  Created by my on 2021/9/16.
//  Copyright © 2021 my. All rights reserved.
//

import XCTest
@testable import GeSwift

class TestKMPSearch: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testKMPSearch() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let baseString = "ajlfafjaslkdfabababcd"
        let pattern = "ababa"
        if let index = baseString.ge.firstIndexForSubstring(pattern) {
            let endIndex = baseString.index(index, offsetBy: pattern.count)
            let subString = String(baseString[index ..< endIndex])
            XCTAssert(subString == pattern)
            print(subString)
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
