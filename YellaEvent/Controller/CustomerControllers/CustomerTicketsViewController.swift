import UIKit
import FirebaseFirestore
import FirebaseAuth

class CustomerTicketsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var ticketsList: [Ticket] = [] // Array to hold the tickets
    var currentUserId: String = "" // Current user's ID

    @IBOutlet weak var tableView: UITableView! // Outlet for the table view
    @IBOutlet weak var activeExpired: UISegmentedControl! // Segmented control for filtering

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
        // Set a default user ID (this will be removed after setting the application)
        UserDefaults.standard.set("xsc9s10sj0JKqpoEJH59", forKey: K.bundleUserID)
        
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
        TicketsManager.getUserTickets(userId: UserDefaults.standard.string(forKey: K.bundleUserID)!) { snapshot, error in
            guard error == nil else {
                print(error?.localizedDescription ?? "Unknown error")
                return
            }
            
            guard let snapshot = snapshot else { return }
            
            for doc in snapshot.documents {
                Task {
                    self.ticketsList.append(try await Ticket(from: doc.data()))
                    DispatchQueue.main.async { self.tableView.reloadData() } // Reload the table view on the main thread
                }
            }
        }
    }

    // MARK: - Table View Data Source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ticketsList.count // Return the number of tickets
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TicketsTableViewCell", for: indexPath) as! TicketsTableViewCell
        let ticket = ticketsList[indexPath.row]

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
        performSegue(withIdentifier: "ShowTicketDetail", sender: ticketsList[indexPath.row])
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
