//
//  AppDelegate.swift
//  Notchy
//
//  Created by Daniel Loewenherz on 11/6/17.
//  Copyright © 2017 Lionheart Software LLC. All rights reserved.
//

import UIKit
import Photos

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let _window = UIWindow(frame: UIScreen.main.bounds)
        let navigation = UINavigationController(rootViewController: RequestAccessViewController())
        _window.rootViewController = navigation
        _window.makeKeyAndVisible()
        window = _window
        return true
    }
}

