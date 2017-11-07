/*
 See LICENSE.txt for this sample’s licensing information.

 Abstract:
 Collection view cell for displaying an asset.
 */

import UIKit
import SuperLayout

final class GridViewCell: UICollectionViewCell {
    var imageView: UIImageView!
    var livePhotoBadgeImageView: UIImageView!

    var representedAssetIdentifier: String!

    var thumbnailImage: UIImage! {
        didSet {
            imageView.image = thumbnailImage
        }
    }

    var livePhotoBadgeImage: UIImage! {
        didSet {
            livePhotoBadgeImageView.image = livePhotoBadgeImage
        }
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)

        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false

        livePhotoBadgeImageView = UIImageView()
        livePhotoBadgeImageView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(imageView)
        contentView.addSubview(livePhotoBadgeImageView)

        imageView.leftAnchor ~~ contentView.leftAnchor
        imageView.topAnchor ~~ contentView.topAnchor
        imageView.rightAnchor ~~ contentView.rightAnchor
        imageView.bottomAnchor ~~ contentView.bottomAnchor

        livePhotoBadgeImageView.topAnchor ~~ contentView.topAnchor
        livePhotoBadgeImageView.leftAnchor ~~ contentView.leftAnchor
        livePhotoBadgeImageView.heightAnchor ~~ 32
        livePhotoBadgeImageView.widthAnchor ~~ 32

        updateConstraintsIfNeeded()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImage = nil
        livePhotoBadgeImage = nil
    }
}

