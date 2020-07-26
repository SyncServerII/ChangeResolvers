//
//  ChangeResolver.swift
//  
//
//  Created by Christopher G Prince on 7/12/20.
//

import Foundation
import ServerAccount
import ServerShared

public protocol ChangeResolver {
    // This must be unique across all ChangeResolvers registered with the server.
    static var changeResolverName: String { get }
}

public enum ChangeResolverConstants {
    public static let maxChangeResolverNameLength = 100
}

public protocol ChangeResolverContents {
    // This must *not* be nil.
    var uploadContents: Data?
}

public extension ChangeResolver {
    // Apply the change resolver
    static func apply(changes: [ChangeResolverContents], toFileUUID fileUUID: String, currentFileVersion: FileVersionInt, deviceUUID: String, cloudStorage: CloudStorage, options: CloudStorageFileNameOptions) {
    }
}
