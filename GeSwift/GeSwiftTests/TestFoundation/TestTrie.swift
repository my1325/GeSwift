//
//  TestTrie.swift
//  GeSwiftTests
//
//  Created by my on 2020/5/9.
//  Copyright © 2020 my. All rights reserved.
//

import XCTest
@testable import GeSwift

class TestTrie: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTrie() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        var trie: Trie<Int> = .empty
        trie.add(key: "hello", for: 100)
        trie.add(key: "word", for: 200)
        trie.add(key: "hbcd", for: 300)
        trie.add(key: "helob", for: 1)
        trie.add(key: "hell", for: 2)
        trie.add(key: "wor", for: 3)

        XCTAssertEqual(trie.count, 6)
        XCTAssertFalse(trie.isEmpty)
        print(trie)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
