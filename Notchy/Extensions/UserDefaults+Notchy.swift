//
//  UserDefaults+Notchy.swift
//  Notchy
//
//  Created by Dan Loewenherz on 2/2/18.
//  Copyright © 2018 Lionheart Software LLC. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

extension UserDefaults {
    static var purchased: Bool {
        #if DEBUG
            return true
        #else
            return Defaults[.purchased]
        #endif
    }
}
