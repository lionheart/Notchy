//
//  NotchyNavigationBar.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 11/11/17.
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

final class NotchyGradientView: UIView {
    init() {
        super.init(frame: .zero)

        isUserInteractionEnabled = false
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func applyToNavigationBar(_ navigationBar: UINavigationBar) {
        let backgroundClassName = "_UIBarBackground"
        for subview in navigationBar.subviews {
            if NSStringFromClass(subview.classForCoder) == backgroundClassName {
                let gradient = CAGradientLayer()
                gradient.frame = frame
                gradient.masksToBounds = true
                gradient.colors = [UIColor(0x007AFF).cgColor, UIColor(0x4CD964).cgColor]
                subview.layer.insertSublayer(gradient, at: 0)
            }
        }
    }
}
