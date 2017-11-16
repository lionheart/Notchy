//
//  ShortPlainButton.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 11/13/17.
//  Copyright © 2017 Lionheart Software LLC. All rights reserved.
//

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

