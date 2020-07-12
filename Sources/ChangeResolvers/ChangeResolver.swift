//
//  File.swift
//  
//
//  Created by Christopher G Prince on 7/12/20.
//

import Foundation

public protocol ChangeResolver {
    // This must be unique across all ChangeResolvers registered with the server.
    static var changeResolverName: String { get }
}
