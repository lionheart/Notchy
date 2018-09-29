//
//  NotchyAlertView.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 11/15/17.
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
import LionheartExtensions

enum NotchyAlertViewType {
    case success(String)
    case loading(String)
}

final class NotchyAlertView: UIView {
    init(type: NotchyAlertViewType) {
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor(0xDDDEE3)

        layer.cornerRadius = 10
        clipsToBounds = true

        let label = UILabel()
        label.font = NotchyTheme.systemFont(ofSize: 14)

        let views: [UIView]
        switch type {
        case .success(let text):
            let imageView = UIImageView(image: UIImage(named: "Checkmark"))
            label.text = text
            views = [imageView, label]

        case .loading(let text):
            let activity = UIActivityIndicatorView(style: .gray)
            activity.startAnimating()
            label.text = text
            views = [activity, label]
        }

        let stackView = UIStackView(arrangedSubviews: views)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.distribution = .equalCentering

        addSubview(stackView)

        let margin: CGFloat = 20

        stackView.heightAnchor ~~ heightAnchor * 0.5
        stackView.centerYAnchor ~~ centerYAnchor
        stackView.leadingAnchor ~~ leadingAnchor + margin
        stackView.trailingAnchor ~~ trailingAnchor - margin
        stackView.topAnchor ≥≥ topAnchor
        stackView.bottomAnchor ≤≤ bottomAnchor
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
