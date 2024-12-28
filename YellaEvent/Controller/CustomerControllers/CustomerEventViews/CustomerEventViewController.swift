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
    @IBOutlet weak var organizerNameLabel: UILabel!
    @IBOutlet weak var ViewOrg: UIBarButtonItem!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    // MARK: - Properties
    var eventID: String = "3jCdiZ7OrVUAksiBrZwr" // The event ID to fetch
    var event: Event? // This will hold the event data for this screen.
    var ticketCount: Int = 0 // Keeps track of the current ticket count
    var organizer: Organizer? // This will hold the organizer data for this screen.
    var delegate : UIViewController?

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the initial ticket count label text
        if let ticketCountLabel = ticketCountLabel {
            ticketCountLabel.text = "\(ticketCount) Ticket"
        }
        
        backButton.title = "Back"
        navigationItem.leftBarButtonItem = backButton
//        backButto????n.
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
                if let eventImageView = self?.eventImageView {
                    eventImageView.image = image
                }
            }
        }

        // Set event name
        if let eventNameLabel = eventNameLabel {
            eventNameLabel.text = event.name
        }

        // Set event price
        if let eventPriceLabel = eventPriceLabel {
            eventPriceLabel.text = "\(event.price) per ticket"
        }

        // Format date components
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d" // Day of the month
        if let dayOfMonthLabel = dayOfMonthLabel {
            dayOfMonthLabel.text = dateFormatter.string(from: event.startTimeStamp)
        }

        dateFormatter.dateFormat = "MMM" // Month (short)
        if let monthLabel = monthLabel {
            monthLabel.text = dateFormatter.string(from: event.startTimeStamp)
        }

        dateFormatter.dateFormat = "EEEE" // Day of the week
        if let dayOfWeekLabel = dayOfWeekLabel {
            dayOfWeekLabel.text = dateFormatter.string(from: event.startTimeStamp)
        }

        // Format event time
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a" // Time in 12-hour format with AM/PM
        let startTime = timeFormatter.string(from: event.startTimeStamp)
        let endTime = timeFormatter.string(from: event.endTimeStamp)
        if let eventTimeLabel = eventTimeLabel {
            eventTimeLabel.text = "\(startTime) - \(endTime)"
        }

        // Set event description
        if let eventDescriptionTextView = eventDescriptionTextView {
            eventDescriptionTextView.text = event.description
        }

        // Set event status
        if let eventStatusLabel = eventStatusLabel {
            eventStatusLabel.text = event.status.rawValue.capitalized
            updateStatusLabelAppearance(status: event.status)
        }

        // Set age range label
        if let eventAgeLabel = eventAgeLabel {
            eventAgeLabel.text = "\(event.minimumAge)-\(event.maximumAge)"
        }

        // Set venue name label
        if let eventVenueLabel = eventVenueLabel {
            eventVenueLabel.text = event.venueName
        }
        
        // Set organizer name
        if let organizerNameLabel = organizerNameLabel {
            organizerNameLabel.text = event.organizerName
        }


    }

    // MARK: - Helper Functions
    func updateStatusLabelAppearance(status: EventStatus) {
        if let eventStatusLabel = eventStatusLabel {
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
        // Optional placeholder for functionality
    }

    @IBAction func TicketIderease(_ sender: UIButton) {
        // Optional placeholder for functionality
    }

    @IBAction func TicketStepperValueChanged(_ sender: UIStepper) {
        if let ticketStepper = ticketStepper, let ticketCountLabel = ticketCountLabel {
            ticketCount = Int(ticketStepper.value) // Update ticket count from stepper's value
            ticketCountLabel.text = "\(ticketCount) Ticket"
        }
    }

    // MARK: - Show Organizer Profile
    @IBAction func showPage(_ sender: Any) {
        // Check if organizer exists
        if let organizer = organizer {
            // Assuming you have a property or method in CustomerEventViewController to display the organizer's details
            // You can set the organizer data on a property in the current view controller
            // Example: self.organizerProfile = organizer
            
            // If you're navigating within the same view controller, update the UI or transition the view accordingly
            updateOrganizerProfileView(with: organizer)
        }
    }

    
    func updateOrganizerProfileView(with organizer: Organizer) {
        // Update the UI with organizer details
        // For example, updating labels, image views, etc.
        organizerNameLabel.text = event?.organizerName
        // Add any other UI elements or logic needed to display organizer's info
    }


    // MARK: - Fetch Events by Organizer
    func fetchEventsByOrganizerID(organizerID: String) {
        Task {
            do {
                let events = try await EventsManager.searchEvents(byOrganizerID: organizerID)
                // Use the fetched events (e.g., display them in a list)
                print("Fetched events: \(events)")
            } catch {
                print("Failed to fetch events by organizer: \(error)")
            }
        }
    }
    
    
    @IBAction func goToTicketButtonTapped(_ sender: UIButton) {
        print("Segue triggered!")
        performSegue(withIdentifier: "goToTicket", sender: self)
    }

    // MARK: - Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toOrganizerView" {
                    // Handle the "toOrganizerView" segue
                    if let organizerView = segue.destination.view as? CustomerEventOrganizerView {
                        organizerView.organizerID = event!.organizerID
                        organizerView.organizerNameLabel.text = event?.organizerName
                        organizerView.delegate = self
                        organizerView.load()
                    }
            
            if let ticketDetailsVC = segue.destination as? CustomerRegistrationViewController {
                
                print("Preparing to pass data:")
                           print("Event ID: \(self.eventID)")
                print("Organizer ID: \(self.organizer?.userID ?? "No Organizer ID")")
                           print("Ticket Quantity: \(self.ticketCount)")
                           print("Ticket Price: \(self.event?.price ?? 0.0)")
                           
                
                // Pass the required values to the destination view controller
                ticketDetailsVC.eventID = self.eventID
                ticketDetailsVC.organizerID = self.organizer!.userID
                ticketDetailsVC.ticketQuantity = self.ticketCount
                ticketDetailsVC.ticketPrice = self.event?.price ?? 0.0  
            }
        }
    }





    @IBAction func backClicked(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}


//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "toOrganizerView" {
//            // Handle the "toOrganizerView" segue
//            if let organizerView = segue.destination.view as? CustomerEventOrganizerView {
//                organizerView.organizerID = event!.organizerID
//                organizerView.organizerNameLabel.text = event?.organizerName
//                organizerView.delegate = self
//                organizerView.load()
//            }
//        } else if segue.identifier == "goToTicket" {
//            // Handle the "goToTicket" segue
//            if let ticketViewController = segue.destination as? CustomerTicketsViewController {
//                // Pass the event ID to the destination view controller
//            //    ticketViewController.organizerID = event!.organizerID
//
////                // Pass the organizer ID to the destination view controller
////                ticketViewController.organizerID = self.event?.organizerID
////
////                // Pass the ticket quantity to the destination view controller
////                ticketViewController.ticketQuantity = self.event?.ticketQuantity
////
////                // Pass the ticket price to the destination view controller
////                ticketViewController.ticketPrice = self.event?.ticketPrice
//            }
//        }
//    }
