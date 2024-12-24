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
    
    @IBOutlet var intrestsCollection: InterestsCollectionView!
    @IBOutlet weak var signInThroughGoogle: UIButton!
    

    @IBOutlet weak var forgotPasswordEmailField: UITextField!
    @IBOutlet weak var loginPasswordField: UITextField!
    @IBOutlet weak var loginEmailField: UITextField!
    
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
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    func showAlert(message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
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
    @IBAction func confirmInterestsAction(_ sender: Any) {
        let interests = intrestsCollection.getInterests()
        
        if interests.count <= 0 {
            self.showAlert(message: "Please pick atleast one interest")
        }

        Task {
            let interestData: [String: Any] = [K.FStore.Customers.intrestArray: interests]

            try await Firestore.firestore()
                .collection(K.FStore.Customers.collectionName)
                .document(UserDefaults.standard.string(forKey: K.bundleUserID)!)
                .updateData(interestData)

            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "goToHomeThroughInterest", sender: self)
            }
        }
    }
}
