//
//  Defaults.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 11/19/17.
//  Copyright © 2017 Lionheart Software LLC. All rights reserved.
//

import Foundation

import SwiftyUserDefaults

extension DefaultsKeys {
    static let addPhone = DefaultsKey<Bool>("addPhone")
    static let removeWatermark = DefaultsKey<Bool>("removeWatermark")
    static let purchased = DefaultsKey<Bool>("purchased")
    static let identifiers = DefaultsKey<[String]>("identifiers")
}
