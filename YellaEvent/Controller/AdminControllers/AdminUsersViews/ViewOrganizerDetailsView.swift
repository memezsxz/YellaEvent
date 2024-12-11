//
//  ViewOrganizerDetailsView.swift
//  YellaEvent
//
//  Created by Admin User on 11/12/2024.
//

import UIKit

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
        txtAccountDate.text = K.DFormatter.string(from: currentOrganizer!.endDate)
        txtPhoneNumber.text = "\(currentOrganizer!.phoneNumber)"
        txtDocumnetName.text = currentOrganizer?.LicenseDocumentURL
        
        
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
        //TODO_Fatima
    }
    
    
    
    @IBAction func resetPassword(_ sender: UIButton) {
        //TODO_FATIMA
        
    }
    
    
    
    
    
    

}
