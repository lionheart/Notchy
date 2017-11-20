//
//  AppDelegate.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 11/6/17.
//  Copyright © 2017 Lionheart Software LLC. All rights reserved.
//

import UIKit
import Photos
import StoreKit
import SwiftyUserDefaults

extension UserDefaults {
    static var purchased: Bool {
        #if DEBUG
            return true
        #else
            return Defaults[.purchased]
        #endif
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        SKPaymentQueue.default().add(self)

        let controller: UIViewController
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            controller = GridViewController()

        // MARK: TODO
        case .denied, .notDetermined, .restricted:
            controller = WelcomeViewController()
        }

        let _window = UIWindow(frame: UIScreen.main.bounds)
        _window.rootViewController = NotchyNavigationController(rootViewController: controller)
        _window.makeKeyAndVisible()
        window = _window
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        SKPaymentQueue.default().remove(self)
    }
}

extension AppDelegate: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased, .restored:
                Defaults[.purchased] = true
                queue.finishTransaction(transaction)

            case .failed:
                queue.finishTransaction(transaction)

            case .deferred, .purchasing:
                // Don't do anything if purchase is in progress.
                break
            }
        }
    }
}
