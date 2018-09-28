//
//  PHAsset+Notchy.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 11/12/17.
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
import Photos

extension PHImageManager {
    func image(asset: PHAsset, _ completion: @escaping MaskCallback) {
        guard let device = NotchyDevice(width: asset.pixelWidth) else {
            completion(nil)
            return
        }

        let size = device.size
        let options = PHImageRequestOptions()
        options.version = .current
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true

        requestImage(for: asset, targetSize: size, contentMode: .default, options: options) { image, other in
            guard let image = image,
                let other = other else {
                    completion(nil)
                    return
            }

            if let degraded = other[PHImageResultIsDegradedKey] as? String {
                print(degraded)
            }

            completion(image)
        }
    }
}
