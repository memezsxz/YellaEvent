//
//  EditOrganizerDetailsView.swift
//  YellaEvent
//
//  Created by Admin User on 11/12/2024.
//

import UIKit

class EditOrganizerDetailsView: UIView, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var delegate : ViewOrganizerDetailsView? = nil
    var currentOrganizer : Organizer? = nil
    var image : UIImage? = nil
    let imagePickerController = UIImagePickerController()

    //MARK: Outlets
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var txtUserType: UITextField!
    @IBOutlet weak var txtName: UINavigationItem!
    @IBOutlet weak var txtDocumnetName: UILabel!
    
    @IBOutlet weak var txtDuraion: UIButton!
    
    @IBOutlet weak var txtDuration: UITextField!
    @IBOutlet weak var lastField: UIStackView!
    
    
    //MARK: errors lables
    @IBOutlet weak var lblErrorEmail: UILabel!
    @IBOutlet weak var lblErrorPhoneNumber: UILabel!
    
    @IBOutlet weak var lblErrorDuration: UILabel!
    
    
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    func setup() {
        lastField.isHidden = true
        txtUserType.isUserInteractionEnabled = false

        txtName.title = currentOrganizer?.fullName
        txtEmail.text = currentOrganizer?.email
        txtUserType.text = "Organizer"
        if let date = currentOrganizer!.endDate {
            txtDuraion.titleLabel?.text = K.DFormatter.string(from: date)
        }
        txtPhoneNumber.text = "\(currentOrganizer!.phoneNumber)"
        txtDocumnetName.text = "License.jpg"
        
     
    }
    
    //MARK: Actions
    @IBAction func selectedOption(_ sender: UIAction){
        if sender.title == "Never Expire" {
             txtDuraion.setTitle("Never Expire", for: .normal) // Set button title to "Never Expire"
            lastField.isHidden = true
         } else {
             print("Enerd")
             lastField.isHidden = false
         }
        
    }
    
    
    
    
    @IBAction func saveButtonClickd(_ sender: UIButton) {
        
        //do validation
        guard validation() else { return}
        
        
        currentOrganizer!.email = txtEmail.text!
        if let phone = Int(txtPhoneNumber.text!){
            currentOrganizer?.phoneNumber = phone
        }
        
        if txtDuraion.titleLabel!.text == "Never Expire"{
            currentOrganizer?.endDate = nil
        }else{
            let days = Calendar.current.date(byAdding: .day, value: Int(txtDuration.text!)!, to: Date())
            if let newdate = days {
                currentOrganizer?.endDate = newdate
            }
        }
        
        
        //save the given documnet 
        if let image  = image{
            PhotoManager.shared.uploadPhoto(image, to: "organizers/\(currentOrganizer!.userID)", withNewName: "License") { result in
                switch result {
                    case .success(let url):
                    self.currentOrganizer?.LicenseDocumentURL = url
                    Task {
                        try await UsersManager.updateUser(user: self.currentOrganizer!)
                    }
                case .failure(let error):
                    print("Error uploading photo: \(error)")
                }
            }
        } else {
            Task{
                try await UsersManager.updateUser(user: self.currentOrganizer!)
            }
        }
        
        
//        take the value from the text fields
        
        
        // 3. Show an alert notifying the user that the changes have been saved
        delegate?.delegate?.saveAlert()
        
        
        //update user
    }
    
    
    
    @IBAction func chnageDocument(_ sender: UIButton) {
        //TODO_FATIMA
        
        presentLicenseImagePicker()

    }
    
    
    
    
    
    
    //MARK: Validation
    func validation() -> Bool {
        var isValid = true
        let parent = (delegate?.delegate!)!
        

        // Validate txtPhoneNumber (Only numbers)
        if let phoneNumber = txtPhoneNumber?.text, phoneNumber.isEmpty {
            lblErrorPhoneNumber.text = "Phone number is required."
            parent.highlightField(txtPhoneNumber)
            isValid = false
        } else if let phoneNumber = txtPhoneNumber?.text, !parent.isValidPhoneNumber(phoneNumber) {
            lblErrorPhoneNumber.text = "Phone number must be exactly 8 digits."
            parent.highlightField(txtPhoneNumber)
            isValid = false
        } else {
            lblErrorPhoneNumber.text = ""
            parent.resetFieldHighlight(txtPhoneNumber)
        }

        // Validate txtEmail (Valid email format)
        if let email = txtEmail?.text, email.isEmpty {
            lblErrorEmail.text = "Email address is required."
            parent.highlightField(txtEmail)
            isValid = false
        } else if let email = txtEmail?.text, !parent.isValidEmail(email) {
            lblErrorEmail.text = "Enter a valid email address (e.g., example@domain.com)."
            parent.highlightField(txtEmail)
            isValid = false
        } else {
            lblErrorEmail.text = ""
            parent.resetFieldHighlight(txtEmail)
        }
        
        if txtDuraion.titleLabel?.text == "Custome Duration"{
            if let duration = txtDuration.text, duration.isEmpty{
                lblErrorDuration.text = "Duration is required."
                parent.highlightField(txtDuration)
                isValid = false
            } else if let duration = txtDuration?.text, !isValidDuration(duration) {
                lblErrorDuration.text = "Duration must be only numbers."
                parent.highlightField(txtDuration)
                isValid = false
            } else {
                lblErrorDuration.text = ""
                parent.resetFieldHighlight(txtDuration)
            }
        }
        

        return isValid
    }
    

    func isValidDuration(_ duration: String) -> Bool {
        let durationRegex = "^[0-9]+$" // Allows one or more digits
        let durationTest = NSPredicate(format: "SELF MATCHES %@", durationRegex)
        return durationTest.evaluate(with: duration)
    }

    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {return}
        
        image = selectedImage
        
        delegate!.delegate!.dismiss(animated: true, completion: nil)
    }

    func presentLicenseImagePicker() {
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        delegate!.delegate!.present(imagePickerController, animated: true, completion: nil)
    }

         
}
