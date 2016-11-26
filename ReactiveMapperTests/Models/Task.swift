//
//  Task.swift
//  Example
//
//  Created by Alexander Schuch on 14/11/16.
//  Copyright © 2016 Alexander Schuch. All rights reserved.
//

import Foundation
import Mapper

struct Task {
    let name: String
}

extension Task: Mappable {

    init(map: Mapper) throws {
        self.name = try map.from("name")
    }

}
