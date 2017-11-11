//
//  WelcomeViewController.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 11/10/17.
//  Copyright © 2017 Lionheart Software LLC. All rights reserved.
//

import UIKit
import QuickTableView
import LionheartExtensions
import SuperLayout
import Photos

final class WelcomeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let gradient = CAGradientLayer()
        gradient.frame = view.frame
        gradient.masksToBounds = true
        gradient.colors = [UIColor(0x4EC8ED).cgColor, UIColor(0x55C229).cgColor]

        let label1 = UILabel()
        label1.textAlignment = .center
        label1.text = "Welcome"
        label1.font = UIFont.systemFont(ofSize: 24)

        let label2 = UILabel()
        label2.textAlignment = .center
        label2.text = "to"
        label2.font = UIFont.systemFont(ofSize: 24)

        let logoImageView = UIImageView(image: UIImage(named: "Logo"))

        let topStackView = UIStackView(arrangedSubviews: [label1, label2, logoImageView])
        topStackView.translatesAutoresizingMaskIntoConstraints = false
        topStackView.axis = .vertical
        topStackView.spacing = 8

        let button = RoundedButton()
        button.addTarget(self, action: #selector(buttonDidTouchUpInside), for: .touchUpInside)
        button.setTitle("Find Screenshots", for: .normal)

        let stackView = UIStackView(arrangedSubviews: [topStackView, button])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = view.frame.height / 4

        view.layer.addSublayer(gradient)

        view.addSubview(stackView)

        stackView.centerXAnchor ~~ view.centerXAnchor
        stackView.centerYAnchor ~~ view.centerYAnchor
    }

    @objc func buttonDidTouchUpInside() {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .notDetermined, .restricted, .denied:
                let alert = UIAlertController(title: "Photo Library Inaccessible", message: "Notchy couldn't read your photo library.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)

            case .authorized:
                let screenshotsAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumScreenshots, options: nil)
                let collection = screenshotsAlbum.object(at: 0)
                let layout = UICollectionViewFlowLayout()
                let gridViewController = GridViewController(collectionViewLayout: layout)
                gridViewController.fetchResult = PHAsset.fetchAssets(in: collection, options: nil)
                gridViewController.assetCollection = collection

                let navigation = UINavigationController(rootViewController: gridViewController)
                self.present(navigation, animated: false, completion: nil)
            }
        }
    }
}
