//
//  NotchyNavigationController.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 11/14/17.
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
import SuperLayout

final class NotchyNavigationController: UINavigationController {
    var imageView: UIImageView?

    override func viewDidLoad() {
        super.viewDidLoad()

        if imageView != nil {
            return
        }

        let image = UIImage(named: "LogoBlack")
        imageView = UIImageView(image: image)
        guard let imageView = imageView else {
            return
        }

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit

        navigationBar.addSubview(imageView)

        imageView.centerXAnchor ~~ navigationBar.centerXAnchor
        imageView.bottomAnchor ≤≤ navigationBar.bottomAnchor - 12
        imageView.heightAnchor ~~ navigationBar.heightAnchor * 0.6

        navigationBar.isTranslucent = false
        navigationBar.barStyle = .default
        navigationBar.barTintColor = .white
        navigationBar.clipsToBounds = false
        navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.black
        ]
    }
}
