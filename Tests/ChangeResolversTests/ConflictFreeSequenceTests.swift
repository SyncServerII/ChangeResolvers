
import XCTest
import ChangeResolvers

class ConflictFreeSequenceTests: XCTestCase {
    static func newJSONFile() -> URL {
        return URL(fileURLWithPath: "/tmp/" + UUID().uuidString + ".json")
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAddNewFixedObjectWorks() {
        var fixedObjects = ConflictFreeSequence()
        
        do {
            try fixedObjects.add(newRecord: [ConflictFreeSequence.idKey: "1"])
        } catch {
            XCTFail()
            return
        }
    }
    
    func testAddNewFixedObjectWithNoIdFails() {
        var fixedObjects = ConflictFreeSequence()
        
        do {
            try fixedObjects.add(newRecord: ["blah": 1])
            XCTFail()
        } catch {
        }
    }
    
    func testAddNewFixedObjectWithSameIdFails() {
        var fixedObjects = ConflictFreeSequence()

        do {
            try fixedObjects.add(newRecord: [ConflictFreeSequence.idKey: "1"])
        } catch {
            XCTFail()
            return
        }
        
        do {
            try fixedObjects.add(newRecord: [ConflictFreeSequence.idKey: "1"])
            XCTFail()
        } catch {
        }
    }
    
    @discardableResult
    func saveToFileWithJustId() -> (ConflictFreeSequence, URL)? {
        var fixedObjects = ConflictFreeSequence()

        let url = Self.newJSONFile()
        print("url: \(url)")
        do {
            try fixedObjects.add(newRecord: [ConflictFreeSequence.idKey: "1"])
            try fixedObjects.save(toFile: url as URL)
        } catch {
            XCTFail()
            return nil
        }
        
        return (fixedObjects, url as URL)
    }
    
    func testSaveToFileWithJustIdWorks() {
        saveToFileWithJustId()
    }
    
    @discardableResult
    func saveToFileWithIdAndOherContents() -> (ConflictFreeSequence, URL)? {
        var fixedObjects = ConflictFreeSequence()

        let url = Self.newJSONFile()
        print("url: \(url)")
        do {
            try fixedObjects.add(newRecord: [
                ConflictFreeSequence.idKey: "1",
                "Foobar": 1,
                "snafu": ["Nested": "object"]
            ])
            try fixedObjects.save(toFile: url as URL)
        } catch {
            XCTFail()
            return nil
        }
        
        return (fixedObjects, url as URL)
    }
    
    func testSaveToFileWithIdAndOherContentsWorks() {
        saveToFileWithIdAndOherContents()
    }
    
    @discardableResult
    func saveToFileWithQuoteInContents() -> (ConflictFreeSequence, URL)? {
        var fixedObjects = ConflictFreeSequence()

        let quote1 = "\""
        let quote2 = "'"
        
        let url = Self.newJSONFile()
        print("url: \(url)")
        do {
            try fixedObjects.add(newRecord: [
                ConflictFreeSequence.idKey: "1",
                "test1": quote1,
                "test2": quote2
            ])
            try fixedObjects.save(toFile: url as URL)
        } catch {
            XCTFail()
            return nil
        }
        
        return (fixedObjects, url as URL)
    }
    
    func testSaveToFileWithQuoteInContentsWorks() {
        saveToFileWithQuoteInContents()
    }
    
    func testEqualityForSameObjectsWorks() {
        let fixedObjects = ConflictFreeSequence()
        XCTAssert(fixedObjects == fixedObjects)
    }
    
    func testEqualityForEmptyObjectsWorks() {
        let fixedObjects1 = ConflictFreeSequence()
        let fixedObjects2 = ConflictFreeSequence()
        XCTAssert(fixedObjects1 == fixedObjects2)
    }
    
    func testNonEqualityForEmptyAndNonEmptyObjectsWorks() {
        var fixedObjects1 = ConflictFreeSequence()
        
        do {
            try fixedObjects1.add(newRecord: [ConflictFreeSequence.idKey: "1"])
        } catch {
            XCTFail()
            return
        }
        
        let fixedObjects2 = ConflictFreeSequence()
        
        XCTAssert(fixedObjects1 != fixedObjects2)
    }
    
    func testNonEqualityForSimilarObjectsWorks() {
        var fixedObjects1 = ConflictFreeSequence()
        do {
            try fixedObjects1.add(newRecord: [ConflictFreeSequence.idKey: "1"])
        } catch {
            XCTFail()
            return
        }
        
        var fixedObjects2 = ConflictFreeSequence()
        do {
            try fixedObjects2.add(newRecord: [ConflictFreeSequence.idKey: "2"])
        } catch {
            XCTFail()
            return
        }
        
        XCTAssert(fixedObjects1 != fixedObjects2)
    }

    func testEqualityForEquivalentObjectsWorks() {
        var fixedObjects1 = ConflictFreeSequence()
        do {
            try fixedObjects1.add(newRecord: [ConflictFreeSequence.idKey: "1"])
        } catch {
            XCTFail()
            return
        }
        
        var fixedObjects2 = ConflictFreeSequence()
        do {
            try fixedObjects2.add(newRecord: [ConflictFreeSequence.idKey: "1"])
        } catch {
            XCTFail()
            return
        }
        
        XCTAssert(fixedObjects1 == fixedObjects2)
    }
    
    func testObjectsDoNotChangeWhenWritten() throws {
        let testData:[(fixedObject: ConflictFreeSequence, url: URL)?] = [
            saveToFileWithJustId(),
            saveToFileWithIdAndOherContents(),
            saveToFileWithQuoteInContents()
        ]
        
        try testData.forEach() { data in
            guard let data = data else {
                XCTFail()
                return
            }
            
            let fromFile = try ConflictFreeSequence(with: data.url)
            
            XCTAssert(data.fixedObject == fromFile)
        }
    }
    
    func testEquivalanceWithNonEqualSameSizeWorks() {
        var fixedObjects1 = ConflictFreeSequence()
        do {
            try fixedObjects1.add(newRecord: [ConflictFreeSequence.idKey: "1"])
        } catch {
            XCTFail()
            return
        }
        
        var fixedObjects2 = ConflictFreeSequence()
        do {
            try fixedObjects2.add(newRecord: [ConflictFreeSequence.idKey: "2"])
        } catch {
            XCTFail()
            return
        }
        
        XCTAssert(!(fixedObjects1 ~~ fixedObjects2))
    }
    
    func testEquivalanceWithNonEqualsDiffSizeWorks() {
        var fixedObjects1 = ConflictFreeSequence()
        do {
            try fixedObjects1.add(newRecord: [ConflictFreeSequence.idKey: "1"])
        } catch {
            XCTFail()
            return
        }
        
        var fixedObjects2 = ConflictFreeSequence()
        do {
            try fixedObjects2.add(newRecord: [ConflictFreeSequence.idKey: "1"])
            try fixedObjects2.add(newRecord: [ConflictFreeSequence.idKey: "2"])
        } catch {
            XCTFail()
            return
        }
        
        XCTAssert(!(fixedObjects1 ~~ fixedObjects2))
    }
    
    func testMergeWithSameWorks() {
        var fixedObjects = ConflictFreeSequence()
        do {
            try fixedObjects.add(newRecord: [ConflictFreeSequence.idKey: "1"])
        } catch {
            XCTFail()
            return
        }
        
        let (result, unread) = fixedObjects.merge(with: fixedObjects)
        XCTAssert(unread  == 0)
        XCTAssert(fixedObjects ~~ result)
        XCTAssert(result.count == 1)
    }
    
    func testMergeNeitherHaveObjectsWorks() {
        let fixedObjects1 = ConflictFreeSequence()
        let fixedObjects2 = ConflictFreeSequence()
        
        let (result, unread) = fixedObjects1.merge(with: fixedObjects2)
        XCTAssert(unread  == 0)
        XCTAssert(fixedObjects1 ~~ result)
        XCTAssert(result.count == 0)
    }

    func testMergeOnlyHaveSameObjectWorks() {
        var fixedObjects1 = ConflictFreeSequence()
        do {
            try fixedObjects1.add(newRecord: [ConflictFreeSequence.idKey: "1"])
        } catch {
            XCTFail()
            return
        }
        
        var fixedObjects2 = ConflictFreeSequence()
        do {
            try fixedObjects2.add(newRecord: [ConflictFreeSequence.idKey: "1"])
        } catch {
            XCTFail()
            return
        }
        
        let (result, unread) = fixedObjects1.merge(with: fixedObjects2)
        XCTAssert(unread  == 0)
        XCTAssert(fixedObjects1 ~~ result)
        XCTAssert(result.count == 1)
    }

    func testMergeHaveSomeSameObjectsWorks() {
        var standard = ConflictFreeSequence()
        do {
            try standard.add(newRecord: [ConflictFreeSequence.idKey: "1"])
            try standard.add(newRecord: [ConflictFreeSequence.idKey: "2"])
            try standard.add(newRecord: [ConflictFreeSequence.idKey: "3"])
        } catch {
            XCTFail()
            return
        }
        
        var fixedObjects1 = ConflictFreeSequence()
        do {
            try fixedObjects1.add(newRecord: [ConflictFreeSequence.idKey: "1"])
            try fixedObjects1.add(newRecord: [ConflictFreeSequence.idKey: "2"])
        } catch {
            XCTFail()
            return
        }
        
        var fixedObjects2 = ConflictFreeSequence()
        do {
            try fixedObjects2.add(newRecord: [ConflictFreeSequence.idKey: "1"])
            try fixedObjects2.add(newRecord: [ConflictFreeSequence.idKey: "3"])
        } catch {
            XCTFail()
            return
        }
        
        let (result, unread) = fixedObjects1.merge(with: fixedObjects2)
        XCTAssert(unread == 1)
        XCTAssert(result ~~ standard)
        XCTAssert(result.count == 3, "Count was: \(result.count)")
    }
    
    func testMergeHaveNoSameObjectsWorks() {
        var standard = ConflictFreeSequence()
        do {
            try standard.add(newRecord: [ConflictFreeSequence.idKey: "1"])
            try standard.add(newRecord: [ConflictFreeSequence.idKey: "2"])
            try standard.add(newRecord: [ConflictFreeSequence.idKey: "3"])
            try standard.add(newRecord: [ConflictFreeSequence.idKey: "4"])
        } catch {
            XCTFail()
            return
        }
        
        var fixedObjects1 = ConflictFreeSequence()
        do {
            try fixedObjects1.add(newRecord: [ConflictFreeSequence.idKey: "1"])
            try fixedObjects1.add(newRecord: [ConflictFreeSequence.idKey: "2"])
        } catch {
            XCTFail()
            return
        }
        
        var fixedObjects2 = ConflictFreeSequence()
        do {
            try fixedObjects2.add(newRecord: [ConflictFreeSequence.idKey: "3"])
            try fixedObjects2.add(newRecord: [ConflictFreeSequence.idKey: "4"])
        } catch {
            XCTFail()
            return
        }
        
        let (result, unread) = fixedObjects1.merge(with: fixedObjects2)
        XCTAssert(unread == 2, "unread: \(unread)")
        XCTAssert(result ~~ standard)
        XCTAssert(result.count == 4)
    }
    
    // MARK: Main dictionary contents
    
    func testSetAndGetMainDictionaryElementInt() {
        var example = ConflictFreeSequence()
        let key = "test"
        let value = 1
        example[key] = value
        guard let result = example[key] as? Int, result == value else {
            XCTFail()
            return
        }
    }
    
    func testSetAndGetMainDictionaryElementString() {
        var example = ConflictFreeSequence()
        let key = "test"
        let value = "Hello World!"
        example[key] = value
        guard let result = example[key] as? String, result == value else {
            XCTFail()
            return
        }
    }
    
    func testSetAndGetMainDictionaryElementIntAndString() {
        var example = ConflictFreeSequence()
        
        let key1 = "test1"
        let value1 = "Hello World!"
        example[key1] = value1
        
        let key2 = "test2"
        let value2 = 42
        example[key2] = value2
        
        guard let result1 = example[key1] as? String, result1 == value1,
            let result2 = example[key2] as? Int, result2 == value2 else {
            XCTFail()
            return
        }
    }
    
    func testSaveAndLoadMainDictionary() throws {
        var example = ConflictFreeSequence()
        
        let key1 = "test1"
        let value1 = "Hello World!"
        example[key1] = value1
        
        let key2 = "test2"
        let value2 = 42
        example[key2] = value2
        
        let url = Self.newJSONFile()
        print("url: \(url)")
        do {
            try example.save(toFile: url as URL)
        } catch {
            XCTFail()
            return
        }
        
        let fromFile = try ConflictFreeSequence(with: url as URL)
        
        guard let result1 = fromFile[key1] as? String, result1 == value1,
            let result2 = fromFile[key2] as? Int, result2 == value2 else {
            XCTFail()
            return
        }
    }
    
    func testSaveAndLoadWithMainDictElementsAndFixedObjects() throws {
        var example = ConflictFreeSequence()
        
        let key1 = "test1"
        let value1 = "Hello World!"
        example[key1] = value1
        
        let key2 = "test2"
        let value2 = 42
        example[key2] = value2
        
        do {
            try example.add(newRecord: [ConflictFreeSequence.idKey: "1"])
            try example.add(newRecord: [ConflictFreeSequence.idKey: "2"])
        } catch {
            XCTFail()
            return
        }
        
        let url = Self.newJSONFile()
        print("url: \(url)")
        do {
            try example.save(toFile: url as URL)
        } catch {
            XCTFail()
            return
        }
        
        let fromFile = try ConflictFreeSequence(with: url as URL)

        guard let result1 = fromFile[key1] as? String, result1 == value1 else {
            XCTFail()
            return
        }
        
        guard let result2 = fromFile[key2] as? Int, result2 == value2 else {
            XCTFail()
            return
        }

        guard example == fromFile else {
            XCTFail()
            return
        }
        
        guard example ~~ fromFile else {
            XCTFail()
            return
        }
        
        guard fromFile.count == example.count else {
            XCTFail()
            return
        }
    }
    
    func testMergeWorksWhenThereAreMainDictionaryElements_NonOverlapping() {
        var example1 = ConflictFreeSequence()
        
        let key1 = "test1"
        let value1 = "Hello World!"
        example1[key1] = value1
        
        let key2 = "test2"
        let value2 = 42
        example1[key2] = value2
        
        var example2 = ConflictFreeSequence()
        
        let key3 = "test3"
        let value3 = 98
        example2[key3] = value3

        let (mergedResult, _) = example1.merge(with: example2)
        
        guard let result1 = mergedResult[key1] as? String,
            let result2 = mergedResult[key2] as? Int,
            let result3 = mergedResult[key3] as? Int else {
            XCTFail()
            return
        }
        
        XCTAssert(result1 == value1)
        XCTAssert(result2 == value2)
        XCTAssert(result3 == value3)
    }
    
    func testMergeWorksWhenThereAreMainDictionaryElements_Overlapping() {
        var example1 = ConflictFreeSequence()
        
        let key1 = "test1"
        let value1 = "Hello World!"
        example1[key1] = value1
        
        let key2 = "test2"
        let value2 = 42
        example1[key2] = value2
        
        var example2 = ConflictFreeSequence()
        
        let key3 = "test2"
        let value3 = 98
        example2[key3] = value3

        let (mergedResult, _) = example1.merge(with: example2)
        
        guard let result1 = mergedResult[key1] as? String,
            let result2 = mergedResult[key2] as? Int,
            let result3 = mergedResult[key3] as? Int else {
            XCTFail()
            return
        }
        
        XCTAssert(result1 == value1)
        XCTAssert(result2 == value2)
        XCTAssert(result3 == value2)
    }
    
    func testTwoUnequalFixedObjectsAreNotTheSame1() {
        var example1 = ConflictFreeSequence()
        
        let key1 = "test1"
        let value1 = "Hello World!"
        example1[key1] = value1
        
        let key2 = "test2"
        let value2 = 42
        example1[key2] = value2
        
        let example2 = ConflictFreeSequence()

        XCTAssert(example1 != example2)
    }
    
    func testTwoUnequalFixedObjectsAreNotTheSame2() {
        var example1 = ConflictFreeSequence()
        
        let key1 = "test1"
        let value1 = "Hello World!"
        example1[key1] = value1
        
        let key2 = "test2"
        let value2 = 42
        example1[key2] = value2
        
        var example2 = ConflictFreeSequence()
        example2[key1] = "Smarg"
        example2[key2] = value2

        XCTAssert(example1 != example2)
    }
    
    func testTwoUnequalFixedObjectsAreNotTheSame3() {
        var example1 = ConflictFreeSequence()
        
        let key1 = "test1"
        let value1 = "Hello World!"
        example1[key1] = value1
        
        let key2 = "test2"
        let value2 = 42
        example1[key2] = value2
        
        var example2 = ConflictFreeSequence()
        example2[key1] = value1
        example2[key2] = value2
        
        do {
            try example1.add(newRecord: [ConflictFreeSequence.idKey: "1"])
        } catch {
            XCTFail()
            return
        }

        XCTAssert(example1 != example2)
    }
    
    func testTwoUnequalFixedObjectsAreNotTheSame4() {
        var example1 = ConflictFreeSequence()
        
        let key1 = "test1"
        let value1 = "Hello World!"
        example1[key1] = value1
        
        let key2 = "test2"
        let value2 = 42
        example1[key2] = value2
        
        var example2 = ConflictFreeSequence()
        example2[key1] = value1
        example2[key2] = value2
        
        do {
            try example1.add(newRecord: [ConflictFreeSequence.idKey: "1"])
            try example2.add(newRecord: [ConflictFreeSequence.idKey: "2"])
        } catch {
            XCTFail()
            return
        }

        XCTAssert(example1 != example2)
    }
    
    func testTwoUnequalFixedObjectsAreTheSame() {
        var example1 = ConflictFreeSequence()
        
        let key1 = "test1"
        let value1 = "Hello World!"
        example1[key1] = value1
        
        let key2 = "test2"
        let value2 = 42
        example1[key2] = value2
        
        var example2 = ConflictFreeSequence()
        example2[key1] = value1
        example2[key2] = value2
        
        do {
            try example1.add(newRecord: [ConflictFreeSequence.idKey: "1"])
            try example2.add(newRecord: [ConflictFreeSequence.idKey: "1"])
        } catch {
            XCTFail()
            return
        }

        XCTAssert(example1 == example2)
    }
}

