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
    
    func testSortedOrder() {
        var s: [Int] = []
        let numbers = [ 450, -15, 393, -172, -62, -450, 370, -118, 844, -844, 446, -885, -419, 226, 415, -802, 361, 130, 83, -875, 367, 777, 891, 679, -104, -35, 665, -808, 232, -103, -766, -842, -513, -845, 161, 861, 520, 32, 551, 58, 631, -154, -840]
        print(numbers)
        for n in numbers {
            s.insert(n)
        }
        print(s)
        s.removeFirst(446)
        s.removeFirst(58)
        s.removeFirst(-875)
        s.removeFirst(861)
        print(s)
    }
    
    

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
