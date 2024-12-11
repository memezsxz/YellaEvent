//
//  EditOrganizerDetailsView.swift
//  YellaEvent
//
//  Created by Admin User on 11/12/2024.
//

import UIKit

class EditOrganizerDetailsView: UIView {

    var delegate : ViewOrganizerDetailsView? = nil
    var currentOrganizer : Organizer? = nil

    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var txtUserType: UITextField!
    @IBOutlet weak var txtName: UINavigationItem!
    @IBOutlet weak var txtDocumnetName: UILabel!
    
    @IBOutlet weak var txtDuraion: UIButton!
    
    @IBOutlet weak var txtDuration: UITextField!
    @IBOutlet weak var lastField: UIStackView!
    
    
    //errors lables
    @IBOutlet weak var lblErrorEmail: UILabel!
    @IBOutlet weak var lblErrorPhoneNumber: UILabel!
    
    @IBOutlet weak var lblErrorDuration: UILabel!
    
    
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    func setup() {
//        setupDatePicker()
        lastField.isHidden = true
        txtUserType.isUserInteractionEnabled = false

        txtName.title = currentOrganizer?.fullName
        txtEmail.text = currentOrganizer?.email
        txtUserType.text = "Organizer"
        txtDuraion.titleLabel?.text = K.DFormatter.string(from: currentOrganizer!.endDate)
        txtPhoneNumber.text = "\(currentOrganizer!.phoneNumber)"
        txtDocumnetName.text = currentOrganizer?.LicenseDocumentURL
        
     
    }
    

    @IBAction func selectedOption(_ sender: UIAction){
        if sender.title == "Never Expire" {
             txtDuraion.setTitle("Never Expire", for: .normal) // Set button title to "Never Expire"
         } else {
             print("Enerd")
             lastField.isHidden = false
         }
        
    }
    
    
    
    
    @IBAction func saveButtonClickd(_ sender: UIButton) {
        
        //do validation
        validation()
        
        currentOrganizer!.email = txtEmail.text!
        if let phone = Int(txtPhoneNumber.text!){
            currentOrganizer?.phoneNumber = phone
        }
        if txtDuraion.titleLabel!.text == "Never Expire"{
            currentOrganizer?.endDate = K.DFormatter.date(from: "31/12/2999")!
        }else{
            var days = Calendar.current.date(byAdding: .day, value: Int(txtDuration.text!)!, to: Date())
            if let newdate = days {
                currentOrganizer?.endDate = days!
            }
        }
        
        //save the given documnet 
        //TODO_FATIMA
        
        
//        take the value from the text fields
        Task{
            try await UsersManager.updateUser(user: currentUser!)
        }
        
        //update user
    }
    
    
    
    @IBAction func chnageDocument(_ sender: UIButton) {
        //TODO_FATIMA
    }
    
    
    
    
    
    
    
    func validation() -> Bool {
        var isValid = true
        var errorMessage = ""
        let parent = (delegate?.delegate!)!
        

        // Validate txtPhoneNumber (Only numbers)
        if let phoneNumber = txtPhoneNumber?.text, phoneNumber.isEmpty {
            lblErrorPhoneNumber.text = "Phone number is required."
            parent.highlightField(txtPhoneNumber)
            isValid = false
            errorMessage = "Please fill in all required fields correctly."
        } else if let phoneNumber = txtPhoneNumber?.text, !parent.isValidPhoneNumber(phoneNumber) {
            lblErrorPhoneNumber.text = "Phone number must be exactly 8 digits."
            parent.highlightField(txtPhoneNumber)
            isValid = false
            errorMessage = "Please fill in all required fields correctly."
        } else {
            lblErrorPhoneNumber.text = ""
            parent.resetFieldHighlight(txtPhoneNumber)
        }

        // Validate txtEmail (Valid email format)
        if let email = txtEmail?.text, email.isEmpty {
            lblErrorEmail.text = "Email address is required."
            parent.highlightField(txtEmail)
            isValid = false
            errorMessage = "Please fill in all required fields correctly."
        } else if let email = txtEmail?.text, !parent.isValidEmail(email) {
            lblErrorEmail.text = "Enter a valid email address (e.g., example@domain.com)."
            parent.highlightField(txtEmail)
            isValid = false
            errorMessage = "Please fill in all required fields correctly."
        } else {
            lblErrorEmail.text = ""
            parent.resetFieldHighlight(txtEmail)
        }
        
        if txtDuraion.titleLabel?.text == "Custome Duration"{
            if let duration = txtDuration.text, duration.isEmpty{
                lblErrorDuration.text = "Duration is required."
                parent.highlightField(txtDuration)
                isValid = false
                errorMessage = "Please fill in all required fields correctly."
            } else if let duration = txtDuration?.text, !isValidDuration(duration) {
                lblErrorDuration.text = "Duration must be only numbers."
                parent.highlightField(txtDuration)
                isValid = false
                errorMessage = "Please fill in all required fields correctly."
            } else {
                lblErrorDuration.text = ""
                parent.resetFieldHighlight(txtDuration)
            }
        }
        

        // Show warning if validation fails
        if !isValid {
            parent.showWarning(message: errorMessage)
        }

        return isValid
    }
    

    func isValidDuration(_ duration: String) -> Bool {
        let durationRegex = "^[0-9]+$" // Allows one or more digits
        let durationTest = NSPredicate(format: "SELF MATCHES %@", durationRegex)
        return durationTest.evaluate(with: duration)
    }

         
}
