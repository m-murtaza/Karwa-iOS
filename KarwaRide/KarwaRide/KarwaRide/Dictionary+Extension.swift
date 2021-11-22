//
//  Dictionary.swift
//  KarwaRide
//
//  Created by Piecyfer on 22/11/2021.
//  Copyright © 2021 Karwa. All rights reserved.
//

import Foundation

extension Dictionary {
    var queryString: String {
        var output: String = ""
        for (key,value) in self {
            output +=  "\(key)=\(value)&"
        }
        output = String(output.dropLast(1))
        print(output)
        return output
    }
}
