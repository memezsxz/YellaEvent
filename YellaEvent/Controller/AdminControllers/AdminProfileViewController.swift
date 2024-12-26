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
    var FAQobject: FAQ?

    
//MARK: Outlets
// the profile tab outlet
    @IBOutlet var roundedViews: [UIView]!
    @IBOutlet weak var BigImageProfile: UIImageView!
    
    
//  Edit Profile Page section
    //Outlet Fields
    @IBOutlet weak var txtFullName: UITextField!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var editProfileImage: UIImageView!
    
    
    //MARK: Error Outlets
    //Outlet Errors
    @IBOutlet weak var lblErrorFullName: UILabel!
    @IBOutlet weak var lblErrorPhoneNumber: UILabel!
    @IBOutlet weak var lblErrorEmail: UILabel!
   
    
    //MARK: Actions
    
    @IBAction func logout(_ sender: UIButton) {
        
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }
    
    
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

    
    // MARK: FAQ Outlet and action
    @IBOutlet weak var question: UILabel!
    @IBOutlet weak var answer: UILabel!
    
    

    
    
    
    
    //MARK: ViewDidLoad
    override func viewDidLoad(){
        super.viewDidLoad()

        setupEditPage()
        UserDefaults.standard.set((Auth.auth().currentUser?.uid)!, forKey: K.bundleUserID) // this will be removed after seting the application

        setup()

    }
    
    
    func setup() {
        // get the current user object
        Task {
            let us = try await UsersManager.getUser(userID: UserDefaults.standard.string(forKey: K.bundleUserID)!)
            currentUser = (us as! Admin)
            do{
                if let _ = bigUserName{
                    bigUserName.text = currentUser?.fullName
                    bigUserType.titleLabel!.text = "Admin"
                }
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
            
        if let faq = FAQobject{
            question.text = faq.question
            answer.text = faq.answer
        }
       
        
    }

    //MARK: ViewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        // method to set the edit user profile page
        setup()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "faqAdmin"{
            (segue.destination as? CustomerFAQTableViewController)?.type = "Admin"
        }
    }

}


//MARK: Edit Profile
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





//MARK: Validation
// extention for filds validations --> inclide the function that related to the validation
extension AdminProfileViewController{
    
    func validateFields() -> Bool {
        var isValid = true


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
        } else if let email = txtEmail?.text, !isValidEmail(email) {
            lblErrorEmail.text = "Enter a valid email address (e.g., example@domain.com)."
            highlightField(txtEmail)
            isValid = false
        }else if thereIs{
            lblErrorEmail.text = "The provided email used by other user"
            highlightField(txtEmail)
            isValid = false
        }else {
            lblErrorEmail.text = ""
            resetFieldHighlight(txtEmail)
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
    

}


//MARK: shared functions
extension AdminProfileViewController{
    
    func showAlert(message: String, completion: (() -> Void)? = nil) {
         let alert = UIAlertController(title: "Reset Password", message: message, preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
             completion?()
         }))
         present(alert, animated: true, completion: nil)
     }
}
