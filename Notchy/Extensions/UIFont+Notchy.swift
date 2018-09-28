//
//  UIFont+Notchy.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 11/15/17.
//  Copyright © 2017 Lionheart Software LLC. All rights reserved.
//
//    This file is part of Notchy.
//
//    Notchy is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    Notchy is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with Notchy.  If not, see <https://www.gnu.org/licenses/>.

import UIKit

struct NotchyTheme {
    static func fontName(forWeight weight: UIFont.Weight) -> String {
        switch weight {
        case .medium: return "Montserrat-Medium"
        default: return "Montserrat-Regular"
        }
    }

    static func systemFont(ofSize size: CGFloat) -> UIFont {
        return NotchyTheme.systemFont(ofSize: size, weight: .regular)
    }

    static func systemFont(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let name = fontName(forWeight: weight)
        return UIFont(name: name, size: size)!
    }
}
