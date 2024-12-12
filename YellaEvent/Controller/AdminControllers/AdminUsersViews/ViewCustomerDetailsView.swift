//
//  ViewCustomerDetailsView.swift
//  YellaEvent
//
//  Created by Admin User on 11/12/2024.
//

import UIKit
import FirebaseAuth

class ViewCustomerDetailsView: UIView {
    
    var delegate : AdminUsersViewController? = nil
    var currentCustomer : Customer? = nil
    var userBan : Bool = false
    
    @IBOutlet weak var txtUserNameCustomer: UINavigationItem!
    @IBOutlet weak var txtPhoneNumberCustomer: UITextField!
    @IBOutlet weak var txtDOBCustomer: UITextField!
    @IBOutlet weak var txtEmailCustomer: UITextField!
    @IBOutlet weak var txtUserTypeCustomer: UITextField!
    @IBOutlet weak var btnBan: UIButton!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    func setup() {
        // Check if the text fields exist before accessing them
        guard let currentCustomer = currentCustomer else {return}
        
        txtUserTypeCustomer.isUserInteractionEnabled = false
        txtUserTypeCustomer.text = "Customer"
        
        
        txtUserNameCustomer.title = currentCustomer.fullName
        
        
        txtPhoneNumberCustomer.isUserInteractionEnabled = false
        txtPhoneNumberCustomer.text = "\(currentCustomer.phoneNumber)"
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        txtDOBCustomer.text = formatter.string(from: currentCustomer.dob)
        txtDOBCustomer.isUserInteractionEnabled = false
        
        
        
        txtEmailCustomer.text = currentCustomer.email
        txtEmailCustomer.isUserInteractionEnabled = false
        
        
        
        // Checking and handling banning logic
        Task {
            
            self.userBan =  try await UsersManager.isUserBanned(userID: currentCustomer.userID)

            
            if !self.userBan {
                self.btnBan.setTitle("Unban Account", for: .normal)
                self.btnBan.setTitleColor(UIColor.brandBlue, for: .normal)
            }else{
                self.btnBan.setTitle("Ban Account", for: .normal)
                self.btnBan.setTitleColor(UIColor.red, for: .normal)
                
            }
            
            
        }
    }
    
    //Action
    @IBAction func ResetCustomerPassword(_ sender: Any) {
        //get the user object and reset the password value of the user
        //TODO-Fatima
        
//        Auth.auth().sendPasswordReset(withEmail: email) { error in
//          // ...
//        }


        
        //show an alert that the password reset
        delegate?.resertPassword()
    }
    
    @IBAction func BanUserButton(_ sender: Any)  {
        //check if the user in the ban collection
        
        // if the user not on the ban collection show this function
        if userBan {
            delegate?.BanAlert()
            self.userBan = true
        }else{
            Task {
                try  await UsersManager.unbanUser(userID: currentCustomer!.userID)
            }
            self.delegate?.UnBanAlert()
            self.userBan = false
        }
        
        // if the user is in the ban collection use this function
        //UnBanAlert
        
    }
    
    
}
