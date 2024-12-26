//  OrganizerViewEventView.swift
//  YellaEvent
//
//  Created by meme on 22/12/2024.
//

import UIKit

class OrganizerViewEventView: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet var eventStatus: UILabel!
    @IBOutlet var eventTitle: UILabel!
    @IBOutlet var statusCircle: UIImageView!
    @IBOutlet var dayOfMonth: UILabel!
    @IBOutlet var Month: UILabel!
    @IBOutlet var dayOfweek: UILabel!
    @IBOutlet var startToEndTime: UILabel!
    @IBOutlet var minimumAge: UILabel!
    @IBOutlet var Venue: UILabel!
    
    @IBOutlet var ticketsSold: UILabel!
    @IBOutlet var avarageRating: UILabel!
    @IBOutlet var remainingTickets: UILabel!
    @IBOutlet var totalAttendens: UILabel!
    @IBOutlet var eventImageView: UIImageView! // Added for event image
    
    // MARK: - Properties
    var eventID: String = "" // The event ID to fetch
    var event: Event? // This will hold the event data
    var usersDec : [String:String] = [:]
    // MARK: - View Lifecycle
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchEventAndUpdateUI()
    }
    
    // MARK: - Fetch event and update UI
    func setup(eventID: String) {
        self.eventID = eventID
        fetchEventAndUpdateUI()
    }
    
    func getStats() {
    }
    func fetchEventAndUpdateUI() {
        Task {
            do {
                // Fetch the event using the EventsManager
                let fetchedEvent = try await EventsManager.getEvent(eventID: eventID)
                self.event = fetchedEvent
                
//                TicketsManager.getEventAttendance(eventId: eventID) { usersDec, totalTickets, attendedTickets in
//                    self.ticketsSold.text = "\(totalTickets)"
//                    self.totalAttendens.text = "\(attendedTickets)"
//                    self.remainingTickets.text = self.event?.maximumTickets - totalTickets
//                }

                // Update the UI with event data
                DispatchQueue.main.async {
                    self.populateEventData()
                }
                
                // Fetch and display the average rating
               
                
            } catch {
                print("Failed to fetch event: \(error)")
            }
        }
    }
    
    
    @IBAction func optionSelectionDelete(_ sender: UIAction) {
        let title = sender.title
        print(title)
    
    }
    
    @IBAction func optionSelectionEdit(_ sender: UIAction) {
        performSegue(withIdentifier: "showEdit", sender: self)
    
    }
    
    @IBAction func optionSelectionCnacel(_ sender: UIAction) {
        let title = sender.title
        print(title)
    
    }
    
    
    
    // MARK: - Populate event data into UI
    func populateEventData() {
        guard let event = event else { return }
        
        // Load event image
        if let url = URL(string: event.coverImageURL) {
            loadImage(from: url) { [weak self] image in
                self?.eventImageView.image = image
            }
        }
        
        // Set event title
        eventTitle.text = event.name
        
        // Set event status
        eventStatus.text = event.status.rawValue.capitalized
        
        // Set event date (day of the month, month, and day of the week)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d" // Day of the month
        dayOfMonth.text = dateFormatter.string(from: event.startTimeStamp)
        
        dateFormatter.dateFormat = "MMM" // Month (short)
        Month.text = dateFormatter.string(from: event.startTimeStamp)
        
        dateFormatter.dateFormat = "EEEE" // Day of the week
        dayOfweek.text = dateFormatter.string(from: event.startTimeStamp)
        
        // Format event time
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a" // Time in 12-hour format with AM/PM
        let startTime = timeFormatter.string(from: event.startTimeStamp)
        let endTime = timeFormatter.string(from: event.endTimeStamp)
        startToEndTime.text = "\(startTime) - \(endTime)"
        
        // Set minimum age
        minimumAge.text = "\(event.minimumAge)-\(event.maximumAge)"
        
        // Set venue name
        Venue.text = event.venueName
    }
    
    // MARK: - Calculate and display average rating

    // MARK: - Helper function to load image asynchronously
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
