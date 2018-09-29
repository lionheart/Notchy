//
//  Defaults.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 11/19/17.
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

import Foundation

import SwiftyUserDefaults

extension DefaultsKeys {
    static let addPhone = DefaultsKey<Bool>("addPhone")
    static let removeWatermark = DefaultsKey<Bool>("removeWatermark")
    static let purchased = DefaultsKey<Bool>("purchased")
    static let identifiers = DefaultsKey<[String]>("identifiers")
    static let numberOfScreenshots = DefaultsKey<Int>("numberOfScreenshots")
    static let hasBeenShownOpenSourceMessage = DefaultsKey<Bool>("hasBeenShownOpenSourceMessage")
}

// 1342 × 2588 pixels - iPhone X/XS

// 1125 × 2436 pixels - iPhone X/XS
// 828 x 1792 - iPhone XR
// 1242 x 2688 - iPhone XS Max

extension CGFloat {
    var cutInHalfCleanly: CGFloat {
        if Int(self) % 2 == 0 {
            return self / 2.0
        } else {
            return (self - 1) / 2.0
        }
    }
}

let frameImageX = UIImage(named: "iPhone X")!
let watermarkImageX = UIImage(named: "WatermarkStickerTopLeft2")!

let frameImageXR = UIImage(named: "iPhone X")!
let watermarkImageXR = UIImage(named: "WatermarkStickerTopLeft2")!

let frameImageXSMax = UIImage(named: "iPhone X")!
let watermarkImageXSMax = UIImage(named: "WatermarkStickerTopLeft2")!

enum NotchyDevice {
    case X
    case XS
    case XR
    case XSMax
    
    init?(width: Int) {
        switch width {
        case 828: self = .XR
        case 1125: self = .X
        case 1242: self = .XSMax
        default: return nil
        }
    }
    
    var frameImage: UIImage {
        switch self {
        case .X, .XS: return frameImageX
        case .XR: return frameImageXR
        case .XSMax: return frameImageXSMax
        }
    }
    
    var watermarkImage: UIImage {
        switch self {
        case .X, .XS: return watermarkImageX
        case .XR: return watermarkImageXR
        case .XSMax: return watermarkImageXSMax
        }
    }
    
    var size: CGSize {
        return CGSize(width: width, height: height)
    }
    
    var halfSize: CGSize {
        return CGSize(width: width.cutInHalfCleanly, height: height.cutInHalfCleanly)
    }
    
    var width: CGFloat {
        switch self {
        case .X, .XS: return 1125
        case .XR: return 828
        case .XSMax: return 1242
        }
    }
    
    var height: CGFloat {
        switch self {
        case .X, .XS: return 2436
        case .XR: return 1792
        case .XSMax: return 2688
        }
    }
    
    var aspectRatio: CGFloat {
        return height / width
    }
    
    var predicate: NSPredicate {
        let format = "pixelWidth == %@ AND pixelHeight == %@"
        return NSPredicate(format: format, argumentArray: [width, height])
    }
    
    static var predicates: [NSPredicate] {
        return [
            X.predicate,
            XR.predicate,
            XSMax.predicate
        ]
    }
    
    func multiplier(hasFrame: Bool) -> CGFloat {
        if hasFrame {
            return 1.9284649776
        } else {
            return aspectRatio
        }
    }
}

