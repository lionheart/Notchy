//
//  PHAsset+Notchy.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 11/12/17.
//  Copyright © 2017 Lionheart Software LLC. All rights reserved.
//

import UIKit
import Photos

extension PHAsset {
    func image(maskType: MaskType, _ completion: @escaping ((UIImage?) -> Void)) {
        DispatchQueue.global(qos: .default).async {
//            [1125, 2436]
            let size = CGSize(width: 1125, height: 2436)
            let options = PHImageRequestOptions()
            options.version = .current
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .none
            options.isNetworkAccessAllowed = true

            let manager = PHImageManager.default()
            manager.requestImage(for: self, targetSize: size, contentMode: .aspectFit, options: options) { image, other in
                guard let image = image,
                    let other = other else {
                        completion(nil)
                        return
                }

                print(other[PHImageResultIsDegradedKey])

                completion(maskType.applyMask(input: image))
            }
        }
    }
}
