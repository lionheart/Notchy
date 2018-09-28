//
//  AppDelegate.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 11/6/17.
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
import Photos
import StoreKit
import LionheartExtensions
import SwiftyUserDefaults
import Presentr

let Defaults = UserDefaults(suiteName: "group.com.lionheartsw.notchy")!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        SKPaymentQueue.default().add(self)
        
        print(UIScreen.main.bounds)

        let controller: UIViewController
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            controller = GridViewController()

        // MARK: TODO
        case .denied, .notDetermined, .restricted:
            controller = WelcomeViewController()
        }

        //        _window.rootViewController = NotchyNavigationController(rootViewController: IconSelectorViewController())

        let _window = UIWindow(frame: UIScreen.main.bounds)
        _window.rootViewController = NotchyNavigationController(rootViewController: controller)
        _window.makeKeyAndVisible()
        window = _window
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
//        print(url)
//        if let data = Data(base64Encoded: url.lastPathComponent),
//            let json = try? JSONSerialization.jsonObject(with: data, options: []) {
//            print(json)
//        }
        guard let parent = UIViewController.topViewController as? ExtraStuffPresentationDelegate else {
            return false
        }
        
        parent.displayExtraStuffViewController()
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        SKPaymentQueue.default().remove(self)
    }
}

// MARK: - SKPaymentTransactionObserver
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
