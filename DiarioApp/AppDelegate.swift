//
//  AppDelegate.swift
//  DiarioApp
//
//  Created by Carlos Alonso Mamani Ccollque on 14/06/25.
//

import UIKit
import Firebase
import FBSDKCoreKit
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        return true
    }

    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if ApplicationDelegate.shared.application(app, open: url, options: options) {
            return true
        }
        
        if GIDSignIn.sharedInstance.handle(url) {
            return true
        }

        return false
    }
}
