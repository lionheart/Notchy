//
//  ActionViewController.swift
//  Action Extension
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
import SuperLayout
import Presentr
import LionheartExtensions
import SwiftyUserDefaults
import MobileCoreServices

let Defaults = UserDefaults(suiteName: "group.com.lionheartsw.notchy")!

/// self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)

final class ActionViewController: BaseImageEditingViewController {
    lazy var alertPresenter = NotchyAlertViewController.presenter(view: view)
    
    private var toolbarVisibleConstraint: NSLayoutConstraint!
    private var toolbarHiddenConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let inputItems = extensionContext?.inputItems as? [NSExtensionItem] else {
            return
        }
        
        // From Apple sample code.
        // Get the item[s] we're handling from the extension context.
        // For example, look for an image and place it into an image view.
        // Replace this with something appropriate for the type[s] your extension supports.
        main: for item in inputItems {
            guard let attachments = item.attachments else {
                continue
            }

            for provider in attachments {
                guard provider.hasItemConformingToTypeIdentifier(kUTTypeImage as String) else {
                    continue
                }

                // This is an image. We'll load it, then place it in our image view.
                provider.loadItem(forTypeIdentifier: kUTTypeImage as String, options: nil, completionHandler: { (item, error) in
                    OperationQueue.main.addOperation {
                        var image: UIImage?
                        if let _image = item as? UIImage {
                            image = _image
                        } else if let imageURL = item as? URL,
                            let data = try? Data(contentsOf: imageURL) {
                            image = UIImage(data: data)
                        }
                        
                        let removeWatermark = Defaults[.removeWatermark]
                        let addPhone = Defaults[.addPhone]
                        if let image = image,
                            let maskedImage = image.maskv2(device: self.device, watermark: !removeWatermark, frame: addPhone) {
                            self.originalImage = image
                            self.maskedImage = maskedImage
                        }
                    }
                })

                // We only handle one image, so stop looking for more.
                break main
            }
        }

        backButton.addTarget(self, action: #selector(backButtonDidTouchUpInside(_:)), for: .touchUpInside)
        
        toolbar = NotchyToolbar(delegate: self, type: .short)

        view.addSubview(toolbar)
        view.addSubview(backButton)
        
        toolbarHiddenConstraint = toolbar.topAnchor ~~ view.bottomAnchor
        toolbarHiddenConstraint.isActive = false

        toolbar.leadingAnchor ~~ view.safeAreaLayoutGuide.leadingAnchor
        toolbar.trailingAnchor ~~ view.safeAreaLayoutGuide.trailingAnchor
        
        backButton.topAnchor.constraint(equalToSystemSpacingBelow: view.layoutMarginsGuide.topAnchor, multiplier: 1)
        view.layoutMarginsGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: backButton.trailingAnchor, multiplier: 1)
        
        toolbarVisibleConstraint = toolbar.bottomAnchor ~~ view.bottomAnchor
        
        helperLayoutGuide.topAnchor ~~ toolbar.topAnchor
        helperLayoutGuide.bottomAnchor ~~ toolbar.bottomAnchor
        helperLayoutGuide.centerXAnchor ~~ view.centerXAnchor
        
        imagePreviewHelperLayoutGuide.widthAnchor ~~ view.widthAnchor * 0.56
        
        guide.topAnchor ~~ view.safeAreaLayoutGuide.bottomAnchor
        guide.bottomAnchor ~~ view.bottomAnchor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        activateShareSheet()
    }
    
    @objc func backButtonDidTouchUpInside(_ sender: Any) {
        let inputItems = extensionContext?.inputItems ?? []
        extensionContext?.completeRequest(returningItems: inputItems)
    }
}

// MARK: - NotchyToolbarDelegate
extension ActionViewController: NotchyToolbarDelegate {
    func copyButtonDidTouchUpInside(_ sender: Any) {
        notificationFeedbackGenerator.prepare()
        
        guard let url = maskedImage.urlForTransparentVersion,
            let data = try? Data(contentsOf: url) else {
                notificationFeedbackGenerator.notificationOccurred(.error)
                return
        }
        
        UIPasteboard.general.setData(data, forPasteboardType: kUTTypePNG as String)
        
        DispatchQueue.main.async {
            self.notificationFeedbackGenerator.notificationOccurred(.success)
            let controller = NotchyAlertViewController(type: .success("Copied"))
            controller.transitioningDelegate = self.alertPresenter
            controller.modalPresentationStyle = .custom
            self.present(controller, animated: false) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    controller.dismiss(animated: true)
                    self.toolbar.notchingComplete()
                }
            }
        }
    }

    // MARK: XXX Duplicate code in SingleImageViewController
    func activateShareSheet() {
        notificationFeedbackGenerator.prepare()
        
        guard let url = maskedImage.urlForTransparentVersion,
            let data = try? Data(contentsOf: url) else {
                notificationFeedbackGenerator.notificationOccurred(.error)
                return
        }
        
        DispatchQueue.main.async {
            let activity = UIActivityViewController(activityItems: [data], applicationActivities: nil)
            activity.excludedActivityTypes = [
                .openInIBooks,
                .print,
                .assignToContact,
                .addToReadingList
            ]

            self.present(activity, animated: true) {
                self.notificationFeedbackGenerator.notificationOccurred(.success)
            }
        }
    }
    
    func shareButtonDidTouchUpInside(_ sender: Any) {
        activateShareSheet()
    }
    
    func saveButtonDidTouchUpInside(_ sender: Any) {
        notificationFeedbackGenerator.prepare()
        
        guard let url = maskedImage.urlForTransparentVersion else {
            notificationFeedbackGenerator.notificationOccurred(.error)
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url)
            guard let identifier = request?.placeholderForCreatedAsset?.localIdentifier else {
                return
            }
            
            let identifiers = Defaults[.identifiers]
            if !identifiers.contains(identifier) {
                Defaults[.identifiers].append(identifier)
            }
        }, completionHandler: { success, error in
            if let error = error {
                self.notificationFeedbackGenerator.notificationOccurred(.error)
                
                print("error creating asset: \(error)")
                return
            }
            
            DispatchQueue.main.async {
                self.notificationFeedbackGenerator.notificationOccurred(.success)
                let controller = NotchyAlertViewController(type: .success("Saved"))
                controller.transitioningDelegate = self.alertPresenter
                controller.modalPresentationStyle = .custom
                self.present(controller, animated: false) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                        controller.dismiss(animated: true)
                        self.toolbar.notchingComplete()
                    }
                }
            }
        })
    }
}
