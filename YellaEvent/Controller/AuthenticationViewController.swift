//
//  AuthenticationViewController.swift
//  YellaEvent
//
//  Created by meme on 25/11/2024.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import FirebaseCore
import FirebaseFirestore

class AuthenticationViewController: UIViewController {
    @IBOutlet weak var signInThroughGoogle: UIButton!
    
    @IBOutlet weak var forgotPasswordEmailField: UITextField!
    @IBOutlet weak var loginPasswordField: UITextField!
    @IBOutlet weak var loginEmailField: UITextField!
    
    @IBOutlet weak var registerFullNameField: UITextField!
    
    @IBOutlet weak var registerPasswordField: UITextField!
    @IBOutlet weak var registerPhoneNumberField: UITextField!
    @IBOutlet weak var registerDateOfBirthField: UITextField!
    @IBOutlet weak var registerEmailField: UITextField!
    @IBAction func signInThroughGoogleAction(_ sender: Any) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("Failed to retrieve Firebase clientID")
            return
        }

        // Configure Google Sign-In
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Start the Google Sign-In flow
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            if let error = error {
                print("Error during Google Sign-In: \(error.localizedDescription)")
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                print("Error retrieving Google user or ID token.")
                return
            }

            // Create a Firebase credential using the Google ID token
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )

            // Authenticate with Firebase using the credential
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase authentication failed: \(error.localizedDescription)")
                    return
                }

                // Successful sign-in
                if let user = authResult?.user {
                                 print("User signed in with Google: \(user.email ?? "No email")")
                                 self.saveUserIdInUserDefaults(user.uid)
                             }

            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    
    func showAlert(message: String, completion: (() -> Void)? = nil) {
         let alert = UIAlertController(title: "Login", message: message, preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
             completion?()
         }))
         present(alert, animated: true, completion: nil)
     }
    
    
    @IBAction func normalLoginAction(_ sender: Any) {
        guard let email = loginEmailField.text, !email.isEmpty else {
            showAlert(message: "Please enter your email.")
            return
        }
        
        guard let password = loginPasswordField.text, !password.isEmpty else {
            showAlert(message: "Please enter your password.")
            return
        }
        
        // Login with Firebase Auth
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error {
                // Handle error
                self.showAlert(message: "Login failed: \(error.localizedDescription)")
                return
            }
            
            // Successful login
            if let user = authResult?.user {
                print("Login successful for user: \(user.email ?? "Unknown email")")
                self.saveUserIdInUserDefaults(user.uid)
                let db = Firestore.firestore()
                
                // Check if user exists in the 'admins' collection
                db.collection("admins").document(user.uid).getDocument { [weak self] document, error in
                    guard let self = self else { return }
                    
                    if let document = document, document.exists {
                        // Navigate to Admin screen
                        self.performSegue(withIdentifier: "goToAdmin", sender: self)
                    } else {
                        // Check if user exists in the 'organizers' collection
                        db.collection("organizers").document(user.uid).getDocument { [weak self] document, error in
                            guard let self = self else { return }
                            
                            if let document = document, document.exists {
                                // Navigate to Organizer screen
                                self.performSegue(withIdentifier: "goToOrganizer", sender: self)
                            } else {
                                // Navigate to Normal User screen
                                self.performSegue(withIdentifier: "goToCustomer", sender: self)
                            }
                        }
                    }
                }
            }
        }
    }
    @IBAction func registerAccountAction(_ sender: Any) {
        guard let fullName = registerFullNameField.text, !fullName.isEmpty else {
            showAlert(message: "Please enter your full name.")
            return
        }
        
        guard let email = registerEmailField.text, !email.isEmpty else {
            showAlert(message: "Please enter your email.")
            return
        }
        
        guard let password = registerPasswordField.text, !password.isEmpty, password.count >= 6 else {
            showAlert(message: "Please enter a password with at least 6 characters.")
            return
        }
        
        guard let phoneNumber = registerPhoneNumberField.text, !phoneNumber.isEmpty else {
            showAlert(message: "Please enter your phone number.")
            return
        }
        
        guard let dateOfBirth = registerDateOfBirthField.text, !dateOfBirth.isEmpty else {
            showAlert(message: "Please enter your date of birth.")
            return
        }
        
        // Register user with Firebase Authentication
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(message: "Registration failed: \(error.localizedDescription)")
                return
            }
            
            guard let user = authResult?.user else { return }
            print("User registered successfully with UID: \(user.uid)")
            
            self.saveUserIdInUserDefaults(user.uid)
            
            // Save additional user details to Firestore
            let db = Firestore.firestore()
            let userData: [String: Any] = [
                "fullName": fullName,
                "email": email,
                "phoneNumber": phoneNumber,
                "dateOfBirth": dateOfBirth,
                "uid": user.uid,
                "type": "customer",
                "dateCreated": FieldValue.serverTimestamp()
            ]
            
            db.collection("customers").document(user.uid).setData(userData) { error in
                if let error = error {
                    self.showAlert(message: "Failed to save user data: \(error.localizedDescription)")
                } else {
                    self.showAlert(message: "Account created successfully!") {

                    }
                }
            }
        }
    }
    
    
    func saveUserIdInUserDefaults(_ userId: String) {
        UserDefaults.standard.set(userId, forKey: K.bundleUserID)
        UserDefaults.standard.synchronize()
        print("User ID saved in UserDefaults under key: \(K.bundleUserID)")
    }
    @IBAction func createForgetPasswordAction(_ sender: Any) {
        
        guard let email = forgotPasswordEmailField.text, !email.isEmpty else {
            showAlert(message: "Please enter your email.")
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
        
                self.showAlert( message: error.localizedDescription)
                return
            }
            
        
            self.showAlert(message: "A password reset link has been sent to \(email).")
        }
    }
}
