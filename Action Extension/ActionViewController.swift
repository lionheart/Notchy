//
//  ActionViewController.swift
//  Action Extension
//
//  Created by Dan Loewenherz on 2/2/18.
//  Copyright © 2018 Lionheart Software LLC. All rights reserved.
//

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
    var toolbar: NotchyToolbar!

    lazy var alertPresenter = NotchyAlertViewController.presenter(view: view)
    
    private var toolbarVisibleConstraint: NSLayoutConstraint!
    private var toolbarHiddenConstraint: NSLayoutConstraint!
    
    private var backButton: UIButton!

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
            guard let attachments = item.attachments as? [NSItemProvider] else {
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
                        
                        if let image = image,
                            let maskedImage = image.maskv2(watermark: true, frame: false) {
                            self.originalImage = image
                            self.maskedImage = maskedImage
                        }
                    }
                })

                // We only handle one image, so stop looking for more.
                break main
            }
        }
        
        backButton = UIButton()
        backButton.contentEdgeInsets = UIEdgeInsetsMake(40, 0, 0, 0 )
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(named: "CircleClose")?.image(withColor: .white), for: .normal)
        backButton.setImage(UIImage(named: "Clear")?.image(withColor: .white), for: .highlighted)
        backButton.addTarget(self, action: #selector(backButtonDidTouchUpInside(_:)), for: .touchUpInside)
        
        toolbar = NotchyToolbar(delegate: self)

        view.addSubview(toolbar)
        view.addSubview(backButton)
        
        let margin: CGFloat = 15
        
        toolbarHiddenConstraint = toolbar.topAnchor ~~ view.bottomAnchor
        toolbarHiddenConstraint.isActive = false
        
        toolbar.stackView.bottomAnchor ≤≤ view.safeAreaLayoutGuide.bottomAnchor
        toolbar.stackView.bottomAnchor ≥≥ view.bottomAnchor - 20
        toolbar.leadingAnchor ~~ view.leadingAnchor
        toolbar.trailingAnchor ~~ view.trailingAnchor
        
        backButton.topAnchor ~~ view.safeAreaLayoutGuide.topAnchor - margin
        backButton.trailingAnchor ~~ view.safeAreaLayoutGuide.trailingAnchor - margin
        
        toolbarVisibleConstraint = toolbar.bottomAnchor ~~ view.bottomAnchor
        
        helperLayoutGuide.topAnchor ~~ toolbar.topAnchor
        helperLayoutGuide.bottomAnchor ~~ toolbar.bottomAnchor
        helperLayoutGuide.centerXAnchor ~~ view.centerXAnchor
        
        imagePreviewHelperLayoutGuide.widthAnchor ~~ view.widthAnchor * 0.56
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
    
    func shareButtonDidTouchUpInside(_ sender: Any) {
        notificationFeedbackGenerator.prepare()
        
        guard let url = maskedImage.urlForTransparentVersion,
            let data = try? Data(contentsOf: url) else {
                notificationFeedbackGenerator.notificationOccurred(.error)
                return
        }
        
        DispatchQueue.main.async {
            let activity = UIActivityViewController(activityItems: [data], applicationActivities: nil)
            self.present(activity, animated: true) {
                self.notificationFeedbackGenerator.notificationOccurred(.success)
            }
        }
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
