//
//  ViewAdminDetailsView.swift
//  YellaEvent
//
//  Created by Admin User on 11/12/2024.
//

import UIKit

class ViewAdminDetailsView: UIView {

    var delegate : AdminUsersViewController? = nil
    var currentAdmin : Admin? = nil
    
    
    
      @IBOutlet weak var txtNameAdmin: UINavigationItem!
      @IBOutlet weak var txtEmailAdmin: UITextField!
      @IBOutlet weak var txtPhoneNumberAdmin: UITextField!
      @IBOutlet weak var txtUsetTypeAdmin: UITextField!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    func setup() {
        guard let currentAdmin = currentAdmin else {return}
        
        
        txtUsetTypeAdmin.isUserInteractionEnabled = false
        txtPhoneNumberAdmin.isUserInteractionEnabled = false
        txtEmailAdmin.isUserInteractionEnabled = false
        
        txtUsetTypeAdmin.text = "Admin"
        txtNameAdmin.title = currentAdmin.fullName
        txtPhoneNumberAdmin.text = "\(currentAdmin.phoneNumber)"
        txtEmailAdmin.text = currentAdmin.email
        
    }
      
    
}
