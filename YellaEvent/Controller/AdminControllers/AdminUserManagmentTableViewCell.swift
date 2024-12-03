//
//  AdminUserManagmentTableViewCell.swift
//  YellaEvent
//
//  Created by Admin User on 02/12/2024.
//

import UIKit

class AdminUserManagmentTableViewCell: UITableViewCell {

    @IBOutlet weak var txtUserName: UILabel!
    
    @IBOutlet weak var txtUserEmail: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setupcell(username: String, email : String){
        txtUserName.text = username
        txtUserEmail.text = email
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
