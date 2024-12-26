//
//  CustomerLeaderboardViewController.swift
//  YellaEvent
//
//  Created by meme on 25/11/2024.
//

import UIKit
import FirebaseAuth

class CustomerLeaderboardViewController: UIViewController {
    
    var users: [User] = []
    
    @IBOutlet weak var tableView
    : UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        Task{
            do{
                self.users = try await UsersManager.getAllUsers()
            }
            
            catch{
                
            }
            
        }
        print(users)
    }
    
    
}


extension CustomerLeaderboardViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        return cell
    }
}
