//
//  UICollectionView+Notchy.swift
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
