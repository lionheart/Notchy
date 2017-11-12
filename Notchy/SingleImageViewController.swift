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

final class SingleImageViewController: UIViewController {
    private var imageView: UIImageView!
    private var asset: PHAsset!
    private var toolbar: NotchyToolbar!
    private var gradientView: NotchyGradientView!

    private var toolbarVisibleConstraint: NSLayoutConstraint!
    private var toolbarHiddenConstraint: NSLayoutConstraint!

    convenience init(asset: PHAsset) {
        self.init()

        self.asset = asset
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateImageView()
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Notchy"

        let topImageView = UIImageView(image: UIImage(named: "Logo"))
        topImageView.contentMode = .scaleAspectFit
        topImageView.isHidden = true
        topImageView.translatesAutoresizingMaskIntoConstraints = false

        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        guard let navigationController = navigationController else {
            return
        }

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

        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Pick", style: .done, target: self, action: #selector(rightBarButtonItemDidTouchUpInside(sender:)))

        gradientView = NotchyGradientView()
        
        toolbar = NotchyToolbar(delegate: self)

        navigationBar.addSubview(gradientView)
        view.addSubview(imageView)
        view.addSubview(toolbar)
        view.addSubview(topImageView)

        topImageView.topAnchor ~~ view.safeAreaLayoutGuide.topAnchor
        topImageView.centerXAnchor ~~ view.centerXAnchor
        topImageView.widthAnchor ~~ 160

        toolbarHiddenConstraint = toolbar.topAnchor ~~ view.bottomAnchor
        toolbarHiddenConstraint.isActive = false

        toolbar.stackView.bottomAnchor ~~ view.safeAreaLayoutGuide.bottomAnchor - 15
        toolbar.leadingAnchor ~~ view.leadingAnchor
        toolbar.trailingAnchor ~~ view.trailingAnchor

        toolbarVisibleConstraint = toolbar.bottomAnchor ~~ view.bottomAnchor

        gradientView.topAnchor ~~ navigationBar.topAnchor - 44
        gradientView.leadingAnchor ~~ navigationBar.leadingAnchor
        gradientView.trailingAnchor ~~ navigationBar.trailingAnchor
        gradientView.bottomAnchor ~~ navigationBar.bottomAnchor + 44

        imageView.leadingAnchor ~~ view.leadingAnchor
        imageView.trailingAnchor ~~ view.trailingAnchor
        imageView.topAnchor ~~ view.safeAreaLayoutGuide.topAnchor
        imageView.bottomAnchor ~~ view.bottomAnchor
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let navigationBar = navigationController?.navigationBar else {
            return
        }

        let backgroundClassName = "_UIBarBackground"
        for subview in navigationBar.subviews {
            if NSStringFromClass(subview.classForCoder) == backgroundClassName {
                let gradient = CAGradientLayer()
                gradient.frame = gradientView.frame
                gradient.masksToBounds = true
                gradient.colors = [UIColor(0x4EC8ED).cgColor, UIColor(0x55C229).cgColor]
                subview.layer.insertSublayer(gradient, at: 0)
            }
        }
    }

    func updateImageView() {
        let width: CGFloat = 1125
        let height: CGFloat = 2436
        let viewWidth = view.frame.width

        let size = CGSize(width: viewWidth, height: viewWidth * height / width)
        let options = PHImageRequestOptions()
        options.version = .current
        options.deliveryMode = .opportunistic
        options.resizeMode = .exact
        options.isNetworkAccessAllowed = true
        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: options) { image, other in
            self.imageView.image = image?.mask(.notch)
        }
    }

    @objc func rightBarButtonItemDidTouchUpInside(sender: Any) {
        print("HI")
    }
}

extension SingleImageViewController: NotchyToolbarDelegate {
    func notchifyButtonDidTouchUpInside(sender: Any) {
        guard let image = imageView.image else {
            return
        }

        let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        controller.completionWithItemsHandler = { (activity, completed, items, error) in
            // MARK: TODO
            guard let activity = activity else {
                return
            }

            if activity == .saveToCameraRoll {
                let alert = UIAlertController(title: "Saved!", message: nil, preferredStyle: .alert)
                alert.addAction(title: "OK", style: .default, handler: nil)
            }
        }

        present(controller, animated: true)
    }

    func screenshotsButtonDidTouchUpInside(sender: Any) {
        let controller = GridViewController(delegate: self)
        let navigation = UINavigationController(rootViewController: controller)
        present(navigation, animated: true)
    }

    func didToggleDeleteOriginalSwitch(sender: Any) {

    }
}

extension SingleImageViewController: GridViewControllerDelegate {
    func gridViewControllerUpdatedAsset(_ asset: PHAsset) {
        self.asset = asset

        updateImageView()
    }
}
