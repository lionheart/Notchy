//
//  ExtraStuffViewController.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 11/16/17.
//  Copyright © 2017 Lionheart Software LLC. All rights reserved.
//

import UIKit
import SuperLayout
import StoreKit

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

extension ExtraStuffViewController: SKProductsRequestDelegate {
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print(error.localizedDescription)
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        product = response.products.first
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
                extraStuffView.transactionCompleted()

            case .failed:
                queue.finishTransaction(transaction)
                extraStuffView.transactionCompleted()

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

extension ExtraStuffViewController: ExtraStuffViewDelegate {
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
