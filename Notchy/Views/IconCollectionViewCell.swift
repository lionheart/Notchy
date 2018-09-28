//
//  IconSelectorCollectionViewCell.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 12/18/17.
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

final class IconCollectionViewCell: UICollectionViewCell {
    var imageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: .zero)

        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear

        contentView.addSubview(imageView)

        let margin: CGFloat = 0
        imageView.leadingAnchor ~~ contentView.leadingAnchor + margin
        imageView.topAnchor ~~ contentView.topAnchor + margin
        imageView.trailingAnchor ~~ contentView.trailingAnchor - margin
        imageView.bottomAnchor ~~ contentView.bottomAnchor - margin

        updateConstraintsIfNeeded()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}

extension IconCollectionViewCell: UICollectionViewCellIdentifiable {
    static var identifier: String {
        return "IconCollectionViewCellIdentifier"
    }
}
