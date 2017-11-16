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

    func applyMask(input: UIImage, watermark: Bool) -> UIImage? {
        switch self {
        case .v1: return input.maskv1(watermark: watermark)
        case .v2: return input.maskv2(watermark: watermark)
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

let watermarkImage = UIImage(named: "WatermarkCorner3g")!

extension UIImage {
    var forced: UIImage? {
        UIGraphicsBeginImageContext(size)
        draw(at: .zero)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    func maskv1(watermark: Bool) -> UIImage? {
        guard let cgImage = cgImage,
            let mask = UIImage(named: "NotchMask"),
            let maskCGImage = mask.cgImage,
            let result = cgImage.masking(maskCGImage) else {
                return nil
        }

        return UIImage(cgImage: result)
    }

    func maskv2(watermark: Bool) -> UIImage? {
        guard let ciImage = CIImage(image: self),
            let filter = maskFilter else {
                return nil
        }

        filter.setValue(ciImage, forKey: kCIInputImageKey)

        guard let output = filter.outputImage else {
            return nil
        }

        guard watermark,
            let watermarkCIImage = CIImage(image: watermarkImage) else {
                return UIImage(ciImage: output)
        }

        let transform = CGAffineTransform(scaleX: 1/watermarkImage.scale, y: 1/watermarkImage.scale)
        let newWatermarkCIImage = watermarkCIImage.transformed(by: transform)

        return UIImage(ciImage: newWatermarkCIImage.composited(over: output))
    }
}
