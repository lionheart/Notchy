//
//  BaseImageEditingViewController.swift
//  Notchy
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

class BaseImageEditingViewController: UIViewController, ExtraStuffPresentationDelegate {
    var selectionFeedbackGenerator = UISelectionFeedbackGenerator()
    let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
    
    var originalImage: UIImage!
    var maskedImage: UIImage! {
        didSet {
            previewImageView.image = maskedImage
        }
    }

    /// A reference for the bottom of the view
    var helperLayoutGuide: UILayoutGuide!
    
    /// A reference for the position of the image preview.
    var imagePreviewHelperLayoutGuide: UILayoutGuide!
    
    /// A guide for the bottom of the view. Needs a rename.
    var guide = UILayoutGuide()
    
    var previewImageView: UIImageView!
    var asset: PHAsset!
    var device: NotchyDevice!
    
    var extraStuffView: ExtraStuffView!
    var backButton: UIButton!
    var toolbar: NotchyToolbar!

    var showWatermark: Bool { return !removeWatermarkButton.isSelected }
    var showFrame: Bool { return addPhoneButton.isSelected }

    private var gradientView: NotchyGradientView!
    private var screenshotLabel: UILabel!
    
    private var imageContainerView: UIView!
    
    private var addPhoneButton: ShortPlainAlternateButton!
    private var removeWatermarkButton: ShortPlainAlternateButton!

    private var phoneImageView: UIImageView!
    private var watermarkImageView: UIImageView!
    private var maskImageView: UIImageView!
    
    private var frameConstraint: NSLayoutConstraint!
    private var noFrameConstraint: NSLayoutConstraint!
    private var widthConstraint: NSLayoutConstraint!
    
    lazy var extraStuffPresenter = ExtraStuffViewController.presenter(view: view)
    
    // MARK: - Initialization
    
    deinit {
        asset = nil
    }
    
    convenience init(asset: PHAsset, original: UIImage, masked: UIImage) {
        self.init()

        self.device = asset.device
        self.asset = asset
        self.originalImage = original
        self.maskedImage = original.maskv2(device: device, watermark: !Defaults[.removeWatermark], frame: Defaults[.addPhone])
    }
    
    convenience init(asset: PHAsset) {
        self.init()
        
        self.asset = asset
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(0x2a2f33)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Pick", style: .done, target: self, action: #selector(rightBarButtonItemDidTouchUpInside(sender:)))
        
        backButton = UIButton()
        backButton.contentEdgeInsets = UIEdgeInsets.init(top: 40, left: 0, bottom: 0, right: 0 )
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(named: "CircleClose")?.image(withColor: .white), for: .normal)
        backButton.setImage(UIImage(named: "Clear")?.image(withColor: .white), for: .highlighted)
        
        imageContainerView = UIView()
        imageContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        phoneImageView = UIImageView(image: UIImage(named: "iPhone X"))
        phoneImageView.translatesAutoresizingMaskIntoConstraints = false
        phoneImageView.contentMode = .scaleAspectFit
        phoneImageView.isHidden = true
        
        maskImageView = UIImageView(image: UIImage(named: "ClearMask"))
        
        previewImageView = UIImageView(image: maskedImage)
        previewImageView.contentMode = .scaleAspectFit
        previewImageView.translatesAutoresizingMaskIntoConstraints = false
        
        watermarkImageView = UIImageView(image: watermarkImage)
        watermarkImageView.translatesAutoresizingMaskIntoConstraints = false
        watermarkImageView.contentMode = .scaleAspectFit
        watermarkImageView.isHidden = true
        
        addPhoneButton = ShortPlainAlternateButton(normalTitle: "Add iPhone", selectedTitle: "Remove iPhone")
        addPhoneButton.isSelected = Defaults[.addPhone]
        addPhoneButton.addTarget(self, action: #selector(addDeviceButtonDidTouchUpInside(_:)), for: .touchUpInside)
        addPhoneButton.addTarget(self, action: #selector(addDeviceButtonDidTouchDown(_:)), for: .touchDown)
        
        removeWatermarkButton = ShortPlainAlternateButton(normalTitle: "Remove Watermark", selectedTitle: "Add Watermark")
        removeWatermarkButton.isSelected = Defaults[.removeWatermark]
        removeWatermarkButton.addTarget(self, action: #selector(removeWatermarkButtonDidTouchUpInside(_:)), for: .touchUpInside)
        removeWatermarkButton.addTarget(self, action: #selector(removeWatermarkButtonDidTouchDown(_:)), for: .touchDown)
        
        screenshotLabel = UILabel()
        screenshotLabel.translatesAutoresizingMaskIntoConstraints = false
        screenshotLabel.font = NotchyTheme.systemFont(ofSize: 12)
        screenshotLabel.textColor = .lightGray
        screenshotLabel.text = "Preview"
        
        if let navigationController = navigationController {
            gradientView = NotchyGradientView()
            
            let navigationBar = navigationController.navigationBar
            navigationController.isNavigationBarHidden = true
            
            navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationBar.shadowImage = UIImage()
            navigationBar.isTranslucent = true
            navigationBar.barStyle = .default
            navigationBar.clipsToBounds = false
            navigationBar.titleTextAttributes = [
                .foregroundColor: UIColor.white
            ]
            navigationBar.addSubview(gradientView)
            
            gradientView.topAnchor ~~ navigationBar.topAnchor - 44
            gradientView.leadingAnchor ~~ navigationBar.leadingAnchor
            gradientView.trailingAnchor ~~ navigationBar.trailingAnchor
            gradientView.bottomAnchor ~~ navigationBar.bottomAnchor + 44
        }

        imageContainerView.addSubview(phoneImageView)
        imageContainerView.addSubview(previewImageView)
        imageContainerView.addSubview(watermarkImageView)

        helperLayoutGuide = UILayoutGuide()
        imagePreviewHelperLayoutGuide = UILayoutGuide()

        view.addLayoutGuide(helperLayoutGuide)
        view.addLayoutGuide(imagePreviewHelperLayoutGuide)
        view.addLayoutGuide(guide)

        view.addSubview(imageContainerView)
        view.addSubview(screenshotLabel)
        view.addSubview(removeWatermarkButton)
        view.addSubview(addPhoneButton)
        view.addSubview(backButton)
        backButton.topAnchor.constraint(equalToSystemSpacingBelow: view.layoutMarginsGuide.topAnchor, multiplier: 1)
        backButton.trailingAnchor ~~ view.layoutMarginsGuide.trailingAnchor

        addPhoneButton.widthAnchor ~~ removeWatermarkButton.widthAnchor

        removeWatermarkButton.trailingAnchor ~~ view.layoutMarginsGuide.trailingAnchor
        helperLayoutGuide.topAnchor.constraint(equalToSystemSpacingBelow: removeWatermarkButton.bottomAnchor, multiplier: 2).isActive = true
        helperLayoutGuide.topAnchor.constraint(equalToSystemSpacingBelow: addPhoneButton.bottomAnchor, multiplier: 2).isActive = true

        addPhoneButton.leadingAnchor ~~ view.layoutMarginsGuide.leadingAnchor

        removeWatermarkButton.leadingAnchor.constraint(equalToSystemSpacingAfter: addPhoneButton.trailingAnchor, multiplier: 2).isActive = true

        previewImageView.centerXAnchor ~~ imageContainerView.centerXAnchor
        previewImageView.centerYAnchor ~~ imageContainerView.centerYAnchor - 16
        widthConstraint = previewImageView.widthAnchor ~~ imagePreviewHelperLayoutGuide.widthAnchor

        noFrameConstraint = previewImageView.heightAnchor ~~ previewImageView.widthAnchor * device.multiplier(hasFrame: false)

        frameConstraint = previewImageView.heightAnchor ~~ previewImageView.widthAnchor * device.multiplier(hasFrame: true)
        frameConstraint.isActive = false

        watermarkImageView.bottomAnchor ~~ previewImageView.bottomAnchor
        watermarkImageView.rightAnchor ~~ previewImageView.rightAnchor
        
        phoneImageView.centerYAnchor ~~ imageContainerView.centerYAnchor - 14
        phoneImageView.centerXAnchor ~~ imageContainerView.centerXAnchor
        phoneImageView.widthAnchor ~~ previewImageView.widthAnchor + 43
        
        imageContainerView.leadingAnchor ~~ view.leadingAnchor
        imageContainerView.trailingAnchor ~~ view.trailingAnchor
        imageContainerView.bottomAnchor ~~ helperLayoutGuide.topAnchor
        imageContainerView.topAnchor ~~ view.safeAreaLayoutGuide.topAnchor
        
        screenshotLabel.topAnchor ~~ phoneImageView.bottomAnchor + 5
        screenshotLabel.centerXAnchor ~~ view.centerXAnchor
        
        guide.topAnchor ~~ view.safeAreaLayoutGuide.bottomAnchor
        guide.bottomAnchor ~~ view.bottomAnchor
        
        updateImageConstraints()
    }
    
    var bottomConstraint: NSLayoutConstraint?
    override func viewDidLayoutSubviews() {
        guard toolbar != nil else {
            return
        }

        // Only let the most recent bottom constraint win.
        if let bottomConstraint = bottomConstraint {
            view.removeConstraint(bottomConstraint)
        }
        
        if guide.layoutFrame.height == 0 {
            bottomConstraint = toolbar.stackView.bottomAnchor ~~ view.bottomAnchor - 16
        } else {
            bottomConstraint = toolbar.stackView.bottomAnchor ~~ view.safeAreaLayoutGuide.bottomAnchor - 4
        }
    }
    
    // MARK: - View Options
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func rightBarButtonItemDidTouchUpInside(sender: Any) {
        
    }
    
    // MARK: - Misc
    
    @objc func removeWatermarkButtonDidTouchDown(_ sender: Any) {
        selectionFeedbackGenerator.prepare()
    }
    
    @objc func removeWatermarkButtonDidTouchUpInside(_ sender: Any) {
        if UserDefaults.purchased {
            selectionFeedbackGenerator.selectionChanged()

            removeWatermarkButton.isSelected = !removeWatermarkButton.isSelected
            Defaults[.removeWatermark] = removeWatermarkButton.isSelected
            
            maskedImage = originalImage.maskv2(device: device, watermark: !removeWatermarkButton.isSelected, frame: addPhoneButton.isSelected)
        } else {
            displayExtraStuffViewController()
        }
    }
    
    @objc func addDeviceButtonDidTouchDown(_ sender: Any) {
        selectionFeedbackGenerator.prepare()
    }
    
    @objc func addDeviceButtonDidTouchUpInside(_ sender: Any) {
        if UserDefaults.purchased {
            selectionFeedbackGenerator.selectionChanged()

            addPhoneButton.isSelected = !addPhoneButton.isSelected
            Defaults[.addPhone] = addPhoneButton.isSelected
            
            maskedImage = originalImage.maskv2(device: device, watermark: !removeWatermarkButton.isSelected, frame: addPhoneButton.isSelected)
            
            updateImageConstraints()
            
            view.setNeedsUpdateConstraints()
        } else {
            displayExtraStuffViewController()
        }
    }
    
    func updateImageConstraints() {
        if addPhoneButton.isSelected {
            noFrameConstraint.isActive = false
            frameConstraint.isActive = true
            widthConstraint.constant = 40
        } else {
            frameConstraint.isActive = false
            noFrameConstraint.isActive = true
            widthConstraint.constant = 0
        }
    }
}
