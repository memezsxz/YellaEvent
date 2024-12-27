//
//  AuthenticationRegisterController.swift
//  YellaEvent
//
//  Created by Ahmed Ali on 24/12/2024.
//

import UIKit
import FirebaseAuth

class AuthenticationRegisterController: UIViewController {

    @IBOutlet weak var passwordValidationLbl: UILabel!
    @IBOutlet weak var emailValidationLbl: UILabel!
    @IBOutlet weak var dateOfBirthValidationLbl: UILabel!
    @IBOutlet weak var phoneNumberValidationLbl: UILabel!
    @IBOutlet weak var fullNameValidationLbl: UILabel!
    @IBOutlet weak var registerFullNameField: UITextField!
    
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var registerDob: UIDatePicker!
    @IBOutlet weak var registerPasswordField: UITextField!
    @IBOutlet weak var registerPhoneNumberField: UITextField!
    @IBOutlet weak var registerEmailField: UITextField!
 
    @IBOutlet weak var registerDateFieldText: UITextField!
    
    
    var currentDateOfBirth = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDatePicker()

        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        fullNameValidationLbl.isHidden = true
        fullNameValidationLbl.text = ""
        
        emailValidationLbl.isHidden = true
        emailValidationLbl.text = ""
        
        passwordValidationLbl.isHidden = true
        passwordValidationLbl.text = ""
        
        phoneNumberValidationLbl.isHidden = true
        phoneNumberValidationLbl.text = ""
        
        dateOfBirthValidationLbl.isHidden = true
        dateOfBirthValidationLbl.text = ""
    }
    
    
    private func setupDatePicker() {
            // Create a UIDatePicker
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            datePicker.preferredDatePickerStyle = .wheels // or .inline for newer styles
            datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
            
            // Assign datePicker to the inputView of the text field
        registerDateFieldText.inputView = datePicker
            
            // Add a toolbar with a Done button
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            
            let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePressed))
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            
            toolbar.setItems([flexibleSpace, doneButton], animated: true)
            
            // Assign toolbar to the inputAccessoryView of the text field
        registerDateFieldText.inputAccessoryView = toolbar
        }
        
        @objc private func dateChanged(_ sender: UIDatePicker) {
            // Format and display the selected date
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            currentDateOfBirth = sender.date
            registerDateFieldText.text = dateFormatter.string(from: sender.date)
        }
        
        @objc private func donePressed() {
            // Dismiss the picker
            registerDateFieldText.resignFirstResponder()
        }
    
    
    @IBAction func registerAccountAction(_ sender: Any) {
        var hasErrors = false

        
        // Validate Full Name
        if let fullName = registerFullNameField.text, fullName.isEmpty {
            fullNameValidationLbl.text = "Please enter your full name."
            fullNameValidationLbl.isHidden = false
            hasErrors = true
        } else {
            fullNameValidationLbl.text = ""
            fullNameValidationLbl.isHidden = true
        }

        // Validate Phone Number
        if let phoneNumber = registerPhoneNumberField.text {
            if phoneNumber.isEmpty {
                phoneNumberValidationLbl.text = "Please enter your phone number."
                phoneNumberValidationLbl.isHidden = false
                hasErrors = true
            } else if phoneNumber.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil {
                phoneNumberValidationLbl.text = "Phone number must contain only digits."
                phoneNumberValidationLbl.isHidden = false
                hasErrors = true
            } else if phoneNumber.count != 8 {
                phoneNumberValidationLbl.text = "Phone number must be exactly 8 digits."
                phoneNumberValidationLbl.isHidden = false
                hasErrors = true
            } else if !["3", "6", "7"].contains(phoneNumber.prefix(1)) {
                phoneNumberValidationLbl.text = "Phone number must start with 3, 6, or 7."
                phoneNumberValidationLbl.isHidden = false
                hasErrors = true
            } else {
                phoneNumberValidationLbl.text = ""
                phoneNumberValidationLbl.isHidden = true
            }
        } else {
            phoneNumberValidationLbl.text = "Please enter a valid phone number."
            phoneNumberValidationLbl.isHidden = false
            hasErrors = true
        }

        // Validate Date of Birth
        let dateOfBirth = currentDateOfBirth
        let minimumDate = Calendar.current.date(from: DateComponents(year: 2010, month: 1, day: 1))!
        if dateOfBirth >= minimumDate {
            dateOfBirthValidationLbl.text = "Date of birth must be before 2010."
            dateOfBirthValidationLbl.isHidden = false
            hasErrors = true
        } else {
            dateOfBirthValidationLbl.text = ""
            dateOfBirthValidationLbl.isHidden = true
        }

        // Validate Email
        if let email = registerEmailField.text, email.isEmpty {
            emailValidationLbl.text = "Please enter your email."
            emailValidationLbl.isHidden = false
            hasErrors = true
        } else if !isValidEmail(registerEmailField.text!) {
            emailValidationLbl.text = "Please enter a valid email address."
            emailValidationLbl.isHidden = false
            hasErrors = true
        } else {
            emailValidationLbl.text = ""
            emailValidationLbl.isHidden = true
        }

        // Validate Password
        if let password = registerPasswordField.text, password.isEmpty || password.count < 6 {
            passwordValidationLbl.text = "Please enter password with atleast 6 chars"
            passwordValidationLbl.isHidden = false
            hasErrors = true
        } else {
            passwordValidationLbl.text = ""
            passwordValidationLbl.isHidden = true
        }

        // Stop execution if there are validation errors
        if hasErrors {
            return
        }

        registerBtn.isEnabled = false
        registerBtn.setTitle("Registering", for: .normal)
        
        let emailNoSpace = registerEmailField.text?.replacingOccurrences(of: " ", with: "") ?? ""

        // Register user with Firebase Authentication
        Auth.auth().createUser(withEmail: emailNoSpace, password: registerPasswordField.text!) { [weak self] authResult, error in
            guard let self = self else { return }
            registerBtn.isEnabled = true
            registerBtn.setTitle("Join Us 🚀", for: .normal)

            if let error = error {
                let alertController = UIAlertController(
                    title: "Registration Failed",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
            }

            guard let firebaseUser = authResult?.user else { return }
            print("User registered successfully with UID: \(firebaseUser.uid)")

            self.saveUserIdInUserDefaults(firebaseUser.uid)

            let customer = Customer(
                userID: firebaseUser.uid,
                fullName: registerFullNameField.text!,
                email: registerEmailField.text!,
                dob: dateOfBirth,
                dateCreated: Date.now,
                phoneNumber: Int(registerPhoneNumberField.text!) ?? 0,
                profileImageURL: "",
                badgesArray: [],
                interestsArray: []
            )

            Task {
                do {
                    try await UsersManager.createNewUser(user: customer)
                    PushNotificationService.showNotification(title: "Welcome!", description: "We hope you enjoy the journey with Yalla Event!")
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
    
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func saveUserIdInUserDefaults(_ userId: String) {
        UserDefaults.standard.set(userId, forKey: K.bundleUserID)
        UserDefaults.standard.synchronize()
        print("User ID saved in UserDefaults under key: \(K.bundleUserID)")
    }
    
    func showAlert(message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion?()
        }))
        present(alert, animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
