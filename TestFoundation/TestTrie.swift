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
        XCTAssert(trie.value(for: "hello") == 100, "\(String(describing: trie.value(for: "hello")))")
        XCTAssert(trie.value(for: "word") == 200, "\(String(describing: trie.value(for: "word")))")
        XCTAssert(trie.value(for: "hbcd") == 300, "\(String(describing: trie.value(for: "hbcd")))")
        XCTAssert(trie.value(for: "helob") == 1, "\(String(describing: trie.value(for: "helob")))")
        XCTAssert(trie.value(for: "hell") == 2, "\(String(describing: trie.value(for: "hell")))")
        XCTAssert(trie.value(for: "wor") == 3, "\(String(describing: trie.value(for: "wor")))")

        trie.add(key: "hello", for: 500)
        XCTAssert(trie.value(for: "hello") == 500, "\(String(describing: trie.value(for: "hello")))")

        trie.remove(for: "hell")
        XCTAssertNil(trie.value(for: "hell"))
        XCTAssert(trie.value(for: "hello") == 500, "\(String(describing: trie.value(for: "hello")))")
        
        trie.remove(for: "word")
        XCTAssertNil(trie.value(for: "word"))
        XCTAssert(trie.value(for: "wor") == 3, "\(String(describing: trie.value(for: "wor")))")

        XCTAssertFalse(trie.isEmpty)
        
        XCTAssertTrue(trie.hasPrefix("wor"))
        XCTAssertTrue(trie.hasPrefix("he"))
        XCTAssertFalse(trie.hasPrefix("word"))
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
