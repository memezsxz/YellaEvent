//
//  AdminUsersViewController.swift
//  YellaEvent
//
//  Created by meme on 25/11/2024.
//

import UIKit
import FirebaseFirestore

class AdminUsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
//Test
    
    
//Users List page outlet
    @IBOutlet weak var addOrganizer: UIBarButtonItem!
    @IBOutlet weak var userListSections: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var users : [User] = []

//Create Organizer Outlet
    

    
////shard values
//let accountDuration = ["Never Expire", "One Day", "One Week", "Two Weeks", "One Month", "One Year", "Custom Duration"]
    
//    let pickerView = UIPickerView()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: "MainTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "MainTableViewCell")
        
//        Task {
//            try await UsersManager.getInstence().createNewUser(user: User(id: "3232", firstName: "3223", lastName: "2323", email: "323@232.com", dob: Date.now, dateCreated: Date.now, phoneNumber: 323232, badgesArray: [], profileImageURL: "sds", type: .organizer))
//        }
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
    
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            // the number of the users
//            let section = userListSections.selectedSegmentIndex
//            var num = 0
//            // depanding on the tab I should return the nuber of users
//            switch section {
//            case 0:
//                num = 2
//            case 1:
//                num =  4
//            case 2:
//                num = 2
//            case 3:
//                num = 1
//            default:
//                break
//            }
            
            
            return users.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            // custmize the cell
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell") as! MainTableViewCell
            let user = users[indexPath.row]
            // chnage the name to the user name and the email to the user email
            
            cell.title.text = user.firstName + " " + user.lastName
            cell.subtext.text = user.email
            
            return cell
        }
    
 
    func usersUpdate() {
        let section = userListSections.selectedSegmentIndex
        switch section {
        case 0:
            Task {
                UsersManager.getInstence().getAllUsers(listener: listner())
            }
        case 1:
            Task {
                UsersManager.getInstence().addUsersListener(userType: .customer, listener: listner())
            }
        case 2:
            Task {
                UsersManager.getInstence().addUsersListener(userType: .organizer, listener: listner())
            }
        case 3:
            Task {
                UsersManager.getInstence().addUsersListener(userType: .admin, listener: listner())
            }
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//create organizer functions
//extension AdminUsersViewController{
//    
//    
//}
