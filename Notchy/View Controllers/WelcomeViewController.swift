//
//  WelcomeViewController.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 11/10/17.
//  Copyright © 2017 Lionheart Software LLC. All rights reserved.
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
import QuickTableView
import LionheartExtensions
import SuperLayout
import Photos

final class WelcomeViewController: UIViewController {
    var selectScreenshotButton: ShortPlainAlternateButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(0x2a2f33)

        selectScreenshotButton = ShortPlainAlternateButton(normalTitle: "Import Screenshots", selectedTitle: "Import Screenshots")
        selectScreenshotButton.setTitle("Import Screenshots", for: .normal)
        selectScreenshotButton.addTarget(self, action: #selector(selectScreenshotButtonDidTouchUpInside(_:)), for: .touchUpInside)

        view.addSubview(selectScreenshotButton)

        selectScreenshotButton.centerXAnchor ~~ view.centerXAnchor
        selectScreenshotButton.centerYAnchor ~~ view.centerYAnchor
    }

    @objc func selectScreenshotButtonDidTouchUpInside(_ sender: Any) {
        PHPhotoLibrary.requestAuthorization { [unowned self] status in
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
