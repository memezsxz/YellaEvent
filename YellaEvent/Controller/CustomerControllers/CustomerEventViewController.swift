//
//  CustomerEventViewController.swift
//  YellaEvent
//
//  Created by Admin on 02/12/2024.
//

import UIKit

class CustomerEventViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventPriceLabel: UILabel!
    @IBOutlet weak var dayOfMonthLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var dayOfWeekLabel: UILabel!
    @IBOutlet weak var eventTimeLabel: UILabel!
    @IBOutlet weak var eventDescriptionTextView: UITextView!
    @IBOutlet weak var eventStatusLabel: UILabel! // New status label

    @IBOutlet weak var eventAgeLabel: UILabel! // Age label
    @IBOutlet weak var eventVenueLabel: UILabel! // Venue label
    @IBOutlet weak var ticketCountLabel: UILabel! // Ticket count label
    @IBOutlet weak var ticketStepper: UIStepper!
    
    
    // MARK: - Local Object
    var event: Event? // This will hold the event data for this screen.
    var ticketCount: Int = 0 // Global ticket count variable

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ticketCountLabel.text = "\(ticketCount) Ticket" // Set the initial label format

        // Create a sample event for testing
        
        let musicCategory = Category(
            categoryID: "1",
            name: "Music",
            icon: "music_icon.png",
            status: .enabled
        )
        
        let sampleEvent = Event(
            organizerID: "123",
            organizerName: "John Doe",
            name: "Music Festival",
            description: "A fun-filled night with live music, food, and entertainment!",
            startTimeStamp: Date(),
            endTimeStamp: Date().addingTimeInterval(4 * 3600), // 4 hours later
            status: .ongoing,
            category: musicCategory ,
            locationURL: "https://example.com",
            venueName: "Aldana",
            minimumAge: 18,
            maximumAge: 60,
            maximumTickets: 500,
            price: 20.0,
            coverImageURL: "https://example.com/image.jpg",
            mediaArray: []
        )

        // Assign the sample event to the event property
        self.event = sampleEvent

        // Populate the UI with the sample event data
        populateEventData()
    }

    // MARK: - Populate Data
    func populateEventData() {
        guard let event = event else { return }

        // Load event image
        if let url = URL(string: event.coverImageURL) {
            loadImage(from: url) { [weak self] image in
                self?.eventImageView.image = image
            }
        }

        // Set event name
        eventNameLabel.text = event.name

        // Set event price
        eventPriceLabel.text = "\(event.price) per ticket"

        // Format date components
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d" // Day of the month
        dayOfMonthLabel.text = dateFormatter.string(from: event.startTimeStamp)

        dateFormatter.dateFormat = "MMM" // Month (short)
        monthLabel.text = dateFormatter.string(from: event.startTimeStamp)

        dateFormatter.dateFormat = "EEEE" // Day of the week
        dayOfWeekLabel.text = dateFormatter.string(from: event.startTimeStamp)

        // Format event time
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a" // Time in 12-hour format with AM/PM
        let startTime = timeFormatter.string(from: event.startTimeStamp)
        let endTime = timeFormatter.string(from: event.endTimeStamp)
        eventTimeLabel.text = "\(startTime) - \(endTime)"

        // Set event description
        eventDescriptionTextView.text = event.description

        // Set event status
        eventStatusLabel.text = event.status.rawValue.capitalized
        updateStatusLabelAppearance(status: event.status)

        // Set age range label
        eventAgeLabel.text = "\(event.minimumAge)-\(event.maximumAge)" // Just the number range

        // Set venue name label
        eventVenueLabel.text = event.venueName // Just the venue name
    }

    // MARK: - Helper Functions
    func updateStatusLabelAppearance(status: EventStatus) {
        switch status {
        case .ongoing:
            eventStatusLabel.textColor = .systemGreen
        case .cancelled:
            eventStatusLabel.textColor = .systemRed
        case .completed:
            eventStatusLabel.textColor = .systemBlue
        case .banned:
            eventStatusLabel.textColor = .systemGray
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
    
    // MARK: - Ticket Count Actions
    // Increase ticket count (for "+")
   
    
    
    @IBAction func TicketIncrease(_ sender: UIButton) {
        
    }

   @IBAction func TicketIderease(_ sender: UIButton) {
        
    }

    
    @IBAction func TicketStepperValueChanged(_ sender: UIStepper) {
        ticketCount = Int(sender.value) // Update ticket count from stepper's value
        ticketCountLabel.text = "\(ticketCount) Ticket"
    }


   
}
