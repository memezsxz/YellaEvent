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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEdit" {
            (segue.destination as? OrganizerEventEditViewController)?.event = self.event
        }
    }
    func getStats() {
    }
    func fetchEventAndUpdateUI() {
            Task {
                do {
                    // Fetch the event using the EventsManager
                    let fetchedEvent = try await EventsManager.getEvent(eventID: eventID)
                    self.event = fetchedEvent
                    
                    DispatchQueue.main.async {
                        self.populateEventData()
                    }
                } catch {
                    print("Failed to fetch event: \(error)")
                }
                
                async let attend: Int = {
                    let v = await TicketsManager.getEventAttendedTickets(eventId: self.eventID)
                    return v
                }()
                
                async let total: Int = {
                    let v = await TicketsManager.getEventTotalTickets(eventId: self.eventID)

                    return v
                }()
                
                // Await both tasks and calculate the remaining tickets
                let (attendedCount, totalCount) = await (attend, total)
                
                // Update the remaining tickets on the main thread
                await MainActor.run {
                    self.ticketsSold.text = "\(totalCount)"
                    self.totalAttendens.text = "\(attendedCount)"
                    self.remainingTickets.text = "\(event!.maximumTickets - totalCount)"
                }
                
                RatingManager.getEventRating(eventID: self.eventID) { result in
                    switch result {
                    case .success(let rating):
                        self.avarageRating.text = "\(rating)"
                    case .failure(let error):
                        print(error)
                    }
                }

            }
            // Update the UI with event data
            
            // Fetch and display the average rating
            
            
        
            
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
