//
//  NotchyNavigationBar.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 11/11/17.
//  Copyright © 2017 Lionheart Software LLC. All rights reserved.
//

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
