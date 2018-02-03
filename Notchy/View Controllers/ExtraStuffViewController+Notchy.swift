//
//  ExtraStuffViewController+Notchy.swift
//  Notchy
//
//  Created by Dan Loewenherz on 2/3/18.
//  Copyright © 2018 Lionheart Software LLC. All rights reserved.
//

import Foundation
import StoreKit

// MARK: - ExtraStuffViewDelegate
extension ExtraStuffViewController: ExtraStuffViewDelegate {
    func thanksButtonDidTouchUpInside(_ sender: Any) {
        dismiss(animated: true)
    }
    
    func getStuffButtonDidTouchUpInside(_ sender: Any) {
        guard let product = product else {
            return
        }
        
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func restoreButtonDidTouchUpInside(_ sender: Any) {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}
