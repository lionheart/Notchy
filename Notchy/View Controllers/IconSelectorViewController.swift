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
    func showIAPModal()
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

        view.isOpaque = false
        view.layer.cornerRadius = 20
        view.clipsToBounds = true

        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: #selector(closeButtonDidTouchUpInside(_:)))
        let button = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(closeButtonDidTouchUpInside(_:)))
        toolbar.items = [space, button, space]

        extendedLayoutIncludesOpaqueBars = true

        guard let collectionView = collectionView else {
            return
        }

        view.addSubview(toolbar)

        toolbar.bottomAnchor ~~ view.bottomAnchor
        toolbar.leadingAnchor ~~ view.leadingAnchor
        toolbar.trailingAnchor ~~ view.trailingAnchor

        collectionView.backgroundColor = UIColor.white
        collectionView.layer.cornerRadius = 20
        collectionView.bounces = true
        collectionView.delegate = self

        let margin: CGFloat = 10
        collectionView.contentInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
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

    @objc func closeButtonDidTouchUpInside(_ sender: Any) {
        dismiss(animated: true)
    }

    private func updateItemSize() {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }

        let viewWidth = view.bounds.size.width
        let columns: CGFloat = 3
        let padding: CGFloat = 10
        let itemWidth = floor((viewWidth - (columns - 1) * padding - (padding * 2)) / columns)
        let itemHeight = itemWidth

        layout.minimumLineSpacing = padding
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
    }
}

// MARK: - UICollectionView
extension IconSelectorViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        guard UserDefaults.purchased else {
            dismiss(animated: true) {
                self.delegate?.showIAPModal()
            }
            return
        }

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
