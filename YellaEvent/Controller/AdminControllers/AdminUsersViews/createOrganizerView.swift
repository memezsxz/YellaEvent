//
//  createOrganizerView.swift
//  YellaEvent
//
//  Created by Admin User on 12/12/2024.
//

import UIKit

class createOrganizerView: UIView {
    
    var delegate : AdminUsersViewController? = nil
    
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
    
    
    //Actions
    @IBAction func createUserTapped(_ sender: Any) {
        createOrganizer()
        //            createOrganizer()
    }
    @IBAction func UploadDoucumentTapped(_ sender: Any) {
        //            uploadDoucument(sender)
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
        validateCreateFields()
        
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
            // Show warning if validation fails
            if !isValid {
                delegate!.showWarning(message: errorMessage)
            }
            
            return isValid
        
    }
        
        func isValidDuration(_ duration: String) -> Bool {
            let durationRegex = "^[0-9]+$" // Allows one or more digits
            let durationTest = NSPredicate(format: "SELF MATCHES %@", durationRegex)
            return durationTest.evaluate(with: duration)
        }
        
    
}
