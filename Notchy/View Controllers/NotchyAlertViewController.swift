//
//  NotchyAlertViewController.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 11/15/17.
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
import SuperLayout
import Presentr

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

// MARK: - Presentable
extension NotchyAlertViewController: Presentable {
    static func presenter(view: UIView) -> Presentr {
        let size = ModalSize.custom(size: 120)
        let center = ModalCenterPosition.center
        let presenter = Presentr(presentationType: .custom(width: size, height: size, center: center))
        let animation = NotchyAlertAnimation(duration: 0.5)
        presenter.backgroundOpacity = 0
        presenter.transitionType = .custom(animation)
        presenter.dismissTransitionType = .custom(animation)
        return presenter
    }
}
