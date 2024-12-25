import FirebaseFirestore
import UIKit

class CustomerRegistrationViewController: UIViewController {
    
    // Outlets for text fields
    @IBOutlet weak var CardNumber: UITextField!
    @IBOutlet weak var CardHolder: UITextField!
    @IBOutlet weak var CardExpiry: UITextField!
    @IBOutlet weak var CardCCV: UITextField!
    
    // Outlets for labels
    @IBOutlet weak var lblTicketAmount: UILabel!
    @IBOutlet weak var lblTicketQuantity: UILabel!
    
    // Ticket ID (you need to set this to the selected ticket's ID)
    var selectedTicketID: String = "yourDocumentID" // Update with the actual ticket ID
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Fetch ticket data once the view is loaded
        fetchTicketData()
    }

    // MARK: - Fetch Ticket Data
    private func fetchTicketData() {
        Task {
            do {
                // Fetch the ticket using the ticket ID
                let ticket = try await TicketsManager.getTicket(ticketId: selectedTicketID)
                
                // Update labels on the main thread
                DispatchQueue.main.async {
                    self.lblTicketQuantity.text = "Quantity: \(ticket.quantity)"
                    self.lblTicketAmount.text = "Total Amount: $\(ticket.totalPrice)"
                }
            } catch {
                print("Error fetching ticket: \(error.localizedDescription)")
            }
        }
    }

    @IBAction func payButton(_ sender: Any) {
        // Validate text fields
        if validateTextFields() {
            // Show success alert
            showAlert(title: "Payment Successful", message: "Your payment has been processed successfully.")
        } else {
            // Show error alert
            showAlert(title: "Error", message: "Please fill in all fields correctly.")
        }
    }

    // MARK: - Validate Text Fields
    private func validateTextFields() -> Bool {
        guard let cardNumber = CardNumber.text, !cardNumber.isEmpty,
              let cardHolder = CardHolder.text, !cardHolder.isEmpty,
              let cardExpiry = CardExpiry.text, !cardExpiry.isEmpty,
              let cardCCV = CardCCV.text, !cardCCV.isEmpty else {
            return false // Return false if any field is empty
        }
        return true
    }

    // MARK: - Show Alert
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
