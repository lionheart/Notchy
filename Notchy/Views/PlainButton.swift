//
//  PlainButton.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 11/13/17.
//  Copyright © 2017 Lionheart Software LLC. All rights reserved.
//

import UIKit
import LionheartExtensions

final class PlainButton: UIButton {
    override func setTitle(_ title: String?, for state: UIControlState) {
        guard let title = title else {
            return
        }

        let attributes: [NSAttributedStringKey: Any] = [
            .font: NotchyTheme.systemFont(ofSize: 20, weight: .medium),
            .foregroundColor: UIColor.white
        ]

        let attributed = NSAttributedString(string: title, attributes: attributes)
        setAttributedTitle(attributed, for: .normal)
    }

    init() {
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true

        layer.cornerRadius = 5

        contentEdgeInsets = UIEdgeInsets(top: 10, left: 30, bottom: 10, right: 30)

        let color = UIColor.black
        setBackgroundImage(UIImage(color: color), for: .normal)
        setBackgroundImage(UIImage(color: .darkGray), for: .highlighted)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
