//
//  Presentable.swift
//  Notchy
//
//  Created by Dan Loewenherz on 2/2/18.
//  Copyright © 2018 Lionheart Software LLC. All rights reserved.
//

import Foundation
import Presentr

protocol Presentable {
    static func presenter(view: UIView) -> Presentr
}
