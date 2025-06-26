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
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            NavigationView {
                if showSplash {
                    SplashView()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                showSplash = false
                            }
                        }
                } else {
                    if let user = authVM.user {
                        HomeView()
                    } else {
                        InicioView()
                    }
                }
            }
            .environmentObject(authVM)
        }
    }
}

