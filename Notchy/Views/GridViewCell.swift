/*
 See LICENSE.txt for this sample’s licensing information.

 Abstract:
 Collection view cell for displaying an asset.
 */

import UIKit
import SuperLayout

final class GridViewCell: UICollectionViewCell {
    var imageView: UIImageView!

    var representedAssetIdentifier: String!

    var thumbnailImage: UIImage! {
        didSet {
            imageView.image = thumbnailImage
        }
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)

        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.borderWidth = 0.5

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
        thumbnailImage = nil
    }
}

