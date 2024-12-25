import UIKit
import FirebaseFirestore

class CustomerTicketDetailsViewController: UIViewController {

    // Property to hold the selected ticket
    var ticket: Ticket? // Make sure Ticket is defined in your project

    @IBOutlet weak var lblEventName: UINavigationItem!
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var lblQuantity: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTime: UILabel!

    // Firestore database reference
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        updateUI()
    }

    @IBAction func btnLocation(_ sender: Any) {
        // Handle location button action
        guard let ticket = ticket else { return }
        fetchLocationURL(for: ticket.eventID)
    }

    private func updateUI() {
        guard let ticket = ticket else { return }
        
        // Update the UI elements with ticket details
        lblEventName.title = ticket.eventName
        lblTotal.text = String(format: "$%.2f", ticket.totalPrice)
        lblQuantity.text = "\(ticket.quantity)"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        lblDate.text = dateFormatter.string(from: ticket.startTimeStamp)
        lblTime.text = dateFormatter.string(from: ticket.startTimeStamp)
    }
    
    // Fetch the location URL from Firestore based on the event ID
    private func fetchLocationURL(for eventID: String) {
        db.collection(K.FStore.Events.collectionName).document(eventID).getDocument { (document, error) in
            if let error = error {
                print("Error fetching event details: \(error)")
                return
            }
            
            guard let document = document, document.exists,
                  let data = document.data(),
                  let locationURL = data["locationURL"] as? String else {
                print("Location URL not found.")
                return
            }
            
            // Open the location URL in a web view or external browser
            if let url = URL(string: locationURL) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                print("Invalid URL.")
            }
        }
    }
}
