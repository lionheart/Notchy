//
//  IconSelectorViewController.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 12/18/17.
//  Copyright © 2017 Lionheart Software LLC. All rights reserved.
//

import UIKit
import SuperLayout
import StoreKit
import SwiftyUserDefaults

protocol IconSelectorViewControllerDelegate: class {

}

struct Icon: ExpressibleByStringLiteral {
    var name: String
    var imageName: String {
        return "\(name)-60x60"
    }

    var image: UIImage? {
        return UIImage(named: imageName)
    }

    typealias StringLiteralType = String

    init(stringLiteral value: StringLiteralType) {
        name = value
    }
}

final class IconSelectorViewController: UICollectionViewController {
    weak var delegate: IconSelectorViewControllerDelegate?
    var icons: [Icon] = [
        "IconStrokeWhite",
        "IconStrokeBlack",
        "IconNotchy",
        "IconNoStrokeWhite",
        "IconNoStrokeBlack",
        "Icon6SilverWhite",
        "Icon6SilverBlack",
        "Icon6BlackWhite",
        "Icon6BlackBlack"
    ]

    // MARK: - Initializers
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }

    convenience init(delegate: IconSelectorViewControllerDelegate? = nil) {
        self.init(collectionViewLayout: UICollectionViewFlowLayout())

        self.delegate = delegate
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        extendedLayoutIncludesOpaqueBars = true

        guard let collectionView = collectionView else {
            return
        }

        collectionView.bounces = true
        collectionView.backgroundColor = UIColor(0x2a2f33)
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView.register(IconCollectionViewCell.self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateItemSize()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        updateItemSize()
    }

    // MARK: - Misc

    private func updateItemSize() {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }

        let viewWidth = view.bounds.size.width
        let columns: CGFloat = 3
        let padding: CGFloat = 10
        let itemWidth = floor((viewWidth - (columns - 1) * padding - 20) / columns)
        let itemHeight = itemWidth

        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
    }
}

// MARK: - UICollectionView
extension IconSelectorViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let icon = icons[indexPath.row]
        UIApplication.shared.setAlternateIconName(icon.name, completionHandler: nil)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return icons.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath) as IconCollectionViewCell
        guard let image = icons[indexPath.row].image else {
            fatalError()
        }

        cell.imageView.image = image
        return cell
    }
}
