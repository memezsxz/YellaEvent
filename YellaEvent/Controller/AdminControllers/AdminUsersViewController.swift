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

class AdminUsersViewController: UIViewController {
    

    
    //Test
    
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
    
    
    
    
    @IBAction func CreateButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "createUser", sender: sender)
        createOrganizer()
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("1")
        //load for the list user page
        do {
            // Ensure tableView exists
            guard let tableView = tableView else {
                throw RuntimeError("TableView is not connected.")
            }
            print("2")

            tableView.delegate = self
            tableView.dataSource = self

            // Ensure the NIB file exists
            
            let nibName = "UsersTableViewCell"
            guard Bundle.main.path(forResource: nibName, ofType: "nib") != nil else {
                throw RuntimeError("Nib file \(nibName) not found in the bundle.")
            }
            print("3")

            tableView.register(UINib(nibName: nibName, bundle: Bundle.main), forCellReuseIdentifier: "UsersTableViewCell")
            print("4")
        } catch {
            print("Error setting up tableView: \(error.localizedDescription)")
        }
        
        print("5")
        // Check if the searchbar exists and set its delegate
        if let searchbar = searchbar {
            searchbar.delegate = self
            print("6")
        } else {
            print("SearchBar is not present for this screen.")
        }

        
//        Task {
//            try await  UsersManager.createNewUser(user: Customer(userID: "sdfsd", fullName: "fds", email: "dsfdfs@dsf.co", dob: Date.now, dateCreated: Date.now, phoneNumber: 2123123, profileImageURL: "321213", badgesArray: [], interestsArray: []))
//        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        print("7")
        super.viewWillAppear(animated)
        print("7")
        do{
            do{
                print("8")
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
                print("9")
            }catch {
                print("Something went wrong: \(error.localizedDescription)")
            }
            print("10")
            // Safely update users
            do {
                usersUpdate()
            } catch {
                print("Something went wrong during usersUpdate: \(error.localizedDescription)")
            }
        }catch{
            print("Something went wrong: \(error.localizedDescription)")
        }

        print("11")
        // chnage it to real data
         var options = ["No Expire","1 Week", "1 Month", "1 Year"]
        
        
        print("12")
        // for the create user page
        do{
            try configureMenu(options: options)
        }catch is Error {
            print("no menue is there")
        }
        

        
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
        var user = users[indexPath.row]
        if (user.type == .admin){
            performSegue(withIdentifier: "ViewAdminPage", sender: self)
        }else if (user.type == .customer){
            performSegue(withIdentifier: "ViewCustomerPage", sender: self)
        }else{
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
                
                if self.currentSegment != nil {
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
extension AdminUsersViewController{
    
    
    
    func createOrganizer(){
        //1. DO validation on the provided information
//        validateCreateFields()
        
        //2. if everything go well
            //create new organization user
            
            //add the organization object in the firbase
        
    }
    
    
    // function to show a list
    func configureMenu(options: [String]) {
        do {
            // Ensure `listAccountDuration` exists
            guard let listAccountDuration = listAccountDuration else {
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
            listAccountDuration.menu = menu
            listAccountDuration.showsMenuAsPrimaryAction = true
            listAccountDuration.backgroundColor = .white
            listAccountDuration.setTitle("Select Duration", for: .normal)
            

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


    

    


