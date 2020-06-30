//
//  TestPriorityQueue.swift
//  GeSwiftTests
//
//  Created by my on 2020/5/9.
//  Copyright © 2020 my. All rights reserved.
//

import XCTest

class TestPriorityQueue: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testArrayHeap() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        var heap: [Int] = Array(elements: [10, 20, 40, 9, 8, 12, 30, 44])
        /// 44、40、30、20、12、10、9、8
        print(heap)
        XCTAssertEqual(44, heap.remove())
        XCTAssertEqual(40, heap.remove())
        XCTAssertEqual(30, heap.remove())
        XCTAssertEqual(20, heap.remove())
        XCTAssertEqual(12, heap.remove())
        XCTAssertEqual(10, heap.remove())
        XCTAssertEqual(9, heap.remove())
        XCTAssertEqual(8, heap.remove())
        
        var heap1: [Int] = []
        for e in [10, 20, 40, 9, 8, 12, 30, 44] {
            heap1.add(e)
        }
        
        print(heap)
        XCTAssertEqual(44, heap1.remove())
        XCTAssertEqual(40, heap1.remove())
        XCTAssertEqual(30, heap1.remove())
        XCTAssertEqual(20, heap1.remove())
        XCTAssertEqual(12, heap1.remove())
        XCTAssertEqual(10, heap1.remove())
        XCTAssertEqual(9, heap1.remove())
        XCTAssertEqual(8, heap1.remove())
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
