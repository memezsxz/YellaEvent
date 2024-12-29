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
        
        // Set Event Name
        if let eventTitle = eventTitle {
            eventTitle.text = event.name // Assuming `event.name` contains the event name
        }
        
        // Set Event Status
        if let eventStatus = eventStatus {
            eventStatus.text = event.status.rawValue.capitalized // Convert status to a readable format
            updateStatusLabelAppearance(status: event.status) // Update color based on status
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
    
    @IBAction func DeleteEvent(_ sender: Any) {
        guard let event = event else { return }
        
        let alert = UIAlertController(
            title: "Delete Event",
            message: "Are you sure you want to delete this event? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            Task {
                do {
                    // Mark the event as deleted
                    try await EventsManager.deleteEvent(eventID: event.eventID)
                    
                    // Inform the delegate to pop or refresh the view
                    DispatchQueue.main.async {
                        self.delegate?.navigationController?.popViewController(animated: true)
                    }
                } catch {
                    print("Failed to delete event: \(error)")
                }
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        delegate?.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func BanEvent(_ sender: Any) {
        guard let event = event else { return }
        
        let alert = UIAlertController(
            title: "Ban Event",
            message: "Please provide a reason and description for banning this event.",
            preferredStyle: .alert
        )

        // Add a text field for the reason
        alert.addTextField { textField in
            textField.placeholder = "Reason for ban"
        }

        // Add a text field for additional description
        alert.addTextField { textField in
            textField.placeholder = "Additional description (optional)"
        }

        alert.addAction(UIAlertAction(title: "Ban", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            guard let reason = alert.textFields?[0].text, !reason.isEmpty else {
                // If the reason field is empty, show an error and return
                let errorAlert = UIAlertController(
                    title: "Error",
                    message: "The reason for banning cannot be empty.",
                    preferredStyle: .alert
                )
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self.delegate?.present(errorAlert, animated: true, completion: nil)
                return
            }

            let description = alert.textFields?[1].text ?? ""

            Task {
                do {
                    // Ban the event
                    try await EventsManager.banEvent(event: event, reason: reason, description: description)

                    // Inform the delegate to pop or refresh the view
                    DispatchQueue.main.async {
                        self.delegate?.navigationController?.popViewController(animated: true)
                    }
                } catch {
                    print("Failed to ban event: \(error)")

                    // Show an error message
                    let errorAlert = UIAlertController(
                        title: "Error",
                        message: "Failed to ban the event. Please try again later.",
                        preferredStyle: .alert
                    )
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.delegate?.present(errorAlert, animated: true, completion: nil)
                }
            }
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        delegate?.present(alert, animated: true, completion: nil)
    }

}
