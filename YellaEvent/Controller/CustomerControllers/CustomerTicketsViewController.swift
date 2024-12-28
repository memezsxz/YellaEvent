import UIKit
import FirebaseFirestore

class CustomerTicketsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CustomerRegistrationDelegate {
    var ticketsList: [Ticket] = []
    var activeTickets: [Ticket] = []
    var expiredTickets: [Ticket] = []

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activeExpired: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()

        UserDefaults.standard.set("r91ayZkyBvM21oL4akWY", forKey: K.bundleUserID)
        activeExpired.addTarget(self, action: #selector(segmentValueChanged), for: .valueChanged)

        Task {
            await fetchTickets()
        }
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TicketsTableViewCell", bundle: .main), forCellReuseIdentifier: "TicketsTableViewCell")
    }

    func fetchTickets() async {
        ticketsList.removeAll()
        activeTickets.removeAll()
        expiredTickets.removeAll()

        TicketsManager.getUserTickets(userId: UserDefaults.standard.string(forKey: K.bundleUserID)!) { snapshot, error in
            guard error == nil else { return }
            guard let snapshot = snapshot else { return }

            for doc in snapshot.documents {
                Task {
                    let ticket = try await Ticket(from: doc.data())
                    self.ticketsList.append(ticket)

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

    private func updateVisibleTickets() {
        tableView.reloadData()
    }

    @objc func segmentValueChanged() {
        updateVisibleTickets()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activeExpired.selectedSegmentIndex == 0 ? activeTickets.count : expiredTickets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TicketsTableViewCell", for: indexPath) as! TicketsTableViewCell
        let ticket = activeExpired.selectedSegmentIndex == 0 ? activeTickets[indexPath.row] : expiredTickets[indexPath.row]
        cell.title.text = ticket.eventName

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let formattedDate = dateFormatter.string(from: ticket.startTimeStamp)
        cell.subtext.text = "\(formattedDate) - \(ticket.eventName)"

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedTicket = activeExpired.selectedSegmentIndex == 0 ? activeTickets[indexPath.row] : expiredTickets[indexPath.row]
        performSegue(withIdentifier: "ShowTicketDetail", sender: selectedTicket)
    }

    func didCreateTicket(_ ticket: Ticket) {
        ticketsList.append(ticket)
        if ticket.endTimeStamp > Date() {
            activeTickets.append(ticket)
        } else {
            expiredTickets.append(ticket)
        }
        updateVisibleTickets()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTicketDetail",
           let destinationVC = segue.destination as? CustomerTicketDetailsViewController,
           let selectedTicket = sender as? Ticket {
            destinationVC.ticket = selectedTicket
        }
    }
}
