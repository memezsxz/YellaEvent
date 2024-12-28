import UIKit
import Firebase
import FirebaseFirestore

// Protocol to delegate ticket creation actions
protocol CustomerRegistrationDelegate: AnyObject {
    func didCreateTicket(_ ticket: Ticket) // Method to notify when a ticket is created
}

class CustomerRegistrationViewController: UIViewController {
    var eventID: String = "" // Event ID
    var organizerID: String = "" // Organizer ID
    var ticketPrice: Double = 0.0 // Ticket Price
    var ticketQuantity: Int = 1 // Ticket Quantity
    weak var delegate: CustomerRegistrationDelegate? // Delegate for ticket creation

    @IBOutlet weak var inputCardNumber: UITextField!
    @IBOutlet weak var lblErrorCardNumber: UILabel!
    @IBOutlet weak var inputCardName: UITextField!
    @IBOutlet weak var lblErrorCardName: UILabel!
    @IBOutlet weak var inputCardExpiry: UITextField!
    @IBOutlet weak var lblErrorCardExpiry: UILabel!
    @IBOutlet weak var inputCardCVV: UITextField!
    @IBOutlet weak var lblErrorCardcvv: UILabel!
    @IBOutlet weak var lblTicketQuantity: UILabel!
    @IBOutlet weak var lblTicketPrice: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        hideErrorLabels()
        lblTicketQuantity.text = "Quantity: \(ticketQuantity)"
        lblTicketPrice.text = String(format: "Total Price: $%.2f", ticketPrice * Double(ticketQuantity))
    }

    @IBAction func payButton(_ sender: Any) {
        hideErrorLabels()
        var isValid = true

        // Validate card number
        if !validateCardNumber(inputCardNumber.text) {
            lblErrorCardNumber.text = "*Invalid card number"
            lblErrorCardNumber.isHidden = false
            isValid = false
        }

        // Validate card name
        if !validateCardName(inputCardName.text) {
            lblErrorCardName.text = "*Invalid card name"
            lblErrorCardName.isHidden = false
            isValid = false
        }

        // Validate card expiry
        if !validateCardExpiry(inputCardExpiry.text) {
            lblErrorCardExpiry.text = "*Invalid expiry date (MM/YY)"
            lblErrorCardExpiry.isHidden = false
            isValid = false
        }

        // Validate card CVV
        if !validateCardCVV(inputCardCVV.text) {
            lblErrorCardcvv.text = "*Invalid CVV"
            lblErrorCardcvv.isHidden = false
            isValid = false
        }

        // Proceed with ticket creation only if all validations pass
        if isValid {
            createTicket()
        } else {
            showAlert(message: "Please correct the highlighted errors and try again.")
        }
    }


    private func createTicket() {
        print("I am creating a ticket")
        Task {
            do {
                // Fetch event details using the eventID
                let event = try await EventsManager.getEvent(eventID: eventID)

                // Create ticket object (temporary, without Firestore ID)
                let ticket = Ticket(
                    ticketID: "1", // Placeholder, will be updated after retrieval
                    eventID: eventID,
                    customerID: UserDefaults.standard.string(forKey: K.bundleUserID) ?? "unknown",
                    organizerID: event.organizerID,
                    eventName: event.name,
                    organizerName: event.organizerName,
                    startTimeStamp: event.startTimeStamp,
                    endTimeStamp: event.endTimeStamp,
                    didAttend: false,
                    totalPrice: ticketPrice * Double(ticketQuantity), // Calculate total price
                    locationURL: event.locationURL,
                    quantity: ticketQuantity,
                    status: .paid
                )

                // Save ticket to Firestore
                try await TicketsManager.createNewTicket(ticket: ticket)

                // Fetch the newly created ticket by querying Firestore
                let query = try await Firestore.firestore()
                    .collection(K.FStore.Tickets.collectionName)
                    .whereField("customerID", isEqualTo: ticket.customerID)
                    .whereField("eventID", isEqualTo: ticket.eventID)
                    .limit(to: 1)
                    .getDocuments()

                guard let document = query.documents.first else {
                    throw NSError(domain: "TicketError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Ticket not found"])
                }

                // Decode the ticket
                let savedTicket = try await Ticket(from: document.data())
                print("this is the ticketID",savedTicket.ticketID)

                // Notify the delegate about the ticket creation
                delegate?.didCreateTicket(savedTicket)

                // Show success alert and navigate to details page
                await showSuccessAlertAndNavigate(ticket: savedTicket)

            } catch {
                showAlert(message: "Failed to create ticket: \(error.localizedDescription)")
            }
        }
    }


    private func showSuccessAlertAndNavigate(ticket: Ticket) async {
        await MainActor.run {
            showAlert(message: "Payment Successful!") {
                // Instantiate the destination view controller
                let storyboard = UIStoryboard(name: "CustomerTicketsView", bundle: nil)
                if let ticketDetailsVC = storyboard.instantiateViewController(withIdentifier: "CustomerTicketDetailsView") as? CustomerTicketDetailsViewController {
                    
                    // Pass the ticket object to the destination view controller
                    ticketDetailsVC.ticket = ticket
                    
                    // Present the destination view controller
                    self.navigationController?.pushViewController(ticketDetailsVC, animated: true)
                } else {
                    print("Failed to instantiate CustomerTicketDetailsViewController")
                }
            }
        }
    }

    func hideErrorLabels() {
        lblErrorCardNumber.isHidden = true
        lblErrorCardName.isHidden = true
        lblErrorCardExpiry.isHidden = true
        lblErrorCardcvv.isHidden = true
    }

    func validateCardNumber(_ cardNumber: String?) -> Bool {
        guard let cardNumber = cardNumber, cardNumber.count == 16, CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: cardNumber)) else {
            return false
        }
        return true
    }

    func validateCardName(_ cardName: String?) -> Bool {
        guard let cardName = cardName, !cardName.isEmpty else {
            return false
        }
        return CharacterSet.letters.isSuperset(of: CharacterSet(charactersIn: cardName))
    }

    func validateCardExpiry(_ expiry: String?) -> Bool {
        guard let expiry = expiry, expiry.count == 5 else { return false }
        let components = expiry.split(separator: "/")
        guard components.count == 2,
              let month = Int(components[0]), month >= 1 && month <= 12,
              let year = Int(components[1]), year >= 0 && year <= 99 else {
            return false
        }
        return true
    }

    func validateCardCVV(_ cvv: String?) -> Bool {
        guard let cvv = cvv, cvv.count == 3, CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: cvv)) else {
            return false
        }
        return true
    }

    func showAlert(message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Payment", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion?() // Execute the completion block after dismissing the alert
        }))
        if self.presentedViewController == nil {
            present(alert, animated: true, completion: nil)
        } else {
            print("Another view controller is already presented.")
        }
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTicketDetail",
           let destinationVC = segue.destination as? CustomerTicketDetailsViewController,
           let newTicket = sender as? Ticket {
            destinationVC.ticket = newTicket
        }
    }
}
