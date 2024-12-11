//
//  AdminUsersViewController.swift
//  YellaEvent
//
//  Created by meme on 25/11/2024.
//

import UIKit
import FirebaseFirestore

struct RuntimeError: LocalizedError {
    private let message: String

    init(_ message: String) {
        self.message = message
    }

    var errorDescription: String? {
        return message
    }
}


var currentUser: User? = nil

class AdminUsersViewController: UIViewController {
    
//Users List page
    // Outlet
    @IBOutlet weak var addOrganizer: UIBarButtonItem!
    @IBOutlet weak var userListSections: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchbar: UISearchBar!
    var users : [User] = []
    var currentSegment : UserType?
    
//Create Organizer Page
    // Outlet
    @IBOutlet weak var txtUserNameCreate: UITextField!
    @IBOutlet weak var txtPhoneNumberCreate: UITextField!
    @IBOutlet weak var txtPasswordCreate: UITextField!
    @IBOutlet weak var txtEmailCreate: UITextField!
    @IBOutlet weak var txtLicenceCreate: UILabel!
    
    @IBOutlet weak var listAccountDuration: UIButton!
    
    //lblError
    @IBOutlet weak var lblErrorUserName: UILabel!
    @IBOutlet weak var lblErrorPhoneNumber: UILabel!
    @IBOutlet weak var lblErrorEmail: UILabel!
    @IBOutlet weak var lblErrorPassword: UILabel!

    @IBOutlet weak var lblErrorAccountDuration: UILabel!
    
    
    //Actions
    @IBAction func createUserTapped(_ sender: Any) {
        createOrganizer()
    }
    @IBAction func UploadDoucumentTapped(_ sender: Any) {
        uploadDoucument(sender)
    }
    
    
    
    //form the main page + button
    @IBAction func CreateButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "createUser", sender: sender)
    }
    
    
    
    //view customer details Page
    //outlets

    @IBOutlet weak var txtUserNameCustomer: UINavigationItem!
    @IBOutlet weak var txtPhoneNumberCustomer: UITextField!
    @IBOutlet weak var txtDOBCustomer: UITextField!
    @IBOutlet weak var txtEmailCustomer: UITextField!
    @IBOutlet weak var txtUserTypeCustomer: UITextField!
    @IBOutlet weak var btnBan: UIButton!
    
    
    //Action
    @IBAction func ResetCustomerPassword(_ sender: Any) {
        //get the user object and reset the password value of the user
        //TODO-Fatima
        
        //show an alert that the password reset
        resertPassword()
    }
    
    @IBAction func BanUserButton(_ sender: Any) {
            //check if the user in the ban collection
        
            // if the user not on the ban collection show this function
             BanAlert()
        
            // if the user is in the ban collection use this function
            //UnBanAlert
        
    }
    
    
    
 //Ban Account Page
    //outlets
    @IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var txtBanReason: UIButton!
    @IBOutlet weak var txtBanduration: UIButton!
    var banReasons = ["Abusive Behavior", "Spam", "Fraudulent Activity", "Harassment", "Other"]
    
    var banDuration = ["24 Hours", "7 Days", "14 Days", "1 Month", "1 Year", "Permanent", "Custom Duration"]
    
    //Actions
    @IBAction func ConformBan(_ sender: Any) {
        // 1. Validation
        if txtBanReason.titleLabel?.text == "Select Ban Reason" ||
           txtBanduration.titleLabel?.text == "Select Ban Duration" ||
           txtDescription.text.isEmpty {
            showWarning(message: "Please fill in all required fields correctly.")
        } else {
            // 2. Get the selected duration and convert it into days
            let selectedDurationText = txtBanduration.titleLabel?.text ?? ""
            let selectedDurationInDays = getDurationInDays(from: selectedDurationText)
            
            // 3. Calculate the end date by adding the duration to today's date
            let startDate = Date()  // today's date
            let endDate = calculateEndDate(from: startDate, durationInDays: selectedDurationInDays)
            
            // 4. Call the UsersManager.banUser method with startDate and endDate
            let txt = (txtBanReason.titleLabel?.text)!
            
            Task{
                try await UsersManager.banUser(userID: currentUser!.userID, userType: currentUser!.type, reason: txt, description: txtDescription.text, startDate: startDate, endDate: endDate)
            }
            
            // 5. Show the confirmation alert
            banConformation()
        }
    }
    
    @IBAction func BanReasonClicked(_ sender: Any) {
        showDropdown(options: banReasons, for: txtBanReason, title: "Select Ban Reason")
    }
    
    @IBAction func BanDurationaClicked(_ sender: Any) {
        showDropdown(options: banDuration, for: txtBanduration, title: "Select Ban Duration")
    }
    
    //View Admin Page
    //Outlet
  
    @IBOutlet weak var txtNameAdmin: UINavigationItem!
    @IBOutlet weak var txtEmailAdmin: UITextField!
    
    @IBOutlet weak var txtPhoneNumberAdmin: UITextField!

    @IBOutlet weak var txtUsetTypeAdmin: UITextField!

    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        //load for the list user page
        do {
            // Ensure tableView exists
            guard let tableView = tableView else {
                throw RuntimeError("TableView is not connected.")
            }

            tableView.delegate = self
            tableView.dataSource = self

            // Ensure the NIB file exists
            
            let nibName = "UsersTableViewCell"
            guard Bundle.main.path(forResource: nibName, ofType: "nib") != nil else {
                throw RuntimeError("Nib file \(nibName) not found in the bundle.")
            }

            tableView.register(UINib(nibName: nibName, bundle: Bundle.main), forCellReuseIdentifier: "UsersTableViewCell")
        } catch {
            print("Error setting up tableView: \(error.localizedDescription)")
        }
        
        // Check if the searchbar exists and set its delegate
        if let searchbar = searchbar {
            searchbar.delegate = self
        } else {
            print("SearchBar is not present for this screen.")
        }
        
        do{
            do{
                // Safely check and handle `userListSections` and `addOrganizer`
                if let userListSections = userListSections {
                   
                    if userListSections.selectedSegmentIndex == 2 {
                        addOrganizer?.isEnabled = true // Use optional chaining for `addOrganizer`
                    } else {
                        addOrganizer?.isHidden = true
                    }
                    
                } else {
                    print("userListSections is not available on this screen.")
                }
            }catch {
                print("Something went wrong: \(error.localizedDescription)")
            }
            // Safely update users
            do {
                usersUpdate()
            } catch {
                print("Something went wrong during usersUpdate: \(error.localizedDescription)")
            }
        }catch{
            print("Something went wrong: \(error.localizedDescription)")
        }

        // chnage it to real data
         var options = ["No Expire","1 Week", "1 Month", "1 Year"]
        
        
        // for the create user page
        do{
            try configureMenu(options: options)
        }catch is Error {
            print("no menue is there")
        }
        
        //view customer page
        do {
            if let currentUser = currentUser {
                if let currentUser = currentUser as? Customer {
                    // Check if the text fields exist before accessing them
                    
                    if let txtUserTypeCustomer = txtUserTypeCustomer {
                        txtUserTypeCustomer.isUserInteractionEnabled = false
                        txtUserTypeCustomer.text = "Customer"
                    }

                    if let txtUserNameCustomer = txtUserNameCustomer {
                        txtUserNameCustomer.title = currentUser.fullName
                    }

                    if let txtPhoneNumberCustomer = txtPhoneNumberCustomer {
                        txtPhoneNumberCustomer.isUserInteractionEnabled = false
                        txtPhoneNumberCustomer.text = "\(currentUser.phoneNumber)"
                    }

                    if let txtDOBCustomer = txtDOBCustomer {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "dd MMMM yyyy"
                        txtDOBCustomer.text = formatter.string(from: currentUser.dob)
                        txtDOBCustomer.isUserInteractionEnabled = false

                    }

                    if let txtEmailCustomer = txtEmailCustomer {
                        txtEmailCustomer.text = currentUser.email
                        txtEmailCustomer.isUserInteractionEnabled = false

                    }

                    // Checking and handling banning logic
                    var isBan = false
                    var banUsers: [UserBan] = []
                    Task {
                        banUsers = try await UsersManager.getUserBans()
                    }

                    for i in banUsers {
                        if i.userID == currentUser.userID {
                            isBan = true
                            break
                        }
                    }

                    if isBan {
                        if let btnBan = btnBan {
                            btnBan.setTitle("Unban Account", for: .normal)
                            btnBan.setTitleColor(UIColor.brandBlue, for: .normal)
                        }
                    }

                } else if currentUser.type == .admin {
                        // Admin page setup
                    if let userType = txtUsetTypeAdmin{
                        txtUsetTypeAdmin.text = "Admin"
                        txtEmailAdmin.text = currentUser.email
                        txtPhoneNumberAdmin.text = "\(currentUser.phoneNumber)"
                        txtNameAdmin.title = currentUser.fullName
                    }
                    
                } else if currentUser.type == .organizer {
                    // Handle organizer-specific code if necessary
                }
            }
        } catch {
            print("Error occurred while processing user data: \(error)")
        }
        
        //view Ban page

        do{
            if let banreason = txtBanReason {
                txtBanReason.setTitle("Select Ban Reason", for: .normal)
                txtBanduration.setTitle("Select Ban Duration", for: .normal)
            }
        }catch {
            
        }
    

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
  
    }

    
}




// MARK: - Segment
extension AdminUsersViewController {
    //     function to change the segment text color
    //    func updateSegment(){
    //
    //        let textAttributesNormal: [NSAttributedString.Key: Any] = [
    //            .foregroundColor: UIColor.brandDarkPurple, // Non-selected text color
    //            .font: UIFont.systemFont(ofSize: 14) // Customize font size
    //        ]
    //
    //        let textAttributesSelected:
    
    
    @IBAction func clickOnSegment(_ sender: Any) {
        if userListSections.selectedSegmentIndex == 2 {
            addOrganizer.isHidden = false
        }else{
            addOrganizer.isHidden = true
        }
        usersUpdate()
    }
    
}


// MARK: - Table View
extension AdminUsersViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // custmize the cell
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UsersTableViewCell") as! UsersTableViewCell
        let user = users[indexPath.row]
        // chnage the name to the user name and the email to the user email
        
        cell.title.text = user.fullName
        cell.subtext.text = user.email
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.width / 6
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let user = users[indexPath.row]
        print("array size: \(users.count)")
        currentUser = user
        print(currentUser!)


        if (user.type == .admin){
            performSegue(withIdentifier: "ViewAdminPage", sender: self)
            

            
        }else if (user.type == .customer){
            performSegue(withIdentifier: "ViewCustomerPage", sender: self)
            
            
        }else if (user.type == .organizer){
            performSegue(withIdentifier: "ViewOrganizerPage", sender: self)
        }
        
    }
    
    func usersUpdate() {
        do {
            // Ensure userListSections is not nil and has a valid selectedSegmentIndex
            guard let userListSections = userListSections else {
                throw RuntimeError("userListSections is not available.")
            }
            let section = userListSections.selectedSegmentIndex

            // Clear users and reset the search bar
            
            users.removeAll()
            users = []
            searchbar?.text = "" // Use optional chaining to handle missing search bar

            // Handle the selected segment and call appropriate methods
            switch section {
            case 0:
                try UsersManager.getAllUsers(listener: listner())
                currentSegment = nil
            case 1:
                try UsersManager.addUsersListener(userType: .customer, listener: listner())
                currentSegment = .customer
            case 2:
                try UsersManager.addUsersListener(userType: .organizer, listener: listner())
                currentSegment = .organizer
            case 3:
                try UsersManager.addUsersListener(userType: .admin, listener: listner())
                currentSegment = .admin
            default:
                print("Unhandled section index: \(section)")
            }
        } catch {
            print("Error occurred during usersUpdate: \(error.localizedDescription)")
        }
    }

        
        func listner()  -> ((QuerySnapshot?, (any Error)?) -> Void)  {
            self.users = []

            return { snapshot, error in
                guard error == nil else {
                    // fatima add error handeling here
                    print("Error: \(error!)")
                    return
                }
                
                guard let snapshot = snapshot else {
                    print("No data available.")
                    return
                }
                
                if self.currentSegment != nil { // if the current segment is on all tap do not emptied the user list
                    self.users = []
                }
                for doc in snapshot.documents {
                    do {
                        if let userType = doc.data()[K.FStore.User.type] as? String {
                            let user: User
                            
                            switch userType {
                            case UserType.admin.rawValue:
                                user = try doc.data(as: Admin.self)
                            case UserType.customer.rawValue:
                                user = try doc.data(as: Customer.self)
                            case UserType.organizer.rawValue:
                                user = try doc.data(as: Organizer.self)
                            default:
                                print("Unknown user type: \(userType)")
                                continue
                            }
                            self.users.append(user)
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    //                self.searchBar(self.searchbar, textDidChange: self.searchbar.text ?? "")
                }
            }
        }
        
}

extension AdminUsersViewController : UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            usersUpdate()
            return
        }
        var searchArray : [User] = []
        
        Task {
            let searchText = searchText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            searchArray = try await (currentSegment == nil
                                     ? UsersManager.getAllUsers()
                                     : UsersManager.getUsers(ofType: currentSegment!))
            
            users = searchArray.filter { user in
                user.fullName.lowercased().split(separator: " ").contains { $0.lowercased().starts(with: searchText) } || user.fullName.lowercased().starts(with: searchText) ||
                user.email.lowercased().starts(with: searchText)
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

//create organizer functions
extension AdminUsersViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    
    
    func createOrganizer(){
        //1. DO validation on the provided information
        validateCreateFields()
        
        //2. if everything go well
            //create new organization user
        let name = txtUserNameCreate.text!
//        let phone = Int(txtPhoneNumberCreate.text!)
        let email = txtEmailCreate.text
        let pass = txtPasswordCreate.text
        let start = Data()

        
//        let org = Organizer(fullName: name, email: email!, dob: Date(), dateCreated: Date(), phoneNumber: phone, profileImageURL: "", startDate: start, endDate: <#T##Date#>, LicenseDocumentURL: <#T##String#>)
//            
            //add the organization object in the firbase
        
    }
    
    
    func uploadDoucument(_ sender: Any){
        
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
        
        //1.get the selected image
        guard let selectedImage = info[.originalImage] as? UIImage else {return}
        
        //2. save the image in somewhere and rename it as Licence
            //save the image to the organizer user object
        
        
        //3. display the documnet name as Licence
        
    }
    
    
    // if the user click cancel run this method
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        //1. close the screen
        dismiss(animated: true, completion: nil)
    }
    
    // function to show a list
    func configureMenu(options: [String]) {
        do {
            // Ensure `listAccountDuration` exists
            guard let list = listAccountDuration else {
                throw RuntimeError("The listAccountDuration button is not connected.")
            }

            // Ensure options are not empty
            guard !options.isEmpty else {
                throw RuntimeError("The options list cannot be empty.")
            }

            // Create UIActions from options
            let menuActions = options.map { option in
                UIAction(title: option, image: nil) { action in
                    do {
                        try self.updateMenuWithSelection(selectedOption: option, options: options)
                    } catch {
                        print("Error updating menu selection: \(error.localizedDescription)")
                    }
                }
            }

            // Attach the menu to the button
            let menu = UIMenu(title: "", children: menuActions)
            list.menu = menu
            list.showsMenuAsPrimaryAction = true
            list.backgroundColor = .white
            list.setTitle("Select Duration", for: .normal)
            

        } catch {
            print("Error configuring menu: \(error.localizedDescription)")
        }
    }

    func updateMenuWithSelection(selectedOption: String, options: [String]) throws {
        // Ensure `listAccountDuration` exists
        guard let listAccountDuration = listAccountDuration else {
            throw RuntimeError("The listAccountDuration button is not connected.")
        }

        // Ensure the selected option is valid
        guard options.contains(selectedOption) else {
            throw RuntimeError("Invalid selected option: \(selectedOption).")
        }

        // Create updated menu actions
        let menuActions = options.map { option in
            UIAction(
                title: option,
                image: option == selectedOption ? UIImage(systemName: "checkmark") : nil
            ) { action in
                do {
                    try self.updateMenuWithSelection(selectedOption: option, options: options)
                } catch {
                    print("Error updating menu selection: \(error.localizedDescription)")
                }
            }
        }

        // Update the button's title and reassign the menu
        listAccountDuration.setTitle(selectedOption, for: .normal)
        listAccountDuration.menu = UIMenu(title: "", children: menuActions)
        

        // Dismiss the menu after 0.4 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            listAccountDuration.showsMenuAsPrimaryAction = false
            listAccountDuration.showsMenuAsPrimaryAction = true
        }
    }

}

// extention for filds validations for create oragnizer --> inclide the function that related to the validation
extension AdminUsersViewController{
        
        func validateCreateFields() -> Bool {
            var isValid = true
            var errorMessage = ""


            // Validate txtFullName (Only letters)
            if let fullName = txtUserNameCreate?.text, fullName.isEmpty {
                lblErrorUserName.text = "Full name is required."
                highlightField(txtUserNameCreate)
                isValid = false
                errorMessage = "Please fill in all required fields correctly."
            } else if let fullName = txtUserNameCreate?.text, !isValidFullName(fullName) {
                lblErrorUserName.text = "Full name must contain only letters."
                highlightField(txtUserNameCreate)
                isValid = false
                errorMessage = "Please fill in all required fields correctly."
            } else {
                lblErrorUserName.text = ""
                resetFieldHighlight(txtUserNameCreate)
            }

            // Validate txtPhoneNumber (Only numbers)
            if let phoneNumber = txtPhoneNumberCreate?.text, phoneNumber.isEmpty {
                lblErrorPhoneNumber.text = "Phone number is required."
                highlightField(txtPhoneNumberCreate)
                isValid = false
                errorMessage = "Please fill in all required fields correctly."
            } else if let phoneNumber = txtPhoneNumberCreate?.text, !isValidPhoneNumber(phoneNumber) {
                lblErrorPhoneNumber.text = "Phone number must be exactly 8 digits."
                highlightField(txtPhoneNumberCreate)
                isValid = false
                errorMessage = "Please fill in all required fields correctly."
            } else {
                lblErrorPhoneNumber.text = ""
                resetFieldHighlight(txtPhoneNumberCreate)
            }

            // Validate txtEmail (Valid email format)
            if let email = txtEmailCreate?.text, email.isEmpty {
                lblErrorEmail.text = "Email address is required."
                highlightField(txtEmailCreate)
                isValid = false
                errorMessage = "Please fill in all required fields correctly."
            } else if let email = txtEmailCreate?.text, !isValidEmail(email) {
                lblErrorEmail.text = "Enter a valid email address (e.g., example@domain.com)."
                highlightField(txtEmailCreate)
                isValid = false
                errorMessage = "Please fill in all required fields correctly."
            } else {
                lblErrorEmail.text = ""
                resetFieldHighlight(txtEmailCreate)
            }
            
            // Validate txtPasswordCreate (Valid password format)
            if let password = txtPasswordCreate?.text, password.isEmpty {
                lblErrorPassword.text = "Password is required."
                highlightField(txtPasswordCreate)
                isValid = false
                errorMessage = "Please fill in all required fields correctly."
            }else {
                lblErrorPassword.text = ""
                resetFieldHighlight(txtPasswordCreate)
            }

            if listAccountDuration.titleLabel?.text == "Select Duration"{
                lblErrorAccountDuration.text = "Account Duration is required."
                listAccountDuration.layer.borderColor = UIColor.red.cgColor // Set the border color (e.g., red)
                listAccountDuration.layer.borderWidth = 1 // Set the border width
                isValid = false
                errorMessage = "Please fill in all required fields correctly."
            }else {
                lblErrorAccountDuration.text = ""
                listAccountDuration?.layer.borderWidth = 0
                listAccountDuration?.layer.borderColor = UIColor.clear.cgColor
            }
            

            // Show warning if validation fails
            if !isValid {
                showWarning(message: errorMessage)
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
        
        
        
        func showWarning(message: String) {
            // Check if the warning view already exists
            if self.view.viewWithTag(999) != nil { return } // Avoid adding duplicate warnings
            
            // Create the warning view
            let warningView = UIView()
            warningView.backgroundColor = UIColor.red
            warningView.tag = 999 // Use a unique tag to identify the view
            warningView.layer.cornerRadius = 5
            warningView.translatesAutoresizingMaskIntoConstraints = false

            // Create the warning message label
            let warningLabel = UILabel()
            warningLabel.text = message
            warningLabel.textColor = .white
            warningLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            warningLabel.numberOfLines = 0
            warningLabel.translatesAutoresizingMaskIntoConstraints = false

            // Create the close button
            let closeButton = UIButton(type: .system)
            closeButton.setTitle("X", for: .normal)
            closeButton.setTitleColor(.white, for: .normal)
            closeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            closeButton.translatesAutoresizingMaskIntoConstraints = false
            closeButton.addTarget(self, action: #selector(hideWarning), for: .touchUpInside)

            // Add subviews to the warning view
            warningView.addSubview(warningLabel)
            warningView.addSubview(closeButton)

            // Add the warning view to the main view
            self.view.addSubview(warningView)

            // Constraints for the warning view
            NSLayoutConstraint.activate([
                warningView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10),
                warningView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
                warningView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
                warningView.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),
            ])

            // Constraints for the warning label
            NSLayoutConstraint.activate([
                warningLabel.leadingAnchor.constraint(equalTo: warningView.leadingAnchor, constant: 10),
                warningLabel.centerYAnchor.constraint(equalTo: warningView.centerYAnchor),
                warningLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -10),
            ])

            // Constraints for the close button
            NSLayoutConstraint.activate([
                closeButton.trailingAnchor.constraint(equalTo: warningView.trailingAnchor, constant: -10),
                closeButton.centerYAnchor.constraint(equalTo: warningView.centerYAnchor),
                closeButton.widthAnchor.constraint(equalToConstant: 30),
                closeButton.heightAnchor.constraint(equalToConstant: 30),
            ])

            // Animate the warning view appearance
            warningView.alpha = 0
            UIView.animate(withDuration: 0.3) {
                warningView.alpha = 1
            }
        }

        
        @objc func hideWarning() {
            if let warningView = self.view.viewWithTag(999) {
                UIView.animate(withDuration: 0.3, animations: {
                    warningView.alpha = 0
                }) { _ in
                    warningView.removeFromSuperview()
                }
            }
        }

    }


// Ban User Page functions {
// Convert the selected duration text (e.g. "1 Day", "1 Week", "1 Month") to days
func getDurationInDays(from text: String) -> Int {
    // Default to 0 if the duration cannot be interpreted
    var durationInDays = 0
    
    if text.contains("Day") {
        // Extract the number of days
        if let numberOfDays = Int(text.split(separator: " ")[0]) {
            durationInDays = numberOfDays
        }
    } else if text.contains("Week") {
        // Assuming a week is 7 days
        if let numberOfWeeks = Int(text.split(separator: " ")[0]) {
            durationInDays = numberOfWeeks * 7
        }
    } else if text.contains("Month") {
        // Assuming a month is approximately 30 days
        if let numberOfMonths = Int(text.split(separator: " ")[0]) {
            durationInDays = numberOfMonths * 30
        }
    }
    
    return durationInDays
}

// Calculate the end date by adding the given number of days to the start date
func calculateEndDate(from startDate: Date, durationInDays: Int) -> Date {
    let calendar = Calendar.current
    let endDate = calendar.date(byAdding: .day, value: durationInDays, to: startDate)
    return endDate ?? startDate // Return the start date if there's any issue with the calculation
}









//shared functions
extension AdminUsersViewController{
    
    
    // Generalized function to show a dropdown with a list of items
    func showDropdown(options: [String], for button: UIButton, title: String) {
        // Ensure the options list is not empty
            guard !options.isEmpty else {
                print("The options list cannot be empty.")
                return
            }

            // Create UIActions from options
            let menuActions = options.map { option in
                UIAction(title: option, image: nil) { action in
                    self.updateMenuWithSelection(selectedOption: option, options: options, button: button)
                }
            }

            // Create the menu and assign it to the button
            let menu = UIMenu(title: "", children: menuActions)
            button.menu = menu
            button.showsMenuAsPrimaryAction = true
        }

        // Function to update the menu with the selected option
        func updateMenuWithSelection(selectedOption: String, options: [String], button: UIButton) {
            // Ensure the selected option is valid
            guard options.contains(selectedOption) else {
                print("Invalid selected option: \(selectedOption).")
                return
            }

            // Create updated menu actions with checkmark for the selected option
            let menuActions = options.map { option in
                UIAction(
                    title: option,
                    image: option == selectedOption ? UIImage(systemName: "checkmark") : nil
                ) { action in
                    self.updateMenuWithSelection(selectedOption: option, options: options, button: button)
                }
            }

            // Update the button's title to the selected option
            button.setTitle(selectedOption, for: .normal)

            // Reassign the updated menu to the button
            button.menu = UIMenu(title: "", children: menuActions)
        }
    
    
    
    func resertPassword(){
        //show an alert that the password reset
        let saveAlert = UIAlertController(
            title: "Password Reset Successful",
            message: "You have successfully reset the user's password. The user will be notified accordingly.",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
        }
        
        saveAlert.addAction(okAction)
        
        self.present(saveAlert, animated: true, completion: nil)
    

    }
    
    //function shows the ban alert
    func BanAlert(){
        
        let saveAlert = UIAlertController(
            title: "Ban User",
            message: "Are you sure you want to ban this user? This action is permanent and cannot be undone.",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        let banlAction = UIAlertAction(title: "Ban", style: .destructive) { action in
            self.goToBan()
            
        }
        
        saveAlert.addAction(cancelAction)
        saveAlert.addAction(banlAction)
        
        self.present(saveAlert, animated: true, completion: nil)
    


    }
    
    
    //function to shoe the unban alert
    func UnBanAlert(){
        
        let saveAlert = UIAlertController(
            title: "Account Unbanned",
            message: "The account has been successfully unbanned. Access has been restored.",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
//
            self.navigationController?.popViewController(animated: true)
        }
        
        saveAlert.addAction(okAction)
        
        self.present(saveAlert, animated: true, completion: nil)
    

        dismiss(animated: true, completion: nil)

    }
    
    
    func goToBan(){
        performSegue(withIdentifier: "BanPage", sender: self)
    }
    
    
    func banConformation() {
        let saveAlert = UIAlertController(
            title: "Account Banned",
            message: "The account has been successfully banned. Access has been restricted.",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
            // Pop the view controller after the user taps "OK"
            self.navigationController?.popToRootViewController(animated: true)
        }
        
        saveAlert.addAction(okAction)
        
        // Present the alert
        self.present(saveAlert, animated: true, completion: nil)
    }
    
    
}
    

    


