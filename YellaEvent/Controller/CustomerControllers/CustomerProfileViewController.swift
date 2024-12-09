//
//  CustomerProfileViewController.swift
//  YellaEvent
//
//  Created by meme on 25/11/2024.
//
// edit_Fatima include the places where I need to edit the code in

import UIKit

class CustomerProfileViewController: UIViewController {
    
    var currentUser: Customer?
    
    
    // the profile tab outlet
    @IBOutlet var roundedViews: [UIView]!
    @IBOutlet weak var BIgImageProfile: UIImageView!
    
    
    
    // Edit Profile Page section
    //Outlet Fields
    @IBOutlet weak var EditProfileImage: UIImageView!
    @IBOutlet weak var txtFieldDate: UITextField!
    @IBOutlet weak var txtFullName: UITextField!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    
    //Outlet Errors
    @IBOutlet weak var lblErrorPhoneNumber: UILabel!
    @IBOutlet weak var lblErrorFullName: UILabel!
    @IBOutlet weak var lblErrorDOB: UILabel!
    @IBOutlet weak var lblErrorEmail: UILabel!
    
    
    //Actions
    @IBAction func ChangeImageTapped(_ sender: UIButton) {
        changeTheUserImage(sender)
    }
    
    @IBAction func SaveButtonTaped(_ sender: Any) {
        saveUserChanges(sender)
    }
    
    
    @IBAction func deleteAccountButtonTapped(_ sender: Any) {
        DeleteAccount(sender)
    }
    
    
    
    
    
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupEditPage()

            
            UserDefaults.standard.set("2", forKey: K.bundleUserID) // this will be removed after seting the application
            
                
            // get the current user object
            Task {
                let us = try await UsersManager.getUser(userID: UserDefaults.standard.string(forKey: K.bundleUserID)!)
                currentUser = us as? Customer
                //download the current user image
                PhotoManager.shared.downloadImage(from: URL(string: us.profileImageURL)!, completion: { result in
                    
                    switch result {
                        //if the user have an image and his/her image
                    case .success(let image):
                        self.BIgImageProfile?.image = image
                        // if the user don't have an image put the defualt image
                    case .failure(_):
                        self.BIgImageProfile?.image = UIImage(named: "DefaultImageProfile")
                    }
                    
                })
            }
        
        
    }
    
    

    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        do {
            //set a date picker on date of birth field
            try setupDatePicker()
        } catch {
            print("Error setting up date picker: \(error.localizedDescription)")
        }
        
        // method to set the edit user profile page
        setupEditPage()
        
    }
    
    
    
    
    
} //end of the class


// ------------------------------------------------------------//


//Customer Profile Tab functions
extension CustomerProfileViewController{
    
    // method set the user profile fields with user information
    func setupEditPage(){
        
        // get the current user object
        Task {
            do {
                
                let userId: String = UserDefaults.standard.string(forKey: K.bundleUserID)!
                let us = try await UsersManager.getUser(userID: userId)
                
                txtFullName?.text = "\(us.fullName)"
                txtEmail?.text = us.email
                
                currentUser = currentUser as? Customer
                PhotoManager.shared.downloadImage(from: URL(string: us.profileImageURL)!, completion: { result in
                    
                    switch result {
                    case .success(let image):
                        self.EditProfileImage?.image = image
                    case .failure(_):
                        self.EditProfileImage?.image = UIImage(named: "DefaultImageProfile")
                    }
                    
                })
                
                
            } catch {
                print("Failed to fetch user: \(error)")
                // Handle error appropriately, such as showing an alert to the user
            }
        }
        
    }
    
    
    //function to make the provided list of views circle
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        for view in roundedViews{
            view.layer.cornerRadius = view.frame.height / 2
            view.clipsToBounds = true
        }
        
    }
    
    
    
}


// edit profile page
extension CustomerProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    // function to set the date picket on the date of birth field in the user profile page
    func setupDatePicker() throws {
        guard txtFieldDate != nil else {
            throw NSError(domain: "ViewController", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Text field is not connected."])
        }
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        
        // Handle maximum date exception
        if let currentDate = Date() as Date? {
            datePicker.maximumDate = currentDate
        } else {
            print("Failed to set maximum date. Using default behavior.")
        }
        
        // Attach action for value change
        datePicker.addTarget(self, action: #selector(dateChange(datePicker:)), for: .valueChanged)
        
        // Assign date picker as inputView of text field
        txtFieldDate.inputView = datePicker
        
        // Setup toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissPicker))
        toolbar.setItems([doneButton], animated: true)
        toolbar.backgroundColor = .gray
        
        // Attach toolbar to text field
        txtFieldDate.inputAccessoryView = toolbar
        
        //             Set default date
        Task {
            do {
                
                
                let userId: String = UserDefaults.standard.string(forKey: K.bundleUserID)!
                let us = try await UsersManager.getUser(userID: userId)
                datePicker.date = us.dob
                txtFieldDate.text = formateDate(date: us.dob)
                
                
            } catch {
                print("Failed to fetch user: \(error)")
                // Handle error appropriately, such as showing an alert to the user
            }
        }
        
        
    }
    
    
    
    
    // Triggered when the date picker value changes
    @objc func dateChange(datePicker: UIDatePicker) {
        do {
            guard txtFieldDate != nil else{
                throw NSError(domain: "ViewController", code: 1002, userInfo: [NSLocalizedDescriptionKey: "Text field is not available for updating."])
            }
            txtFieldDate.text = formateDate(date: datePicker.date)
        } catch {
            print("Error updating date: \(error.localizedDescription)")
        }
    }
    
    
    // Dismiss the date picker when the Done button is tapped
    @objc func dismissPicker() {
        view.endEditing(true)
    }
    
    // Format the date to a readable string
    func formateDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy" // Customize as needed
        return formatter.string(from: date)
    }
    
    
    // function show two options (camera, photo library)
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
        
//        guard let img = selectedImage.jpegData(compressionQuality: 0.9) else {return}
        
        PhotoManager.shared.uploadPhoto(selectedImage, to: "\(currentUser!.userID)", withNewName: "profile") { result in
            switch result {
            case .success(let url):
                // TODO: Update in user
                print("Image uploaded successfully: \(url)")
            case .failure(let error):
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
        
        
        
   //edit the user image by uploading it.
   //edit_Fatima
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
            if let phone = Int(txtPhoneNumber.text!){
                currentUser?.phoneNumber = phone
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMMM yyyy" // Adjust this to match your input format
            currentUser?.dob = dateFormatter.date(from: txtFieldDate.text!)!
            
            Task{
                try await UsersManager.updateUser(user: currentUser!)
            }
        }catch{
            print("dob errer save")
        }
            //add the requird code
        
        // 3. Show an alert notifying the user that the changes have been saved
        let saveAlert = UIAlertController(
            title: "Save Changes",
            message: "Your changes have been saved successfully.",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
//
            self.navigationController?.popViewController(animated: true)
        }
        
        saveAlert.addAction(okAction)
        
        present(saveAlert, animated: true, completion: nil)
    }
    
 
        
      
    //delete user account function connected to the onclick on the delete button
    func DeleteAccount(_ sender: Any){
        
        let DeleteAlert = UIAlertController(title: "Delete Account", message: "Are you sure you want to permanently delete your account? This action cannot be undone.", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            print("cancel pressed")
        }
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { action in
            
            //delete the user from database -- edit_Fatima
            //add another user and try o delete it
            
            /*Task {
                try await UsersManager.deleteUser(userID: self.currentUser!.userID, userType: .customer)
            }*/
            
            if let LaunchScreen = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController() {
                LaunchScreen.modalPresentationStyle = .fullScreen
                self.present(LaunchScreen, animated: true, completion: nil)
            } else {
                print("LaunchScreen could not be instantiated.")
            }
        }
        
        DeleteAlert.addAction(cancelAction)
        
        DeleteAlert.addAction(deleteAction)
        
        present(DeleteAlert, animated: true)
        
    }
    
 
    
    
    
}


// extention for filds validations --> inclide the function that related to the validation
extension CustomerProfileViewController{
    
    func validateFields() -> Bool {
        var isValid = true
        var errorMessage = ""

        // Validate txtFieldDate
        if txtFieldDate?.text?.isEmpty ?? true {
            lblErrorDOB.text = "Date of birth is required."
            highlightField(txtFieldDate)
            isValid = false
            errorMessage = "Please fill in all required fields correctly."
        } else {
            lblErrorDOB.text = ""
            resetFieldHighlight(txtFieldDate)
        }

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
        } else {
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
