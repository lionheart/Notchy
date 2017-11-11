//
//  UIImage+Notchy.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 11/11/17.
//  Copyright © 2017 Lionheart Software LLC. All rights reserved.
//

import UIKit

enum MaskType {
    case rounded
    case notch

    var imageName: String {
        switch self {
        case .rounded: return "RoundedMask"
        case .notch: return "NotchMask"
        }
    }

    var image: CGImage? {
        return UIImage(named: imageName)?.cgImage
    }
}

extension UIImage {
    func mask(_ maskType: MaskType) -> UIImage? {
        guard let cgImage = cgImage,
            let maskCGImage = maskType.image,
            let result = cgImage.masking(maskCGImage) else {
                return nil
        }

        return UIImage(cgImage: result)
    }
}
