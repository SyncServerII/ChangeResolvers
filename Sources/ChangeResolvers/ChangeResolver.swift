//
//  ChangeResolver.swift
//  
//
//  Created by Christopher G Prince on 7/12/20.
//

import Foundation
import ServerAccount
import ServerShared

public struct ApplyResult {
    public let newFileVersion: FileVersionInt
    public let checkSum: String
}

public protocol ChangeResolverContents {
    // This must *not* be nil.
    var uploadContents: Data? { get }
}

public protocol ChangeResolver {
    // This must be unique across all ChangeResolvers registered with the server.
    static var changeResolverName: String { get }
    
    // Apply the change resolver
    static func apply(changes: [ChangeResolverContents], toFileUUID fileUUID: String, currentFileVersion: FileVersionInt, deviceUUID: String, cloudStorage: CloudStorage, options: CloudStorageFileNameOptions, completion: ((Swift.Result<ApplyResult, Error>) -> ())?)
}

public enum ChangeResolverConstants {
    public static let maxChangeResolverNameLength = 100
}



