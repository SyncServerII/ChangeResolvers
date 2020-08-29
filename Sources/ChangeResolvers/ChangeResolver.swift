//
//  ChangeResolver.swift
//  
//
//  Created by Christopher G Prince on 7/12/20.
//

import Foundation
import ServerAccount
import ServerShared
import Logging

var logger:Logger?

// I've got a question on this: https://github.com/apple/swift-log/issues/155 here.
public func setupLogger(log:Logger) {
    logger = log
}

public struct ApplyResult {
    public let newFileVersion: FileVersionInt
    
    // Check sum for entire new file version. Specifics of the check sum depend on the specific `CloudStorage` in use.
    public let checkSum: String
}

public protocol ChangeResolverContents {
    // This must *not* be nil.
    var uploadContents: Data? { get }
}

public protocol ChangeResolver {
    // This must be unique across all ChangeResolvers registered with the server.
    static var changeResolverName: String { get }
    
    // Apply the change resolver. It is assumed that applying a series of changes to a file at a current file version results in a new version of that file, and that after this call, the prior version should be deleted. (This method does not delete that prior version).
    static func apply(changes: [ChangeResolverContents], toFileUUID fileUUID: String, currentFileVersion: FileVersionInt, deviceUUID: String, cloudStorage: CloudStorage, options: CloudStorageFileNameOptions, completion: ((Swift.Result<ApplyResult, Error>) -> ())?)
}

public enum ChangeResolverConstants {
    public static let maxChangeResolverNameLength = 100
}



