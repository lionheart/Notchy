//
//  UICollectionView+Notchy.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 12/18/17.
//  Copyright © 2017 Lionheart Software LLC. All rights reserved.
//

import UIKit

protocol UICollectionViewCellIdentifiable {
    static var identifier: String { get }
}

extension UICollectionView {
    func register(_ cellClass: UICollectionViewCellIdentifiable.Type) {
        let identifier = cellClass.identifier
        guard let cellClass = cellClass as? AnyClass else {
            return
        }

        register(cellClass, forCellWithReuseIdentifier: identifier)
    }

    func dequeueReusableCell<T>(for indexPath: IndexPath) -> T where T: UICollectionViewCellIdentifiable {
        return dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as! T
    }
}
