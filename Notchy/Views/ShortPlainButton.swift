//
//  ShortPlainButton.swift
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

final class ShortPlainButton: UIButton {
    override func setTitle(_ title: String?, for state: UIControlState) {
        guard let title = title else {
            return
        }

        let attributes: [NSAttributedStringKey: Any] = [
            .font: NotchyTheme.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.black
        ]

        let attributed = NSAttributedString(string: title, attributes: attributes)
        setAttributedTitle(attributed, for: state)
    }

    init() {
        super.init(frame: .zero)

        adjustsImageWhenHighlighted = false
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true

        setBackgroundImage(UIImage(color: .white), for: .normal)
//        setBackgroundImage(UIImage(color: .lightGray), for: .highlighted)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

