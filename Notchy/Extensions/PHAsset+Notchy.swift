//
//  PHAsset+Notchy.swift
//  Notchy
//
//  Created by Dan Loewenherz on 9/26/18.
//  Copyright © 2018 Lionheart Software LLC. All rights reserved.
//

import Foundation
import Photos

extension PHAsset {
    var device: NotchyDevice? {
        return NotchyDevice(width: pixelWidth)
    }
}
