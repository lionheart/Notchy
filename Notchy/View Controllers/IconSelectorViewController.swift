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

struct Section {
    var name: String
    var icons: [Icon]
}

final class HeaderView: UICollectionReusableView {
    var label: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)

        label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        addSubview(label)

        label.leadingAnchor ~~ leadingAnchor
        label.trailingAnchor ~~ trailingAnchor
        label.topAnchor ~~ topAnchor + 10
        label.bottomAnchor ~~ bottomAnchor - 2
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class IconSelectorViewController: UICollectionViewController {
    weak var delegate: IconSelectorViewControllerDelegate?

    let sections: [Section] = [
        Section(name: "Tap to switch icons", icons: []),
        Section(name: "Border", icons: ["IconStrokeBlack", "IconStrokeWhite"]),
        Section(name: "No Border", icons: ["IconNoStrokeWhite", "IconNoStrokeBlack"]),
        Section(name: "iPhone X Silver", icons: ["Icon6SilverBlack", "Icon6SilverWhite"]),
        Section(name: "iPhone X Space Gray", icons: ["Icon6BlackWhite", "Icon6BlackBlack"]),
    ]

    // MARK: - Initializers
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }

    convenience init(delegate: IconSelectorViewControllerDelegate? = nil) {
        let layout = UICollectionViewFlowLayout()
        self.init(collectionViewLayout: layout)

        self.delegate = delegate
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let HeaderIdentifier = "HeaderIdentifier"
    let margin: CGFloat = 60
    override func viewDidLoad() {
        super.viewDidLoad()

        view.isOpaque = false
        view.layer.cornerRadius = 20
        view.clipsToBounds = true

        extendedLayoutIncludesOpaqueBars = true

        guard let collectionView = collectionView else {
            return
        }

        let label = HeaderView()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.label.text = "Tap to switch icons"

        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Close", for: .normal)
        button.addTarget(self, action: #selector(closeButtonDidTouchUpInside(_:)), for: .touchUpInside)

        view.addSubview(label)
        view.addSubview(button)

        label.topAnchor ~~ view.topAnchor + 10
        label.centerXAnchor ~~ view.centerXAnchor

        button.bottomAnchor ~~ view.bottomAnchor - 10
        button.centerXAnchor ~~ view.centerXAnchor

        collectionView.clipsToBounds = false
        collectionView.backgroundColor = UIColor.white
        collectionView.layer.cornerRadius = 20
        collectionView.bounces = true
        collectionView.delegate = self

        collectionView.contentInset = UIEdgeInsets(top: 0, left: margin, bottom: 0, right: margin)
        collectionView.register(IconCollectionViewCell.self)
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: HeaderIdentifier)
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

        let viewWidth = view.bounds.size.width - 10
        let columns: CGFloat = 2
        let padding: CGFloat = 0
        let itemWidth = floor((viewWidth - (columns - 1) * padding - (margin * 2)) / columns)
        let itemHeight = itemWidth

        layout.minimumLineSpacing = padding
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
    }
}

extension IconSelectorViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 40)
    }
}

// MARK: - UICollectionView
extension IconSelectorViewController {
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let label = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderIdentifier, for: indexPath) as! HeaderView
            let section = sections[indexPath.section]
            label.label.text = section.name

            if indexPath.section == 0 {
                label.label.text = ""
            }
            return label

        default:
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderIdentifier, for: indexPath)
        }
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        guard UserDefaults.purchased else {
            dismiss(animated: true) {
                self.delegate?.showIAPModal()
            }
            return
        }

        let section = sections[indexPath.section]
        let icon = section.icons[indexPath.row]
        UIApplication.shared.setAlternateIconName(icon.name, completionHandler: nil)
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let section = sections[section]
        return section.icons.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath) as IconCollectionViewCell
        let section = sections[indexPath.section]
        let icon = section.icons[indexPath.row]
        guard let image = icon.image else {
            fatalError()
        }

        cell.imageView.image = image
        return cell
    }
}
