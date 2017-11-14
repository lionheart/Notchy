//
//  UIImage+Notchy.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 11/11/17.
//  Copyright © 2017 Lionheart Software LLC. All rights reserved.
//

import UIKit
import CoreImage

enum MaskType {
    case v1
    case v2

    func applyMask(input: UIImage) -> UIImage? {
        switch self {
        case .v1: return input.maskv1
        case .v2: return input.maskv2
        }
    }
}

let maskFilter: CIFilter? = {
    guard let mask = UIImage(named: "NotchMask"),
        let ciImageMask = CIImage(image: mask),
        let background = UIImage(named: "BlackBackground"),
        let ciImageMaskBackground = CIImage(image: background) else {
            return nil
    }

    let parameters = [
        kCIInputBackgroundImageKey: ciImageMaskBackground,
        kCIInputMaskImageKey: ciImageMask
    ]

    guard let filter = CIFilter(name: "CIBlendWithMask", withInputParameters: parameters) else {
        return nil
    }

    return filter
}()

extension UIImage {
    var forced: UIImage? {
        UIGraphicsBeginImageContext(size)
        draw(at: .zero)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    var maskv1: UIImage? {
        guard let cgImage = cgImage,
            let mask = UIImage(named: "NotchMask"),
            let maskCGImage = mask.cgImage,
            let result = cgImage.masking(maskCGImage) else {
                return nil
        }

        return UIImage(cgImage: result)
    }

    var maskv2: UIImage? {
        guard let ciImage = CIImage(image: self),
            let filter = maskFilter else {
                return nil
        }

        filter.setValue(ciImage, forKey: kCIInputImageKey)

        guard let output = filter.outputImage else {
            return nil
        }

        return UIImage(ciImage: output)
    }
}
