//
//  ExtraStuffViewController+Action.swift
//  Action Extension
//
//  Created by Dan Loewenherz on 2/3/18.
//  Copyright © 2018 Lionheart Software LLC. All rights reserved.
//

import Foundation
import StoreKit

let notchyURL = URL(string: "notchy://iap")!

// MARK: - ExtraStuffViewDelegate
extension ExtraStuffViewController: ExtraStuffViewDelegate {
    func thanksButtonDidTouchUpInside(_ sender: Any) {
        dismiss(animated: true)
    }
    
    func getStuffButtonDidTouchUpInside(_ sender: Any) {
        openURL(notchyURL)
        dismiss(animated: false)
    }
    
    func restoreButtonDidTouchUpInside(_ sender: Any) {
        openURL(notchyURL)
        dismiss(animated: false)
    }
}
