//
//  Encodeable.swift
//  Example
//
//  Created by Alexander Schuch on 11/11/16.
//  Copyright © 2016 Alexander Schuch. All rights reserved.
//

import Foundation

// Works around a compiler limitation when using something like
// optional ?? NSNull()
public let null = NSNull() as Any


// MARK: Encodeable 

/// Encode a model's properties to a `[String: Any]` JSON dictionary
public protocol Encodeable {
    func encode() -> [String: Any]
}

public extension Array where Element: Encodeable {
    /// Encodes `self` to an array of JSON dictionaries
    func encode() -> [[String: Any]] {
        return map { $0.encode() }
    }
}
