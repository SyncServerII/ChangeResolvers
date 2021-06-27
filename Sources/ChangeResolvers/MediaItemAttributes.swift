//
//  MediaItemAttributes.swift
//  
//
//  Created by Christopher G Prince on 5/31/21.
//

// Each media item is going to have a file describing attributes:
//  https://github.com/SyncServerII/Neebla/issues/15

import Foundation
 
public enum KeyType {
    case readCount
    case keyword
    case badge
}
 
// Each case here must correspond to one KeyType case
public enum KeyValue: Codable, Equatable {
    case readCount(userId: String, readCount: Int?)
    case keyword(String, used:Bool?)
    case badge(userId: String, code: String?)
    
    enum CodingKeys: CodingKey {
        case readCount, keyword, badge
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let key = container.allKeys.first
        
        switch key {
        case .readCount:
            var nestedContainer = try container.nestedUnkeyedContainer(forKey: .readCount)
            let userId = try nestedContainer.decode(String.self)
            let readCount = try nestedContainer.decode(Int?.self)
            self = .readCount(userId: userId, readCount: readCount)
            
        case .keyword:
            var nestedContainer = try container.nestedUnkeyedContainer(forKey: .keyword)
            let keyword = try nestedContainer.decode(String.self)
            let used = try nestedContainer.decode(Bool?.self)
            self = .keyword(keyword, used: used)
            
        case .badge:
            var nestedContainer = try container.nestedUnkeyedContainer(forKey: .badge)
            let userId = try nestedContainer.decode(String.self)
            let code = try nestedContainer.decode(String?.self)
            self = .badge(userId: userId, code: code)

        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unabled to decode enum."
                )
            )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .readCount(userId: let userId, readCount: let readCount):
            var nestedContainer = container.nestedUnkeyedContainer(forKey: .readCount)
            try nestedContainer.encode(userId)
            try nestedContainer.encode(readCount)
        case .keyword(let keyword, used: let used):
            var nestedContainer = container.nestedUnkeyedContainer(forKey: .keyword)
            try nestedContainer.encode(keyword)
            try nestedContainer.encode(used)
        case .badge(userId: let userId, code: let code):
            var nestedContainer = container.nestedUnkeyedContainer(forKey: .badge)
            try nestedContainer.encode(userId)
            try nestedContainer.encode(code)
        }
    }
}
 
class KeyValues<KEY: Hashable & Codable, VALUE: Codable>: Codable {
    var contents = [KEY: VALUE]()
    
    func add(key: KEY, value: VALUE) {
        contents[key] = value
    }
    
    func get(key: KEY) -> VALUE? {
        return contents[key]
    }
}

class ReadCounts: KeyValues<String, Int> {
    // For UnreadCounts we don't want just a simple replace last value strategy.
    // Instead, I want: The maximum of two (same) userId keys should be used. I.e., the maximum across the current and last value for the same UserId.
    // See https://github.com/SyncServerII/Neebla/issues/15#issuecomment-850734982
    override func add(key: String, value: Int) {
        if let lastValue = get(key: key) {
            super.add(key: key, value: max(lastValue, value))
        }
        else {
            super.add(key: key, value: value)
        }
    }
}

public class MediaItemAttributes: WholeFileReplacer, Codable {
    public static var changeResolverName: String = "MediaItemAttributes"
    
    // Key: userId; Value: readCount
    var readCounts = ReadCounts()
    
    // Key: Keyword; Value: used/unused
    var keywords = KeyValues<String, Bool>()
    
    // Key: userId; Value: Badge code
    var badges = KeyValues<String, String>()
    
    public required init(with data: Data) throws {
        let decoder = JSONDecoder()
        let selfObject = try decoder.decode(Self.self, from: data)
        readCounts = selfObject.readCounts
        keywords = selfObject.keywords
        badges = selfObject.badges
    }
    
    // a `newRecord` must be an encoded `KeyValue`
    public func add(newRecord: Data) throws {
        let decoder = JSONDecoder()
        
        let keyValue = try decoder.decode(KeyValue.self, from: newRecord)
        try add(keyValue: keyValue)
    }
    
    public func getData() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }
    
    // a `uploadContents` must be an encoded `KeyValue`
    public static func valid(uploadContents: Data) -> Bool {
        let decoder = JSONDecoder()

        do {
            let _ = try decoder.decode(KeyValue.self, from: uploadContents)
            return true
        } catch let error {
            logger?.error("valid: \(error)")
            return false
        }
    }
    
    enum MediaItemAttributesError: Error {
        case nilValue
    }
    
    // MARK: Class specific methods
    
    // For testing.
    init() {
    }
    
    // Write the data returned from this for an empty file.
    public static func emptyFile() throws -> Data {
        let coder = JSONEncoder()
        let mia = MediaItemAttributes()
        return try coder.encode(mia)
    }
    
    // Convenience for encoding
    public static func encode(keyValue: KeyValue) throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(keyValue)
    }
    
    // The value in the KeyValue cannot be nil.
    public func add(keyValue: KeyValue) throws {
        switch keyValue {
        case .readCount(userId: let userId, readCount: let readCount):
            guard let readCount = readCount else {
                throw MediaItemAttributesError.nilValue
            }
            self.readCounts.add(key: userId, value: readCount)
            
        case .keyword(let keyword, used: let used):
            guard let used = used else {
                throw MediaItemAttributesError.nilValue
            }
            self.keywords.add(key: keyword, value: used)
            
        case .badge(userId: let userId, code: let code):
            guard let code = code else {
                throw MediaItemAttributesError.nilValue
            }
            self.badges.add(key: userId, value: code)
        }
    }
    
    public func get(type: KeyType, key: String) -> KeyValue {
        switch type {
        case .readCount:
            let value = self.readCounts.get(key: key)
            return .readCount(userId: key, readCount: value)
            
        case .keyword:
            let value = self.keywords.get(key: key)
            return .keyword(key, used: value)
            
        case .badge:
            let value = self.badges.get(key: key)
            return .badge(userId: key, code: value)
        }
    }
    
    // Get all userId key's for badges. Client can then retrieve the values for each key.
    public func badgeUserIdKeys() -> Set<String> {
        Set<String>(badges.contents.keys)
    }
    
    // If `onlyThoseUsed` is true, then only those keywords in active use (with get result `true`) are returned. Otherwise, all keywords are returned.
    public func getKeywords(onlyThoseUsed: Bool = true) -> Set<String> {
        let keywords = self.keywords.contents.keys
        if onlyThoseUsed {
            return Set<String>(keywords.filter { keyword in
                self.keywords.get(key: keyword) ?? false
            })
        }
        return Set<String>(keywords)
    }
}
