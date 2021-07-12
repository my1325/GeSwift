//
//  TestSort.swift
//  GeSwiftTests
//
//  Created by my on 2021/5/18.
//  Copyright © 2021 my. All rights reserved.
//

import XCTest
@testable import GeSwift

class TestSort: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testQuickSort() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        var needSortArray: [Int] = Array<Int>.randomCount(20, range: 0 ..< 100)
        print(needSortArray)
        needSortArray.quickSort()
        print(needSortArray)
        print("xxxx")
    }
    
    

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
