//
//  AdminUsersViewController.swift
//  YellaEvent
//
//  Created by meme on 25/11/2024.
//

import UIKit
import FirebaseFirestore

//MARK: local Exception
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

//MARK: Class Start
class AdminUsersViewController: UIViewController {
    
    let dateFormatter = DateFormatter()
    
    //MARK: Outlet
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
    var organizerName: String?
    var backFromCell = false
    
    
    //form the main page + button
    @IBAction func CreateButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "createUser", sender: sender)
    }
    
    
    
    //Ban Account Page
    //outlets
    @IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var txtBanReason: UIButton!
    @IBOutlet weak var txtBanduration: UIButton!
    @IBOutlet weak var txtDuration: UITextField!
    @IBOutlet weak var lastField: UIStackView!
    
    //Errors lable
    @IBOutlet weak var lblErrorBanReason: UILabel!
    @IBOutlet weak var lblErrorBanDuration: UILabel!
    @IBOutlet weak var lblErrorDescription: UILabel!
    @IBOutlet weak var lblErrorDuration: UILabel!
    
    var banReasons = ["Abusive Behavior", "Spam", "Fraudulent Activity", "Harassment", "Other"]
    
    var banDuration = ["24 Hours", "7 Days", "14 Days", "1 Month", "1 Year", "Permanent", "Custom Duration"]
    
    
    
    
    //MARK: Actions
    @IBAction func ConformBan(_ sender: Any) {
        // 1. Validation
        guard validationBan() else {
            return
        }
        // 2. Get the selected duration and convert it into days
        let selectedDurationText = txtBanduration.titleLabel?.text ?? ""
        let selectedDurationInDays = getDurationInDays(from: selectedDurationText)
        
        // 3. Calculate the end date by adding the duration to today's date
        let startDate = Date()  // today's date
        let endDate = calculateEndDate(from: startDate, durationInDays: selectedDurationInDays)
        
        // 4. Call the UsersManager.banUser method with startDate and endDate
        let txt = (txtBanReason.titleLabel?.text)!
        
        Task{
            try UsersManager.banUser(userID: currentUser!.userID, userType: currentUser!.type, reason: txt, description: txtDescription.text, startDate: startDate, endDate: endDate)
        }
        
        // 5. Show the confirmation alert
        banConformation()
        
    }
    
    @IBAction func BanReasonClicked(_ sender: Any) {
        showDropdown(options: banReasons, for: txtBanReason, title: "Select Ban Reason")
    }
    
    @IBAction func BanDurationaClicked(_ sender: Any) {
        showDropdown(options: banDuration, for: txtBanduration, title: "Select Ban Duration")
    }
    
    //MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        
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
            }
            // Safely update users
            do {
                usersUpdate()
            }
        }
        
        
        do{
            if let _ = txtBanReason {
                txtBanReason.setTitle("Select Ban Reason", for: .normal)
                txtBanduration.setTitle("Select Ban Duration", for: .normal)
                lastField.isHidden = true
            }
        }
        
        
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
        }else if (segue.identifier == "showEvents"){
            if let navController = segue.destination as? UINavigationController,
               let destination = navController.topViewController as? AdminEventsViewController {
                // Successfully accessed AdminEventsViewController
                destination.orgName = organizerName
            }
            
            
            
        }
        
        super.prepare(for: segue, sender: sender)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if let userListSections = userListSections{
            if !backFromCell {
                userListSections.selectedSegmentIndex = 0
                clickOnSegment(userListSections)
            } else {
                backFromCell = false
            }
        }
    }
    
    @IBAction func unwindfromFAQs(for unwindSegue: UIStoryboardSegue, towards subsequentVC: UIViewController) {
        
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
        return tableView.frame.width / 5
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let user = users[indexPath.row]
        currentUser = user
        
        if (user.type == .admin){
            performSegue(withIdentifier: "ViewAdminPage", sender: self)
            backFromCell = true
            
            
        }else if (user.type == .customer){
            performSegue(withIdentifier: "ViewCustomerPage", sender: self)
            backFromCell = true
            
        }else if (user.type == .organizer){
            performSegue(withIdentifier: "ViewOrganizerPage", sender: self)
            backFromCell = true
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
                UsersManager.getAllUsers(listener: listner())
                currentSegment = nil
            case 1:
                UsersManager.addUsersListener(userType: .customer, listener: listner())
                currentSegment = .customer
            case 2:
                UsersManager.addUsersListener(userType: .organizer, listener: listner())
                currentSegment = .organizer
            case 3:
                UsersManager.addUsersListener(userType: .admin, listener: listner())
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
            let searchText = searchText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            searchArray = try await (currentSegment == nil
                                     ? UsersManager.getAllUsers()
                                     : UsersManager.getUsers(ofType: currentSegment!))
            
            
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
    
    
    func highlightField(_ textField: UIView?) {
        textField?.layer.borderWidth = 1
        textField?.layer.borderColor = UIColor.red.cgColor
        textField?.layer.cornerRadius = 5
    }
    
    func resetFieldHighlight(_ textField: UIView?) {
        textField?.layer.borderWidth = 0
        textField?.layer.borderColor = UIColor.clear.cgColor
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
    
    func validationBan() -> Bool{
        
        var isValidate = true
        
        //Ban reason validation
        if txtBanReason.titleLabel?.text == "Select Ban Reason"{
            lblErrorBanReason.text = "Please select a reason."
            highlightField(txtBanReason)
            isValidate = false
        }else{
            lblErrorBanReason.text = ""
            resetFieldHighlight(txtBanReason)
        }
        
        //Ban Duration validation
        if txtBanduration.titleLabel?.text == "Select Ban Duration"{
            lblErrorBanDuration.text = "Please select a duration."
            highlightField(txtBanduration)
            isValidate = false
        }else{
            lblErrorBanDuration.text = ""
            resetFieldHighlight(txtBanduration)
        }
        
        
        // Duration Validation
        if !lastField.isHidden {
            if txtDuration.text!.isEmpty {
                lblErrorDuration.text = "Please enter a duration."
                highlightField(txtDuration)
                isValidate = false
            } else if Int(txtDuration.text!) == nil { // Check if it's a valid number
                lblErrorDuration.text = "Please enter a valid numeric duration."
                highlightField(txtDuration)
                isValidate = false
            } else {
                lblErrorDuration.text = ""
                resetFieldHighlight(txtDuration)
            }
        }
        
        
        //Description Validation
        if txtDescription.text.isEmpty{
            lblErrorDescription.text = "Please enter a description."
            highlightField(txtDescription)
            isValidate = false
        }else{
            lblErrorDescription.text = ""
            resetFieldHighlight(txtDescription)
        }
        
        
        
        return isValidate
    }
    
    
    
    
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
        
        if selectedOption == "Custom Duration"{
            lastField.isHidden = false
        }else{
            lastField.isHidden = true
        }
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
    
    
    func showEvents(){
        performSegue(withIdentifier: "showEvents", sender: self)
    }
    
    
    
    
}
