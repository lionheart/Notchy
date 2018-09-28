//
//  ExtraStuffViewController.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 11/16/17.
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
import StoreKit
import SwiftyUserDefaults
import Presentr

final class ExtraStuffViewController: UIViewController {
    var product: SKProduct?
    var extraStuffView: ExtraStuffView!

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let productsRequest = SKProductsRequest(productIdentifiers: Set(["ExtraStuff"]))
        productsRequest.delegate = self
        productsRequest.start()

        extraStuffView = ExtraStuffView(delegate: self)

        view.addSubview(extraStuffView)

        extraStuffView.leadingAnchor ~~ view.leadingAnchor
        extraStuffView.trailingAnchor ~~ view.trailingAnchor
        extraStuffView.topAnchor ~~ view.topAnchor
        extraStuffView.bottomAnchor ~~ view.bottomAnchor
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        SKPaymentQueue.default().add(self)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        SKPaymentQueue.default().remove(self)
    }
}

// MARK: - SKProductsRequestDelegate
extension ExtraStuffViewController: SKProductsRequestDelegate {
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print(error.localizedDescription)
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        product = response.products.first
        
        guard let product = product else {
            return
        }

        let currencyFormatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = product.priceLocale
            formatter.maximumFractionDigits = 2
            return formatter
        }()
        
        extraStuffView.productPrice = currencyFormatter.string(from: product.price)
    }
}

// MARK: - SKPaymentTransactionObserver
extension ExtraStuffViewController: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased, .restored:
                // Finish the transaction if deferred, purchased, or restored
                queue.finishTransaction(transaction)
                extraStuffView.transactionCompleted(status: .success)
                Defaults[.purchased] = true

                let alert = UIAlertController(title: "Thanks!", message: "Thanks for your purchase.", preferredStyle: .alert)
                present(alert, animated: true) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                        alert.dismiss(animated: true)
                    }
                }

            case .failed:
                queue.finishTransaction(transaction)
                extraStuffView.transactionCompleted(status: .failure)

                guard let error = transaction.error as? SKError else {
                    return
                }

                let message: String
                switch error {
                case SKError.unknown:
                    // This error occurs if running on the simulator.
                    message = error.localizedDescription

                case SKError.clientInvalid:
                    message = "This client is unauthorized to make in-app purchases."

                default:
                    message = error.localizedDescription
                }

                let alert = UIAlertController(title: "Purchase Error", message: message, preferredStyle: .alert)
                alert.addAction(title: "OK", style: .default, handler: nil)
                present(alert, animated: true)

            case .deferred, .purchasing:
                break
            }
        }
    }

    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        return true
    }
}

// MARK: - Presentable
extension ExtraStuffViewController: Presentable {
    static func presenter(view: UIView) -> Presentr {
        let width = ModalSize.custom(size: Float(view.frame.width * 0.7))
        let height = ModalSize.custom(size: 350)
        let center = ModalCenterPosition.custom(centerPoint: view.center)

        let presenter = Presentr(presentationType: .custom(width: width, height: height, center: center))

        presenter.backgroundOpacity = 0.5
        presenter.transitionType = TransitionType.crossDissolve
        presenter.dismissTransitionType = TransitionType.crossDissolve
        
        return presenter
    }
}
