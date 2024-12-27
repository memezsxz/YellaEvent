//
//  CustomerLeaderboardViewController.swift
//  YellaEvent
//
//  Created by meme on 25/11/2024.
//

import UIKit
import FirebaseFirestore

class CustomerLeaderboardViewController: UIViewController {
    
    var customers: [Customer] = []
    var currentUserID = "r91ayZkyBvM21oL4akWY"
    @IBOutlet weak var tableView: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchLeaderboard()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "LeaderboardTableViewCell", bundle: nil), forCellReuseIdentifier: "LeaderboardTableViewCell")
    }
    
    private func fetchLeaderboard() {
        Task {
            do {
                let fetchedCustomers = try await UsersManager.getUsers(ofType: .customer) as! [Customer]
                self.customers = fetchedCustomers.sorted {
                    $0.badgesArray.count > $1.badgesArray.count
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    
                    // Automatically scroll to the current user's cell
                    if let currentUserIndex = self.indexOfCurrentUser() {
                        let indexPath = IndexPath(row: currentUserIndex, section: 0)
                        self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                    }
                }
            } catch {
                print("Error fetching leaderboard: \(error.localizedDescription)")
            }
        }
    }

    
    private func indexOfCurrentUser() -> Int? {
        return customers.firstIndex { $0.userID == currentUserID }
    }

}

extension CustomerLeaderboardViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderboardTableViewCell", for: indexPath) as! LeaderboardTableViewCell
            let customer = customers[indexPath.row]
            let rank = indexPath.row + 1
            let score = "\(customer.badgesArray.count) Badges"
            let isCurrentUser = customer.userID == currentUserID
        cell.setup(rank: rank, username: customer.fullName, score: score, isCurrentUser: isCurrentUser, userID: currentUserID)
        cell.delegate = self
            return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.width / 5
    }
    
    
}

extension CustomerLeaderboardViewController: LeaderboardTableViewCellDelegate {
    func didTapMyBadges(for userID: String) {
        guard let badgesVC = storyboard?.instantiateViewController(withIdentifier: "CustomerBadgesViewController") as? CustomerBadgesViewController else {
            return
        }

        // Fetch the badges asynchronously
        
            
            // Pass the fetched badges to the next view controller
        badgesVC.userID = currentUserID

            // Navigate to the badges view controller on the main thread
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(badgesVC, animated: true)
            }
        }
    }




