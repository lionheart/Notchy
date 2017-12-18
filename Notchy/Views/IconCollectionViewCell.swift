//
//  IconSelectorCollectionViewCell.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 12/18/17.
//  Copyright © 2017 Lionheart Software LLC. All rights reserved.
//

import UIKit
import SuperLayout

final class IconCollectionViewCell: UICollectionViewCell {
    var imageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: .zero)

        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(imageView)

        imageView.leftAnchor ~~ contentView.leftAnchor
        imageView.topAnchor ~~ contentView.topAnchor
        imageView.rightAnchor ~~ contentView.rightAnchor
        imageView.bottomAnchor ~~ contentView.bottomAnchor

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
