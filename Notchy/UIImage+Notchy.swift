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
        case .notch: return "NotchMask@3x"
        }
    }

    var image: CGImage? {
        guard let url = Bundle.main.url(forResource: "NotchMask", withExtension: "png"),
            let data = try? Data(contentsOf: url) else {
            return nil
        }

        return UIImage(data: data)?.cgImage
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
