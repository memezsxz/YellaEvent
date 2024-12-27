import UIKit
import FirebaseFirestore

class CustomerRegistrationViewController: UIViewController {
    
    // Outlets for text fields
    @IBOutlet weak var CardNumber: UITextField!
    @IBOutlet weak var CardHolder: UITextField!
    @IBOutlet weak var CardExpiry: UITextField!
    @IBOutlet weak var CardCCV: UITextField!
    
    // Outlets for error labels
    @IBOutlet weak var cardNumberErrorLabel: UILabel!
    @IBOutlet weak var cardHolderErrorLabel: UILabel!
    @IBOutlet weak var cardExpiryErrorLabel: UILabel!
    @IBOutlet weak var cardCCVErrorLabel: UILabel!
    
    // Outlets for labels
    @IBOutlet weak var lblTicketAmount: UILabel!
    @IBOutlet weak var lblTicketQuantity: UILabel!
    
    // Properties to hold the passed details
    var organizerID: String = ""
    var eventID: String = ""
    var ticketPrice: Double = 0.0
    var ticketQuantity: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Update UI with the passed ticket information
        lblTicketQuantity.text = "Quantity: \(ticketQuantity)"
        lblTicketAmount.text = "Total Amount: $\(ticketPrice)"
        
        // Hide error labels initially
        hideErrorLabels()
    }
    
    @IBAction func payButton(_ sender: Any) {
        if validateTextFields() {
            // Create a local Ticket object using the passed properties
            let ticket = Ticket(
                ticketID: UUID().uuidString,
                eventID: eventID,
                customerID: UserDefaults.standard.string(forKey: K.bundleUserID) ?? "unknown",
                organizerID: organizerID,
                eventName: "", // Set as needed
                organizerName: "", // Set as needed
                startTimeStamp: Date(), // Set as needed
                endTimeStamp: Date(), // Set as needed
                didAttend: false, // Set as needed
                totalPrice: ticketPrice,
                locationURL: "", // Set as needed
                quantity: ticketQuantity,
                status: .paid // Assuming TicketStatus is an enum and .paid is a valid case
            )
            
            // Create a new ticket in Firestore
            Task {
                do {
                    // Call the method to create a new ticket in Firestore
                    try await TicketsManager.createNewTicket(ticket: ticket)
                    
                    // Show success alert
                    showAlert(title: "Payment Successful", message: "Your payment has been processed successfully.") {
                        // Navigate to the ticket details view only after the alert is dismissed
                        self.performSegue(withIdentifier: "ShowTicketDetail", sender: ticket)
                    }
                } catch {
                    showAlert(title: "Error", message: "Failed to create ticket: \(error.localizedDescription)")
                }
            }
        } else {
            showAlert(title: "Error", message: "Please fill in all fields correctly.")
        }
    }
    
    private func validateTextFields() -> Bool {
        var isValid = true
        
        // Validate card number (16 digits)
        if let cardNumber = CardNumber.text, cardNumber.range(of: #"^\d{16}$"#, options: .regularExpression) == nil {
            cardNumberErrorLabel.text = "*Card number must be 16 digits."
            cardNumberErrorLabel.isHidden = false
            isValid = false
        } else {
            cardNumberErrorLabel.isHidden = true
        }
        
        // Validate card holder name (only letters)
        if let cardHolder = CardHolder.text, cardHolder.range(of: #"^[A-Za-z\s]+$"#, options: .regularExpression) == nil {
            cardHolderErrorLabel.text = "*Card holder name must only contain letters."
            cardHolderErrorLabel.isHidden = false
            isValid = false
        } else {
            cardHolderErrorLabel.isHidden = true
        }
        
        // Validate card expiry date (MM/YY format)
        if let cardExpiry = CardExpiry.text, cardExpiry.range(of: #"^(0[1-9]|1[0-2])/\d{2}$"#, options: .regularExpression) == nil {
            cardExpiryErrorLabel.text = "*Expiry date must be in MM/YY format."
            cardExpiryErrorLabel.isHidden = false
            isValid = false
        } else {
            cardExpiryErrorLabel.isHidden = true
        }
        
        // Validate CVV (3 digits)
        if let cardCCV = CardCCV.text, cardCCV.range(of: #"^\d{3}$"#, options: .regularExpression) == nil {
            cardCCVErrorLabel.text = "*CVV must be 3 digits."
            cardCCVErrorLabel.isHidden = false
            isValid = false
        } else {
            cardCCVErrorLabel.isHidden = true
        }
        
        return isValid
    }
    
    private func hideErrorLabels() {
        cardNumberErrorLabel.isHidden = true
        cardHolderErrorLabel.isHidden = true
        cardExpiryErrorLabel.isHidden = true
        cardCCVErrorLabel.isHidden = true
    }
    
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            completion?() // Execute the completion block if provided
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTicketDetail" {
            // Ensure the destination view controller is of the expected type
            if let ticketDetailsVC = segue.destination as? CustomerTicketDetailsViewController {
                // Ensure the sender is the ticket being passed
                if let newTicket = sender as? Ticket {
                    ticketDetailsVC.ticket = newTicket // Pass the new ticket to the ticket details view controller
                }
            }
        }
    }
}
