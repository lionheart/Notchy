//
//  NotchyAlertViewController.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 11/15/17.
//  Copyright © 2017 Lionheart Software LLC. All rights reserved.
//

import UIKit
import SuperLayout

final class NotchyAlertViewController: UIViewController {
    var alertType: NotchyAlertViewType = .loading("Notching…")

    init(type: NotchyAlertViewType) {
        super.init(nibName: nil, bundle: nil)

        alertType = type
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let alertView = NotchyAlertView(type: alertType)

        view.addSubview(alertView)

        alertView.leadingAnchor ~~ view.leadingAnchor
        alertView.trailingAnchor ~~ view.trailingAnchor
        alertView.topAnchor ~~ view.topAnchor
        alertView.bottomAnchor ~~ view.bottomAnchor
    }
}
