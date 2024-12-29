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

    // Outlets for UI elements
    @IBOutlet weak var inputCardNumber: UITextField! // Input field for card number
    @IBOutlet weak var lblErrorCardNumber: UILabel! // Label for card number error message
    @IBOutlet weak var inputCardName: UITextField! // Input field for cardholder name
    @IBOutlet weak var lblErrorCardName: UILabel! // Label for card name error message
    @IBOutlet weak var inputCardExpiry: UITextField! // Input field for card expiry date
    @IBOutlet weak var lblErrorCardExpiry: UILabel! // Label for expiry date error message
    @IBOutlet weak var inputCardCVV: UITextField! // Input field for card CVV
    @IBOutlet weak var lblErrorCardcvv: UILabel! // Label for CVV error message
    @IBOutlet weak var lblTicketQuantity: UILabel! // Label to display ticket quantity
    @IBOutlet weak var lblTicketPrice: UILabel! // Label to display total ticket price

    // Called after the view has been loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()
        hideErrorLabels() // Hide error labels on load
        lblTicketQuantity.text = "Quantity: \(ticketQuantity)" // Display selected ticket quantity
        lblTicketPrice.text = String(format: "Total Price: $%.2f", ticketPrice * Double(ticketQuantity)) // Calculate and display total price
    }

    // Action for the pay button
    @IBAction func payButton(_ sender: Any) {
        hideErrorLabels() // Hide any previous error messages
        var isValid = true // Flag to track validation status

        // Validate card number
        if !validateCardNumber(inputCardNumber.text) {
            lblErrorCardNumber.text = "*Invalid card number" // Show error message
            lblErrorCardNumber.isHidden = false // Make error label visible
            isValid = false // Set validity to false
        }

        // Validate card name
        if !validateCardName(inputCardName.text) {
            lblErrorCardName.text = "*Invalid card name" // Show error message
            lblErrorCardName.isHidden = false // Make error label visible
            isValid = false // Set validity to false
        }

        // Validate card expiry
        if !validateCardExpiry(inputCardExpiry.text) {
            lblErrorCardExpiry.text = "*Invalid expiry date (MM/YY)" // Show error message
            lblErrorCardExpiry.isHidden = false // Make error label visible
            isValid = false // Set validity to false
        }

        // Validate card CVV
        if !validateCardCVV(inputCardCVV.text) {
            lblErrorCardcvv.text = "*Invalid CVV" // Show error message
            lblErrorCardcvv.isHidden = false // Make error label visible
            isValid = false // Set validity to false
        }

        // Proceed with ticket creation only if all validations pass
        if isValid {
            createTicket() // Call function to create the ticket
        } else {
            showAlert(message: "Please correct the highlighted errors and try again.") // Show alert for errors
        }
    }

    // Function to create a ticket
    private func createTicket() {
        print("I am creating a ticket") // Debugging statement
        Task {
            do {
                // Fetch event details using the eventID
                let event = try await EventsManager.getEvent(eventID: eventID)

                // Create ticket object (temporary, without Firestore ID)
                let ticket = Ticket(
                    ticketID: "1", // Placeholder, will be updated after retrieval
                    eventID: eventID,
                    customerID: UserDefaults.standard.string(forKey: K.bundleUserID) ?? "unknown", // Get customer ID from UserDefaults
                    organizerID: event.organizerID,
                    eventName: event.name,
                    organizerName: event.organizerName,
                    startTimeStamp: event.startTimeStamp,
                    endTimeStamp: event.endTimeStamp,
                    didAttend: false,
                    totalPrice: ticketPrice * Double(ticketQuantity), // Calculate total price
                    locationURL: event.locationURL,
                    quantity: ticketQuantity,
                    status: .paid // Set initial status to paid
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
                    throw NSError(domain: "TicketError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Ticket not found"]) // Handle ticket not found error
                }

                // Decode the ticket
                let savedTicket = try await Ticket(from: document.data())
                print("this is the ticketID", savedTicket.ticketID) // Debugging statement

                // Notify the delegate about the ticket creation
                delegate?.didCreateTicket(savedTicket)

                // Show success alert and navigate to details page
                await showSuccessAlertAndNavigate(ticket: savedTicket)

            } catch {
                showAlert(message: "Failed to create ticket: \(error.localizedDescription)") // Show error alert
            }
        }
    }

    // Function to show a success alert and navigate to the ticket details page
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
                    print("Failed to instantiate CustomerTicketDetailsViewController") // Debugging statement
                }
            }
        }
    }

    // Function to hide error labels
    func hideErrorLabels() {
        lblErrorCardNumber.isHidden = true
        lblErrorCardName.isHidden = true
        lblErrorCardExpiry.isHidden = true
        lblErrorCardcvv.isHidden = true
    }

    // Function to validate the card number
    func validateCardNumber(_ cardNumber: String?) -> Bool {
        guard let cardNumber = cardNumber, cardNumber.count == 16, CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: cardNumber)) else {
            return false // Return false if validation fails
        }
        return true // Return true if validation succeeds
    }

    // Function to validate the cardholder name
    func validateCardName(_ cardName: String?) -> Bool {
        guard let cardName = cardName, !cardName.isEmpty else {
            return false // Return false if validation fails
        }
        return CharacterSet.letters.isSuperset(of: CharacterSet(charactersIn: cardName)) // Return true if validation succeeds
    }

    // Function to validate the card expiry date
    func validateCardExpiry(_ expiry: String?) -> Bool {
        guard let expiry = expiry, expiry.count == 5 else { return false } // Check format MM/YY
        let components = expiry.split(separator: "/") // Split month and year
        guard components.count == 2,
              let month = Int(components[0]), month >= 1 && month <= 12,
              let year = Int(components[1]), year >= 0 && year <= 99 else {
            return false // Return false if validation fails
        }
        return true // Return true if validation succeeds
    }

    // Function to validate the CVV
    func validateCardCVV(_ cvv: String?) -> Bool {
        guard let cvv = cvv, cvv.count == 3, CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: cvv)) else {
            return false // Return false if validation fails
        }
        return true // Return true if validation succeeds
    }

    // Function to show an alert with a message
    func showAlert(message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Payment", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion?() // Execute the completion block after dismissing the alert
        }))
        if self.presentedViewController == nil {
            present(alert, animated: true, completion: nil) // Present the alert
        } else {
            print("Another view controller is already presented.") // Debugging statement
        }
    }

    // Prepare for segue to the ticket details view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTicketDetail",
           let destinationVC = segue.destination as? CustomerTicketDetailsViewController,
           let newTicket = sender as? Ticket {
            destinationVC.ticket = newTicket // Pass the new ticket to the destination view controller
        }
    }
}
