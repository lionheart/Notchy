//
//  UIFont+Notchy.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 11/15/17.
//  Copyright © 2017 Lionheart Software LLC. All rights reserved.
//

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
