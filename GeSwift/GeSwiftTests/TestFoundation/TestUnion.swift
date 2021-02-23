//
//  TestUnion.swift
//  GeSwiftTests
//
//  Created by my on 2021/2/23.
//  Copyright © 2021 my. All rights reserved.
//

import XCTest
@testable import GeSwift

class TestUnion: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUnion() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        var unionSet = UnionSet_Enum.root(value: 0)
        print(unionSet.description)
        unionSet.union(0, 1)
        XCTAssert(unionSet.findAncestor(0) == 1)
        print(unionSet.description)
        unionSet.union(0, 3)
        XCTAssert(unionSet.findAncestor(1) == 3)
        XCTAssert(unionSet.findAncestor(0) == 3)
        print(unionSet.description)
        unionSet.union(0, 10)
        XCTAssert(unionSet.findAncestor(1) == 10)
        XCTAssert(unionSet.findAncestor(0) == 10)
        XCTAssert(unionSet.findAncestor(3) == 10)
        print(unionSet.description)
        unionSet.union(3, 10)
        XCTAssert(unionSet.findAncestor(1) == 10)
        XCTAssert(unionSet.findAncestor(0) == 10)
        XCTAssert(unionSet.findAncestor(3) == 10)
        print(unionSet.description)
        unionSet.union(3, 12)
        XCTAssert(unionSet.findAncestor(10) == 12)
        XCTAssert(unionSet.findAncestor(1) == 12)
        XCTAssert(unionSet.findAncestor(0) == 12)
        XCTAssert(unionSet.findAncestor(3) == 12)
        print(unionSet.description)
        unionSet.union(10, 11)
        XCTAssert(unionSet.findAncestor(10) == 11)
        XCTAssert(unionSet.findAncestor(12) == 11)
        XCTAssert(unionSet.findAncestor(1) == 11)
        XCTAssert(unionSet.findAncestor(0) == 11)
        XCTAssert(unionSet.findAncestor(3) == 11)
        print(unionSet.description)
        unionSet.union(10, 20)
        XCTAssert(unionSet.findAncestor(12) == 20)
        XCTAssert(unionSet.findAncestor(11) == 20)
        XCTAssert(unionSet.findAncestor(1) == 20)
        XCTAssert(unionSet.findAncestor(0) == 20)
        XCTAssert(unionSet.findAncestor(3) == 20)
        XCTAssert(unionSet.findAncestor(0) == 20)
        print(unionSet.description)
    }
    
    func testTime() {
        let count = 1000000
        let randoms: [Int] = Array.randomCount(count, range: 0 ..< 99)
        let unionRandoms: [Int] = Array.randomCount(1, range: 0 ..< 99)
        var unionSet = UnionSet_QU(count)
        let _startTime = Date()
        for index in 0 ..< unionRandoms.count {
            unionSet.union(unionRandoms[index], randoms[index])
        }
        print("consumption time", Date().timeIntervalSince(_startTime))
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        let count = 10000000
        let randoms: [Int] = Array.randomCount(count, range: 0 ..< 99)
        let unionRandoms: [Int] = Array.randomCount(count, range: 0 ..< 50)
        var unionSet = UnionSet_QF(count)
        let _startTime = Date()
        for index in 0 ..< unionRandoms.count {
            unionSet.union(unionRandoms[index], randoms[index])
        }
        let time = String(format: "consumption time %.6f", Date().timeIntervalSince(_startTime))
        print(time)
    }
}
