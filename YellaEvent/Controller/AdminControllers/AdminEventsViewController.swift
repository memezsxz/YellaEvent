//
//  AdminEventsViewController.swift
//  YellaEvent
//
//  Created by meme on 25/11/2024.
//

import UIKit
import FirebaseFirestore
import SwiftUI
class AdminEventsViewController: UIViewController  {
    
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var eventsStatusSegment: MainUISegmentedControl!
    @IBOutlet var tableView: UITableView!
    var currentSegment : EventStatus? = nil
    var organizerCache: [String: String] = [:] // Cache for organizer names (organizerID -> organizerName)

    @IBOutlet var eventStatus: UILabel!
    @IBOutlet var eventTitle: UILabel!
    @IBOutlet var statusCircle: UIImageView!
    @IBOutlet var dayOfMonth: UILabel!
    @IBOutlet var Month: UILabel!
    @IBOutlet var dayOfweek: UILabel!
    @IBOutlet var startToEndTime: UILabel!
    @IBOutlet var minimumAge: UILabel!
    @IBOutlet var Venue: UILabel!
    @IBOutlet var eventImageView: UIImageView!
    @IBOutlet weak var EventDescription: UITextView!
    @IBOutlet weak var price: UILabel!
    
    
    //for page 2
    var eventID: String = "3jCdiZ7OrVUAksiBrZwr"
        var event: Event?
        var ticketCount: Int = 0
        var organizer: Organizer?
        var delegate: UIViewController?
    
    var orgName: String?{
        didSet {
            if let orgName{
                setOrganizerName(orgName)
            }
        }
    }
    
    var events : [(eventID: String, eventName : String, organizerID: String, status: String)] = []
    var segmentEvents : [(eventID: String, eventName : String, organizerID: String, status: String)] = []
    var searchEvents : [(eventID: String, eventName : String, organizerID: String, status: String)] = []


    
    override func viewDidLoad() {
        
        //for page 2
            fetchEventAndUpdateUI()
        tableView.delegate = self
                tableView.dataSource = self
                tableView.register(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: "MainTableViewCell")

        
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "MainTableViewCell", bundle: .main), forCellReuseIdentifier: "MainTableViewCell")
        
        searchBar.delegate = self
        
        
        
        Task {
            EventsManager.getAllEvents { snapshot, error in
                guard error == nil else{
                    let alert = UIAlertController(title: "Unable To Fetch Events", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                guard let snapshot else { return }
                
                self.events.removeAll()
                
                for document in snapshot.documents {
                    
                    let id = document.documentID
                    let data = document.data()
                    let eventName = data[K.FStore.Events.name] as! String
                    let organizerId = data[K.FStore.Events.organizerID] as! String
                    let status = data[K.FStore.Events.status] as! String
                    
                    self.events.append((id, eventName, organizerId, status))
                }
                
                DispatchQueue.main.async {
                    self.setSegmentEvents()
                }
                
            }
            
        }
        
        
        if let orgName = orgName {
               searchBar.text = orgName // Set the search bar text
               performSearch(with: orgName) // Trigger the search programmatically
           }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
           
           if let orgName = orgName {
               searchBar.text = orgName // Set the search bar text
               performSearch(with: orgName) // Trigger the search programmatically
           }
    }
    
    
    
    
    @IBAction func segmentClick(_ sender: Any) {
        
        switch eventsStatusSegment.selectedSegmentIndex {
        case 0: currentSegment = nil
        case 1: currentSegment = .ongoing
        case 2: currentSegment = .completed
        case 3: currentSegment = .cancelled
        default:
            currentSegment = nil
        }
        
        setSegmentEvents()
    }
    
    func setSegmentEvents() {
        if let currentSegment = currentSegment  {
            segmentEvents = events.filter { $0.status == currentSegment.rawValue}
        } else {
            segmentEvents  = events
        }
        searchBar(searchBar, textDidChange: searchBar.text ?? "")
    }
}

// MARK: table view
extension AdminEventsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath) as! MainTableViewCell
        cell.title.text = searchEvents[indexPath.row].eventName
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60 // Adjust the height as needed
    }
}

// MARK: searchbar
extension AdminEventsViewController : UISearchBarDelegate {
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() // Convert search text to lowercase
        
        guard !searchText.isEmpty else {
            searchEvents = segmentEvents
            tableView.reloadData()
            return
        }
        
        // Filter events synchronously using the preloaded cache
        searchEvents = segmentEvents.filter { event in
            let eventNameMatches = event.eventName.lowercased().contains(searchText) || // Convert event name to lowercase
            event.eventName.split(separator: " ").contains { $0.lowercased().contains(searchText) } // Split and compare in lowercase
            
            let organizerNameMatches = organizerCache[event.organizerID]?.contains(searchText) ?? false
            return eventNameMatches || organizerNameMatches
        }
        
        tableView.reloadData()
    }
    
    
    // Helper function to get the organizer name from the organizer ID
    func organizerName(for organizerID: String) async throws -> String {
        // Fetch the organizer details from the database or API
        let organizer = try await UsersManager.getOrganizer(organizerID: organizerID)
        return organizer.fullName
    }
    
    
    func setOrganizerName(_ name: String?){
        
        if let name = name{
            if let searchBar = searchBar{
                searchBar.text = name
            }
        }
    }
    
    func preloadOrganizerNames(completion: @escaping () -> Void) {
        Task {
            for event in events {
                if organizerCache[event.organizerID] == nil {
                    if let organizer = try? await UsersManager.getOrganizer(organizerID: event.organizerID) {
                        organizerCache[event.organizerID] = organizer.fullName.lowercased()
                    }
                }
            }
            completion() // Notify when preloading is complete
        }
    }
    
    func performSearch(with text: String) {
        let searchText = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        guard !searchText.isEmpty else {
            searchEvents = segmentEvents
            tableView.reloadData()
            return
        }
        
        preloadOrganizerNames {
            DispatchQueue.main.async {
                // Perform filtering after preloading is complete
                self.searchEvents = self.segmentEvents.filter { event in
                    let eventNameMatches = event.eventName.lowercased().contains(searchText)
                    let organizerNameMatches = self.organizerCache[event.organizerID]?.contains(searchText) ?? false
                    return eventNameMatches || organizerNameMatches
                }
                
                self.tableView.reloadData()
            }
        }
    }
    
    //page 2
    
    func fetchEventAndUpdateUI() {
        Task {
            do {
                let fetchedEvent = try await EventsManager.getEvent(eventID: eventID)
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
    
    //            func updateOrganizerProfileView(with organizer: Organizer) {
    //                // Assuming organizerNameLabel is the outlet for organizer name
    //                if let organizerNameLabel = organizerNameLabel {
    //                    organizerNameLabel.text = event?.organizerName
    //                    // Additional UI updates for organizer profile view
    //                }
    //}
    
    //        @IBAction func showPage(_ sender: Any) {
    //            if let organizer = organizer {
    //                updateOrganizerProfileView(with: organizer)
    //            }
    //        }
    //
    class AdminEventsViewController: UIViewController {
        
        var selectedEventID: String?
        var selectedEvent: Event?
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            // Load event details for the selected event
            loadEventDetails()
        }
        
        private func loadEventDetails() {
            guard let eventID = selectedEventID else { return }
            
            // Fetch event details using the eventID
            Task {
                do {
                    let eventDetails = try await EventsManager.getEvent(eventID: eventID)
                    // Update UI with eventDetails
                  //  displayEventDetails(eventDetails)
                } catch {
                    // Handle errors (e.g., show an alert)
                    print("Error fetching event details: \(error)")
                }
            }
        }
        
        //        private func displayEventDetails(_ details: EventDetails) {
        //            // Update UI components with the event details
        //            // For example:
        //            eventTitle.text = event?.name
        //           // eventDateLabel.text = details.date
        //            // Update other UI components as needed
        //        }
        //    }
        //
        func fetchEventsByOrganizerID(organizerID: String) {
            Task {
                do {
                    let events = try await EventsManager.searchEvents(byOrganizerID: organizerID)
                    print("Fetched events: \(events)")
                } catch {
                    print("Failed to fetch events by organizer: \(error)")
                }
            }
        }
        
    }
}
