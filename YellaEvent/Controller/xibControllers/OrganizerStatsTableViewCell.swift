//
//  OrganizerStatsTableViewCell.swift
//  YellaEvent
//
//  Created by meme on 20/12/2024.
//

import UIKit

protocol OrganizerStatsTableViewCellDelegate: AnyObject {
    func didUpdateOngoingEvents(_ events: [String: String])
}

class OrganizerStatsTableViewCell: UITableViewCell {
    var organizer : Organizer?

    weak var delegate: OrganizerStatsTableViewCellDelegate?

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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setup() {
        Task {
            try await EventsManager.getDashboardStats(organizerID: UserDefaults.standard.string(forKey: K.bundleUserID)!, completion: { canceledEvents,overEvents,ongoingEvents,allEvents,numTotalAttendence,revenue,averageRating,soldTickets in
                
                DispatchQueue.main.async {
                    self.canceledEventsLabel.text = "\(canceledEvents)"
                    self.overEventsLabel.text = "\(overEvents)"
                    self.ongoingEventsLabel.text = "\(ongoingEvents)"
                    self.allEventsLabel.text = "\(allEvents)"
                    
                    self.totalAttendence.text = "\(numTotalAttendence)"
                    self.revenueLabel.text = String(format: "%.3f", revenue)
                    self.averageRatingLabel.text = String(format: "%.2f", averageRating)
                    self.soldTicketsLabel.text = "\(soldTickets)"

                }
            }
            )
        }
        
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

    }
    
    func update() {
        Task{
            EventsManager.getOrganizerEvents(organizerID: UserDefaults.standard.string(forKey: K.bundleUserID)!) { snapshot, error in
                guard let snapshot else { return }
                
                var updatedEvents: [String: String] = [:]
                
                for event in snapshot.documents {
                    if event.data()[K.FStore.Events.status] as! String == EventStatus.ongoing.rawValue {
                        let eventID = event.data()[K.FStore.Events.eventID] as! String
                        let eventName = event.data()[K.FStore.Events.name] as? String
                        updatedEvents[eventID] = eventName
                    }
                }
                
                self.onGoingEvents = updatedEvents
                DispatchQueue.main.async {
                    self.delegate?.didUpdateOngoingEvents(self.onGoingEvents)
                }
            }
        }
    }

}
