//
//  OrganizerDashboardViewController.swift
//  YellaEvent
//
//  Created by meme on 25/11/2024.
//

import UIKit

class OrganizerDashboardViewController: UITableViewController {
    
    var organizer: Organizer?
    var statCell: OrganizerStatsTableViewCell? = nil
    
    var onGoingEvents: [String: String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set("VxVB0GrEFw5ToXf2dO6q", forKey: K.bundleUserID) // this will be removed after seting the application
    }
    
    override func viewWillAppear(_ animated: Bool) {
        statCell?.update()
    }
}

extension OrganizerDashboardViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            tableView.register(UINib(nibName: "MainTableViewCell", bundle: .main), forCellReuseIdentifier: "MainTableViewCell")
            let cell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath) as! MainTableViewCell
            cell.title.text = Array(statCell!.onGoingEvents)[indexPath.row].value
            return cell
        }
        
        tableView.register(UINib(nibName: "OrganizerStatsTableViewCell", bundle: .main), forCellReuseIdentifier: "OrganizerStatsTableViewCell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrganizerStatsTableViewCell", for: indexPath) as! OrganizerStatsTableViewCell
        
        cell.delegate = self
        statCell = cell
        statCell?.update()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return tableView.frame.width / 6
        }
        
        return tableView.frame.height / 2
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            tableView.cellForRow(at: indexPath)?.isSelected = false
        }
        
        if indexPath.section == 1 {
            let eventID = Array(statCell!.onGoingEvents)[indexPath.row].key
            
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
            headerView.backgroundColor = UIColor(named: K.BrandColors.backgroundGray) // Or set to a desired background color
            
            // Add a new UILabel
            let label = UILabel()
            label.text = "On Going Events"
            if K.HSizeclass == .regular && K.VSizeclass == .regular {
                label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
            } else {
                label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            }
            
            label.textColor = UIColor(named: K.BrandColors.darkPurple)
            
            headerView.addSubview(label)
            
            
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
                label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
                label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: -10),
                label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 10)
            ])
            
            
            return headerView
            
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        
        return K.HSizeclass == .regular && K.VSizeclass == .regular ? 50 : 30
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        if section == 1 {
            return statCell?.onGoingEvents.count ?? 0
        }
        
        return 0
    }
}

extension OrganizerDashboardViewController : OrganizerStatsTableViewCellDelegate {
    func didUpdateOngoingEvents(_ events: [String : String]) {
        self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
    }
}
