//
//  CustomerEventOrganizerView.swift
//  YellaEvent
//
//  Created by Admin on 26/12/2024.
//

import UIKit

class CustomerEventOrganizerView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var organizerNameLabel: UILabel!
    
    var delegate : CustomerEventViewController?
    
    var organizerID = ""
    var events : [EventSummary] = []
    
    
    func load() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "EventSummaryTableViewCell", bundle: .main), forCellReuseIdentifier: "EventSummaryTableViewCell")
        Task {
            EventsManager.getOrganizerOngoingEvents(organizerID: organizerID) { snapshot, error in
                
                guard error == nil else {
                    print(error!)
                    return
                }
                
                guard let  snapshot else {
                    return
                }
                
                for doc in snapshot.documents {
                    Task {
                        do {
                            let eventSummary = try await EventSummary(from: doc.data())
                            DispatchQueue.main.async {
                                self.events.append(eventSummary)
                                self.tableView.insertRows(at: [IndexPath(row: self.events.count - 1, section: 0)], with: .bottom)
                            }
                            
                        } catch {
                            print("Error loading event")
                        }
                        
                    }
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventSummaryTableViewCell", for: indexPath) as! EventSummaryTableViewCell
        cell.setup(with: events[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.frame.width / 2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.eventID = events[indexPath.row].eventID
        delegate?.fetchEventAndUpdateUI()
        delegate?.navigationController?.popViewController(animated: true)
    }
    
}
