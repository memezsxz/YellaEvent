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
    
    @IBOutlet weak var forgotBtn: UIButton!
    @IBOutlet weak var loginPasswordValidationLbl: UILabel!
    
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var forgotEmailValidationLbl: UILabel!
    @IBOutlet weak var loginEmailValidationLbl: UILabel!
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
               if let firebaseUser = authResult?.user {
                   print("User signed in with Google: \(firebaseUser.email ?? "No email")")
            
                   // Check if the user is banned
                   Task {
                       do {
                           let isNotBanned = try await UsersManager.isUserBanned(userID: firebaseUser.uid)
                           if !isNotBanned {
                               // Show banned user message and sign out
                               let alertController = UIAlertController(
                                   title: "Account Banned",
                                   message: "Your account has been banned. Please contact support.",
                                   preferredStyle: .alert
                               )
                               alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                               self.present(alertController, animated: true, completion: nil)
                               try? Auth.auth().signOut()
                               return
                           }
                           
                           self.saveUserIdInUserDefaults(firebaseUser.uid)
                           
                           let db = Firestore.firestore()
                           
                           // Check if user exists in the 'admins' collection
                           db.collection("admins").document(firebaseUser.uid).getDocument { [weak self] document, error in
                               guard let self = self else { return }
                               
                               if let document = document, document.exists {
                                   // Navigate to Admin screen
                                   self.performSegue(withIdentifier: "goToAdmin", sender: self)
                               } else {
                                   // Check if user exists in the 'organizers' collection
                                   db.collection("organizers").document(firebaseUser.uid).getDocument { [weak self] document, error in
                                       guard let self = self else { return }
                                       
                                       if let document = document, document.exists {
                                           // Navigate to Organizer screen
                                           self.performSegue(withIdentifier: "goToOrganizer", sender: self)
                                       } else {
                                           // Check if user exists in the 'customers' collection
                                           print(firebaseUser)
                                           db.collection("customers").document(firebaseUser.uid).getDocument { [weak self] document, error in
                                               guard let self = self else { return }
                                               
                                               if let document = document, document.exists {
                                                   // Navigate to Normal User screen
                                                   self.performSegue(withIdentifier: "goToCustomer", sender: self)
                                               } else {
                                                   // Create a new account for the user
                                                   let customer = Customer(
                                                       userID: firebaseUser.uid,
                                                       fullName: user.profile?.name ?? "No Name",
                                                       email: user.profile?.email ?? "No email",
                                                       dob: Date(), // Default DOB if not available
                                                       dateCreated: Date.now,
                                                       phoneNumber:  00, // Default phone number if not available
                                                       profileImageURL: user.profile?.imageURL(withDimension: 200)?.absoluteString ?? "",
                                                       badgesArray: [],
                                                       interestsArray: []
                                                   )
                                                   
                                                   Task {
                                                       do {
                                                           try await UsersManager.createNewUser(user: customer)
                                                           // Navigate to Interest Picker
                                                           self.performSegue(withIdentifier: "goToInterestPicker", sender: self)
                                                       } catch {
                                                           let alertController = UIAlertController(
                                                               title: "Error",
                                                               message: "Failed to create user: \(error.localizedDescription)",
                                                               preferredStyle: .alert
                                                           )
                                                           alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                                           self.present(alertController, animated: true, completion: nil)
                                                       }
                                                   }
                                               }
                                           }
                                       }
                                   }
                               }
                           }
                       } catch {
                           let alertController = UIAlertController(
                               title: "Error",
                               message: "An error occurred while checking ban status: \(error.localizedDescription)",
                               preferredStyle: .alert
                           )
                           alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                           self.present(alertController, animated: true, completion: nil)
                       }
                   }
               }
           }
       }

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (loginEmailValidationLbl != nil) {
            loginEmailValidationLbl.isHidden = true
            loginEmailValidationLbl.text = ""
            loginPasswordValidationLbl.isHidden = true
            loginPasswordValidationLbl.text = ""
        }
        
        if(forgotEmailValidationLbl != nil){
            forgotEmailValidationLbl.text = ""
            forgotEmailValidationLbl.isHidden = true
        }
    }
    
    
    func showAlert(message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion?()
        }))
        present(alert, animated: true, completion: nil)
    }
    

    
    
    @IBAction func normalLoginAction(_ sender: Any) {
        var hasErrors = false

        // Validate Email
        if let email = loginEmailField.text, !isValidEmail(email), email.isEmpty {
            loginEmailValidationLbl.text = "Please enter a valid email."
            loginEmailValidationLbl.isHidden = false
            hasErrors = true
        } else {
            loginEmailValidationLbl.text = ""
            loginEmailValidationLbl.isHidden = true
        }

        // Validate Password
        if let password = loginPasswordField.text, password.isEmpty {
            loginPasswordValidationLbl.text = "Please enter your password."
            loginPasswordValidationLbl.isHidden = false
            hasErrors = true
        } else {
            loginPasswordValidationLbl.text = ""
            loginPasswordValidationLbl.isHidden = true
        }

        // Stop execution if there are validation errors
        if hasErrors {
            return
        }

        loginBtn.isEnabled = false
        signInThroughGoogle.isEnabled = false
        loginBtn.setTitle("Loading", for: .normal)

        // Login with Firebase Auth
        Auth.auth().signIn(withEmail: loginEmailField.text!, password: loginPasswordField.text!) { [weak self] authResult, error in
            guard let self = self else { return }
            
            loginBtn.isEnabled = true
            loginBtn.setTitle("Login", for: .normal)
            signInThroughGoogle.isEnabled = true

            if let error = error {
                // Handle error
                self.showAlert(message: "Login failed: \(error.localizedDescription)")
                return
            }

            // Successful login
            if let user = authResult?.user {
                print("Login successful for user: \(user.email ?? "Unknown email")")

                // Check if user is banned
                Task {
                    do {
                        let isNotBanned = try await UsersManager.isUserBanned(userID: user.uid)
                        if !isNotBanned {
                            // Show banned user message and sign out
                            self.showAlert(message: "Your account has been banned. Please contact support.")
                            try? Auth.auth().signOut()
                            return
                        }

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
                    } catch {
                        // Handle error
                        self.showAlert(message: "An error occurred while checking ban status: \(error.localizedDescription)")
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
        forgotEmailValidationLbl.isHidden = true
        forgotEmailValidationLbl.text = ""
    
        guard let email = forgotPasswordEmailField.text, !email.isEmpty else {
            forgotEmailValidationLbl.isHidden = false
            forgotEmailValidationLbl.text = "Please enter your email"
            return
        }

        guard isValidEmail(email) else {
            forgotEmailValidationLbl.isHidden = false
            forgotEmailValidationLbl.text = "Please enter a valid email"
            return
        }
        forgotBtn.isEnabled = false
        forgotBtn.setTitle("Loading", for: .normal)
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            self.forgotBtn.isEnabled = true
            self.forgotBtn.setTitle("Forgot Password", for: .normal)
            if let error = error {
                
                self.showAlert(message: error.localizedDescription)
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
