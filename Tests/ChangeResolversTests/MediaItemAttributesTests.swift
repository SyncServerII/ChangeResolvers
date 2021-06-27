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
    
    func testValidV0WhenV0ValidWorks() throws {
        let data = try MediaItemAttributes.emptyFile()
        XCTAssert(MediaItemAttributes.validV0(contents: data))
    }
    
    func testValidV0WhenV0InvalidFails() throws {
        let randomishString = "1234roihqwleijhf"
        let data = randomishString.data(using: .utf8)!
        XCTAssert(!MediaItemAttributes.validV0(contents: data))
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
    
    func testKeyValueCoding_readCount() throws {
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
    
    func testGetKeywords_empty() throws {
        let mia = MediaItemAttributes()
        let result = mia.getKeywords()
        XCTAssert(result.count == 0)
    }
    
    func testGetKeywords_nonEmpty() throws {
        let mia = MediaItemAttributes()
        let keyword = "Foo"
        let keyValue: KeyValue = .keyword(keyword, used: true)
        try mia.add(keyValue: keyValue)
        
        let result = mia.getKeywords()
        guard result.count == 1 else {
            XCTFail()
            return
        }
        
        XCTAssert(result.first == keyword)
    }
    
    func testGetKeywords_onlyUsed() throws {
        let mia = MediaItemAttributes()
        
        let keyword1 = "Foo"
        let keyValue1: KeyValue = .keyword(keyword1, used: false)
        try mia.add(keyValue: keyValue1)

        let keyword2 = "Bar"
        let keyValue2: KeyValue = .keyword(keyword2, used: true)
        try mia.add(keyValue: keyValue2)
        
        let result1 = mia.getKeywords()
        guard result1.count == 1 else {
            XCTFail()
            return
        }
        
        XCTAssert(result1.first == keyword2)
        
        let result2 = mia.getKeywords(onlyThoseUsed: false)
        guard result2.count == 2 else {
            XCTFail()
            return
        }
        
        XCTAssert(result2 == Set<String>([keyword1, keyword2]))
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
    
    func testBadgeUserIdKeys_emptyMia() {
        let mia = MediaItemAttributes()
        let keys = mia.badgeUserIdKeys()
        XCTAssert(keys.count == 0)
    }
    
    func testBadgeUserIdKeys_decodedEmptyMia() throws {
        let data = try MediaItemAttributes.emptyFile()
        let decoder = JSONDecoder()
        let mia = try decoder.decode(MediaItemAttributes.self, from: data)
        let keys = mia.badgeUserIdKeys()
        XCTAssert(keys.count == 0)
    }
    
    func testBadgeUserIdKeys_oneUserId() throws {
        let userId = "Foo"
        let mia = MediaItemAttributes()
        let keyValue: KeyValue = .badge(userId: userId, code: "Bar")
        try mia.add(keyValue: keyValue)
        
        let keys = mia.badgeUserIdKeys()
        guard keys.count == 1 else {
            XCTFail()
            return
        }
        
        XCTAssert(keys.first == userId)
    }
    
    func testBadgeUserIdKeys_twoUserIds() throws {
        let userId1 = "Fido"
        let userId2 = "Bido"

        let mia = MediaItemAttributes()
        
        let keyValue1: KeyValue = .badge(userId: userId1, code: "Bar")
        try mia.add(keyValue: keyValue1)
        let keyValue2: KeyValue = .badge(userId: userId2, code: "Baz")
        try mia.add(keyValue: keyValue2)
        
        let keys = mia.badgeUserIdKeys()
        guard keys.count == 2 else {
            XCTFail()
            return
        }
        
        XCTAssert(keys.contains(userId1))
        XCTAssert(keys.contains(userId2))
    }
}
