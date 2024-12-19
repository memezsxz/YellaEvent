//
//  AdminProfileViewController.swift
//  YellaEvent
//
//  Created by meme on 25/11/2024.
//

import UIKit
import FirebaseAuth

class AdminProfileViewController: UIViewController {
    
    
    var currentUser: Admin?
    var imageUpdated : Bool = false
    
// the profile tab outlet
    @IBOutlet var roundedViews: [UIView]!
    @IBOutlet weak var BigImageProfile: UIImageView!
    
    
// Edit Profile Page section
    //Outlet Fields
    @IBOutlet weak var txtFullName: UITextField!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var editProfileImage: UIImageView!
    
    
    
    //Outlet Errors
    @IBOutlet weak var lblErrorFullName: UILabel!
    @IBOutlet weak var lblErrorPhoneNumber: UILabel!
    @IBOutlet weak var lblErrorEmail: UILabel!
   
    //Actions
    @IBAction func EditImageButtonTapped(_ sender: Any) {
        changeTheUserImage(sender)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        saveUserChanges(sender)
    }
    
    @IBAction func changePassword(_ sender: Any) {
        
        guard let email = txtEmail.text, !email.isEmpty else {
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
    
    
    
    
    @IBOutlet weak var bigUserName: UILabel!
    @IBOutlet weak var bigUserType: UIButton!

    
    
    
    
    
    override func viewDidLoad(){
        super.viewDidLoad()

        setupEditPage()
        UserDefaults.standard.set("zxnzNnd9FK8xcnATlYUh", forKey: K.bundleUserID) // this will be removed after seting the application

        setup()

    }
    
    func setup() {
        // get the current user object
        Task {
            let us = try await UsersManager.getUser(userID: UserDefaults.standard.string(forKey: K.bundleUserID)!)
            currentUser = (us as! Admin)
            do{
                if let text = bigUserName{
                    bigUserName.text = currentUser?.fullName
                    bigUserType.titleLabel!.text = "Admin"
                }
            }catch{
                print("check")
            }
            
           
                PhotoManager.shared.downloadImage(from: URL(string: currentUser!.profileImageURL)!, completion: { result in
                    
                    switch result {
                    case .success(let image):
                        self.BigImageProfile?.image = image
                    case .failure(_):
                        self.BigImageProfile?.image = UIImage(named: "DefaultImageProfile")
                    }
                    
                })
            
        }
            
            //download the current user image
       
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        // method to set the edit user profile page
        setup()

    }
    
    

}

//Admin Profile Page Functions
extension AdminProfileViewController{
    
    // method set the user profile fields with user information
    func setupEditPage(){
        // get the current user object
        Task {
            do {
                
                let userId: String = UserDefaults.standard.string(forKey: K.bundleUserID)!
                let us = try await UsersManager.getUser(userID: userId)
                
                txtFullName?.text = "\(us.fullName)"
                txtEmail?.text = us.email
                txtPhoneNumber?.text = "\(us.phoneNumber)"
                
//                txtPhoneNumber?.text = String(us.phoneNumber)
                if !(us.profileImageURL.isEmpty){
                    
                    PhotoManager.shared.downloadImage(from: URL(string: us.profileImageURL)!, completion: { result in
                        
                        switch result {
                        case .success(let image):
                            self.editProfileImage?.image = image
                        case .failure(_):
                            self.editProfileImage?.image = UIImage(named: "DefaultImageProfile")
                        }
                        
                    })
                }
    
                

                
            } catch {
                print("Failed to fetch user: \(error)")
                // Handle error appropriately, such as showing an alert to the user
            }
        }
        
    }
    //function to make the provided list of views circle
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let shape = roundedViews {
            for view in shape{
                view.layer.cornerRadius = view.frame.height / 2
                view.clipsToBounds = true
            }
        }
            
        
    }
    
}// End of the class




// Admin edit profile page functions
extension AdminProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func changeTheUserImage(_ sender: Any){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let menue = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        menue.addAction(cancelAction)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            }
            
            menue.addAction(cameraAction)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            
            let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { _ in
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
            }
            
            menue.addAction(photoLibraryAction)
        }
        
        
        
        
        
        menue.popoverPresentationController?.sourceView = sender as? UIView
        present(menue, animated: true)
        
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {return}
        
        editProfileImage.image = selectedImage
        
        dismiss(animated: true, completion: nil)
    }
    
    
    
    // if the user click cancel run this method
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        //1. close the screen
        dismiss(animated: true, completion: nil)
    }
    
    
    //function to save th user changes an do some validation
    func saveUserChanges(_ sender: Any) {
        
        // 1. Validate inputs
        guard validateFields() else {
            // Exit if validation fails
            return
        }
        
        // 2. Proceed to save changes if validation passes
        do{
            currentUser?.email = txtEmail.text!
            currentUser?.fullName = txtFullName.text!
            currentUser?.phoneNumber = Int(txtPhoneNumber.text!)!
            if let image = editProfileImage.image, imageUpdated {
                PhotoManager.shared.uploadPhoto(image, to: "admins/\(currentUser!.userID)", withNewName: "profile") { result in
                    switch result {
                    case .success(let url):
                        
                        
                        // TODO: Update in user
                        
                        print("Image uploaded successfully: \(url)")
                        self.currentUser?.profileImageURL = url
                        self.imageUpdated = false
                        
                    case .failure( _):
                        let saveAlert = UIAlertController(
                            title: "Error",
                            message: "Error uploading image",
                            preferredStyle: .alert
                        )
                        
                        let okAction = UIAlertAction(title: "OK", style: .default) { action in
                //
                            self.navigationController?.popViewController(animated: true)
                        }
                        
                        saveAlert.addAction(okAction)
                        
                        self.present(saveAlert, animated: true, completion: nil)
                    }
                }
            }

            Task{
                try await UsersManager.updateUser(user: currentUser!)
            }
            
        
        }catch {
            print("error with user saving data")
        }
        
        
           
        // 3. Show an alert notifying the user that the changes have been saved
        let saveAlert = UIAlertController(
            title: "Save Changes",
            message: "Your changes have been saved successfully.",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
            
            self.navigationController?.popToRootViewController(animated: true)
        }
        
        saveAlert.addAction(okAction)
        present(saveAlert, animated: true, completion: nil)
    
    }
}






// extention for filds validations --> inclide the function that related to the validation
extension AdminProfileViewController{
    
    func validateFields() -> Bool {
        var isValid = true
        var errorMessage = ""


        // Validate txtFullName (Only letters)
        if let fullName = txtFullName?.text, fullName.isEmpty {
            lblErrorFullName.text = "Full name is required."
            highlightField(txtFullName)
            isValid = false
            errorMessage = "Please fill in all required fields correctly."
        } else if let fullName = txtFullName?.text, !isValidFullName(fullName) {
            lblErrorFullName.text = "Full name must contain only letters."
            highlightField(txtFullName)
            isValid = false
            errorMessage = "Please fill in all required fields correctly."
        } else {
            lblErrorFullName.text = ""
            resetFieldHighlight(txtFullName)
        }

        // Validate txtPhoneNumber (Only numbers)
        if let phoneNumber = txtPhoneNumber?.text, phoneNumber.isEmpty {
            lblErrorPhoneNumber.text = "Phone number is required."
            highlightField(txtPhoneNumber)
            isValid = false
            errorMessage = "Please fill in all required fields correctly."
        } else if let phoneNumber = txtPhoneNumber?.text, !isValidPhoneNumber(phoneNumber) {
            lblErrorPhoneNumber.text = "Phone number must be exactly 8 digits."
            highlightField(txtPhoneNumber)
            isValid = false
            errorMessage = "Please fill in all required fields correctly."
        } else {
            lblErrorPhoneNumber.text = ""
            resetFieldHighlight(txtPhoneNumber)
        }

        var users: [User] = []
        Task{
            users = try await  UsersManager.getAllUsers()
        }
        
        
        var thereIs: Bool = false
        for user in users {
            if txtEmail.text != currentUser?.email && txtEmail.text == user.email{
                thereIs = true
            }
        }
        
        // Validate txtEmail (Valid email format)
        if let email = txtEmail?.text, email.isEmpty {
            lblErrorEmail.text = "Email address is required."
            highlightField(txtEmail)
            isValid = false
            errorMessage = "Please fill in all required fields correctly."
        } else if let email = txtEmail?.text, !isValidEmail(email) {
            lblErrorEmail.text = "Enter a valid email address (e.g., example@domain.com)."
            highlightField(txtEmail)
            isValid = false
            errorMessage = "Please fill in all required fields correctly."
        }else if thereIs{
            lblErrorEmail.text = "The provided email used by other user"
            highlightField(txtEmail)
            isValid = false
            errorMessage = "Please fill in all required fields correctly."
        }else {
            lblErrorEmail.text = ""
            resetFieldHighlight(txtEmail)
        }

        // Show warning if validation fails
        if !isValid {
            showWarning(message: errorMessage)
        }

        return isValid
    }

    
    
    
    
    func isValidFullName(_ fullName: String) -> Bool {
        let fullNameRegex = "^[a-zA-Z ]+$"
        let fullNameTest = NSPredicate(format: "SELF MATCHES %@", fullNameRegex)
        return fullNameTest.evaluate(with: fullName)
    }
    
    func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        let phoneNumberRegex = "^[0-9]{8}$"
        let phoneNumberTest = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegex)
        return phoneNumberTest.evaluate(with: phoneNumber)
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
    
    
    func highlightField(_ textField: UITextField?) {
        textField?.layer.borderWidth = 1
        textField?.layer.borderColor = UIColor.red.cgColor
        textField?.layer.cornerRadius = 5
    }

    func resetFieldHighlight(_ textField: UITextField?) {
        textField?.layer.borderWidth = 0
        textField?.layer.borderColor = UIColor.clear.cgColor
    }
    
    
    
    func showWarning(message: String) {
        // Check if the warning view already exists
        if self.view.viewWithTag(999) != nil { return } // Avoid adding duplicate warnings
        
        // Create the warning view
        let warningView = UIView()
        warningView.backgroundColor = UIColor.red
        warningView.tag = 999 // Use a unique tag to identify the view
        warningView.layer.cornerRadius = 5
        warningView.translatesAutoresizingMaskIntoConstraints = false

        // Create the warning message label
        let warningLabel = UILabel()
        warningLabel.text = message
        warningLabel.textColor = .white
        warningLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        warningLabel.numberOfLines = 0
        warningLabel.translatesAutoresizingMaskIntoConstraints = false

        // Create the close button
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("X", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(hideWarning), for: .touchUpInside)

        // Add subviews to the warning view
        warningView.addSubview(warningLabel)
        warningView.addSubview(closeButton)

        // Add the warning view to the main view
        self.view.addSubview(warningView)

        // Constraints for the warning view
        NSLayoutConstraint.activate([
            warningView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10),
            warningView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            warningView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            warningView.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),
        ])

        // Constraints for the warning label
        NSLayoutConstraint.activate([
            warningLabel.leadingAnchor.constraint(equalTo: warningView.leadingAnchor, constant: 10),
            warningLabel.centerYAnchor.constraint(equalTo: warningView.centerYAnchor),
            warningLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -10),
        ])

        // Constraints for the close button
        NSLayoutConstraint.activate([
            closeButton.trailingAnchor.constraint(equalTo: warningView.trailingAnchor, constant: -10),
            closeButton.centerYAnchor.constraint(equalTo: warningView.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),
        ])

        // Animate the warning view appearance
        warningView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            warningView.alpha = 1
        }
    }

    
    @objc func hideWarning() {
        if let warningView = self.view.viewWithTag(999) {
            UIView.animate(withDuration: 0.3, animations: {
                warningView.alpha = 0
            }) { _ in
                warningView.removeFromSuperview()
            }
        }
    }

}


//shared functions
extension AdminProfileViewController{
    
    func showAlert(message: String, completion: (() -> Void)? = nil) {
         let alert = UIAlertController(title: "Reset Password", message: message, preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
             completion?()
         }))
         present(alert, animated: true, completion: nil)
     }
}
