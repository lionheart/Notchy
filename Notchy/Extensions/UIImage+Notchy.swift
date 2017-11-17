//
//  UIImage+Notchy.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 11/11/17.
//  Copyright © 2017 Lionheart Software LLC. All rights reserved.
//

import UIKit
import CoreImage

typealias MaskCallback = (UIImage?) -> ()

enum MaskType {
    case v1
    case v2

    func applyMask(input: UIImage, watermark: Bool, completion: @escaping MaskCallback) {
        switch self {
        case .v1: return input.maskv1(watermark: watermark, completion: completion)
        case .v2: return input.maskv2(watermark: watermark, completion: completion)
        }
    }
}

let notchMask = UIImage(named: "NotchMask")!
let watermarkImage = UIImage(named: "WatermarkCorner3g")!

let maskFilter: CIFilter? = {
    guard let ciImageMask = CIImage(image: notchMask),
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

extension CIImage {
    var forced: UIImage? {
        UIGraphicsBeginImageContextWithOptions(extent.size, false, 1)
        guard let cgContext = UIGraphicsGetCurrentContext() else {
            return nil
        }
        let context = CIContext(cgContext: cgContext, options: nil)
        context.draw(self, in: extent, from: extent)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

extension UIImage {
    var forced: UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        draw(at: .zero)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    func maskv1(watermark: Bool, completion: @escaping MaskCallback) {
        guard let cgImage = cgImage,
            let maskCGImage = notchMask.cgImage,
            let result = cgImage.masking(maskCGImage) else {
                completion(nil)
                return
        }

        completion(UIImage(cgImage: result))
    }

    func maskv2(watermark: Bool, completion: @escaping MaskCallback) {
        guard let filter = maskFilter,
            let ciImage = CIImage(image: self) else {
            completion(nil)
            return
        }

        filter.setValue(ciImage, forKey: kCIInputImageKey)

        guard let output = filter.outputImage else {
            completion(nil)
            return
        }

        guard let watermarkCIImage = CIImage(image: watermarkImage) else {
            completion(UIImage(ciImage: output))
            return
        }

        let transform = CGAffineTransform(scaleX: 1/watermarkImage.scale, y: 1/watermarkImage.scale)
        let newWatermarkCIImage = watermarkCIImage.transformed(by: transform)
//        completion(newWatermarkCIImage.composited(over: output).forced)
        completion(UIImage(ciImage: newWatermarkCIImage.composited(over: output)))
    }
}
