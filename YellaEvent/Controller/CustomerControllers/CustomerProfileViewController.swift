//
//  CustomerProfileViewController.swift
//  YellaEvent
//
//  Created by meme on 25/11/2024.
//
// edit_Fatima include the places where I need to edit the code in

import UIKit
import FirebaseAuth


class CustomerProfileViewController: UIViewController, UITextFieldDelegate {
    
    var currentUser: Customer?
    var imageUpdated : Bool = false
    var FAQobject: FAQ?
    
    let dateFormatter = DateFormatter()

    //MARK: Outleat Fields
    @IBOutlet var intrestsCollection: InterestsCollectionView!
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

    
    
    //MARK: Outlet Errors
    @IBOutlet weak var lblErrorPhoneNumber: UILabel!
    @IBOutlet weak var lblErrorFullName: UILabel!
    @IBOutlet weak var lblErrorDOB: UILabel!
    @IBOutlet weak var lblErrorEmail: UILabel!
    
    @IBOutlet weak var txtBigUserName: UILabel!
    
    @IBOutlet weak var txtUserType: UIButton!
    
    
    
    //MARK: Actions
    @IBAction func logout(_ sender: UIButton) {
        do{
            try Auth.auth().signOut()
            
            // need to be changed to the login screen
            if let LaunchScreen = UIStoryboard(name: "AuthenticationView", bundle: nil).instantiateInitialViewController() {
                LaunchScreen.modalPresentationStyle = .fullScreen
                self.present(LaunchScreen, animated: true, completion: nil)
            } else {
                print("LaunchScreen could not be instantiated.")
            }
            
        }catch{
            print("someting went wrong with log out")
        }
    }
    
    @IBAction func ChangeImageTapped(_ sender: UIButton) {
        changeTheUserImage(sender)
    }
    
    @IBAction func SaveButtonTaped(_ sender: Any) {
        saveUserChanges(sender)
        
//        createAdmin()



    }
    
    
    @IBAction func deleteAccountButtonTapped(_ sender: Any) {
        DeleteAccount(sender)
    }
    

    
    
    @IBAction func chnagePassword(_ sender: UIButton) {
        
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
    
        
    @IBAction func InterestsSaveBtnClicked(_ sender: UIButton) {
        currentUser?.interestsArray =  intrestsCollection.getInterests()
        
        Task {
            try await UsersManager.updateUser(user: currentUser!)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    //FAQ Outlet
    @IBOutlet weak var question: UILabel!
    @IBOutlet weak var answer: UILabel!
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        setup()
    }
    
    //MARK: ViewDidLoad
    override func viewDidLoad(){
        super.viewDidLoad()
       
        //set the date format
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        setupEditPage()
        
//        UserDefaults.standard.set("1OJ9cN1iMAG5pjNocI7Z", forKey: K.bundleUserID) // this will be removed after seting the application
        
        UserDefaults.standard.set((Auth.auth().currentUser?.uid)!, forKey: K.bundleUserID) // this will be removed after seting the application
        
        
        setup()
        
        if let faq = FAQobject{
            question.text = faq.question
            answer.text = faq.answer
        }
        
    }
    
    
    //MARK: ViweWillAppear
    override func viewWillAppear(_ animated: Bool) {
        
        setup()
    }
    
    
    
    func setup() {
        // get the current user object
        Task {
            do {
                let userId: String = UserDefaults.standard.string(forKey: K.bundleUserID)!
                let us = try await UsersManager.getUser(userID: userId) as! Customer
                
                txtBigUserName?.text = "\(us.fullName)"
                txtUserType?.titleLabel?.text = "Customer"
                currentUser = us

                if !(currentUser!.profileImageURL.isEmpty){
                    PhotoManager.shared.downloadImage(from: URL(string: currentUser!.profileImageURL)!, completion: { result in
                        
                        switch result {
                        case .success(let image):
                            self.BIgImageProfile?.image = image
                        case .failure(_):
                            self.BIgImageProfile?.image = UIImage(named: "DefaultImageProfile")
                        }
                        
                    })
                }
                
            
                
                
            } catch {
                print("Failed to fetch user: \(error)")
                // Handle error appropriately, such as showing an alert to the user
            }
        }

            
            
        
        
        
    }
    
    
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "faqCustomer"{
            (segue.destination as? CustomerFAQTableViewController)?.type = "Customer"
        }
    }
    
    
} //end of the class


// ------------------------------------------------------------//


//MARK: Edir Profile setup
//Customer Profile Tab functions
extension CustomerProfileViewController{
    
    // method set the user profile fields with user information
    func setupEditPage(){
        
        // get the current user object
        Task {
            do {
                
                let userId: String = UserDefaults.standard.string(forKey: K.bundleUserID)!
                let us = try await UsersManager.getUser(userID: userId) as! Customer
                
                
                
                txtFullName?.text = "\(us.fullName)"
                txtEmail?.text = us.email
                txtPhoneNumber?.text = "\(us.phoneNumber)"
                txtFieldDate?.text = dateFormatter.string(from: us.dob)
                currentUser = us

                if !(currentUser!.profileImageURL.isEmpty){
                    PhotoManager.shared.downloadImage(from: URL(string: currentUser!.profileImageURL)!, completion: { result in
                        
                        switch result {
                        case .success(let image):
                            self.EditProfileImage?.image = image
                        case .failure(_):
                            self.EditProfileImage?.image = UIImage(named: "DefaultImageProfile")
                        }
                        
                    })
                }
                    
                   
                
                
                do {
                    //set a date picker on date of birth field
                    try self.setupDatePicker()
                } catch {
                    print("Error setting up date picker: \(error.localizedDescription)")
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
                let us = try await UsersManager.getUser(userID: userId) as! Customer
                datePicker.date = us.dob
                
                
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
            txtFieldDate.text = dateFormatter.string(from:datePicker.date)
        } catch {
            print("Error updating date: \(error.localizedDescription)")
        }
    }
    
    
    // Dismiss the date picker when the Done button is tapped
    @objc func dismissPicker() {
        view.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if textField == txtFieldDate {
                return false // Prevent typing in txtFieldDate
            }
            return true // Allow typing in other text fields
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
        
        EditProfileImage.image = selectedImage
        
        imageUpdated = true
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
        
        
        Task {
            
                
        
        // 1. Proceed to save changes if validation passes
            do{
                
                
                currentUser?.fullName = txtFullName.text!
                currentUser?.phoneNumber = Int(txtPhoneNumber.text!)!
                if let date = txtFieldDate.text,  let dateInDate = dateFormatter.date(from: date) {
                    currentUser?.dob = dateInDate
                    
                }
                
                
                if let image = EditProfileImage.image, imageUpdated {
                    PhotoManager.shared.uploadPhoto(image, to: "customers/\(currentUser!.userID)", withNewName: "profile") { result in
                        switch result {
                        case .success(let url):
                            
                            
                            // TODO: Update in user
                            
                            print("Image uploaded successfully: \(url)")
                            self.currentUser?.profileImageURL = url
                            self.imageUpdated = false
                            print("saved", url)
                            Task{
                                try await UsersManager.updateUser(user: self.currentUser!, fields: [K.FStore.Customers.profileImageURL: self.currentUser!.profileImageURL])
                                
                            }
                            
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
                
                // Update the user in your database
                           try await UsersManager.updateUser(user: currentUser!)
                           
                           // Show success message
                           DispatchQueue.main.async {
                               let successAlert = UIAlertController(
                                   title: "Success",
                                   message: "Your changes have been saved successfully.",
                                   preferredStyle: .alert
                               )
                               successAlert.addAction(UIAlertAction(title: "OK", style: .default) { action in
                                   
                                   self.navigationController?.popToRootViewController(animated: true)
                               })
                               self.present(successAlert, animated: true, completion: nil)
                           }
               
            }catch{
                DispatchQueue.main.async {
                               let errorAlert = UIAlertController(
                                   title: "Error",
                                   message: error.localizedDescription,
                                   preferredStyle: .alert
                               )
                               errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                               self.present(errorAlert, animated: true, completion: nil)
                           }
            }

            
        }
        
//        // 3. Show an alert notifying the user that the changes have been saved
//        let saveAlert = UIAlertController(
//            title: "Save Changes",
//            message: "Your changes have been saved successfully.",
//            preferredStyle: .alert
//        )
//        
//        let okAction = UIAlertAction(title: "OK", style: .default) { action in
//            self.navigationController?.popToRootViewController(animated: true)
//        }
//        
//        saveAlert.addAction(okAction)
//        self.present(saveAlert, animated: true, completion: nil)
    }
    
    
    
    
    //delete user account function connected to the onclick on the delete button
    func DeleteAccount(_ sender: Any){
        
        let DeleteAlert = UIAlertController(title: "Delete Account", message: "Are you sure you want to permanently delete your account? This action cannot be undone.", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            print("cancel pressed")
        }
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { action in
            
            guard let user = Auth.auth().currentUser else {
                        print("No current user found.")
                        return
                    }
            
            Task{
                do{
                    
                    // Delete Firestore or Database documents
                    try await UsersManager.deleteUser(userID: self.currentUser!.userID, userType: self.currentUser!.type)
                    print("User document deleted successfully.")
                    
                    
                    user.delete { error in
                      if let _ = error {
                        // An error happened.
                      } else {
                        // Account deleted.
                      }
                    }
                    print("User account deleted successfully.")

                    
                    
                    
                    try Auth.auth().signOut()
                    
                    
                    // need to be changed to the login screen
                    if let LaunchScreen = UIStoryboard(name: "AuthenticationView", bundle: nil).instantiateInitialViewController() {
                        LaunchScreen.modalPresentationStyle = .fullScreen
                        self.present(LaunchScreen, animated: true, completion: nil)
                    } else {
                        print("LaunchScreen could not be instantiated.")
                    }
                }catch{
                    print("an error with signout occured")
                }
            }
        }
        
        DeleteAlert.addAction(cancelAction)
        
        DeleteAlert.addAction(deleteAction)
        
        present(DeleteAlert, animated: true)
        
    }
    
    
    
    func showAlert(message: String, completion: (() -> Void)? = nil) {
         let alert = UIAlertController(title: "Reset Password", message: message, preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
             completion?()
         }))
         present(alert, animated: true, completion: nil)
     }
    
    
    
}



//MARK: Validation
// extention for filds validations --> inclide the function that related to the validation
extension CustomerProfileViewController{
    
    func validateFields() -> Bool {
        var isValid = true
        
        // Validate txtFieldDate
        if txtFieldDate?.text?.isEmpty ?? true {
            lblErrorDOB.text = "Date of birth is required."
            highlightField(txtFieldDate)
            isValid = false
        } else if !isValidDate(txtFieldDate.text ?? "", format: "dd/MM/yyyy") {
            lblErrorDOB.text = "Invalid date format. Please use dd/mm/yyyy."
            highlightField(txtFieldDate)
            isValid = false
        }else {
            lblErrorDOB.text = ""
            resetFieldHighlight(txtFieldDate)
        }
        
        // Validate txtFullName (Only letters)
        if let fullName = txtFullName?.text, fullName.isEmpty {
            lblErrorFullName.text = "Full name is required."
            highlightField(txtFullName)
            isValid = false
        } else if let fullName = txtFullName?.text, !isValidFullName(fullName) {
            lblErrorFullName.text = "Full name must contain only letters."
            highlightField(txtFullName)
            isValid = false
        } else {
            lblErrorFullName.text = ""
            resetFieldHighlight(txtFullName)
        }
        
        // Validate txtPhoneNumber (Only numbers)
        if let phoneNumber = txtPhoneNumber?.text, phoneNumber.isEmpty {
            lblErrorPhoneNumber.text = "Phone number is required."
            highlightField(txtPhoneNumber)
            isValid = false
        } else if let phoneNumber = txtPhoneNumber?.text, !isValidPhoneNumber(phoneNumber) {
            lblErrorPhoneNumber.text = "Phone number must be exactly 8 digits."
            highlightField(txtPhoneNumber)
            isValid = false
        } else {
            lblErrorPhoneNumber.text = ""
            resetFieldHighlight(txtPhoneNumber)
        }
        
        
        var users: [User] = []
        var thereIs: Bool = false

        Task {
            users = try await UsersManager.getAllUsers()
            
            // Trim the email in the text field
            let trimmedEmail = txtEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            for user in users {
                let userEmailTrimmed = user.email.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmedEmail != currentUser?.email && trimmedEmail == userEmailTrimmed {
                    thereIs = true
                    break // Exit the loop early if a match is found
                }
            }
            
            // Perform validation after the Task completes
            DispatchQueue.main.async {
                // Validate txtEmail (Valid email format)
                if let email = self.txtEmail?.text, email.isEmpty {
                    self.lblErrorEmail.text = "Email address is required."
                    self.highlightField(self.txtEmail)
                    isValid = false
                } else if let email = self.txtEmail?.text, !self.isValidEmail(email) {
                    self.lblErrorEmail.text = "Enter a valid email address (e.g., example@domain.com)."
                    self.highlightField(self.txtEmail)
                    isValid = false
                }else if thereIs{
                    self.lblErrorEmail.text = "The provided email used by other user"
                    self.highlightField(self.txtEmail)
                    isValid = false
                }else {
                    self.lblErrorEmail.text = ""
                    self.resetFieldHighlight(self.txtEmail)
                }
            }
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
    
    func isValidDate(_ dateString: String, format: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Ensure consistent parsing
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        // Check if the date is valid and matches the format exactly
        if let _ = dateFormatter.date(from: dateString) {
            return true
        } else {
            return false
        }
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
    
    func createAdmin(){
        
        Task {
            var admin = Admin(
                userID: "placeholder",
                fullName: "Fatima Hasan",
                email: "ffooffy35@gmail.com",
                dateCreated: Date(),
                phoneNumber: 35303815,
                profileImageURL: ""
            )
            
            do {
                // Explicitly specify the type of the continuation
                let authResult: AuthDataResult = try await withCheckedThrowingContinuation { continuation in
                    Auth.auth().createUser(withEmail: admin.email, password: "123456") { result, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else if let result = result {
                            continuation.resume(returning: result)
                        }
                    }
                }
                
                // Update admin's userID with the newly created user's UID
                admin.userID = authResult.user.uid
                print("Firebase Auth UID: \(authResult.user.uid)")
                print("Admin userID: \(admin.userID)")
                
                // Create the user document in Firestore
                try await UsersManager.createNewUser(user: admin)
                print("Admin created successfully with UID: \(admin.userID)")
                
            } catch {
                // Handle errors (Firebase Auth or Firestore)
                let alert = UIAlertController(
                    title: "Error Creating Admin",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                DispatchQueue.main.async { [weak self] in
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
        
    }
    
}
