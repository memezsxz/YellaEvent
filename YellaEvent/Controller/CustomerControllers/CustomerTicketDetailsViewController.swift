import UIKit
import FirebaseFirestore

class CustomerTicketDetailsViewController: UIViewController {

    // Property to hold the selected ticket
    var ticket: Ticket? // Ensure Ticket is defined in your project
    var ticketDeletedCallback: (() -> Void)? // This will notify when a ticket is deleted

    @IBOutlet weak var lblBtnCancelTicket: UIBarButtonItem!
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
            
            // Additional logic to hide cancel button for expired tickets
            if let ticket = ticket, ticket.endTimeStamp < Date() {
                lblBtnCancelTicket.isHidden = true
            }
            
            if let ticket = ticket?.status, ticket != .paid {
                lblBtnCancelTicket.isEnabled = false
   
            }
        
    }

    // Action for the cancel button
    @IBAction func cancelBTN(_ sender: Any) {
        self.deleteTicket() // Call the delete function
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
        print(ticket.status)
        
        if ticket.status == .paid {
            lblBtnCancelTicket.isEnabled = true

        } else if ticket.status == .cancelled || ticket.status == .refunded {
            lblBtnCancelTicket.isEnabled = false

        }
    
    
        
        Task{
//            var eventobject = try await EventsManager.getEvent(eventID: ticket.eventID)
            
            // Set the UI elements with the ticket details
            lblEventName.title = ticket.eventName
            lblTotal.text = String(format: "$%.2f", ticket.totalPrice)
            lblQuantity.text = "\(ticket.quantity)"
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            
            lblDate.text = dateFormatter.string(from: ticket.startTimeStamp)
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "hh:mm a" // Use "a" for AM/PM format

//            lblTime.text = "\(timeFormatter.string(from: ticket.startTimeStamp))"

            lblTime.text = "\(timeFormatter.string(from: ticket.startTimeStamp) ) -  \(timeFormatter.string(from: ticket.endTimeStamp))"
            // Format the date and time for display
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateStyle = .medium
//            dateFormatter.timeStyle = .short
//            lblDate.text = dateFormatter.string(from: ticket.startTimeStamp)
//            lblTime.text = dateFormatter.string(from: ticket.startTimeStamp)
            
        }
       
    }
    
    // Function to delete the ticket from Firestore
    private func deleteTicket() {
        let alertController = UIAlertController(
               title: "Confirm Cancelation",
               message: "Are you sure you want to cancel this ticket?",
               preferredStyle: .alert
           )
           
           // Add the "Yes" action
           let yesAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
               // Handle the cancellation logic here
               
               Task{
                   self.ticket!.status = .refunded
//                   print(self.ticket)
                   try await TicketsManager.updateTicket(ticket: self.ticket!)
                   print(self.ticket)
                   self.navigationController?.popViewController(animated: true)
               }
               self.lblBtnCancelTicket.isHidden = true
           }
           
           // Add the "No" action
           let noAction = UIAlertAction(title: "No", style: .cancel) { _ in
               // Handle the case where the user does not want to cancel
               print("Cancelation aborted")
           }
           
           // Add the actions to the alert controller
           alertController.addAction(yesAction)
           alertController.addAction(noAction)
           
           // Present the alert
           self.present(alertController, animated: true, completion: nil)
  
        
    }
    
    // Function to fetch the location URL for the event
    private func fetchLocationURL(for eventID: String) {

        print(ticket!.eventID)
            // Open the location URL in a web browser
        if let url = URL(string: ticket!.locationURL) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                print("Invalid URL.") // Notify if the URL is invalid
            }
    }
}
