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
