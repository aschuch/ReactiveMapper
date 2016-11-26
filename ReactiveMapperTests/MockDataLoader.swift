//
//  MockDataLoader.swift
//  Example
//
//  Created by Alexander Schuch on 14/11/16.
//  Copyright © 2016 Alexander Schuch. All rights reserved.
//

import Foundation
import ReactiveSwift

class MockDataLoader {

    func dictionary(_ fileName: String) -> SignalProducer<Any, NSError> {
        let json = try! JSONSerialization.jsonObject(with: self.jsonData(fileName), options: []) as! [String: Any]
        return SignalProducer(value: json)
    }

    func array(_ fileName: String) -> SignalProducer<Any, NSError> {
        let json = try! JSONSerialization.jsonObject(with: self.jsonData(fileName), options: []) as! [[String: Any]]
        return SignalProducer(value: json)
    }

    
    // MARK: Helper

    private func jsonData(_ name: String) -> Data {
        let bundle = Bundle(for: type(of: self))
        let url = bundle.url(forResource: name, withExtension: "json")!
        return try! Data(contentsOf: url)
    }

}
