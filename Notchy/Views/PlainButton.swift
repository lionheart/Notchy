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
    func setTitle(_ title: String?, for state: UIControlState, size: CGFloat = 20) {
        guard let title = title else {
            setAttributedTitle(nil, for: state)
            return
        }

        let attributes: [NSAttributedStringKey: Any] = [
            .font: NotchyTheme.systemFont(ofSize: size, weight: .medium),
            .foregroundColor: UIColor.white
        ]

        let attributed = NSAttributedString(string: title, attributes: attributes)
        setAttributedTitle(attributed, for: state)
    }

    init() {
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true

        layer.cornerRadius = 13

        contentEdgeInsets = UIEdgeInsets(top: 12, left: 30, bottom: 12, right: 30)

        let color = UIColor.black
        setBackgroundImage(UIImage(color: color), for: .normal)
        setBackgroundImage(UIImage(color: .darkGray), for: .highlighted)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
