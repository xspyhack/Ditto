//
//  AppDelegate.swift
//  Example
//
//  Created by alex.huo on 2019/2/19.
//  Copyright © 2019 blessingsoft. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Router.register()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController")
        window?.rootViewController = UINavigationController(rootViewController: rootViewController)
        Router.shared.appCoordinator = AppCoodinator(rootViewController: rootViewController)
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if Router.schemes.contains(url.scheme ?? "") {
            return Router.route(to: url, isFromLaunching: true)
        } else {
            return false
        }
    }
}

