import UIKit
import FirebaseFirestore

class CustomerTicketsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var ticketsList: [Ticket] = []
    let db = Firestore.firestore() // Initialize Firestore
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchTickets() // Fetch tickets from Firestore
    }
    
    // Set up table view delegate and data source
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TicketsTableViewCell", bundle: .main), forCellReuseIdentifier: "TicketsTableViewCell")
    }
    
    // Fetch tickets from Firestore
    func fetchTickets() {
        db.collection("tickets").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error during fetch: \(error)")
                return
            }
            
            self.ticketsList = [] // Clear existing tickets
            for document in querySnapshot!.documents {
                let data = document.data()
                if let ticket = self.parseTicket(data: data) {
                    self.ticketsList.append(ticket)
                }
            }
            self.tableView.reloadData() // Reload the table view
        }
    }
    
    // Parse ticket from Firestore data
    func parseTicket(data: [String: Any]) -> Ticket? {
        guard let ticketID = data["ticketID"] as? String,
              let eventID = data["eventID"] as? String,
              let customerID = data["customerID"] as? String,
              let organizerID = data["organizerID"] as? String,
              let eventName = "Sample" as? String,
              let organizerName = "Sample" as? String,
              let timestamp = Date() as? Date,
              let didAttend = data["didAttend"] as? Bool,
              let totalPrice = data["totalPrice"] as? Double,
              let locationURL = "Sample" as? String,
              let quantity = data["quantity"] as? Int,
              let statusString = data["status"] as? String,
              let status = TicketStatus(rawValue: statusString)
        else {
            return nil
        }
        
        return Ticket(ticketID: ticketID, eventID: eventID, customerID: customerID, organizerID: organizerID, eventName: eventName, organizerName: organizerName, startTimeStamp: timestamp, didAttend: didAttend, totalPrice: totalPrice, locationURL: locationURL, quantity: quantity, status: status)
    }
    
    // MARK: - Table View Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ticketsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TicketsTableViewCell", for: indexPath) as! TicketsTableViewCell
        let ticket = ticketsList[indexPath.row]
        
        cell.title.text = ticket.eventName // Use eventName
        cell.subtext.text = "\(ticket.startTimeStamp) - \(ticket.organizerName)" // Display more relevant info
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.width / 6
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
                destinationVC.ticket = selectedTicket // Pass the selected ticket to the new view controller
            } else {
                print("Failed to cast destinationVC or selectedTicket.")
            }
        }
    }
}
