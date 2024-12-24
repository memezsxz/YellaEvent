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
    
    // Initialize Firestore
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Fetch ticket data once the view is loaded
        fetchTicketData()
    }

    // MARK: - Fetch Ticket Data
    private func fetchTicketData() {
        // Replace 'yourDocumentID' with the actual document ID
        let documentID = "yourDocumentID" // Update this with your actual document ID
        db.collection("tickets").document(documentID).getDocument { (document, error) in
            if let error = error {
                print("Error fetching document: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists,
                  let data = document.data() else {
                print("Document does not exist")
                return
            }

            // Extract quantity and total price
            let quantity = data["quantity"] as? Int ?? 0
            let totalPrice = data["totalPrice"] as? Double ?? 0.0
            
            // Update labels on the main thread
            DispatchQueue.main.async {
                self.lblTicketQuantity.text = "Quantity: \(quantity)"
                self.lblTicketAmount.text = "Total Amount: $\(totalPrice)"
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
