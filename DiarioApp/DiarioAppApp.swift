//
//  DiarioAppApp.swift
//  DiarioApp
//
//  Created by Carlos Alonso Mamani Ccollque on 10/06/25.
//

import SwiftUI
import Firebase

@main
struct DiarioAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authVM = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                SplashView()
            }
            .environmentObject(authVM)
            .environmentObject(authVM.appSettings)
        }
    }
}
