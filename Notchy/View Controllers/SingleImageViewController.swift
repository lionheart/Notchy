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

func ExtraStuffPresenter(view: UIView) -> Presentr {
    let width = ModalSize.custom(size: Float(view.frame.width * 0.7))
    let height = ModalSize.custom(size: 350)
    let center = ModalCenterPosition.custom(centerPoint: view.center)

    let presenter = Presentr(presentationType: .custom(width: width, height: height, center: center))

    presenter.backgroundOpacity = 0.5
    presenter.transitionType = TransitionType.crossDissolve
    presenter.dismissTransitionType = TransitionType.crossDissolve

    return presenter
}

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

final class SingleImageViewController: UIViewController {
    let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
    let notificationFeedbackGenerator = UINotificationFeedbackGenerator()

    lazy var extraStuffPresenter: Presentr = {
        return ExtraStuffPresenter(view: view)
    }()

    lazy var modalPresenter: Presentr = {
        let size = ModalSize.custom(size: 120)
        let center = ModalCenterPosition.center
        let presenter = Presentr(presentationType: .custom(width: size, height: size, center: center))
        let animation = NotchyAlertAnimation(duration: 0.5)
        presenter.backgroundOpacity = 0
        presenter.transitionType = .custom(animation)
        presenter.dismissTransitionType = .custom(animation)
        return presenter
    }()

    private var imageView: UIImageView!

    fileprivate var originalImage: UIImage!
    fileprivate var maskedImage: UIImage!

    private var asset: PHAsset!
    private var toolbar: NotchyToolbar!
    private var gradientView: NotchyGradientView!
    private var screenshotLabel: UILabel!

    private var backButton: UIButton!

    private var imageContainerView: UIView!

    private var addPhoneButton: ShortPlainAlternateButton!
    private var removeWatermarkButton: ShortPlainAlternateButton!

    private var toolbarVisibleConstraint: NSLayoutConstraint!
    private var toolbarHiddenConstraint: NSLayoutConstraint!

    private var phoneImageView: UIImageView!
    private var watermarkImageView: UIImageView!
    private var maskImageView: UIImageView!

    private var frameConstraint: NSLayoutConstraint!
    private var noFrameConstraint: NSLayoutConstraint!
    private var widthConstraint: NSLayoutConstraint!
    private var centerYConstraint: NSLayoutConstraint!

    var extraStuffView: ExtraStuffView!

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

        isHeroEnabled = true

        imageContainerView = UIView()
        imageContainerView.translatesAutoresizingMaskIntoConstraints = false

        backButton = UIButton()
        backButton.contentEdgeInsets = UIEdgeInsetsMake(40, 0, 0, 0 )
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(named: "CircleClose")?.image(withColor: .white), for: .normal)
        backButton.setImage(UIImage(named: "Clear")?.image(withColor: .white), for: .highlighted)
        backButton.addTarget(self, action: #selector(backButtonDidTouchUpInside(_:)), for: .touchUpInside)

        phoneImageView = UIImageView(image: UIImage(named: "iPhone X"))
        phoneImageView.translatesAutoresizingMaskIntoConstraints = false
        phoneImageView.contentMode = .scaleAspectFit
        phoneImageView.isHidden = true

        maskImageView = UIImageView(image: UIImage(named: "ClearMask"))

        imageView = UIImageView(image: maskedImage)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heroID = asset.localIdentifier

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
        
        toolbar = NotchyToolbar(delegate: self)

        imageContainerView.addSubview(phoneImageView)
        imageContainerView.addSubview(imageView)
        imageContainerView.addSubview(watermarkImageView)

        view.addSubview(imageContainerView)
        view.addSubview(screenshotLabel)
        view.addSubview(toolbar)
        view.addSubview(removeWatermarkButton)
        view.addSubview(addPhoneButton)
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

        removeWatermarkButton.trailingAnchor ~~ view.safeAreaLayoutGuide.trailingAnchor - margin
        removeWatermarkButton.bottomAnchor ~~ toolbar.topAnchor - margin
        removeWatermarkButton.widthAnchor ~~ 153

        addPhoneButton.widthAnchor ~~ 125
        addPhoneButton.bottomAnchor ~~ toolbar.topAnchor - margin
        addPhoneButton.leadingAnchor ~~ view.safeAreaLayoutGuide.leadingAnchor + margin

        toolbarVisibleConstraint = toolbar.bottomAnchor ~~ view.bottomAnchor

        imageView.centerXAnchor ~~ imageContainerView.centerXAnchor
        centerYConstraint = imageView.centerYAnchor ~~ imageContainerView.centerYAnchor - 16
        widthConstraint = imageView.widthAnchor ~~ imageContainerView.widthAnchor * 0.56

        noFrameConstraint = imageView.heightAnchor ~~ imageView.widthAnchor * PhoneDimension.noFrame.multiplier

        frameConstraint = imageView.heightAnchor ~~ imageView.widthAnchor * PhoneDimension.frame.multiplier
        frameConstraint.isActive = false

        watermarkImageView.bottomAnchor ~~ imageView.bottomAnchor
        watermarkImageView.rightAnchor ~~ imageView.rightAnchor

        phoneImageView.centerYAnchor ~~ imageContainerView.centerYAnchor - 14
        phoneImageView.centerXAnchor ~~ imageContainerView.centerXAnchor
        phoneImageView.widthAnchor ~~ imageView.widthAnchor + 43

        imageContainerView.leadingAnchor ~~ view.leadingAnchor
        imageContainerView.trailingAnchor ~~ view.trailingAnchor
        imageContainerView.bottomAnchor ~~ toolbar.topAnchor
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
            imageView.image = maskedImage
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
            imageView.image = maskedImage

            if addPhoneButton.isSelected {
                noFrameConstraint.isActive = false
                frameConstraint.isActive = true
                widthConstraint.constant = 45
                centerYConstraint.constant = -16
            } else {
                frameConstraint.isActive = false
                noFrameConstraint.isActive = true
                widthConstraint.constant = 0
                centerYConstraint.constant = -16
            }

            view.setNeedsUpdateConstraints()
        } else {
            displayExtraStuffViewController()
        }
    }

    func backButtonDidTouchUpInside(_ sender: Any) {
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
            controller.transitioningDelegate = self.modalPresenter
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
                controller.transitioningDelegate = self.modalPresenter
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

    func displayExtraStuffViewController() {
        selectionFeedbackGenerator.selectionChanged()
        let controller = ExtraStuffViewController()
        controller.transitioningDelegate = extraStuffPresenter
        controller.modalPresentationStyle = .custom
        present(controller, animated: true, completion: nil)
    }
}
