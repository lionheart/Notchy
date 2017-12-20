//
//  IconSelectorCollectionViewCell.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 12/18/17.
//  Copyright © 2017 Lionheart Software LLC. All rights reserved.
//

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
