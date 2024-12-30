import UIKit
import FirebaseFirestore

// View controller for displaying customer tickets
class CustomerTicketsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CustomerRegistrationDelegate {
    var ticketsList: [Ticket] = [] // Array to hold all tickets
    var activeTickets: [Ticket] = [] // Array to hold active tickets
    var expiredTickets: [Ticket] = [] // Array to hold expired tickets

    @IBOutlet weak var tableView: UITableView! // Outlet for the table view
    @IBOutlet weak var activeExpired: UISegmentedControl! // Segment control to toggle between active and expired tickets
    
    
    
    let userId = UserDefaults.standard.string(forKey: K.bundleUserID)! // Retrieve user ID from UserDefaults

    // Called after the view has been loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView() // Set up the table view

        // Set automatic row height for the table view
//        tableView.rowHeight = UITableView.automaticDimension
//        tableView.estimatedRowHeight = 100 // Provide an estimated height for better performance

        // Add target for segmented control to handle value changes
        activeExpired.addTarget(self, action: #selector(segmentValueChanged), for: .valueChanged)

        // Fetch tickets asynchronously
        Task {
            await fetchTickets()
        }
    }

    // Function to set up the table view
    private func setupTableView() {
        tableView.delegate = self // Set the delegate
        tableView.dataSource = self // Set the data source
        tableView.register(UINib(nibName: "TicketsTableViewCell", bundle: .main), forCellReuseIdentifier: "TicketsTableViewCell") // Register custom cell
    }

    // Asynchronous function to fetch tickets from Firestore
    func fetchTickets() async {

        // Fetch user tickets using TicketsManager
        TicketsManager.getUserTickets(userId: userId) { snapshot, error in
            guard error == nil else { return } // Handle errors
            guard let snapshot = snapshot else { return }

            self.ticketsList.removeAll() // Clear previous ticket lists
            self.activeTickets.removeAll()
            self.expiredTickets.removeAll()

            // Iterate through documents in the snapshot
            for doc in snapshot.documents {
                Task {
                    // Attempt to create a Ticket object from document data
                    let ticket = try await Ticket(from: doc.data())
                    self.ticketsList.append(ticket) // Add ticket to the list

                    // Check if the ticket is active or expired
                    if ticket.endTimeStamp > Date() && ticket.status == .paid {
                        self.activeTickets.append(ticket) // Add to active tickets
                    } else {
                        self.expiredTickets.append(ticket) // Add to expired tickets
                    }

                    // Update the table view on the main thread
                    DispatchQueue.main.async {
                        self.updateVisibleTickets()
                    }
                }
            }
        }
    }

    // Function to update the visible tickets by reloading the table view
    private func updateVisibleTickets() {
        tableView.reloadData() // Reload the table view data
    }

    // Action method for when the segmented control value changes
    @objc func segmentValueChanged() {
        updateVisibleTickets() // Refresh the visible tickets based on selected segment
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height / 8.5
    }
    // Data source method to determine the number of rows in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activeExpired.selectedSegmentIndex == 0 ? activeTickets.count : expiredTickets.count // Return count based on selected segment
    }

    // Data source method to configure and return a cell for the table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TicketsTableViewCell", for: indexPath) as! TicketsTableViewCell
        let ticket = activeExpired.selectedSegmentIndex == 0 ? activeTickets[indexPath.row] : expiredTickets[indexPath.row] // Get the appropriate ticket

        cell.title.text = ticket.eventName // Set the cell title
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy" // Format the date
        let formattedDate = dateFormatter.string(from: ticket.startTimeStamp) // Format the ticket start date
        cell.subtext.text = "\(formattedDate) - \(ticket.eventName)" // Set the subtext with date and event name

        return cell // Return the configured cell
    }

    // Delegate method triggered when a row is selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // Deselect the row with animation
        let selectedTicket = activeExpired.selectedSegmentIndex == 0 ? activeTickets[indexPath.row] : expiredTickets[indexPath.row] // Get the selected ticket
        performSegue(withIdentifier: "ShowTicketDetail", sender: selectedTicket) // Perform segue to ticket detail view
    }

    // Delegate method to handle ticket creation
    func didCreateTicket(_ ticket: Ticket) {
        ticketsList.append(ticket) // Add the new ticket to the list
        if ticket.endTimeStamp > Date() {
            activeTickets.append(ticket) // Add to active tickets if not expired
        } else {
            expiredTickets.append(ticket) // Add to expired tickets if expired
        }
        updateVisibleTickets() // Update the visible tickets in the table view
    }

    // Prepare for segue to the ticket details view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTicketDetail",
           let destinationVC = segue.destination as? CustomerTicketDetailsViewController,
           let selectedTicket = sender as? Ticket {
            destinationVC.ticket = selectedTicket // Pass the selected ticket to the destination view controller
        }
    }
}
