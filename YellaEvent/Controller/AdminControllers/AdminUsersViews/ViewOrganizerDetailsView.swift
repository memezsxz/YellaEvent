//
//  ViewOrganizerDetailsView.swift
//  YellaEvent
//
//  Created by Admin User on 11/12/2024.
//

import UIKit
import Photos
import FirebaseAuth

class ViewOrganizerDetailsView: UIView {
    
    var delegate : AdminUsersViewController? = nil
    var currentOrganizer : Organizer? = nil
    var userBan : Bool = false
    
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var txtUserType: UITextField!
    @IBOutlet weak var txtAccountDate: UITextField!
    @IBOutlet weak var txtName: UINavigationItem!
    @IBOutlet weak var txtDocumnetName: UILabel!
    @IBOutlet weak var btnBan: UIButton!
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    func setup() {
        txtEmail.isUserInteractionEnabled = false
        txtAccountDate.isUserInteractionEnabled = false
        txtUserType.isUserInteractionEnabled = false
        txtPhoneNumber.isUserInteractionEnabled = false
        
        txtName.title = currentOrganizer?.fullName
        txtEmail.text = currentOrganizer?.email
        txtUserType.text = "Organizer"
        if let date =  currentOrganizer!.endDate {
            txtAccountDate.text = K.DFormatter.string(from: date)
        }
        txtPhoneNumber.text = "\(currentOrganizer!.phoneNumber)"
        //        txtDocumnetName.text = currentOrganizer?.LicenseDocumentURL
        
        
        Task {
            
            self.userBan =  try await UsersManager.isUserBanned(userID: currentOrganizer!.userID)
            
            
            if !self.userBan {
                self.btnBan.setTitle("Unban Account", for: .normal)
                self.btnBan.setTitleColor(UIColor.brandBlue, for: .normal)
            }else{
                self.btnBan.setTitle("Ban Account", for: .normal)
                self.btnBan.setTitleColor(UIColor.red, for: .normal)
                
            }
            
            
        }
        
        
    }
    
    
    
    @IBAction func BanUserButton(_ sender: Any)  {
        //check if the user in the ban collection
        
        // if the user not on the ban collection show this function
        if userBan {
            delegate?.BanAlert()
            self.userBan = true
        }else{
            Task {
                try  await UsersManager.unbanUser(userID: currentOrganizer!.userID)
            }
            self.delegate?.UnBanAlert()
            self.userBan = false
        }
        
        // if the user is in the ban collection use this function
        //UnBanAlert
        
    }
    
    
    @IBAction func ViewOrganizerEvents(_ sender: UIButton) {
        //TODO_FATIMA
    }
    
    @IBAction func DownloadDocumnets(_ sender: UIButton) {
        //        currentOrganizer?.profileImageURL?
        
        PhotoManager.shared.downloadImage(from: URL(string: currentOrganizer!.LicenseDocumentURL)!) { result in
            switch result {
            case .success(let image):
                self.saveImageToPhotos(image: image)
                let alert = UIAlertController(title: "Download Compleated", message: "Photo added to library", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in }))
                self.delegate!.present(alert, animated: true, completion: {})

            case .failure(let error):
                let alert = UIAlertController(title: "Failed to Download", message: error.localizedDescription, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in }))
                self.delegate!.present(alert, animated: true, completion: {})

            }

        }
        
    }
    
    
    
    
    
    @IBAction func resetPassword(_ sender: UIButton) {
        
        guard let email = txtEmail.text, !email.isEmpty else {
            delegate!.showAlert(message: "Please enter your email.")
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
        
                self.delegate!.showAlert( message: error.localizedDescription)
                return
            }
            
        
            self.delegate!.showAlert(message: "A password reset link has been sent to \(email).")
        }
        
    }
    
    
    
    func saveImageToPhotos(image: UIImage) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                print("Photo library access not granted.")
                return
            }
            
            PHPhotoLibrary.shared().performChanges({
                // Add the image to the library
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { success, error in
                if success {
                    print("Image successfully saved to Photos.")
                } else if let error = error {
                    print("Error saving image: \(error.localizedDescription)")
                } else {
                    print("Unknown error occurred.")
                }
            }
        }
    }
    
    
    
    
}
