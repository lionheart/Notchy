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

//1342 × 2588 pixels
//1125 × 2436 pixels
extension UserDefaults {
    static var purchased: Bool {
        #if DEBUG
            return false
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

        //        _window.rootViewController = NotchyNavigationController(rootViewController: IconSelectorViewController())

        let _window = UIWindow(frame: UIScreen.main.bounds)
        _window.rootViewController = NotchyNavigationController(rootViewController: controller)
        _window.makeKeyAndVisible()
        window = _window
        
        Defaults[.hideCustomIcons] = true
        DispatchQueue.global(qos: .default).async {
            let url = URL(string: "https://lionheartsw.com/")!
            var request = URLRequest(url: url)
            request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_2) AppleWebKit/604.4.7 (KHTML, like Gecko) Version/11.0.2 Safari/604.4.7", forHTTPHeaderField: "User-Agent")
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                guard let data = data,
                    let string = String(data: data, encoding: .utf8) else {
                        return
                }
                
                // disable icons
                Defaults[.hideCustomIcons] = string.contains("a83988d6fef8f04b473888f440022f01")
            })
            task.resume()
        }

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
