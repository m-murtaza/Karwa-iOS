//
//  StringProtocol_Ex.swift
//  KarwaRide
//
//  Created by Sam Ash on 9/8/20.
//  Copyright © 2020 Karwa. All rights reserved.
//

import Foundation

extension StringProtocol {
    var data: Data { .init(utf8) }
    var bytes: [UInt8] { .init(utf8) }
}
