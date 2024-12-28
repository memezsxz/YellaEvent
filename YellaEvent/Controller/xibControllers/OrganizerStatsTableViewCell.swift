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
            try await loadStats()
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
        Task {
            try await loadStats()
        }
        
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

    
    func loadStats() async throws {
        let id = UserDefaults.standard.string(forKey: K.bundleUserID)!
        async let _: () = {
            let eventsSum = try await EventsManager.getOrganizerEvents(organizerID: id).documents.count
            await MainActor.run {
                self.allEventsLabel.text = "\(eventsSum)"
            }
        }()
        
        async let _: () = {
            let ongoing = try await EventsManager.getEventsSum(organizerID: id, withStatus: .ongoing)
            await MainActor.run {
                self.ongoingEventsLabel.text = "\(ongoing)"
            }
        }()
        
        async let _: () = {
            let over = try await EventsManager.getEventsSum(organizerID: id, withStatus: .completed)
            await MainActor.run {
                self.overEventsLabel.text = "\(over)"
            }
        }()
        
        async let _: () = {
            let canceled = try await EventsManager.getEventsSum(organizerID: id, withStatus: .cancelled)
            await MainActor.run {
                self.canceledEventsLabel.text = "\(canceled)"
            }
        }()
        
        async let _: () = {
            let sold = try await TicketsManager.getOrginizerSoldTicketsSum(organizerID: id)
            await MainActor.run {
                self.soldTicketsLabel.text = "\(sold)"
            }
        }()

        async let _: () = {
            let revenue = try await TicketsManager.getOrginizerSoldTicketsRevenue(organizerID: id)
            await MainActor.run {
                self.revenueLabel.text = String(format: "%.3f", revenue)
            }
        }()
        
        async let _: () = {
            let rating = try await RatingManager.getOrganizerRating(organizerID: id)
            await MainActor.run {
                self.averageRatingLabel.text = String(format: "%.2f", rating)
            }
        }()
        
        async let _: () = {
            let attended = try await TicketsManager.getOrginizerAttendedTicketsSum(organizerID: id)
            await MainActor.run {
                self.totalAttendence.text = "\(attended)"
            }
        }()
    }
}
