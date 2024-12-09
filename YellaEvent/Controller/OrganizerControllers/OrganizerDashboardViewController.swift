//
//  OrganizerDashboardViewController.swift
//  YellaEvent
//
//  Created by meme on 25/11/2024.
//

import UIKit

class OrganizerDashboardViewController: UITableViewController {
    
    @IBOutlet var canceledEventsLabel: UILabel!
    @IBOutlet var overEventsLabel: UILabel!
    @IBOutlet var ongoingEventsLabel: UILabel!
    @IBOutlet var allEventsLabel: UILabel!
    
    
    @IBOutlet var totalAttendence: UILabel!
    @IBOutlet var revenueLabel: UILabel!
    @IBOutlet var averageRatingLabel: UILabel!
    @IBOutlet var soldTicketsLabel: UILabel!
    
    var organizer : Organizer?
    
    override func viewWillAppear(_ animated: Bool) {
//        Task {
//            try await EventsManager.getDashboardStats(organizerID: "212``2", completion: { canceledEvents,overEvents,ongoingEvents,allEvents,numTotalAttendence,revenue,averageRating,soldTickets in
//                
//                DispatchQueue.main.async {
//                    self.canceledEventsLabel.text = "\(canceledEvents)"
//                    self.overEventsLabel.text = "\(overEvents)"
//                    self.ongoingEventsLabel.text = "\(ongoingEvents)"
//                    self.allEventsLabel.text = "\(allEvents)"
//                    
//                    self.totalAttendence.text = "\(numTotalAttendence)"
//                    self.revenueLabel.text = String(format: "%.3f", revenue)
//                    self.averageRatingLabel.text = String(format: "%.1f", revenue)
//                    self.soldTicketsLabel.text = "\(soldTickets)"
//                    
//                }
//            }
//            )
//        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        Task {
//            self.organizer = try await UsersManager.getOrganizer(organizerID: UserDefaults.standard.string(forKey: K.bundleUserID)!)
//        }
        // Do any additional setup after loading the view.
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
