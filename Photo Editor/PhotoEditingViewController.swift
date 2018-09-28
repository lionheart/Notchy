//
//  PhotoEditingViewController.swift
//  photoeditor
//
//  Created by Dan Loewenherz on 2/2/18.
//  Copyright © 2018 Lionheart Software LLC. All rights reserved.
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
import Photos
import PhotosUI
import SuperLayout

let Defaults = UserDefaults(suiteName: "group.com.lionheartsw.notchy")!

final class PhotoEditingViewController: BaseImageEditingViewController {
    var input: PHContentEditingInput?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        helperLayoutGuide.topAnchor ≥≥ view.safeAreaLayoutGuide.bottomAnchor
        helperLayoutGuide.topAnchor ≤≤ view.bottomAnchor

        helperLayoutGuide.bottomAnchor ~~ view.bottomAnchor
        helperLayoutGuide.centerXAnchor ~~ view.centerXAnchor
        helperLayoutGuide.leadingAnchor ~~ view.leadingAnchor
        helperLayoutGuide.trailingAnchor ~~ view.trailingAnchor
        
        imagePreviewHelperLayoutGuide.widthAnchor ≤≤ view.widthAnchor * 0.65
        imagePreviewHelperLayoutGuide.bottomAnchor ≤≤ helperLayoutGuide.topAnchor
    }
}

struct NotchyImageAdjustmentData: Codable {
    var showWatermark: Bool
    var showFrame: Bool
    
    init(_ showWatermark: Bool, _ showFrame: Bool) {
        self.showWatermark = showWatermark
        self.showFrame = showFrame
    }
}

// MARK: - PHContentEditingController
extension PhotoEditingViewController: PHContentEditingController {
    func canHandle(_ adjustmentData: PHAdjustmentData) -> Bool {
        // Inspect the adjustmentData to determine whether your extension can work with past edits.
        // (Typically, you use its formatIdentifier and formatVersion properties to do this.)
        guard adjustmentData.formatIdentifier == "com.lionheartsw.notchy",
            adjustmentData.formatVersion == "1" else {
                return false
        }

        return true
    }
    
    func startContentEditing(with contentEditingInput: PHContentEditingInput, placeholderImage: UIImage) {
        // Present content for editing, and keep the contentEditingInput for use when closing the edit session.
        // If you returned true from canHandleAdjustmentData:, contentEditingInput has the original image and adjustment data.
        // If you returned false, the contentEditingInput has past edits "baked in".
        input = contentEditingInput

        self.originalImage = placeholderImage

        let decoder = JSONDecoder()
        if let adjustmentData = contentEditingInput.adjustmentData,
            let adjustment = try? decoder.decode(NotchyImageAdjustmentData.self, from: adjustmentData.data) {
            self.maskedImage = placeholderImage.maskv2(device: device, watermark: adjustment.showWatermark, frame: adjustment.showFrame)
        } else {
            self.maskedImage = placeholderImage.maskv2(device: device, watermark: true, frame: false)
        }
    }

    func finishContentEditing(completionHandler: @escaping ((PHContentEditingOutput?) -> Void)) {
        // Update UI to reflect that editing has finished and output is being rendered.
        
        // Render and provide output on a background queue.
        DispatchQueue.global().async {
            // Create editing output from the editing input.
            let output = PHContentEditingOutput(contentEditingInput: self.input!)

            // Provide new adjustments and render output to given location.
            let adjustment = NotchyImageAdjustmentData(self.showWatermark, self.showFrame)
            let encoder = JSONEncoder()

            guard let data = try? encoder.encode(adjustment),
                let image = self.maskedImage.forced else {
                    completionHandler(output)
                    return
            }
            
            let format = UIGraphicsImageRendererFormat()
            let renderer = UIGraphicsImageRenderer(size: image.size, format: format)
            let imageData = renderer.jpegData(withCompressionQuality: 0.8) { context in
                UIColor.black.setFill()
                let rect = CGRect(origin: .zero, size: image.size)
                UIRectFill(rect)
                image.draw(in: rect)
            }

            output.adjustmentData = PHAdjustmentData(formatIdentifier: "com.lionheartsw.notchy", formatVersion: "1", data: data)

            do {
                try imageData.write(to: output.renderedContentURL)
            } catch {}

            // Call completion handler to commit edit to Photos.
            completionHandler(output)
        }
    }
    
    var shouldShowCancelConfirmation: Bool {
        return false
    }
    
    func cancelContentEditing() {
    }
}
