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
    var selectScreenshotButton: ShortPlainAlternateButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        selectScreenshotButton = ShortPlainAlternateButton()
        selectScreenshotButton.setTitle("Select Screenshot", for: .normal)
        selectScreenshotButton.addTarget(self, action: #selector(selectScreenshotButtonDidTouchUpInside(_:)), for: .touchUpInside)

        view.addSubview(selectScreenshotButton)

        selectScreenshotButton.centerXAnchor ~~ view.centerXAnchor
        selectScreenshotButton.centerYAnchor ~~ view.centerYAnchor
    }

    @objc func selectScreenshotButtonDidTouchUpInside(_ sender: Any) {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .notDetermined, .restricted, .denied:
                let alert = UIAlertController(title: "Photo Library Inaccessible", message: "Notchy couldn't read your photo library.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)

            case .authorized:
                let navigation = NotchyNavigationController(rootViewController: GridViewController())
                self.present(navigation, animated: true, completion: nil)
            }
        }
    }
}
