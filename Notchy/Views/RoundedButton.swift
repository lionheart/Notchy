//
//  RoundedButton.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 11/10/17.
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
import LionheartExtensions

extension UIImage {
    convenience init?(color: UIColor) {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }

        context.setFillColor(color.cgColor)
        context.fill(rect)

        guard let image = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
            return nil
        }

        UIGraphicsEndImageContext()

        self.init(cgImage: image)
    }
}


final class RoundedButton: UIButton {
    var textColor: UIColor!

    override func setTitle(_ title: String?, for state: UIControlState) {
        guard let title = title else {
            return
        }

        let attributes: [NSAttributedStringKey: Any] = [
            .font: NotchyTheme.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: textColor
        ]

        let attributed = NSAttributedString(string: title, attributes: attributes)
        setAttributedTitle(attributed, for: state)
    }

    init(color: UIColor, textColor: UIColor, padding: CGFloat) {
        super.init(frame: .zero)

        self.textColor = textColor

        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true

        layer.cornerRadius = 20 + padding

        contentEdgeInsets = UIEdgeInsets(top: 10 + padding, left: 30, bottom: 10 + padding, right: 30)

        setBackgroundImage(UIImage(color: color), for: .normal)
        setBackgroundImage(UIImage(color: color.lighten(byRatio: 0.5)), for: .highlighted)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
