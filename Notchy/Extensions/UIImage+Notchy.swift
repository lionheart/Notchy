//
//  UIImage+Notchy.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 11/11/17.
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
import CoreImage

typealias MaskCallback = (UIImage?) -> ()

enum MaskType {
    case v1
    case v2

    func applyMask(device: NotchyDevice, input: UIImage, watermark: Bool) -> UIImage? {
        switch self {
        case .v1: return input.maskv1(watermark: watermark)
        case .v2: return input.maskv2(device: device, watermark: watermark, frame: false)
        }
    }
}

let background = UIImage(named: "ClearBackground")!
let ciImageMaskBackground = CIImage(image: background)!
let notchMask = UIImage(named: "NotchMask")!
let frameImage = UIImage(named: "iPhone X")!
let watermarkImage = UIImage(named: "WatermarkStickerTopLeft2")!
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
    return CIImage(image: image)!.masked
}

extension CIImage {
    var masked: CIImage {
        // Memory leak?!
        #if false
            return inputImage.applyingFilter("CIBlendWithMask", parameters: maskFilterParameters)
        #else
            maskFilter.setValue(self, forKey: kCIInputImageKey)
            return maskFilter.outputImage!
        #endif
    }

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
    
    var _XSizeImage: UIImage? {
        let hasAlpha = true
        let size = CGSize(width: 375, height: 812)
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, 0)
        draw(in: CGRect(origin: .zero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
    
    func sizeImage(device: NotchyDevice) -> UIImage? {
        let hasAlpha = true
        let size = device.halfSize
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, 0)
        draw(in: CGRect(origin: .zero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }

    func maskv1(watermark: Bool) -> UIImage? {
        guard let cgImage = cgImage,
            let maskCGImage = notchMask.cgImage,
            let result = cgImage.masking(maskCGImage) else {
                return nil
        }

        return UIImage(cgImage: result)
    }

    func maskv2(device: NotchyDevice, watermark: Bool, frame: Bool) -> UIImage? {
        guard let resizedToX = sizeImage(device: device) else {
            return nil
        }

        let original = CIImage(image: resizedToX)!

        guard let watermarkCIImage = CIImage(image: device.watermarkImage),
            let frameImage = CIImage(image: device.frameImage) else {
                return UIImage(ciImage: original.masked)
        }

        let watermarked: CIImage
        if watermark {
            watermarked = watermarkCIImage.composited(over: original).masked
        } else {
            watermarked = original.masked
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
