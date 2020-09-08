
import XCTest
@testable import ChangeResolvers

class CommentFileTests: XCTestCase {
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
    
    func testValidV0WhenV0ValidWorks() throws {
        let fixedObjects = CommentFile()
        let data = try fixedObjects.getData()
        XCTAssert(CommentFile.validV0(contents: data))
    }
    
    func testValidV0WhenV0InvalidFails() throws {
        let randomishString = "1234roihqwleijhf"
        let data = randomishString.data(using: .utf8)!
        XCTAssert(!CommentFile.validV0(contents: data))
    }
    
    func testAddNewFixedObjectWorks() {
        var fixedObjects = CommentFile()
        
        do {
            try fixedObjects.add(newRecord: [CommentFile.idKey: "1"])
        } catch {
            XCTFail()
            return
        }
    }
    
    func testAddNewFixedObjectWithNoIdFails() {
        var fixedObjects = CommentFile()
        
        do {
            try fixedObjects.add(newRecord: ["blah": 1])
            XCTFail()
        } catch {
        }
    }
    
    func testAddNewFixedObjectWithSameIdFails() {
        var fixedObjects = CommentFile()

        do {
            try fixedObjects.add(newRecord: [CommentFile.idKey: "1"])
        } catch {
            XCTFail()
            return
        }
        
        do {
            try fixedObjects.add(newRecord: [CommentFile.idKey: "1"])
            XCTFail()
        } catch {
        }
    }
    
    @discardableResult
    func saveToFileWithJustId() -> (CommentFile, URL)? {
        var fixedObjects = CommentFile()

        let url = Self.newJSONFile()
        print("url: \(url)")
        do {
            try fixedObjects.add(newRecord: [CommentFile.idKey: "1"])
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
    func saveToFileWithIdAndOherContents() -> (CommentFile, URL)? {
        var fixedObjects = CommentFile()

        let url = Self.newJSONFile()
        print("url: \(url)")
        do {
            try fixedObjects.add(newRecord: [
                CommentFile.idKey: "1",
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
    func saveToFileWithQuoteInContents() -> (CommentFile, URL)? {
        var fixedObjects = CommentFile()

        let quote1 = "\""
        let quote2 = "'"
        
        let url = Self.newJSONFile()
        print("url: \(url)")
        do {
            try fixedObjects.add(newRecord: [
                CommentFile.idKey: "1",
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
        let fixedObjects = CommentFile()
        XCTAssert(fixedObjects == fixedObjects)
    }
    
    func testEqualityForEmptyObjectsWorks() {
        let fixedObjects1 = CommentFile()
        let fixedObjects2 = CommentFile()
        XCTAssert(fixedObjects1 == fixedObjects2)
    }
    
    func testNonEqualityForEmptyAndNonEmptyObjectsWorks() {
        var fixedObjects1 = CommentFile()
        
        do {
            try fixedObjects1.add(newRecord: [CommentFile.idKey: "1"])
        } catch {
            XCTFail()
            return
        }
        
        let fixedObjects2 = CommentFile()
        
        XCTAssert(fixedObjects1 != fixedObjects2)
    }
    
    func testNonEqualityForSimilarObjectsWorks() {
        var fixedObjects1 = CommentFile()
        do {
            try fixedObjects1.add(newRecord: [CommentFile.idKey: "1"])
        } catch {
            XCTFail()
            return
        }
        
        var fixedObjects2 = CommentFile()
        do {
            try fixedObjects2.add(newRecord: [CommentFile.idKey: "2"])
        } catch {
            XCTFail()
            return
        }
        
        XCTAssert(fixedObjects1 != fixedObjects2)
    }

    func testEqualityForEquivalentObjectsWorks() {
        var fixedObjects1 = CommentFile()
        do {
            try fixedObjects1.add(newRecord: [CommentFile.idKey: "1"])
        } catch {
            XCTFail()
            return
        }
        
        var fixedObjects2 = CommentFile()
        do {
            try fixedObjects2.add(newRecord: [CommentFile.idKey: "1"])
        } catch {
            XCTFail()
            return
        }
        
        XCTAssert(fixedObjects1 == fixedObjects2)
    }
    
    func testObjectsDoNotChangeWhenWritten() throws {
        let testData:[(fixedObject: CommentFile, url: URL)?] = [
            saveToFileWithJustId(),
            saveToFileWithIdAndOherContents(),
            saveToFileWithQuoteInContents()
        ]
        
        try testData.forEach() { data in
            guard let data = data else {
                XCTFail()
                return
            }
            
            let fromFile = try CommentFile(with: data.url)
            
            XCTAssert(data.fixedObject == fromFile)
        }
    }
    
    func testEquivalanceWithNonEqualSameSizeWorks() {
        var fixedObjects1 = CommentFile()
        do {
            try fixedObjects1.add(newRecord: [CommentFile.idKey: "1"])
        } catch {
            XCTFail()
            return
        }
        
        var fixedObjects2 = CommentFile()
        do {
            try fixedObjects2.add(newRecord: [CommentFile.idKey: "2"])
        } catch {
            XCTFail()
            return
        }
        
        XCTAssert(!(fixedObjects1 ~~ fixedObjects2))
    }
    
    func testEquivalanceWithNonEqualsDiffSizeWorks() {
        var fixedObjects1 = CommentFile()
        do {
            try fixedObjects1.add(newRecord: [CommentFile.idKey: "1"])
        } catch {
            XCTFail()
            return
        }
        
        var fixedObjects2 = CommentFile()
        do {
            try fixedObjects2.add(newRecord: [CommentFile.idKey: "1"])
            try fixedObjects2.add(newRecord: [CommentFile.idKey: "2"])
        } catch {
            XCTFail()
            return
        }
        
        XCTAssert(!(fixedObjects1 ~~ fixedObjects2))
    }
    
    func testMergeWithSameWorks() {
        var fixedObjects = CommentFile()
        do {
            try fixedObjects.add(newRecord: [CommentFile.idKey: "1"])
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
        let fixedObjects1 = CommentFile()
        let fixedObjects2 = CommentFile()
        
        let (result, unread) = fixedObjects1.merge(with: fixedObjects2)
        XCTAssert(unread  == 0)
        XCTAssert(fixedObjects1 ~~ result)
        XCTAssert(result.count == 0)
    }

    func testMergeOnlyHaveSameObjectWorks() {
        var fixedObjects1 = CommentFile()
        do {
            try fixedObjects1.add(newRecord: [CommentFile.idKey: "1"])
        } catch {
            XCTFail()
            return
        }
        
        var fixedObjects2 = CommentFile()
        do {
            try fixedObjects2.add(newRecord: [CommentFile.idKey: "1"])
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
        var standard = CommentFile()
        do {
            try standard.add(newRecord: [CommentFile.idKey: "1"])
            try standard.add(newRecord: [CommentFile.idKey: "2"])
            try standard.add(newRecord: [CommentFile.idKey: "3"])
        } catch {
            XCTFail()
            return
        }
        
        var fixedObjects1 = CommentFile()
        do {
            try fixedObjects1.add(newRecord: [CommentFile.idKey: "1"])
            try fixedObjects1.add(newRecord: [CommentFile.idKey: "2"])
        } catch {
            XCTFail()
            return
        }
        
        var fixedObjects2 = CommentFile()
        do {
            try fixedObjects2.add(newRecord: [CommentFile.idKey: "1"])
            try fixedObjects2.add(newRecord: [CommentFile.idKey: "3"])
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
        var standard = CommentFile()
        do {
            try standard.add(newRecord: [CommentFile.idKey: "1"])
            try standard.add(newRecord: [CommentFile.idKey: "2"])
            try standard.add(newRecord: [CommentFile.idKey: "3"])
            try standard.add(newRecord: [CommentFile.idKey: "4"])
        } catch {
            XCTFail()
            return
        }
        
        var fixedObjects1 = CommentFile()
        do {
            try fixedObjects1.add(newRecord: [CommentFile.idKey: "1"])
            try fixedObjects1.add(newRecord: [CommentFile.idKey: "2"])
        } catch {
            XCTFail()
            return
        }
        
        var fixedObjects2 = CommentFile()
        do {
            try fixedObjects2.add(newRecord: [CommentFile.idKey: "3"])
            try fixedObjects2.add(newRecord: [CommentFile.idKey: "4"])
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
        var example = CommentFile()
        let key = "test"
        let value = 1
        example[key] = value
        guard let result = example[key] as? Int, result == value else {
            XCTFail()
            return
        }
    }
    
    func testSetAndGetMainDictionaryElementString() {
        var example = CommentFile()
        let key = "test"
        let value = "Hello World!"
        example[key] = value
        guard let result = example[key] as? String, result == value else {
            XCTFail()
            return
        }
    }
    
    func testSetAndGetMainDictionaryElementIntAndString() {
        var example = CommentFile()
        
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
        var example = CommentFile()
        
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
        
        let fromFile = try CommentFile(with: url as URL)
        
        guard let result1 = fromFile[key1] as? String, result1 == value1,
            let result2 = fromFile[key2] as? Int, result2 == value2 else {
            XCTFail()
            return
        }
    }
    
    func testSaveAndLoadWithMainDictElementsAndFixedObjects() throws {
        var example = CommentFile()
        
        let key1 = "test1"
        let value1 = "Hello World!"
        example[key1] = value1
        
        let key2 = "test2"
        let value2 = 42
        example[key2] = value2
        
        do {
            try example.add(newRecord: [CommentFile.idKey: "1"])
            try example.add(newRecord: [CommentFile.idKey: "2"])
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
        
        let fromFile = try CommentFile(with: url as URL)

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
        var example1 = CommentFile()
        
        let key1 = "test1"
        let value1 = "Hello World!"
        example1[key1] = value1
        
        let key2 = "test2"
        let value2 = 42
        example1[key2] = value2
        
        var example2 = CommentFile()
        
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
        var example1 = CommentFile()
        
        let key1 = "test1"
        let value1 = "Hello World!"
        example1[key1] = value1
        
        let key2 = "test2"
        let value2 = 42
        example1[key2] = value2
        
        var example2 = CommentFile()
        
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
        var example1 = CommentFile()
        
        let key1 = "test1"
        let value1 = "Hello World!"
        example1[key1] = value1
        
        let key2 = "test2"
        let value2 = 42
        example1[key2] = value2
        
        let example2 = CommentFile()

        XCTAssert(example1 != example2)
    }
    
    func testTwoUnequalFixedObjectsAreNotTheSame2() {
        var example1 = CommentFile()
        
        let key1 = "test1"
        let value1 = "Hello World!"
        example1[key1] = value1
        
        let key2 = "test2"
        let value2 = 42
        example1[key2] = value2
        
        var example2 = CommentFile()
        example2[key1] = "Smarg"
        example2[key2] = value2

        XCTAssert(example1 != example2)
    }
    
    func testTwoUnequalFixedObjectsAreNotTheSame3() {
        var example1 = CommentFile()
        
        let key1 = "test1"
        let value1 = "Hello World!"
        example1[key1] = value1
        
        let key2 = "test2"
        let value2 = 42
        example1[key2] = value2
        
        var example2 = CommentFile()
        example2[key1] = value1
        example2[key2] = value2
        
        do {
            try example1.add(newRecord: [CommentFile.idKey: "1"])
        } catch {
            XCTFail()
            return
        }

        XCTAssert(example1 != example2)
    }
    
    func testTwoUnequalFixedObjectsAreNotTheSame4() {
        var example1 = CommentFile()
        
        let key1 = "test1"
        let value1 = "Hello World!"
        example1[key1] = value1
        
        let key2 = "test2"
        let value2 = 42
        example1[key2] = value2
        
        var example2 = CommentFile()
        example2[key1] = value1
        example2[key2] = value2
        
        do {
            try example1.add(newRecord: [CommentFile.idKey: "1"])
            try example2.add(newRecord: [CommentFile.idKey: "2"])
        } catch {
            XCTFail()
            return
        }

        XCTAssert(example1 != example2)
    }
    
    func testTwoUnequalFixedObjectsAreTheSame() {
        var example1 = CommentFile()
        
        let key1 = "test1"
        let value1 = "Hello World!"
        example1[key1] = value1
        
        let key2 = "test2"
        let value2 = 42
        example1[key2] = value2
        
        var example2 = CommentFile()
        example2[key1] = value1
        example2[key2] = value2
        
        do {
            try example1.add(newRecord: [CommentFile.idKey: "1"])
            try example2.add(newRecord: [CommentFile.idKey: "1"])
        } catch {
            XCTFail()
            return
        }

        XCTAssert(example1 == example2)
    }
    
    func testAddDataRecordWorks() throws {
        var fixedObjects = CommentFile()
        
        let messageString1 = "Example"
        let id1 = Foundation.UUID().uuidString
        var record1 = CommentFile.FixedObject()
        record1[CommentFile.idKey] = id1
        record1["messageString"] = messageString1
        let updateContents1 = try JSONSerialization.data(withJSONObject: record1)
        
        try fixedObjects.add(newRecord: updateContents1)

        guard fixedObjects.count == 1 else {
            XCTFail()
            return
        }
        
        guard let record = fixedObjects[0] else {
            XCTFail()
            return
        }
        
        XCTAssert(record[CommentFile.idKey] as? String == id1)
        XCTAssert(record["messageString"] as? String == messageString1)
    }
    
    func testAddSameDataTwiceRecordWorks() throws {
        var fixedObjects = CommentFile()
        
        let messageString1 = "Example"
        let id1 = Foundation.UUID().uuidString
        var record1 = CommentFile.FixedObject()
        record1[CommentFile.idKey] = id1
        record1["messageString"] = messageString1
        let updateContents1 = try JSONSerialization.data(withJSONObject: record1)
        
        try fixedObjects.add(newRecord: updateContents1)
        try fixedObjects.add(newRecord: updateContents1)

        guard fixedObjects.count == 1 else {
            XCTFail()
            return
        }
        
        guard let record = fixedObjects[0] else {
            XCTFail()
            return
        }
        
        XCTAssert(record[CommentFile.idKey] as? String == id1)
        XCTAssert(record["messageString"] as? String == messageString1)
    }
    
    func testValidUploadContentsWorks() throws {
        var record1 = CommentFile.FixedObject()
        
        let data1 = try CommentFile.getData(obj: record1)
        
        // Not valid because the record has no idKey
        guard !CommentFile.valid(uploadContents: data1) else {
            XCTFail()
            return
        }
        
        let id1 = Foundation.UUID().uuidString
        record1[CommentFile.idKey] = id1
        let data2 = try CommentFile.getData(obj: record1)

        guard CommentFile.valid(uploadContents: data2) else {
            XCTFail()
            return
        }
        
        let messageString1 = "Example"
        record1["messageString"] = messageString1
        let data3 = try CommentFile.getData(obj: record1)

        guard CommentFile.valid(uploadContents: data3) else {
            XCTFail()
            return
        }
    }
}

