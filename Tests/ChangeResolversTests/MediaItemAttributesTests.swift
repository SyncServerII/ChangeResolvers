//
//  MediaItemAttributesTests.swift
//  ChangeResolversTests
//
//  Created by Christopher G Prince on 5/31/21.
//

import XCTest
@testable import ChangeResolvers

class MediaItemAttributesTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: Test KeyValue coding.
    
    func testKeyValueCoding_keyword() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        var data: Data!
        
        let keyValue1 = KeyValue.keyword("Key1", used: true)
        data = try encoder.encode(keyValue1)
        let keyValue1Decoded = try decoder.decode(KeyValue.self, from: data)
        XCTAssert(keyValue1 == keyValue1Decoded)
        
        let keyValue2 = KeyValue.keyword("Key1", used: nil)
        data = try encoder.encode(keyValue2)
        let keyValue2Decoded = try decoder.decode(KeyValue.self, from: data)
        XCTAssert(keyValue2 == keyValue2Decoded)
    }
    
    func testKeyValueCoding_unreadCount() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        var data: Data!
        
        let keyValue1 = KeyValue.readCount(userId: "Foo", readCount: 100)
        data = try encoder.encode(keyValue1)
        let keyValue1Decoded = try decoder.decode(KeyValue.self, from: data)
        XCTAssert(keyValue1 == keyValue1Decoded)
        
        let keyValue2 = KeyValue.readCount(userId: "Foo", readCount: nil)
        data = try encoder.encode(keyValue2)
        let keyValue2Decoded = try decoder.decode(KeyValue.self, from: data)
        XCTAssert(keyValue2 == keyValue2Decoded)
    }
    
   func testKeyValueCoding_badge() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        var data: Data!
        
        let keyValue1 = KeyValue.badge(userId: "Foo", code: "badge1")
        data = try encoder.encode(keyValue1)
        let keyValue1Decoded = try decoder.decode(KeyValue.self, from: data)
        XCTAssert(keyValue1 == keyValue1Decoded)
        
        let keyValue2 = KeyValue.badge(userId: "Foo", code: nil)
        data = try encoder.encode(keyValue2)
        let keyValue2Decoded = try decoder.decode(KeyValue.self, from: data)
        XCTAssert(keyValue2 == keyValue2Decoded)
    }
    
    // MARK: Test add KeyValue
    
    func testAddKeyValue_badge_nonNilCode() throws {
        let mia = MediaItemAttributes()
        let keyValue: KeyValue = .badge(userId: "Foo", code: "Bar")
        try mia.add(keyValue: keyValue)
        let keyValueResult = mia.get(type: .badge, key: "Foo")
        XCTAssert(keyValue == keyValueResult)
    }
    
    func testAddKeyValue_badge_nilCode() throws {
        let mia = MediaItemAttributes()
        let keyValue: KeyValue = .badge(userId: "Foo", code: nil)
        do {
            try mia.add(keyValue: keyValue)
        } catch {
            return
        }
        XCTFail()
    }
    
    func testAddKeyValue_unreadCount_nonNilCode() throws {
        let mia = MediaItemAttributes()
        let keyValue: KeyValue = .readCount(userId: "Foo", readCount: 20)
        try mia.add(keyValue: keyValue)
        let keyValueResult = mia.get(type: .readCount, key: "Foo")
        XCTAssert(keyValue == keyValueResult)
    }
    
    func testAddKeyValue_unreadCount_nilCode() throws {
        let mia = MediaItemAttributes()
        let keyValue: KeyValue = .readCount(userId: "Foo", readCount: nil)
        do {
            try mia.add(keyValue: keyValue)
        } catch {
            return
        }
        XCTFail()
    }
    
    // The `add` for unread counts actually has a `max` rather than replacing effect.
    func testSuccessiveUnreadCountAdd_smallestFirst() throws {
        let mia = MediaItemAttributes()
        
        let keyValue: KeyValue = .readCount(userId: "Foo", readCount: 20)
        try mia.add(keyValue: keyValue)
        
        let keyValue2: KeyValue = .readCount(userId: "Foo", readCount: 81)
        try mia.add(keyValue: keyValue2)
        
        let keyValueResult = mia.get(type: .readCount, key: "Foo")
        
        switch keyValueResult {
        case .readCount(userId: "Foo", readCount: let readCount):
            XCTAssert(readCount == 81, "\(String(describing: readCount))")
        default:
            XCTFail()
        }
    }
    
    func testSuccessiveUnreadCountAdd_smallestSecond() throws {
        let mia = MediaItemAttributes()
        
        let keyValue: KeyValue = .readCount(userId: "Foo", readCount: 81)
        try mia.add(keyValue: keyValue)
        
        let keyValue2: KeyValue = .readCount(userId: "Foo", readCount: 20)
        try mia.add(keyValue: keyValue2)
        
        let keyValueResult = mia.get(type: .readCount, key: "Foo")
        
        switch keyValueResult {
        case .readCount(userId: "Foo", readCount: let readCount):
            XCTAssert(readCount == 81, "\(String(describing: readCount))")
        default:
            XCTFail()
        }
    }
    
    func testAddKeyValue_keyword_nonNilCode() throws {
        let mia = MediaItemAttributes()
        let keyValue: KeyValue = .keyword("Foo", used: true)
        try mia.add(keyValue: keyValue)
        let keyValueResult = mia.get(type: .keyword, key: "Foo")
        XCTAssert(keyValue == keyValueResult)
    }
    
    func testAddKeyValue_keyword_nilCode() throws {
        let mia = MediaItemAttributes()
        let keyValue: KeyValue = .keyword("Foo", used: nil)
        do {
            try mia.add(keyValue: keyValue)
        } catch {
            return
        }
        XCTFail()
    }
    
    func testAddNewRecord_badge() throws {
        let coder = JSONEncoder()
        let keyValue: KeyValue = .badge(userId: "Foo", code: "20")
        let data = try coder.encode(keyValue)
        
        let mia = MediaItemAttributes()
        try mia.add(newRecord: data)
        
//        let data2 = try coder.encode(mia)
//        let str = String(data: data2, encoding: .utf8)
//        print("\(String(describing: str))")
    }
    
    func testAddNewRecord_unreadCount() throws {
        let coder = JSONEncoder()
        let keyValue: KeyValue = .readCount(userId: "Foo", readCount: 208)
        let data = try coder.encode(keyValue)
        
        let mia = MediaItemAttributes()
        try mia.add(newRecord: data)
    }
    
    func testAddNewRecord_keyword() throws {
        let coder = JSONEncoder()
        let keyValue: KeyValue = .keyword("Bar", used: false)
        let data = try coder.encode(keyValue)
        
        let mia = MediaItemAttributes()
        try mia.add(newRecord: data)
    }
    
    // MARK: Init from data
    
    func testInitFromData() throws {
        let coder = JSONEncoder()
        let keyValue: KeyValue = .badge(userId: "Foo", code: "20")
        let data = try coder.encode(keyValue)
        
        let mia = MediaItemAttributes()
        try mia.add(newRecord: data)
        
        let miaData = try coder.encode(mia)
        
        let mia2 = try MediaItemAttributes(with: miaData)
        XCTAssert(mia2.get(type: .badge, key: "Foo") == keyValue)
    }
    
    func testValidTrue() throws {
        let coder = JSONEncoder()
        let keyValue: KeyValue = .badge(userId: "Foo", code: "20")
        let data = try coder.encode(keyValue)
        
        XCTAssert(MediaItemAttributes.valid(uploadContents: data))
    }
    
    func testValidFalse() {
        XCTAssert(!MediaItemAttributes.valid(uploadContents: Data()))
    }
    
    func testEmptyFile() throws {
        let data = try MediaItemAttributes.emptyFile()
        let decoder = JSONDecoder()
        let mia = try decoder.decode(MediaItemAttributes.self, from: data)
        
        let result = mia.get(type: .badge, key: "Foo")
        switch result {
        case .badge(userId: let userId, code: let code):
            XCTAssert(userId == "Foo")
            XCTAssert(code == nil)
        default:
            XCTFail()
        }
    }
}
