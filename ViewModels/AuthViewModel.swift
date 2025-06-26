//
//  AuthViewModel.swift
//  DiarioApp
//
//  Created by Carlos Alonso Mamani Ccollque on 13/06/25.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import FacebookLogin
import FirebaseCore
import GoogleSignInSwift

class AuthViewModel: ObservableObject {
    @Published var user: User? = Auth.auth().currentUser

    // Login con correo
    func signInWithEmail(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            self.user = result?.user
            completion(error)
        }
    }

    // Registro con correo
    func registerWithEmail(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            self.user = result?.user
            completion(error)
        }
    }

    // Cerrar sesión
    func signOut() {
        try? Auth.auth().signOut()
        self.user = nil
    }

    // ✅ Iniciar sesión con Google
    func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("No se pudo obtener el rootViewController")
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                print("Error en Google Sign-In: \(error.localizedDescription)")
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                print("No se pudo obtener token de Google")
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)

            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    print("Error autenticando con Firebase: \(error.localizedDescription)")
                } else {
                    self.user = result?.user
                    print("✅ Inicio de sesión exitoso con Google")
                }
            }
        }
    }

    // ✅ Iniciar sesión con Facebook
    func signInWithFacebook() {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["email"], from: nil) { result, error in
            if let error = error {
                print("Error Facebook Login: \(error.localizedDescription)")
                return
            }

            guard let accessToken = AccessToken.current else {
                print("Token de acceso de Facebook no disponible")
                return
            }

            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)

            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    print("Error Firebase con Facebook: \(error.localizedDescription)")
                } else {
                    self.user = result?.user
                }
            }
        }
    }
}

