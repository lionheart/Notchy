/*
 See LICENSE.txt for this sample’s licensing information.

 Abstract:
 Collection view cell for displaying an asset.
 */

import UIKit
import SuperLayout

final class GridViewCell: UICollectionViewCell {
    var imageView: UIImageView!

    #if MASK_IMAGE_WITH_VIEW
        var maskImageView: UIImageView!
    #endif

    var representedAssetIdentifier: String!

    var thumbnailImage: UIImage! {
        didSet {
            imageView.image = thumbnailImage

            // MARK: XXX Creates a weird white border around images
            #if MASK_IMAGE_WITH_VIEW
                maskImageView.frame = imageView.bounds
                imageView.mask = maskImageView
            #endif
        }
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)

        #if MASK_IMAGE_WITH_VIEW
            maskImageView = UIImageView(image: UIImage(named: "ClearMask"))
        #endif

        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false

        #if !MASK_IMAGE_WITH_VIEW
            imageView.layer.borderColor = UIColor.lightGray.cgColor
            imageView.layer.borderWidth = 0.5
        #endif

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

