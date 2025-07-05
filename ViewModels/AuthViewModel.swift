//
//  AuthViewModel.swift
//  DiarioApp
//
//  Created by Carlos Alonso Mamani Ccollque on 13/06/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import FacebookLogin
import FirebaseCore
import GoogleSignInSwift

class AuthViewModel: ObservableObject {
    @Published var user: User? = Auth.auth().currentUser
    @Published var appSettings: AppSettings = AppSettings()

    // MARK: - Login con correo
    func signInWithEmail(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            self.user = result?.user
            if self.user != nil {
                self.cargarEstiloDelUsuario()
            }
            completion(error)
        }
    }

    // MARK: - Registro con correo
    func registerWithEmail(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            self.user = result?.user
            if let user = self.user {
                self.guardarEstiloInicial(uid: user.uid)
            }
            completion(error)
        }
    }

    // MARK: - Cerrar sesión
    func signOut() {
        try? Auth.auth().signOut()
        self.user = nil
    }

    // MARK: - Google Login
    func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else { return }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                print("Error en Google Sign-In: \(error.localizedDescription)")
                return
            }

            guard let user = result?.user, let idToken = user.idToken?.tokenString else { return }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)

            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    print("Error autenticando con Firebase: \(error.localizedDescription)")
                } else {
                    self.user = result?.user
                    self.cargarEstiloDelUsuario()
                    print("✅ Inicio de sesión exitoso con Google")
                }
            }
        }
    }

    // MARK: - Facebook Login
    func signInWithFacebook() {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["email"], from: nil) { result, error in
            if let error = error {
                print("Error Facebook Login: \(error.localizedDescription)")
                return
            }

            guard let accessToken = AccessToken.current else { return }

            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)

            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    print("Error Firebase con Facebook: \(error.localizedDescription)")
                } else {
                    self.user = result?.user
                    self.cargarEstiloDelUsuario()
                }
            }
        }
    }

    // MARK: - Estilo: Guardar inicial
    private func guardarEstiloInicial(uid: String) {
        let data: [String: Any] = [
            "colorTema": appSettings.colorTema.toHex ?? "#B1B3FB",
            "fuente": appSettings.fuente,
            "tamanoFuente": Double(appSettings.tamanoFuente)
        ]
        Firestore.firestore().collection("usuarios").document(uid).setData(data)
    }

    // MARK: - Estilo: Cargar
    func cargarEstiloDelUsuario() {
        guard let uid = user?.uid else { return }
        Firestore.firestore().collection("usuarios").document(uid).getDocument { snapshot, error in
            if let data = snapshot?.data() {
                if let hex = data["colorTema"] as? String {
                    self.appSettings.colorTema = Color(hex: hex)
                }
                if let fuente = data["fuente"] as? String {
                    self.appSettings.fuente = fuente
                }
                if let tamano = data["tamanoFuente"] as? Double {
                    self.appSettings.tamanoFuente = CGFloat(tamano)
                }
            }
        }
    }

    // MARK: - Estilo: Guardar cambios
    func guardarEstiloActual() {
        guard let uid = user?.uid else { return }
        let data: [String: Any] = [
            "colorTema": appSettings.colorTema.toHex ?? "#B1B3FB",
            "fuente": appSettings.fuente,
            "tamanoFuente": Double(appSettings.tamanoFuente)
        ]
        Firestore.firestore().collection("usuarios").document(uid).setData(data, merge: true)
    }
}
