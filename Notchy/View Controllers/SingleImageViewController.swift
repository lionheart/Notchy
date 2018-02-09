//
//  SingleImageViewController.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 11/11/17.
//  Copyright © 2017 Lionheart Software LLC. All rights reserved.
//

import UIKit
import Photos
import SuperLayout
import Hero
import Presentr
import LionheartExtensions
import SwiftyUserDefaults
import MobileCoreServices
import StoreKit

final class SingleImageViewController: BaseImageEditingViewController {
    lazy var iconSelectorPresenter = IconSelectorViewController.presenter(view: view)
    lazy var alertPresenter = NotchyAlertViewController.presenter(view: view)
    
    private var toolbarVisibleConstraint: NSLayoutConstraint!
    private var toolbarHiddenConstraint: NSLayoutConstraint!
    
    var saved = false {
        willSet(newValue) {
            guard !saved else {
                return
            }
            
            Defaults[.numberOfScreenshots] += 1
            
            if Defaults[.numberOfScreenshots] >= 5 {
                DispatchQueue.main.async {
                    SKStoreReviewController.requestReview()
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        backButton.addTarget(self, action: #selector(backButtonDidTouchUpInside(_:)), for: .touchUpInside)
        
        isHeroEnabled = true
        
        previewImageView.heroID = asset.localIdentifier
        
        toolbar = NotchyToolbar(delegate: self, type: .regular)

        view.addSubview(toolbar)

        toolbarHiddenConstraint = toolbar.topAnchor ~~ view.bottomAnchor
        toolbarHiddenConstraint.isActive = false

        toolbar.leadingAnchor ~~ view.safeAreaLayoutGuide.leadingAnchor
        toolbar.trailingAnchor ~~ view.safeAreaLayoutGuide.trailingAnchor
        
        toolbarVisibleConstraint = toolbar.bottomAnchor ~~ view.bottomAnchor

        helperLayoutGuide.topAnchor ~~ toolbar.topAnchor
        helperLayoutGuide.bottomAnchor ~~ toolbar.bottomAnchor
        helperLayoutGuide.centerXAnchor ~~ view.centerXAnchor

        imagePreviewHelperLayoutGuide.widthAnchor ~~ view.widthAnchor * 0.56
    }

    @objc func backButtonDidTouchUpInside(_ sender: Any) {
        hero_dismissViewController()
    }
}

// MARK: - NotchyToolbarDelegate
extension SingleImageViewController: NotchyToolbarDelegate {
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
                    self.saved = true
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
            activity.excludedActivityTypes = [
                .openInIBooks,
                .print,
                .assignToContact,
                .addToReadingList
            ]
            activity.completionWithItemsHandler = { activityType, completed, items, error in
                guard completed else {
                    return
                }

                self.saved = true
            }
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
                        self.saved = true
                    }
                }
            }
        })
    }
}
