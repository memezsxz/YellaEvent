//
//  AdminUsersViewController.swift
//  YellaEvent
//
//  Created by meme on 25/11/2024.
//

import UIKit
import FirebaseFirestore

class AdminUsersViewController: UIViewController {
    
    //Test
    
    
    //Users List page outlet
    @IBOutlet weak var addOrganizer: UIBarButtonItem!
    @IBOutlet weak var userListSections: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchbar: UISearchBar!
    var users : [User] = []
    var currentSegment : UserType?
    
    //Create Organizer Outlet
    
    
    
    ////shard values
    //let accountDuration = ["Never Expire", "One Day", "One Week", "Two Weeks", "One Month", "One Year", "Custom Duration"]
    
    //    let pickerView = UIPickerView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: "UsersTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "UsersTableViewCell")
        
        searchbar.delegate = self
//                Task {
//                    try await UsersManager.getInstence().createNewUser(user: User(id: "202200805", firstName: "gtgggggggggggg", lastName: "hhhhhhhhhhghghg", email: "323jhjhyubyuybyh_ghg0000@232.com", dob: Date.now, dateCreated: Date.now, phoneNumber: 323232, badgesArray: [], profileImageURL: "sds", type: .organizer))
//                }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // to make the add functionlity only show in the organizer tab
        if userListSections.selectedSegmentIndex == 2 {
            addOrganizer.isEnabled = false
        }else{
            addOrganizer.isHidden = true
        }
        usersUpdate()
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

// MARK: - Segment
extension AdminUsersViewController {
    // function to change the segment text color
    func updateSegment(){
        
        let textAttributesNormal: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.brandDarkPurple, // Non-selected text color
            .font: UIFont.systemFont(ofSize: 14) // Customize font size
        ]
        
        let textAttributesSelected: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white, // Selected text color
            .font: UIFont.boldSystemFont(ofSize: 14) // Customize font size for selected
        ]
        
        // loop over the segment items
        for i in 0...userListSections.numberOfSegments{
            
            
            //if the tab selected the text could should be white
            if userListSections.selectedSegmentIndex == i {
                userListSections.setTitleTextAttributes(textAttributesSelected, for: .selected)
            }
            //if the tab not selected the text must be brandDarkPurple (defind color in the assets)
            else{
                userListSections.setTitleTextAttributes(textAttributesNormal, for: .normal)
            }
        }
        
    }
    
    
    
    @IBAction func clickOnSegment(_ sender: Any) {
        if userListSections.selectedSegmentIndex == 2 {
            addOrganizer.isHidden = false
        }else{
            addOrganizer.isHidden = true
        }
        usersUpdate()
    }
    
    
    //    func updateView(){
    //        usersUpdate()
    //        tableView.reloadData()
    //    }
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
        
        cell.title.text = user.firstName + " " + user.lastName
        cell.subtext.text = user.email
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.width / 6
    }

    
    func usersUpdate() {
        let section = userListSections.selectedSegmentIndex
        switch section {
        case 0:
            Task {
                UsersManager.getInstence().getAllUsers(listener: listner())
            }
            currentSegment = nil
        case 1:
            Task {
                UsersManager.getInstence().addUsersListener(userType: .customer, listener: listner())
            }
            currentSegment = .customer
        case 2:
            Task {
                UsersManager.getInstence().addUsersListener(userType: .organizer, listener: listner())
            }
            currentSegment = .organizer
        case 3:
            Task {
                UsersManager.getInstence().addUsersListener(userType: .admin, listener: listner())
            }
            currentSegment = .admin
        default:
            break
        }
    }
    
    func listner()  -> ((QuerySnapshot?, (any Error)?) -> Void)  {
        updateSegment()
        users.removeAll()
        
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
            self.users = []
            
            for doc in snapshot.documents {
                do {
                    let user = try doc.data(as: User.self)
                    self.users.append(user)
                } catch {
                    print(error.localizedDescription)
                }
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
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
        let section = userListSections.selectedSegmentIndex
        var searchArray : [User] = []

        Task {
            
            if currentSegment == nil {
                searchArray = try await UsersManager.getInstence().getAllUsers()
            } else {
                searchArray = try await UsersManager.getInstence().getUsersOfType(currentSegment!)
            }
            
            users = searchArray.filter { user in
                user.firstName.lowercased().starts(with: searchText.lowercased()) ||
                user.lastName.lowercased().starts(with: searchText.lowercased()) ||
                user.email.lowercased().starts(with: searchText.lowercased())
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

//create organizer functions
//extension AdminUsersViewController{
//
//
//}

