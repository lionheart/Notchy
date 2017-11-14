//
//  NotchyNavigationController.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 11/14/17.
//  Copyright © 2017 Lionheart Software LLC. All rights reserved.
//

import UIKit
import SuperLayout

final class NotchyNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let image = UIImage(named: "LogoBlack")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit

        navigationBar.addSubview(imageView)

        imageView.centerXAnchor ~~ navigationBar.centerXAnchor
        imageView.centerYAnchor ~~ navigationBar.centerYAnchor
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
