//
//  AdminEventView.swift
//  YellaEvent
//
//  Created by meme on 29/12/2024.
//

import UIKit

class AdminEventView: UIView {
    var delegate: AdminEventsViewController?
    var eventID : String?
    var event : Event?
    
    @IBAction func viewOrganizerButtonClicked(_ sender: UIBarButtonItem) {
        delegate?.tabBarController?.selectedIndex = 1
        let usersController = (delegate?.tabBarController?.selectedViewController as! UINavigationController).topViewController as! AdminUsersViewController
        let _ = usersController.view
        let userIndex = usersController.users.firstIndex {
            $0.userID == event?.organizerID
        }
        print(userIndex)
        
        if let userIndex = userIndex {
            usersController.tableView.scrollToRow(at: IndexPath(row: userIndex, section: 0), at: .middle, animated: true)
        
            usersController.tableView(usersController.tableView, didSelectRowAt: IndexPath(row: userIndex, section: 0))
        }
        
        
    }
    
    @IBOutlet var eventStatus: UILabel!
    @IBOutlet var eventTitle: UILabel!
//    @IBOutlet var statusCircle: UIImageView!
    @IBOutlet var dayOfMonth: UILabel!
    @IBOutlet var Month: UILabel!
    @IBOutlet var dayOfweek: UILabel!
    @IBOutlet var startToEndTime: UILabel!
    @IBOutlet var minimumAge: UILabel!
    @IBOutlet var Venue: UILabel!
    @IBOutlet var eventImageView: UIImageView!
    @IBOutlet weak var EventDescription: UITextView!
    @IBOutlet weak var price: UILabel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    

    

    func fetchEventAndUpdateUI() {
        Task {
            do {
                let fetchedEvent = try await EventsManager.getEvent(eventID: eventID!)
                self.event = fetchedEvent
                
                DispatchQueue.main.async {
                    self.populateEventData()
                }
            } catch {
                print("Failed to fetch event: \(error)")
            }
        }
    }
    
    func populateEventData() {
        guard let event = event else { return }
        
        if let url = URL(string: event.coverImageURL) {
            loadImage(from: url) { [weak self] image in
                if let eventImageView = self?.eventImageView {
                    eventImageView.image = image
                }
            }
        }
        
        
        if let price = price {
            price.text = "\(event.price) per ticket"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        if let dayOfMonth = dayOfMonth {
            dayOfMonth.text = dateFormatter.string(from: event.startTimeStamp)
        }
        
        dateFormatter.dateFormat = "MMM"
        if let Month = Month {
            Month.text = dateFormatter.string(from: event.startTimeStamp)
        }
        
        dateFormatter.dateFormat = "EEEE"
        if let dayOfweek = dayOfweek {
            dayOfweek.text = dateFormatter.string(from: event.startTimeStamp)
        }
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        let startTime = timeFormatter.string(from: event.startTimeStamp)
        let endTime = timeFormatter.string(from: event.endTimeStamp)
        if let startToEndTime = startToEndTime {
            startToEndTime.text = "\(startTime) - \(endTime)"
        }
        
        if let EventDescription = EventDescription {
            EventDescription.text = event.description
        }
        
        if let eventStatus = eventStatus {
            eventStatus.text = event.status.rawValue.capitalized
            updateStatusLabelAppearance(status: event.status)
        }
        
        if let minimumAge = minimumAge {
            minimumAge.text = "\(event.minimumAge)-\(event.maximumAge)"
        }
        
        if let Venue = Venue {
            Venue.text = event.venueName
        }
        
        //                // Assuming organizerNameLabel is the outlet for organizer name
        //                if let organizerNameLabel = organizerNameLabel {
        //                    organizerNameLabel.text = event.organizerName
        //                }
    }
    
    func updateStatusLabelAppearance(status: EventStatus) {
        if let eventStatus = eventStatus {
            switch status {
            case .ongoing:
                eventStatus.textColor = .systemGreen
            case .cancelled:
                eventStatus.textColor = .systemRed
            case .completed:
                eventStatus.textColor = .systemBlue
            case .banned:
                eventStatus.textColor = .systemGray
            }
        }
    }
    
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
}
