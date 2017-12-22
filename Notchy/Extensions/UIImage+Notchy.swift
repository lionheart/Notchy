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

    func applyMask(input: UIImage, watermark: Bool) -> UIImage? {
        switch self {
        case .v1: return input.maskv1(watermark: watermark)
        case .v2: return input.maskv2(watermark: watermark, frame: false)
        }
    }
}

let background = UIImage(named: "ClearBackground")!
let ciImageMaskBackground = CIImage(image: background)!
let notchMask = UIImage(named: "NotchMask")!
let frameImage = UIImage(named: "iPhone X")!
let watermarkImage = UIImage(named: "WatermarkStickerOverlay")!
let ciImageMask = CIImage(image: notchMask)!

let maskFilterParameters: [String: Any] = [
    kCIInputBackgroundImageKey: ciImageMaskBackground,
    kCIInputMaskImageKey: ciImageMask,
]

let maskFilter: CIFilter = {
    guard let _filter = CIFilter(name: "CIBlendWithMask", withInputParameters: maskFilterParameters) else {
        fatalError()
    }

    return _filter
}()

func maskedImage(image: UIImage) -> CIImage {
    // Memory leak?!
    let inputImage = CIImage(image: image)!

    // Memory leak?!
    #if false
        return inputImage.applyingFilter("CIBlendWithMask", parameters: maskFilterParameters)
    #else
        maskFilter.setValue(inputImage, forKey: kCIInputImageKey)
        return maskFilter.outputImage!
    #endif
}

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
    var urlForTransparentVersion: URL? {
        print(size)
        guard let image = forced,
            let data = UIImagePNGRepresentation(image) else {
                return nil
        }

        let url = FileManager.temporaryURL(forFileName: "screenshot.png")
        do {
            try data.write(to: url)
        } catch {
            return nil
        }

        return url
    }

    var forced: UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        draw(at: .zero)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    func maskv1(watermark: Bool) -> UIImage? {
        guard let cgImage = cgImage,
            let maskCGImage = notchMask.cgImage,
            let result = cgImage.masking(maskCGImage) else {
                return nil
        }

        return UIImage(cgImage: result)
    }

    func maskv2(watermark: Bool, frame: Bool) -> UIImage? {
        let outputImage = maskedImage(image: self)

        guard let watermarkCIImage = CIImage(image: watermarkImage),
            let frameImage = CIImage(image: frameImage) else {
                return UIImage(ciImage: outputImage)
        }

        let watermarked: CIImage
        if watermark {
            watermarked = watermarkCIImage.composited(over: outputImage)
        } else {
            watermarked = outputImage
        }

        let new: CIImage
        if frame {
            new = watermarked.transformed(by: CGAffineTransform(translationX: 108, y: 75)).composited(over: frameImage)
        } else {
            new = watermarked
        }

        return UIImage(ciImage: new)
    }
}
