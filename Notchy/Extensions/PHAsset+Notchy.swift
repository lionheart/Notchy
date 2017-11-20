//
//  PHAsset+Notchy.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 11/12/17.
//  Copyright © 2017 Lionheart Software LLC. All rights reserved.
//

import UIKit
import Photos

extension PHImageManager {
    func image(asset: PHAsset, _ completion: @escaping MaskCallback) {
        //            [1125, 2436]
//        let size = CGSize(width: 375, height: 812)
        let size = CGSize(width: 1125, height: 2436)
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
