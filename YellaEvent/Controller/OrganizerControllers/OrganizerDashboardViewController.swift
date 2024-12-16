//
//  OrganizerDashboardViewController.swift
//  YellaEvent
//
//  Created by meme on 25/11/2024.
//

import UIKit

extension UIViewController {
  func sizeClass() -> (UIUserInterfaceSizeClass, UIUserInterfaceSizeClass) {
      return (self.traitCollection.horizontalSizeClass, self.traitCollection.verticalSizeClass)
  }
}

class OrganizerDashboardViewController: UITableViewController {
    var organizer : Organizer?
    
    @IBOutlet var helloLabel: UILabel!
    var onGoingEvents : [String: String] = [:]
    
    @IBOutlet var canceledEventsLabel: UILabel!
    @IBOutlet var overEventsLabel: UILabel!
    @IBOutlet var ongoingEventsLabel: UILabel!
    @IBOutlet var allEventsLabel: UILabel!
    
    
    @IBOutlet var totalAttendence: UILabel!
    @IBOutlet var revenueLabel: UILabel!
    @IBOutlet var averageRatingLabel: UILabel!
    @IBOutlet var soldTicketsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        Task {
        //            self.organizer = try await UsersManager.getOrganizer(organizerID: UserDefaults.standard.string(forKey: K.bundleUserID)!)
        //        }
        
        UserDefaults.standard.set("0TgGkZPHew1WhMNVvHcU", forKey: K.bundleUserID) // this will be removed after seting the application
        
        Task {
            self.organizer = try await UsersManager.getOrganizer(organizerID: UserDefaults.standard.string(forKey: K.bundleUserID)!)
            
            let fullName = self.organizer!.fullName
            
            let welcomeText = "Hi \(fullName), Welcome to your Dashboard"
            
            self.helloLabel.text  = welcomeText
            
            let attributedString = NSMutableAttributedString(string: welcomeText)
            
            if let nameRange = welcomeText.range(of: fullName) {
                let nsRange = NSRange(nameRange, in: welcomeText)
                attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: self.helloLabel.font.pointSize), range: nsRange)
            }
            
            // Set the attributed string to the label
            self.helloLabel.attributedText = attributedString
            
        }
        
        tableView.register(UINib(nibName: "MainTableViewCell", bundle: .main), forCellReuseIdentifier: "MainTableViewCell")
        
        //        Task {
        //            self.organizer = try await UsersManager.getOrganizer(organizerID: UserDefaults.standard.string(forKey: K.bundleUserID)!)
        //        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Task {
            try await EventsManager.getDashboardStats(organizerID: UserDefaults.standard.string(forKey: K.bundleUserID)!, completion: { canceledEvents,overEvents,ongoingEvents,allEvents,numTotalAttendence,revenue,averageRating,soldTickets in
                
                DispatchQueue.main.async {
                    self.canceledEventsLabel.text = "\(canceledEvents)"
                    self.overEventsLabel.text = "\(overEvents)"
                    self.ongoingEventsLabel.text = "\(ongoingEvents)"
                    self.allEventsLabel.text = "\(allEvents)"
                    
                    self.totalAttendence.text = "\(numTotalAttendence)"
                    self.revenueLabel.text = String(format: "%.3f", revenue)
                    self.averageRatingLabel.text = String(format: "%.1f", averageRating)
                    self.soldTicketsLabel.text = "\(soldTickets)"

                }
            }
            )
        }
        
        Task {
            EventsManager.getOrganizerEvents(organizerID: UserDefaults.standard.string(forKey: K.bundleUserID)!) { snapshot, error in
                guard let snapshot else { return }
                
                for event in snapshot.documents {
                    if event.data()[K.FStore.Events.status] as! String == EventStatus.ongoing.rawValue {
                        
                        self.onGoingEvents[event.data()[K.FStore.Events.eventID] as! String] = event.data()[K.FStore.Events.name] as? String
                    }
                    
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        if section == 1 {
            return onGoingEvents.count
        }
        
        return 0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath) as! MainTableViewCell
            
            cell.title.text = Array(onGoingEvents)[indexPath.row].value
            
            return cell
        }
        
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return tableView.frame.width / 6
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            tableView.cellForRow(at: indexPath)?.isSelected = false
        }
        
        if indexPath.section == 1 {
            let eventID = Array(onGoingEvents)[indexPath.row].key
            
            let eventsNavigationController = self.tabBarController?.viewControllers?[1] as! UINavigationController
            
            
            if let viewcontroller = eventsNavigationController.viewControllers.first as? OrganizerEventsViewController {
                viewcontroller.selectedEventID = eventID
            }
            
            self.tabBarController?.selectedViewController = eventsNavigationController
            eventsNavigationController.popToRootViewController(animated: true)
            
            //            let eventsViewController  = eventsViews?.first as? OrganizerEventsViewController
            //            print(eventsViews)
            //            eventsViewController?.selectedEventID = eventID
            
            //            eventsViewController?.tableView.selectRow(at: IndexPath(row: <#T##Int#>, section: 0), animated: <#T##Bool#>, scrollPosition: <#T##UITableView.ScrollPosition#>)
            // navigate to the event's details screen
            
            //            eventsViewController?.sea
            
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if section == 1 {

                // Find the UILabel inside the default header view (if it exists)
                let headerView = UIView()
                headerView.backgroundColor = .clear // Or set to a desired background color
                
                // Add a new UILabel
                let label = UILabel()
                label.text = "On Going Events"
            let HSizeClass = UIScreen.main.traitCollection.horizontalSizeClass
            let VSizeClass = UIScreen.main.traitCollection.verticalSizeClass
            if HSizeClass == .regular && VSizeClass == .regular {
                label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
            } else {
                label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            }
                label.textColor = UIColor(named: K.BrandColors.darkPurple)
//                label.textAlignment = .center
                
                // Add the label to the header view
                headerView.addSubview(label)
            
            
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
                label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
                label.topAnchor.constraint(equalTo: headerView.topAnchor),
                label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
            ])

            
                return headerView
            
        }
        
        return super.tableView(tableView, viewForHeaderInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        
        return super.tableView(tableView, heightForHeaderInSection: section)
    }
}
