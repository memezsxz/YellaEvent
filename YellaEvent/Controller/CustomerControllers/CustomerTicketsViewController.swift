import UIKit
import FirebaseFirestore
import FirebaseAuth

class CustomerTicketsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var ticketsList: [Ticket] = [] // Array to hold the tickets
    var currentUserId: String = "" // Current user's ID

    @IBOutlet weak var tableView: UITableView! // Outlet for the table view

    @IBOutlet weak var activeExpired: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
        // Set a default user ID (this will be removed after setting the application)
        UserDefaults.standard.set("xsc9s10sj0JKqpoEJH59", forKey: K.bundleUserID)
        
        fetchCurrentUserId() // Fetch the current user's ID when the view loads
    }

    // Set up table view delegate and data source
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TicketsTableViewCell", bundle: .main), forCellReuseIdentifier: "TicketsTableViewCell")
    }

    // Fetch current user ID
    private func fetchCurrentUserId() {
        // Retrieve user ID from UserDefaults
        guard let userId = UserDefaults.standard.string(forKey: K.bundleUserID) else {
            print("User ID not found.")
            return
        }
        
        Task {
            do {
                // Fetch user data using the retrieved user ID
                let us = try await UsersManager.getUser(userID: userId) as! Customer
                self.currentUserId = us.userID // Assuming Customer has a userID property
                await self.fetchTickets() // Fetch tickets for the user
            } catch {
                print("Error fetching user: \(error.localizedDescription)")
            }
        }
    }

    // Fetch tickets for the current user
    func fetchTickets() async {
        do {
            ticketsList = try await TicketsManager.getUserTickets(userId: currentUserId) // Fetch tickets
            await MainActor.run { self.tableView.reloadData() } // Reload the table view on the main thread
        } catch {
            print("Error fetching tickets: \(error.localizedDescription)")
        }
    }

    // MARK: - Table View Data Source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ticketsList.count // Return the number of tickets
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TicketsTableViewCell", for: indexPath) as! TicketsTableViewCell
        let ticket = ticketsList[indexPath.row]
        
        cell.title.text = ticket.eventName // Use eventName
        cell.subtext.text = "\(ticket.startTimeStamp) - \(ticket.organizerName)" // Display more info
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
