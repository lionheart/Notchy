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

final class SingleImageViewController: BaseImageEditingViewController {
    var toolbar: NotchyToolbar!
    
    lazy var iconSelectorPresenter = IconSelectorViewController.presenter(view: view)
    lazy var alertPresenter = NotchyAlertViewController.presenter(view: view)
    
    private var toolbarVisibleConstraint: NSLayoutConstraint!
    private var toolbarHiddenConstraint: NSLayoutConstraint!

    private var backButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        isHeroEnabled = true
        
        previewImageView.heroID = asset.localIdentifier
        
        backButton = UIButton()
        backButton.contentEdgeInsets = UIEdgeInsetsMake(40, 0, 0, 0 )
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(named: "CircleClose")?.image(withColor: .white), for: .normal)
        backButton.setImage(UIImage(named: "Clear")?.image(withColor: .white), for: .highlighted)
        backButton.addTarget(self, action: #selector(backButtonDidTouchUpInside(_:)), for: .touchUpInside)
        
        toolbar = NotchyToolbar(delegate: self, type: .regular)

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
