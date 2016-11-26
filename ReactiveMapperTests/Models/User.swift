//
//  User.swift
//  Example
//
//  Created by Alexander Schuch on 14/11/16.
//  Copyright © 2016 Alexander Schuch. All rights reserved.
//

import Foundation
import Mapper

struct User {
    let name: String
}

extension User: Mappable {

    init(map: Mapper) throws {
        self.name = try map.from("name")
    }
    
}
