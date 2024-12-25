import UIKit
import FirebaseFirestore

class CustomerTicketDetailsViewController: UIViewController {

    // Property to hold the selected ticket
    var ticket: Ticket? // Ensure Ticket is defined in your project
    var ticketDeletedCallback: (() -> Void)? // This will notify when a ticket is deleted

    // Outlets for UI elements
    @IBOutlet weak var lblEventName: UINavigationItem! // Label for the event name
    @IBOutlet weak var lblTotal: UILabel! // Label for the total price
    @IBOutlet weak var lblQuantity: UILabel! // Label for the quantity of tickets
    @IBOutlet weak var lblDate: UILabel! // Label for the event date
    @IBOutlet weak var lblTime: UILabel! // Label for the event time

    // Firestore database reference
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Update the UI with ticket details when the view loads
        updateUI()
    }

    // Action for the cancel button
    @IBAction func cancelBTN(_ sender: Any) {
        // Show a confirmation alert to the user
        let alert = UIAlertController(title: "Cancel Ticket", message: "Are you sure you want to cancel this ticket?", preferredStyle: .alert)
        
        // Add 'Yes' action to delete the ticket
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { _ in
            self.deleteTicket() // Call the delete function
        })
        
        // Add 'No' action to dismiss the alert
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        // Present the alert
        present(alert, animated: true, completion: nil)
    }

    // Action for the location button
    @IBAction func btnLocation(_ sender: Any) {
        // Check if the ticket is available
        guard let ticket = ticket else { return }
        // Fetch the location URL for the event
        fetchLocationURL(for: ticket.eventID)
    }

    // Function to update the UI with ticket details
    private func updateUI() {
        guard let ticket = ticket else { return }
        
        // Set the UI elements with the ticket details
        lblEventName.title = ticket.eventName
        lblTotal.text = String(format: "$%.2f", ticket.totalPrice)
        lblQuantity.text = "\(ticket.quantity)"
        
        // Format the date and time for display
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        lblDate.text = dateFormatter.string(from: ticket.startTimeStamp)
        lblTime.text = dateFormatter.string(from: ticket.startTimeStamp)
    }
    
    // Function to delete the ticket from Firestore
    private func deleteTicket() {
        guard let ticket = ticket else { return }
        
        // Delete the ticket document from Firestore
        db.collection(K.FStore.Tickets.collectionName).document(ticket.ticketID).delete { error in
            if let error = error {
                print("Error deleting ticket: \(error.localizedDescription)") // Print error if deletion fails
            } else {
                print("Ticket successfully deleted.") // Notify successful deletion
                self.ticketDeletedCallback?() // Call the callback to notify the listing
                self.navigationController?.popViewController(animated: true) // Go back to the previous screen
            }
        }
    }
    
    // Function to fetch the location URL for the event
    private func fetchLocationURL(for eventID: String) {
        db.collection(K.FStore.Events.collectionName).document(eventID).getDocument { (document, error) in
            if let error = error {
                print("Error fetching event details: \(error)") // Print error if fetching fails
                return
            }
            
            // Check if the document exists and contains a location URL
            guard let document = document, document.exists,
                  let data = document.data(),
                  let locationURL = data["locationURL"] as? String else {
                print("Location URL not found.") // Notify if URL is not found
                return
            }
            
            // Open the location URL in a web browser
            if let url = URL(string: locationURL) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                print("Invalid URL.") // Notify if the URL is invalid
            }
        }
    }
}
