//
//  AdminUsersViewController.swift
//  YellaEvent
//
//  Created by meme on 25/11/2024.
//

import UIKit

class AdminUsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var addOrganizer: UIBarButtonItem!
    @IBOutlet weak var userListSections: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // to make the add functionlity only show in the organizer tab
        if userListSections.selectedSegmentIndex == 2 {
            addOrganizer.isEnabled = false
        }else{
            addOrganizer.isHidden = true
        }
        updateSegment()
        
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
            if userListSections.selectedSegmentIndex == i{
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
        updateSegment()
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // the number of the users
        let section = userListSections.selectedSegmentIndex
        var num = 0
        // depanding on the tab I should return the nuber of users
        switch section {
        case 0:
            num = 1
        case 1:
            num =  1
        case 2:
            num = 0
        case 3:
            num = 0
        default:
            break
        }
        
        
        return num
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // custmize the cell
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as! AdminUserManagmentTableViewCell
        
        // chnage the name to the user name and the email to the user email
        cell.setupcell(username: "Fatima", email: "Fatima45@gmail.com")
        
        return cell
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
