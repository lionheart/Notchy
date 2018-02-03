//
//  ExtraStuffPresentationDelegate.swift
//  Notchy
//
//  Created by Dan Loewenherz on 2/3/18.
//  Copyright © 2018 Lionheart Software LLC. All rights reserved.
//

import Foundation
import Presentr

protocol ExtraStuffPresentationDelegate {
    var selectionFeedbackGenerator: UISelectionFeedbackGenerator { get }
    var extraStuffPresenter: Presentr { get }

    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)
}

extension ExtraStuffPresentationDelegate {
    func displayExtraStuffViewController() {
        selectionFeedbackGenerator.selectionChanged()

        let controller = ExtraStuffViewController()
        controller.transitioningDelegate = extraStuffPresenter
        controller.modalPresentationStyle = .custom
        present(controller, animated: true, completion: nil)
    }
}
