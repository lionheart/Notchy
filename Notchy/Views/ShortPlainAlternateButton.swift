//
//  ShortPlainButtonAlternate.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 11/13/17.
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

final class ShortPlainAlternateButton: UIButton {
    override func setTitle(_ title: String?, for state: UIControl.State) {
        guard let title = title else {
            return
        }

        let color: UIColor
        switch state {
        case .normal: color = .white
        default: color = UIColor(0x2a2e32)
        }

        let paragraph = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraph.alignment = .center

        let attributes: [NSAttributedString.Key: Any] = [
            .font: NotchyTheme.systemFont(ofSize: 13, weight: .medium),
            .foregroundColor: color,
            .paragraphStyle: paragraph
        ]

        let attributed = NSAttributedString(string: title, attributes: attributes)
        setAttributedTitle(attributed, for: state)
    }

    init(normalTitle: String, selectedTitle: String) {
        super.init(frame: .zero)

        setTitle(normalTitle, for: .normal)
        setTitle(normalTitle, for: .highlighted)
        setTitle(selectedTitle, for: UIControl.State(rawValue: 5))
        setTitle(selectedTitle, for: .selected)

        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true

        layer.cornerRadius = 17
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1

        contentEdgeInsets = UIEdgeInsets(top: 9, left: 10, bottom: 9, right: 10)

        setBackgroundImage(UIImage(color: .clear), for: .normal)
        setBackgroundImage(UIImage(color: .lightGray), for: .highlighted)
        setBackgroundImage(UIImage(color: .lightGray), for: [.highlighted, .selected])
        setBackgroundImage(UIImage(color: .white), for: .selected)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


