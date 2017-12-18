//
//  ShortPlainButtonAlternate.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 11/13/17.
//  Copyright © 2017 Lionheart Software LLC. All rights reserved.
//

import UIKit
import LionheartExtensions

final class ShortPlainAlternateButton: UIButton {
    override func setTitle(_ title: String?, for state: UIControlState) {
        guard let title = title else {
            return
        }

        let color: UIColor
        switch state {
        case .normal: color = .white
        default: color = .black
        }

        let attributes: [NSAttributedStringKey: Any] = [
            .font: NotchyTheme.systemFont(ofSize: 13, weight: .medium),
            .foregroundColor: color
        ]

        let attributed = NSAttributedString(string: title, attributes: attributes)
        setAttributedTitle(attributed, for: state)
    }

    init(normalTitle: String, selectedTitle: String) {
        super.init(frame: .zero)

        setTitle(normalTitle, for: .normal)
        setTitle(normalTitle, for: .highlighted)
        setTitle(selectedTitle, for: UIControlState(rawValue: 5))
        setTitle(selectedTitle, for: .selected)

        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true

        layer.cornerRadius = 15
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1

        contentEdgeInsets = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)

        setBackgroundImage(UIImage(color: .clear), for: .normal)
        setBackgroundImage(UIImage(color: .lightGray), for: .highlighted)
        setBackgroundImage(UIImage(color: .lightGray), for: UIControlState(rawValue: 5))
        setBackgroundImage(UIImage(color: .white), for: .selected)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


