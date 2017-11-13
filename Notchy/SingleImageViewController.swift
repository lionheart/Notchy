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

    private var toolbarVisibleConstraint: NSLayoutConstraint!
    private var toolbarHiddenConstraint: NSLayoutConstraint!

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

        imageView = UIImageView(image: maskedImage)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        isHeroEnabled = true
        imageView.heroID = asset.localIdentifier

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

        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Pick", style: .done, target: self, action: #selector(rightBarButtonItemDidTouchUpInside(sender:)))
        
        toolbar = NotchyToolbar(delegate: self)

        view.addSubview(imageView)
        view.addSubview(toolbar)

        toolbarHiddenConstraint = toolbar.topAnchor ~~ view.bottomAnchor
        toolbarHiddenConstraint.isActive = false

        toolbar.stackView.bottomAnchor ~~ view.safeAreaLayoutGuide.bottomAnchor
        toolbar.leadingAnchor ~~ view.leadingAnchor
        toolbar.trailingAnchor ~~ view.trailingAnchor

        toolbarVisibleConstraint = toolbar.bottomAnchor ~~ view.bottomAnchor

        imageView.leadingAnchor ~~ view.leadingAnchor
        imageView.trailingAnchor ~~ view.trailingAnchor
        imageView.topAnchor ~~ view.safeAreaLayoutGuide.topAnchor
        imageView.bottomAnchor ~~ toolbar.topAnchor
    }

    @objc func rightBarButtonItemDidTouchUpInside(sender: Any) {
        print("HI")
    }
}

extension SingleImageViewController: NotchyToolbarDelegate {
    func addDeviceButtonDidTouchUpInside(_ sender: Any) {

    }

    func notchifyButtonDidTouchUpInside(sender: Any) {
        asset.image(maskType: .v2) { image in
            guard let image = image?.forced else {
                return
            }

            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)

            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Notched!", message: nil, preferredStyle: .alert)
                alert.addAction(title: "OK", style: .default, handler: nil)
                self.present(alert, animated: true)
                self.toolbar.notchingComplete()
            }
        }

        return;

        /*
        let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        controller.completionWithItemsHandler = { (activity, completed, items, error) in
            // MARK: TODO
            guard let activity = activity else {
                return
            }

            if activity == .saveToCameraRoll {
                let alert = UIAlertController(title: "Saved!", message: nil, preferredStyle: .alert)
                alert.addAction(title: "OK", style: .default, handler: nil)

                self.present(alert, animated: true)
            }
        }
        present(controller, animated: true)

        return;

        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)

        return;

        DispatchQueue.global(qos: .default).async {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { (success, error) in
                print(success)
                print(error)

                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Saved!", message: nil, preferredStyle: .alert)
                    alert.addAction(title: "OK", style: .default, handler: nil)
                    self.present(alert, animated: true)
                }
            }
        }

        return

        return
        #if false


        #endif
 */
    }

    func removeWatermarkButtonDidTouchUpInside(_ sender: Any) {

    }

    func backButtonDidTouchUpInside(sender: Any) {
        hero_dismissViewController()
    }

    func screenshotsButtonDidTouchUpInside(sender: Any) {
        hero_dismissViewController()
    }

    func didToggleDeleteOriginalSwitch(sender: Any) { }
}
