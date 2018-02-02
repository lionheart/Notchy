//
//  BaseImageEditingViewController.swift
//  Notchy
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

enum PhoneDimension {
    case frame
    case noFrame
    
    var multiplier: CGFloat {
        switch self {
        // 2436/1125
        case .frame: return 1.9284649776
        case .noFrame: return 2.1653
        }
    }
}

class BaseImageEditingViewController: UIViewController {
    let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
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
    
    var previewImageView: UIImageView!
    var asset: PHAsset!
    
    var extraStuffView: ExtraStuffView!

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
        
        self.asset = asset
        self.originalImage = original
        self.maskedImage = original.maskv2(watermark: true, frame: false)
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
        addPhoneButton.addTarget(self, action: #selector(addDeviceButtonDidTouchUpInside(_:)), for: .touchUpInside)
        addPhoneButton.addTarget(self, action: #selector(addDeviceButtonDidTouchDown(_:)), for: .touchDown)
        
        removeWatermarkButton = ShortPlainAlternateButton(normalTitle: "Remove Watermark", selectedTitle: "Add Watermark")
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

        view.addSubview(imageContainerView)
        view.addSubview(screenshotLabel)
        view.addSubview(removeWatermarkButton)
        view.addSubview(addPhoneButton)

        let margin: CGFloat = 15

        removeWatermarkButton.trailingAnchor ~~ view.safeAreaLayoutGuide.trailingAnchor - margin
        removeWatermarkButton.bottomAnchor ~~ helperLayoutGuide.topAnchor - margin
        removeWatermarkButton.widthAnchor ~~ 153

        addPhoneButton.widthAnchor ~~ 125
        addPhoneButton.bottomAnchor ~~ helperLayoutGuide.topAnchor - margin
        addPhoneButton.leadingAnchor ~~ view.safeAreaLayoutGuide.leadingAnchor + margin

        previewImageView.centerXAnchor ~~ imageContainerView.centerXAnchor
        previewImageView.centerYAnchor ~~ imageContainerView.centerYAnchor - 16
        widthConstraint = previewImageView.widthAnchor ~~ imagePreviewHelperLayoutGuide.widthAnchor
        
        noFrameConstraint = previewImageView.heightAnchor ~~ previewImageView.widthAnchor * PhoneDimension.noFrame.multiplier
        
        frameConstraint = previewImageView.heightAnchor ~~ previewImageView.widthAnchor * PhoneDimension.frame.multiplier
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
        
        print(addPhoneButton.frame.width)
        print(removeWatermarkButton.frame.width)
    }
    
    @objc func removeWatermarkButtonDidTouchUpInside(_ sender: Any) {
        if UserDefaults.purchased {
            selectionFeedbackGenerator.selectionChanged()
            
            removeWatermarkButton.isSelected = !removeWatermarkButton.isSelected
            
            maskedImage = originalImage.maskv2(watermark: !removeWatermarkButton.isSelected, frame: addPhoneButton.isSelected)
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
            
            maskedImage = originalImage.maskv2(watermark: !removeWatermarkButton.isSelected, frame: addPhoneButton.isSelected)
            
            if addPhoneButton.isSelected {
                noFrameConstraint.isActive = false
                frameConstraint.isActive = true
                widthConstraint.constant = 45
            } else {
                frameConstraint.isActive = false
                noFrameConstraint.isActive = true
                widthConstraint.constant = 0
            }
            
            view.setNeedsUpdateConstraints()
        } else {
            displayExtraStuffViewController()
        }
    }
    
    func displayExtraStuffViewController() {
        selectionFeedbackGenerator.selectionChanged()
        let controller = ExtraStuffViewController()
        controller.transitioningDelegate = extraStuffPresenter
        controller.modalPresentationStyle = .custom
        present(controller, animated: true, completion: nil)
    }
}
