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
    
    @IBOutlet var viewCustomerDetailsView: ViewCustomerDetailsView!
    @IBOutlet var viewAdminDetailsView: ViewAdminDetailsView!
    @IBOutlet var viewOrganizerDetailsView: ViewOrganizerDetailsView!
    @IBOutlet var editOrganizerDetailsView: EditOrganizerDetailsView!
    @IBOutlet var createOrganizerView: createOrganizerView!
    
    
    
    //Users List page
    // Outlet
    @IBOutlet weak var addOrganizer: UIBarButtonItem!
    @IBOutlet weak var userListSections: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchbar: UISearchBar!
    var users : [User] = []
    var currentSegment : UserType?
    

    
    
    //form the main page + button
    @IBAction func CreateButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "createUser", sender: sender)
    }
    
    
    
    //view customer details Page
    //outlets
//
//    @IBOutlet weak var txtUserNameCustomer: UINavigationItem!
//    @IBOutlet weak var txtPhoneNumberCustomer: UITextField!
//    @IBOutlet weak var txtDOBCustomer: UITextField!
//    @IBOutlet weak var txtEmailCustomer: UITextField!
//    @IBOutlet weak var txtUserTypeCustomer: UITextField!
//    @IBOutlet weak var btnBan: UIButton!
//    
//    
//    //Action
//    @IBAction func ResetCustomerPassword(_ sender: Any) {
//        //get the user object and reset the password value of the user
//        //TODO-Fatima
//        
//        //show an alert that the password reset
//        resertPassword()
//    }
//    
//    @IBAction func BanUserButton(_ sender: Any) {
//            //check if the user in the ban collection
//        
//            // if the user not on the ban collection show this function
//             BanAlert()
//        
//            // if the user is in the ban collection use this function
//            //UnBanAlert
//        
//    }
//    
//    
//    
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

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewCustomerPage" {
            viewCustomerDetailsView = segue.destination.view as? ViewCustomerDetailsView
            viewCustomerDetailsView.delegate = self
            viewCustomerDetailsView.currentCustomer = (currentUser as! Customer)
            viewCustomerDetailsView.setup()
            return
        }else if (segue.identifier == "ViewAdminPage" ){
            viewAdminDetailsView = segue.destination.view as? ViewAdminDetailsView
            viewAdminDetailsView.delegate = self
            viewAdminDetailsView.currentAdmin = (currentUser as! Admin)
            viewAdminDetailsView.setup()
        }else if (segue.identifier == "ViewOrganizerPage"){
            viewOrganizerDetailsView = segue.destination.view as? ViewOrganizerDetailsView
            viewOrganizerDetailsView.delegate = self
            viewOrganizerDetailsView.currentOrganizer = (currentUser as! Organizer)
            viewOrganizerDetailsView.setup()
        }else if (segue.identifier == "EditUser"){
            editOrganizerDetailsView = segue.destination.view as? EditOrganizerDetailsView
            editOrganizerDetailsView.delegate = viewOrganizerDetailsView
            editOrganizerDetailsView.currentOrganizer = (currentUser as! Organizer)
            editOrganizerDetailsView.setup()
        }else if (segue.identifier == "createUser"){
            createOrganizerView = segue.destination.view as? createOrganizerView
            createOrganizerView.delegate = self
            createOrganizerView.setup()
        }
        
        super.prepare(for: segue, sender: sender)
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
        currentUser = user

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

// MARK: Search delegate
extension AdminUsersViewController : UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            usersUpdate()
            return
        }
        var searchArray : [User] = []
        
        Task {
//            print("in")
            let searchText = searchText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            searchArray = try await (currentSegment == nil
                                     ? UsersManager.getAllUsers()
                                     : UsersManager.getUsers(ofType: currentSegment!))
            
//            print(currentSegment == nil
//                         ? "UsersManager.getAllUsers()"
//                         : "UsersManager.getUsers(ofType: currentSegment!))")
            self.users = searchArray.filter { user in
                let searchText = searchText.lowercased()
                let fullName = user.fullName.lowercased()
                let email = user.email.lowercased()
                
                let nameMatches = fullName.split(separator: " ").contains { $0.starts(with: searchText) }
                
                let fullNameContains = fullName.starts(with: searchText)
                
                let emailContains = email.contains(searchText)
                
                return nameMatches || fullNameContains || emailContains
            }

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}


// extention for filds validations for create oragnizer --> inclide the function that related to the validation
extension AdminUsersViewController{
    
        
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



// MARK: Shared functions
extension AdminUsersViewController{
    
    func showAlert(message: String, completion: (() -> Void)? = nil) {
         let alert = UIAlertController(title: "Reset Password", message: message, preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
             completion?()
         }))
         present(alert, animated: true, completion: nil)
     }
    
    
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
        
        //reset the user password
        //TODO: FATIMA
        
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

            self.navigationController?.popViewController(animated: true)
        }
        
        saveAlert.addAction(okAction)
        
        self.present(saveAlert, animated: true, completion: nil)
    

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
    
    func saveAlert(){
        // 3. Show an alert notifying the user that the changes have been saved
        let saveAlert = UIAlertController(
            title: "Save Changes",
            message: "Your changes have been saved successfully.",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
            self.navigationController?.popToRootViewController(animated: true)
        }
        
        saveAlert.addAction(okAction)
        present(saveAlert, animated: true, completion: nil)
    }
    
}
