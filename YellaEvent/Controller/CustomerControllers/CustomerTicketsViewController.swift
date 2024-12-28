import UIKit
import FirebaseFirestore
import FirebaseAuth

class CustomerTicketsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var ticketsList: [Ticket] = [] // Array to hold all tickets
    var activeTickets: [Ticket] = [] // Array to hold active tickets
    var expiredTickets: [Ticket] = [] // Array to hold expired tickets
    var currentUserId: String = "" // Current user's ID

    @IBOutlet weak var tableView: UITableView! // Outlet for the table view
    @IBOutlet weak var activeExpired: UISegmentedControl! // Segmented control for filtering

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
        // Set a default user ID (this will be removed after setting the application)
        UserDefaults.standard.set("r91ayZkyBvM21oL4akWY", forKey: K.bundleUserID)
        
        // Add target to segmented control for filtering
        activeExpired.addTarget(self, action: #selector(segmentValueChanged), for: .valueChanged)

        Task {
            await fetchTickets()
        }
    }

    // Set up table view delegate and data source
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TicketsTableViewCell", bundle: .main), forCellReuseIdentifier: "TicketsTableViewCell")
    }

    // Fetch tickets for the current user
    func fetchTickets() async {
        // Clear the arrays to avoid duplicate entries
        self.ticketsList.removeAll()
        self.activeTickets.removeAll()
        self.expiredTickets.removeAll()
        
        TicketsManager.getUserTickets(userId: UserDefaults.standard.string(forKey: K.bundleUserID)!) { snapshot, error in
            guard error == nil else {
                print(error?.localizedDescription ?? "Unknown error")
                return
            }
            
            guard let snapshot = snapshot else { return }
            
            for doc in snapshot.documents {
                Task {
                    let ticket = try await Ticket(from: doc.data())
                    self.ticketsList.append(ticket)

                    // Print the event ID for debugging purposes
                    print("Event ID: \(ticket.eventID)")

                    // Remove ticket from both arrays before reassigning
                    if let index = self.activeTickets.firstIndex(where: { $0.eventID == ticket.eventID }) {
                        self.activeTickets.remove(at: index)
                    }
                    if let index = self.expiredTickets.firstIndex(where: { $0.eventID == ticket.eventID }) {
                        self.expiredTickets.remove(at: index)
                    }

                    // Sort tickets into active and expired arrays based on endTimeStamp
                    if ticket.endTimeStamp > Date() {
                        self.activeTickets.append(ticket)
                    } else {
                        self.expiredTickets.append(ticket)
                    }

                    DispatchQueue.main.async {
                        self.updateVisibleTickets()
                    }
                }
            }
        }
    }

    // Update table view based on the selected segment
    private func updateVisibleTickets() {
        tableView.reloadData()
    }

    // Handle segmented control value change
    @objc func segmentValueChanged() {
        updateVisibleTickets()
    }

    // MARK: - Table View Data Source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activeExpired.selectedSegmentIndex == 0 ? activeTickets.count : expiredTickets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TicketsTableViewCell", for: indexPath) as! TicketsTableViewCell
        
        let ticket = activeExpired.selectedSegmentIndex == 0 ? activeTickets[indexPath.row] : expiredTickets[indexPath.row]

        // Set the event name
        cell.title.text = ticket.eventName

        // Format the date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy" // Format: 25/12/2024
        let formattedDate = dateFormatter.string(from: ticket.startTimeStamp)

        // Set the subtitle text with date and venue
        cell.subtext.text = "\(formattedDate) - \(ticket.eventName)"

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.width / 6 // Set height for each row
    }

    // MARK: - Table View Delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect the cell
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Perform the segue
        let selectedTicket = activeExpired.selectedSegmentIndex == 0 ? activeTickets[indexPath.row] : expiredTickets[indexPath.row]
        print(selectedTicket)
        performSegue(withIdentifier: "ShowTicketDetail", sender: selectedTicket)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTicketDetail" {
            if let destinationVC = segue.destination as? CustomerTicketDetailsViewController,
               let selectedTicket = sender as? Ticket {
                destinationVC.ticket = selectedTicket // Pass the selected ticket
            }
        }
    }
}
