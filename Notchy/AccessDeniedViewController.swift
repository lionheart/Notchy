//
//  AccessDeniedViewController.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 11/11/17.
//  Copyright © 2017 Lionheart Software LLC. All rights reserved.
//

import UIKit
import SuperLayout
import Photos

final class AccessDeniedViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Photos access is required to use Notchy."
        label.numberOfLines = 0
        label.textAlignment = .center

        let button = RoundedButton(color: UIColor(0xE74C3B), textColor: .white, padding: 0)
        button.setTitle("Fix In Settings", for: .normal)
        button.addTarget(self, action: #selector(openSettingsButtonDidTouchUpInside(sender:)), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [label, button])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        stackView.centerXAnchor ~~ view.centerXAnchor
        stackView.centerYAnchor ~~ view.centerYAnchor
        stackView.widthAnchor ~~ view.widthAnchor * 0.6
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized, .notDetermined:
            let controller = RequestAccessViewController()
            present(controller, animated: false, completion: nil)

        case .denied: break
        case .restricted: break
        }
    }

    @objc func openSettingsButtonDidTouchUpInside(sender: Any) {
        let url = URL(string: UIApplicationOpenSettingsURLString)!
        UIApplication.shared.open(url, options: [:])
    }
}
