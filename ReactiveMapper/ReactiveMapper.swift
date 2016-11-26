//
//  Mapper.swift
//  Example
//
//  Created by Alexander Schuch on 11/11/16.
//  Copyright © 2016 Alexander Schuch. All rights reserved.
//

import Foundation
import Mapper
import ReactiveSwift
import Result

public let ReactiveMapperErrorDomain = "com.aschuch.ReactiveMapper.ErrorDomain"

/// Error emitted by ReactiveMapper mapping methods
public enum ReactiveMapperError: Error {
    case decoding(MapperError)
    case underlying(Error)

    public var nsError: NSError {
        switch self {
        case let .decoding(error):
            let info = ["mapperError": error]
            return NSError(domain: ReactiveMapperErrorDomain, code: -1000, userInfo: info)
        case let .underlying(error):
            return error as NSError
        }
    }
}

// MARK: SignalProducer

extension SignalProtocol where Value == Any {

    /// Maps the given JSON object within the stream to an object of given `type`.
    ///
    /// - parameter type: The type of the object that should be returned
    /// - parameter rootKeys: An array of keys that should be traversed in order to find a nested JSON object. The resulting object is subsequently used for further decoding.
    ///
    /// - returns: A new Signal emitting the decoded object.
    public func mapToType<T: Mappable>(_ type: T.Type, rootKeys: [String]? = nil) -> Signal<T, ReactiveMapperError> {
        return signal
            .mapError { ReactiveMapperError.underlying($0) }
            .attemptMap { json -> Result<T, ReactiveMapperError> in
                if let json = extract(json, rootKeys: rootKeys) as? NSDictionary {
                    return unwrapThrowableResult { try type.init(map: Mapper(JSON: json)) }
                }

                let info = [NSLocalizedFailureReasonErrorKey: "The provided `Value` could not be cast to `NSDictionary` or there is no value at the given `rootKeys`: \(rootKeys)"]
                let error = NSError(domain: ReactiveMapperErrorDomain, code: -1, userInfo: info)
                return .failure(.underlying(error))
            }
    }

    /// Maps the given JSON object array within the stream to an array of objects of the given `type`.
    ///
    /// - parameter type: The type of the array that should be returned
    /// - parameter rootKeys: An array of keys that should be traversed in order to find a nested JSON object. The resulting object is subsequently used for further decoding.
    /// - parameter innerRootKeys: An array of keys that should traversed in order to find a nested JSON object. The resulting object is subsequently used for further decoding.
    ///                            In contrast to the `rootKeys`, the `innerRootKeys` are applied on each nested array element and the resulting object is used for decoding.
    ///                            For example, use .mapToType(User.self, rootKeys: ["outer"], innerRootKeys: ["inner"]) to decode the following JSON
    /// ```
    /// {
    ///   "outer": [
    ///     {
    ///       "inner": { "name": "Alex" }
    ///     },
    ///     {
    ///       "inner": { "name": "Tom" }
    ///     }
    ///   ]
    /// }
    /// ```
    ///
    /// - returns: A new Signal emitting an array of decoded objects.
    public func mapToTypeArray<T: Mappable>(_ type: T.Type, rootKeys: [String]? = nil, innerRootKeys: [String]? = nil) -> Signal<[T], ReactiveMapperError> {
        return signal
            .mapError { ReactiveMapperError.underlying($0) }
            .attemptMap { json -> Result<[T], ReactiveMapperError> in
                if let array = extract(json, rootKeys: rootKeys) as? [NSDictionary] {
                    return unwrapThrowableResult {
                        try array.map { jsonObject in
                            if let jsonObject = extract(jsonObject, rootKeys: innerRootKeys) as? NSDictionary {
                                return try type.init(map: Mapper(JSON: jsonObject))
                            }
                            throw MapperError.customError(field: "", message: "Could not parse inner object with root keys: \(innerRootKeys)")
                        }
                    }
                }

                let info = [NSLocalizedFailureReasonErrorKey: "The provided `Value` could not be cast to `[NSDictionary]` or there is no array of values at the given `rootKeys`: \(rootKeys)"]
                let error = NSError(domain: ReactiveMapperErrorDomain, code: -1, userInfo: info)
                return .failure(.underlying(error))
            }
    }

}

// MARK: Signal

extension SignalProducerProtocol where Value == Any {

    /// Maps the given JSON object within the stream to an object of given `type`
    ///
    /// - parameter type: The type of the object that should be returned
    /// - parameter rootKeys: An array of keys that should be traversed in order to find a nested JSON object. The resulting object is subsequently used for further decoding.
    ///
    /// - returns: A new SignalProducer emitting the decoded object.
    public func mapToType<T: Mappable>(_ type: T.Type, rootKeys: [String]? = nil) -> SignalProducer<T, ReactiveMapperError> {
        return lift { $0.mapToType(type, rootKeys: rootKeys) }
    }

    /// Maps the given JSON object array within the stream to an array of objects of the given `type`.
    ///
    /// - parameter type: The type of the array that should be returned
    /// - parameter rootKeys: An array of keys that should be traversed in order to find a nested JSON object. The resulting object is subsequently used for further decoding.
    /// - parameter innerRootKeys: An array of keys that should traversed in order to find a nested JSON object. The resulting object is subsequently used for further decoding.
    ///                            In contrast to the `rootKeys`, the `innerRootKeys` are applied on each nested array element and the resulting object is used for decoding.
    ///                            For example, use .mapToType(User.self, rootKeys: ["outer"], innerRootKeys: ["inner"]) to decode the following JSON
    /// ```
    /// {
    ///   "outer": [
    ///     {
    ///       "inner": { "name": "Alex" }
    ///     },
    ///     {
    ///       "inner": { "name": "Tom" }
    ///     }
    ///   ]
    /// }
    /// ```
    ///
    /// - returns: A new SignalProducer emitting an array of decoded objects.
    public func mapToTypeArray<T: Mappable>(_ type: T.Type, rootKeys: [String]? = nil, innerRootKeys: [String]? = nil) -> SignalProducer<[T], ReactiveMapperError> {
        return lift { $0.mapToTypeArray(type, rootKeys: rootKeys, innerRootKeys: innerRootKeys) }
    }

}


// MARK: Helper

/// Extract a nested JSON object by traversing an array of `rootKeys`.
///
/// - parameter json: The JSON object that needs to be traversed and extracted.
/// - parameter rootKeys: An array of keys that should be traversed in order to find a nested JSON object. The resulting object is subsequently used for further decoding.
///
/// - returns: The nested JSON object, or `nil` if there is no JSON object at the given `rootKeys` path. If no `rootKeys` are specified, the `json` in returned as is.
private func extract(_ json: Any, rootKeys: [String]? = nil) -> Any? {
    guard let rootKeys = rootKeys else { return json }

    return rootKeys.reduce(json as Any?) { accum, key in
        if let json = accum as? [String: Any] {
            return json[key]
        }
        return nil
    }
}

private func unwrapThrowableResult<T>(throwable: () throws -> T) -> Result<T, ReactiveMapperError> {
    do {
        return .success(try throwable())
    } catch {
        if let error = error as? MapperError {
            return .failure(.decoding(error))
        } else {
            // For extra safety, but the above cast should never fail
            return .failure(.underlying(error))
        }
    }
}
