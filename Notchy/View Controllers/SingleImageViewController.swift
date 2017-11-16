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

final class SingleImageViewController: UIViewController {
    private var imageView: UIImageView!
    fileprivate var maskedImage: UIImage?
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

    convenience init(asset: PHAsset, image: UIImage) {
        self.init()

        self.asset = asset
        self.maskedImage = image
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        asset.image(maskType: .v1) { image in
            self.imageView.image = image
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Pick", style: .done, target: self, action: #selector(rightBarButtonItemDidTouchUpInside(sender:)))

        isHeroEnabled = true

        imageContainerView = UIView()
        imageContainerView.translatesAutoresizingMaskIntoConstraints = false

        backButton = UIButton()
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(named: "CircleClose")?.image(withColor: .white), for: .normal)
        backButton.setImage(UIImage(named: "Clear")?.image(withColor: .white), for: .highlighted)
        backButton.addTarget(self, action: #selector(backButtonDidTouchUpInside(_:)), for: .touchUpInside)

        phoneImageView = UIImageView(image: UIImage(named: "iPhoneXSpaceGrey"))
        phoneImageView.translatesAutoresizingMaskIntoConstraints = false
        phoneImageView.contentMode = .scaleAspectFit
        phoneImageView.isHidden = true

        imageView = UIImageView(image: maskedImage)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heroID = asset.localIdentifier

        addPhoneButton = ShortPlainAlternateButton()
        addPhoneButton.addTarget(self, action: #selector(addDeviceButtonDidTouchUpInside(_:)), for: .touchUpInside)
        addPhoneButton.setTitle("Add iPhone X", for: .normal)
        addPhoneButton.setTitle("Remove iPhone X", for: .selected)

        removeWatermarkButton = ShortPlainAlternateButton()
        removeWatermarkButton.setTitle("Remove Mark", for: .normal)

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

        imageContainerView.addSubview(imageView)
        imageContainerView.addSubview(phoneImageView)

        view.addSubview(imageContainerView)
        view.addSubview(screenshotLabel)
        view.addSubview(toolbar)
        view.addSubview(removeWatermarkButton)
        view.addSubview(addPhoneButton)
        view.addSubview(backButton)

        let margin: CGFloat = 15

        toolbarHiddenConstraint = toolbar.topAnchor ~~ view.bottomAnchor
        toolbarHiddenConstraint.isActive = false

        toolbar.stackView.bottomAnchor ~~ view.safeAreaLayoutGuide.bottomAnchor
        toolbar.leadingAnchor ~~ view.leadingAnchor
        toolbar.trailingAnchor ~~ view.trailingAnchor

        backButton.topAnchor ~~ view.safeAreaLayoutGuide.topAnchor - margin
        backButton.trailingAnchor ~~ view.safeAreaLayoutGuide.trailingAnchor - margin

        removeWatermarkButton.trailingAnchor ~~ view.safeAreaLayoutGuide.trailingAnchor - margin
        removeWatermarkButton.bottomAnchor ~~ toolbar.topAnchor - margin
        addPhoneButton.bottomAnchor ~~ toolbar.topAnchor - margin
        addPhoneButton.leadingAnchor ~~ view.safeAreaLayoutGuide.leadingAnchor + margin

        toolbarVisibleConstraint = toolbar.bottomAnchor ~~ view.bottomAnchor

        // 2436/1125
        imageView.centerXAnchor ~~ imageContainerView.centerXAnchor
        imageView.centerYAnchor ~~ imageContainerView.centerYAnchor - 15
        imageView.widthAnchor ~~ imageContainerView.widthAnchor * 0.6
        imageView.heightAnchor ~~ imageView.widthAnchor * 2.1653

        phoneImageView.centerYAnchor ~~ imageContainerView.centerYAnchor - 15
        phoneImageView.centerXAnchor ~~ imageContainerView.centerXAnchor
        phoneImageView.widthAnchor ~~ imageContainerView.widthAnchor * 0.75

        imageContainerView.leadingAnchor ~~ view.leadingAnchor
        imageContainerView.trailingAnchor ~~ view.trailingAnchor
        imageContainerView.bottomAnchor ~~ toolbar.topAnchor
        imageContainerView.topAnchor ~~ view.safeAreaLayoutGuide.topAnchor

        screenshotLabel.topAnchor ~~ phoneImageView.bottomAnchor + 5
        screenshotLabel.centerXAnchor ~~ view.centerXAnchor
    }

    @objc func rightBarButtonItemDidTouchUpInside(sender: Any) {
        print("HI")
    }
}

extension SingleImageViewController: NotchyToolbarDelegate {
    func copyButtonDidTouchUpInside(_ sender: Any) {
        let alertView = NotchyAlertView(type: .loading("Notching…"))

        imageContainerView.addSubview(alertView)

        alertView.centerXAnchor ~~ imageContainerView.centerXAnchor
        alertView.centerYAnchor ~~ imageContainerView.centerYAnchor
        alertView.widthAnchor ~~ 120
        alertView.widthAnchor ~~ alertView.heightAnchor

        asset.image(maskType: .v2) { image in
            guard let image = image?.forced else {
                return
            }

            UIPasteboard.general.setObjects([image])

            DispatchQueue.main.async {
                alertView.removeFromSuperview()

                let alertView = NotchyAlertView(type: .success("Copied!"))

                self.imageContainerView.addSubview(alertView)

                alertView.centerXAnchor ~~ self.imageContainerView.centerXAnchor
                alertView.centerYAnchor ~~ self.imageContainerView.centerYAnchor
                alertView.widthAnchor ~~ 120
                alertView.widthAnchor ~~ alertView.heightAnchor

                UIView.animate(withDuration: 0.5, delay: 1, options: [], animations: {
                    alertView.alpha = 0
                }, completion: { _ in
                    self.toolbar.notchingComplete()
                })
            }
        }
    }

    func shareButtonDidTouchUpInside(_ sender: Any) {
        let alertView = NotchyAlertView(type: .loading("Notching…"))

        imageContainerView.addSubview(alertView)

        alertView.centerXAnchor ~~ imageContainerView.centerXAnchor
        alertView.centerYAnchor ~~ imageContainerView.centerYAnchor
        alertView.widthAnchor ~~ 120
        alertView.widthAnchor ~~ alertView.heightAnchor

        asset.image(maskType: .v2) { image in
            alertView.removeFromSuperview()

            guard let image = image?.forced else {
                return
            }

            let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            self.present(controller, animated: true)
        }
    }

    func saveButtonDidTouchUpInside(_ sender: Any) {
        let alertView = NotchyAlertView(type: .loading("Notching…"))

        imageContainerView.addSubview(alertView)

        alertView.centerXAnchor ~~ imageContainerView.centerXAnchor
        alertView.centerYAnchor ~~ imageContainerView.centerYAnchor
        alertView.widthAnchor ~~ 120
        alertView.widthAnchor ~~ alertView.heightAnchor

        asset.image(maskType: .v2) { image in
            guard let image = image?.forced else {
                return
            }

            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)

            DispatchQueue.main.async {
                alertView.removeFromSuperview()

                let alertView = NotchyAlertView(type: .success("Notched!"))

                self.imageContainerView.addSubview(alertView)

                alertView.centerXAnchor ~~ self.imageContainerView.centerXAnchor
                alertView.centerYAnchor ~~ self.imageContainerView.centerYAnchor
                alertView.widthAnchor ~~ 120
                alertView.widthAnchor ~~ alertView.heightAnchor

                UIView.animate(withDuration: 0.5, delay: 1, options: [], animations: {
                    alertView.alpha = 0
                }, completion: { _ in
                    self.toolbar.notchingComplete()
                })
            }
        }
    }

    func addDeviceButtonDidTouchUpInside(_ sender: Any) {
        phoneImageView.isHidden = !phoneImageView.isHidden
        addPhoneButton.isSelected = !phoneImageView.isHidden
    }

    func removeWatermarkButtonDidTouchUpInside(_ sender: Any) {

    }

    func backButtonDidTouchUpInside(_ sender: Any) {
        hero_dismissViewController()
    }

    func screenshotsButtonDidTouchUpInside(sender: Any) {
        hero_dismissViewController()
    }

    func didToggleDeleteOriginalSwitch(sender: Any) { }
}
