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
    @IBOutlet weak var eventStatusLabel: UILabel!
    @IBOutlet weak var eventAgeLabel: UILabel!
    @IBOutlet weak var eventVenueLabel: UILabel!
    @IBOutlet weak var ticketCountLabel: UILabel!
    @IBOutlet weak var ticketStepper: UIStepper!

    @IBOutlet weak var ViewOrg: UIBarButtonItem!
    @IBAction func showPage(_ sender: Any) {
    }
    
    
    // MARK: - Properties
    var eventID: String = "3jCdiZ7OrVUAksiBrZwr" // The event ID to fetch
    var event: Event? // This will hold the event data for this screen.
    var ticketCount: Int = 0 // Keeps track of the current ticket count

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Set the initial ticket count label text
      //ticketCountLabel.text = "\(ticketCount) Ticket"
       
        

        // Fetch and populate event data
        fetchEventAndUpdateUI()
    }

    // MARK: - Fetch Event
    func fetchEventAndUpdateUI() {
        Task {
            do {
                // Fetch the event using the EventsManager
                let fetchedEvent = try await EventsManager.getEvent(eventID: eventID)
                self.event = fetchedEvent

                // Update the UI on the main thread
                DispatchQueue.main.async {
                    self.populateEventData()
                }
            } catch {
                print("Failed to fetch event: \(error)")
            }
        }
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
    @IBAction func TicketIncrease(_ sender: UIButton) {
           
       }

      @IBAction func TicketIderease(_ sender: UIButton) {
           
       }

       
    @IBAction func TicketStepperValueChanged(_ sender: UIStepper) {
        guard let ticketStepper = ticketStepper else {
            print("ticketStepper is nil!")
            return
        }
        
        ticketCount = Int(ticketStepper.value) // Update ticket count from stepper's value
        ticketCountLabel.text = "\(ticketCount) Ticket"
    }



}
