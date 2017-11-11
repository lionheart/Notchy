//
//  RoundedButton.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 11/10/17.
//  Copyright © 2017 Lionheart Software LLC. All rights reserved.
//

import UIKit
import LionheartExtensions

extension UIImage {
    convenience init?(color: UIColor) {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }

        context.setFillColor(color.cgColor)
        context.fill(rect)

        guard let image = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
            return nil
        }

        UIGraphicsEndImageContext()

        self.init(cgImage: image)
    }
}

final class RoundedButton: UIButton {
    var textColor: UIColor!

    override func setTitle(_ title: String?, for state: UIControlState) {
        guard let title = title else {
            return
        }

        let attributes: [NSAttributedStringKey: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: textColor
        ]

        let attributed = NSAttributedString(string: title, attributes: attributes)
        setAttributedTitle(attributed, for: .normal)
    }

    init(color: UIColor, textColor: UIColor, padding: CGFloat) {
        super.init(frame: .zero)

        self.textColor = textColor

        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true

        layer.cornerRadius = 20 + padding

        contentEdgeInsets = UIEdgeInsets(top: 10 + padding, left: 30, bottom: 10 + padding, right: 30)

        setBackgroundImage(UIImage(color: color), for: .normal)
        setBackgroundImage(UIImage(color: color.lighten(byRatio: 0.5)), for: .highlighted)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
