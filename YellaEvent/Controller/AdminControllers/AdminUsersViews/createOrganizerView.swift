//
//  createOrganizerView.swift
//  YellaEvent
//
//  Created by Admin User on 12/12/2024.
//

import UIKit
import FirebaseAuth
import Photos

class createOrganizerView: UIView, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var delegate : AdminUsersViewController? = nil
    var organizer : Organizer = Organizer(fullName: "name", email: "email", dateCreated: Date.now, phoneNumber: 12345678, profileImageURL: "sdsasdasda", startDate: nil, endDate: nil, LicenseDocumentURL: "sdasad")
    var image : UIImage?
    let imagePickerController = UIImagePickerController()

    //Create Organizer Page
    // Outlet
    @IBOutlet weak var txtUserNameCreate: UITextField!
    @IBOutlet weak var txtPhoneNumberCreate: UITextField!
    @IBOutlet weak var txtPasswordCreate: UITextField!
    @IBOutlet weak var txtEmailCreate: UITextField!
    @IBOutlet weak var txtLicenceCreate: UILabel!
    @IBOutlet weak var lastField: UIStackView!
    @IBOutlet weak var txtduration: UITextField!
    
    @IBOutlet weak var btnActivationAccount: UIButton!
    
    
    
    //lblError
    @IBOutlet weak var lblErrorUserName: UILabel!
    @IBOutlet weak var lblErrorPhoneNumber: UILabel!
    @IBOutlet weak var lblErrorEmail: UILabel!
    @IBOutlet weak var lblErrorPassword: UILabel!
    
    @IBOutlet weak var lblErrorAccountDuration: UILabel!
    @IBOutlet weak var lblErrorDuration: UILabel!
    
    //    @IBOutlet var txtErrorImage: UILabel!
    
    //Actions
    @IBAction func createUserTapped(_ sender: Any) {
        createOrganizer()
        //            createOrganizer()
    }
    @IBAction func UploadDoucumentTapped(_ sender: Any) {
        presentLicenseImagePicker()
    }
    
    @IBAction func valueChanged(_ sender: Any) {
        if btnActivationAccount.titleLabel?.text == "Never Expire"{
            lastField.isHidden = true
        }else{
            lastField.isHidden = false
        }
        
    }
    @IBAction func chnage(_ sender: Any) {
        
        
    }
    
    
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    func setup() {
        //        setupDatePicker()
        lastField.isHidden = true
        
    }
    
    
    @IBAction func selectedOption(_ sender: UIAction){
        if sender.title == "Never Expire" {
            btnActivationAccount.setTitle("Never Expire", for: .normal)
            
            lastField.isHidden = true
            // Set button title to "Never Expire"
        } else {
            print("Enerd")
            lastField.isHidden = false
        }
        
    }
    
    
    
    
    
    
    
    func createOrganizer(){
        //1. DO validation on the provided information
        guard validateCreateFields() else {
            return
        }

        
        organizer.email = (txtEmailCreate?.text)!
        organizer.phoneNumber = Int((txtPhoneNumberCreate?.text)!)!
        organizer.fullName = (txtUserNameCreate?.text)!
        organizer.dateCreated = Date.now
        if lastField.isHidden {
            organizer.endDate = nil
            organizer.startDate = nil
        } else {
            organizer.startDate = Date.now
            organizer.endDate = Calendar.current.date(byAdding: .day, value: Int(txtduration.text!)!, to: Date())
        }
        
        Auth.auth().createUser(withEmail: organizer.email, password: txtPasswordCreate!.text!) { result, error  in
            guard  error == nil else {
                let alert = UIAlertController(title: "Unable To Create Organizer", message: error?.localizedDescription, preferredStyle: .alert)
                
                // Add an action (button)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                // Show the alert
                self.delegate!.present(alert, animated: true, completion: nil)
                return
            }
            self.organizer.userID = (result!.user.uid)
            
            PhotoManager.shared.uploadPhoto(self.image!, to: "\(self.organizer.userID)", withNewName: "license", completion: { result in
                switch result {
                    case .success(let url):
                    self.organizer.LicenseDocumentURL = url
                    Task {
                        try await  UsersManager.createNewUser(user: self.organizer)
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Organizer Created", message: "Organizer Created Successfully", preferredStyle: .alert)
                            
                            alert.addAction(
                                UIAlertAction(title: "OK", style: .default, handler: { action in
                                self.delegate!.navigationController?.popToRootViewController(animated: true)
                            }))
                            self.delegate!.present(alert, animated: true, completion: {})
                        }
                    }
                case .failure(let error):
                    let alert = UIAlertController(title: "Unable to upload image", message: error.localizedDescription, preferredStyle: .alert)
                    
                    alert.addAction(
                        UIAlertAction(title: "OK", style: .default, handler: { action in
                    }))
                    self.delegate!.present(alert, animated: true, completion: {})
                }
            })
        }
        
        //2. if everything go well
        //create new organization user
        //        let name = txtUserNameCreate.text!
        //        //        let phone = Int(txtPhoneNumberCreate.text!)
        //        let email = txtEmailCreate.text
        //        let pass = txtPasswordCreate.text
        //        let start = Data()
        //
        //user the usersmanager to create user in the firebase
    }
    
    
    // function to show a list
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {return}
        
        image = selectedImage
        txtLicenceCreate.text = "License.jpg"
        txtLicenceCreate.textColor = .brandBlue
        delegate!.dismiss(animated: true, completion: nil)
    }
    
    func validateCreateFields() -> Bool {
        var isValid = true
        var errorMessage = ""
        
        
        // Validate txtFullName (Only letters)
        if let fullName = txtUserNameCreate?.text, fullName.isEmpty {
            lblErrorUserName.text = "Full name is required."
            delegate!.highlightField(txtUserNameCreate)
            isValid = false
            errorMessage = "Please fill in all required fields correctly."
        } else if let fullName = txtUserNameCreate?.text, !delegate!.isValidFullName(fullName) {
            lblErrorUserName.text = "Full name must contain only letters."
            delegate!.highlightField(txtUserNameCreate)
            isValid = false
            errorMessage = "Please fill in all required fields correctly."
        } else {
            lblErrorUserName.text = ""
            delegate!.resetFieldHighlight(txtUserNameCreate)
        }
        
        
        // Validate Password (Only letters)
        if let pass = txtPasswordCreate?.text, pass.isEmpty {
            lblErrorPassword.text = "Password is required."
            delegate!.highlightField(txtPasswordCreate)
            isValid = false
            errorMessage = "Please fill in all required fields correctly."
        } else {
            lblErrorPassword.text = ""
            delegate!.resetFieldHighlight(txtPasswordCreate)
        }
        
        
        // Validate txtPhoneNumber (Only numbers)
        if let phoneNumber = txtPhoneNumberCreate?.text, phoneNumber.isEmpty {
            lblErrorPhoneNumber.text = "Phone number is required."
            delegate!.highlightField(txtPhoneNumberCreate)
            isValid = false
            errorMessage = "Please fill in all required fields correctly."
        } else if let phoneNumber = txtPhoneNumberCreate?.text, !delegate!.isValidPhoneNumber(phoneNumber) {
            lblErrorPhoneNumber.text = "Phone number must be exactly 8 digits."
            delegate!.highlightField(txtPhoneNumberCreate)
            isValid = false
            errorMessage = "Please fill in all required fields correctly."
        } else {
            lblErrorPhoneNumber.text = ""
            delegate!.resetFieldHighlight(txtPhoneNumberCreate)
        }
        
        // Validate txtEmail (Valid email format)
        if let email = txtEmailCreate?.text, email.isEmpty {
            lblErrorEmail.text = "Email address is required."
            delegate!.highlightField(txtEmailCreate)
            isValid = false
            errorMessage = "Please fill in all required fields correctly."
        } else if let email = txtEmailCreate?.text, !delegate!.isValidEmail(email) {
            lblErrorEmail.text = "Enter a valid email address (e.g., example@domain.com)."
            delegate!.highlightField(txtEmailCreate)
            isValid = false
            errorMessage = "Please fill in all required fields correctly."
        } else {
            lblErrorEmail.text = ""
            delegate!.resetFieldHighlight(txtEmailCreate)
        }
        
        // Validate txtPasswordCreate (Valid password format)
        if let password = txtPasswordCreate?.text, password.isEmpty {
            lblErrorPassword.text = "Password is required."
            delegate!.highlightField(txtPasswordCreate)
            isValid = false
            errorMessage = "Please fill in all required fields correctly."
        }else {
            lblErrorPassword.text = ""
            delegate!.resetFieldHighlight(txtPasswordCreate)
        }
        
        if btnActivationAccount.titleLabel?.text == "Custome Duration"{
            if let duration = txtduration.text, duration.isEmpty{
                lblErrorDuration.text = "Duration is required."
                delegate!.highlightField(txtduration)
                isValid = false
                errorMessage = "Please fill in all required fields correctly."
            } else if let duration = txtduration?.text, !isValidDuration(duration) {
                lblErrorDuration.text = "Duration must be only numbers."
                delegate!.highlightField(txtduration)
                isValid = false
                errorMessage = "Please fill in all required fields correctly."
            } else {
                lblErrorDuration.text = ""
                delegate!.resetFieldHighlight(txtduration)
            }
            
        }
        
        if let license = txtLicenceCreate.text, license.isEmpty || license == "License is required." {
                txtLicenceCreate.textColor = .red
                txtLicenceCreate.text = "License is required."
                isValid = false
                errorMessage = "Please fill in all required fields correctly."
        }else {
            lblErrorPassword.text = ""
            delegate!.resetFieldHighlight(txtPasswordCreate)
        }
            
        
        
        
        if image == nil {
            isValid = false
//            txtErrorImage.text = "Image is required."
        } else {
//            txtErrorImage.text = ""
        }
        
        // Show warning if validation fails
        if !isValid {
            //delegate!.showWarning(message: errorMessage)
        }
        
        return isValid
        
    }
    
    func isValidDuration(_ duration: String) -> Bool {
        let durationRegex = "^[0-9]+$" // Allows one or more digits
        let durationTest = NSPredicate(format: "SELF MATCHES %@", durationRegex)
        return durationTest.evaluate(with: duration)
    }
    
    func presentLicenseImagePicker() {
        imagePickerController.delegate = self
        
//        let menue = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
//        menue.addAction(cancelAction)
//        
//        if UIImagePickerController.isSourceTypeAvailable(.camera) {
//            
//            let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
//                imagePicker.sourceType = .camera
//                self.present(imagePicker, animated: true, completion: nil)
//            }
//            
//            menue.addAction(cameraAction)
//        }
//        
//        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
//            
//            let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { _ in
//                imagePicker.sourceType = .photoLibrary
//                self.present(imagePicker, animated: true, completion: nil)
//            }
//            
//            menue.addAction(photoLibraryAction)
//        }
//
//        menue.popoverPresentationController?.sourceView = sender as? UIView
//        present(menue, animated: true)

        
        
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        delegate!.present(imagePickerController, animated: true, completion: nil)
    }
}
