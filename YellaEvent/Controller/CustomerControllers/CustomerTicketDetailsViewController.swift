import UIKit
import FirebaseFirestore
import FirebaseAuth

// View controller for displaying details of a selected ticket
class CustomerTicketDetailsViewController: UIViewController {
    var ticket: Ticket? // Property to hold the selected ticket
    var ticketDeletedCallback: (() -> Void)? // Callback to notify when a ticket is deleted

    var eventObject: Event?
    
    // Outlets for UI elements
    @IBOutlet weak var lblBtnCancelTicket: UIBarButtonItem! // Cancel ticket button
    @IBOutlet weak var lblEventName: UINavigationItem! // Label for the event name
    @IBOutlet weak var lblTotal: UILabel! // Label for the total price
    @IBOutlet weak var lblQuantity: UILabel! // Label for the quantity of tickets
    @IBOutlet weak var lblDate: UILabel! // Label for the event date
    @IBOutlet weak var lblTime: UILabel! // Label for the event time
    @IBOutlet weak var qrCode: UIImageView! // QR code image view

    @IBOutlet var btnRateEvent: UIButton!
    // Action for the "Rate Event" button
    
    @IBOutlet var btnViewEvent: UIButton!
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEventDetails" {
            
            if let navController = segue.destination as? UINavigationController,
               let destination = navController.topViewController as? CustomerEventViewController {
                // Successfully accessed AdminEventsViewController
                print(eventObject?.name)
                destination.eventID = eventObject!.eventID
            }


        }
    }
    
    @IBAction func btnRateEvent(_ sender: UIButton) {
        // Present an alert controller to collect the rating
        let alertController = UIAlertController(
            title: "Rate Event",
            message: "\n\n\n", // Add space to fit the stars
            preferredStyle: .alert
            
        )

        // Add a container view for the stars
        let containerView = UIView(frame: CGRect(x: 0, y: 70, width: 250, height: 30))
        containerView.translatesAutoresizingMaskIntoConstraints = false
        alertController.view.addSubview(containerView)

        // Create star buttons for rating
        let starButtons = (1...5).map { index -> UIButton in
            let button = UIButton(type: .system)
            button.tag = index
            button.setTitle("★", for: .normal) // Filled star
            button.setTitleColor(.lightGray, for: .normal) // Unselected color
            button.titleLabel?.font = UIFont.systemFont(ofSize: 30)
            button.addTarget(self, action: #selector(self.starTapped(_:)), for: .touchUpInside)
            return button
        }

        // Add stars to the container view
        let stackView = UIStackView(arrangedSubviews: starButtons)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.frame = containerView.bounds
        containerView.addSubview(stackView)

        // Action for submitting the rating
        let okAction = UIAlertAction(title: "Submit Rating", style: .default) { _ in
            let selectedRating = self.selectedRating // This will hold the selected rating
            print("Rating submitted: \(selectedRating)")

            // Save the rating to the backend
            self.submitRating(rating: selectedRating)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)

        // Add the OK action to the alert
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        // Present the alert
        self.present(alertController, animated: true, completion: nil)
    }

    // Variable to hold the selected rating
    private var selectedRating: Int = 0

    // Handle star button taps
    @objc private func starTapped(_ sender: UIButton) {
        selectedRating = sender.tag
        guard let stackView = sender.superview as? UIStackView else { return }

        // Update star colors based on the selection
        for button in stackView.arrangedSubviews.compactMap({ $0 as? UIButton }) {
            button.setTitleColor(button.tag <= selectedRating ? .systemYellow : .lightGray, for: .normal)
        }
    }

    // Submit the rating to the backend
    private func submitRating(rating: Int) {
        guard let ticket = ticket else { return }
        var current = Auth.auth().currentUser
        
        var currentRating = Rating(userID: current!.uid, eventID: ticket.eventID, organizerID: ticket.organizerID, rating: Double(rating))
        print(currentRating.eventID)
        Task{
            try await RatingManager.createNewRating(rating: currentRating)
        }
    

    }


    // Called after the view has been loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI() // Update user interface with ticket details

        
        Task{
            eventObject = try await EventsManager.getEvent(eventID: ticket!.eventID)
        }
        
        
        // Hide cancel button if the ticket has expired
        if let ticket = ticket, ticket.endTimeStamp < Date() {
            lblBtnCancelTicket.isHidden = true
        }

        // Disable cancel button if the ticket is not paid
        if let ticketStatus = ticket?.status, ticketStatus != .paid {
            lblBtnCancelTicket.isEnabled = false
        }

        if ticket!.endTimeStamp > Date() {
            self.btnRateEvent.isHidden = true
            
            
        }else{
            self.btnRateEvent.isHidden = false
            btnViewEvent.tintColor = .brandBlue
            btnViewEvent.titleLabel?.text = "View Event"
        }
        
 
    }

    // Action for the cancel ticket button
    @IBAction func cancelBTN(_ sender: Any) {
        self.deleteTicket() // Call function to delete the ticket
    }

    // Action for the location button that opens the event location in a browser
    @IBAction func btnLocation(_ sender: Any) {
        guard let url = URL(string: ticket?.locationURL ?? "") else {
            print("Invalid location URL.") // Print error if URL is invalid
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil) // Open the URL
    }

    // Updates the UI with ticket details
    private func updateUI() {
        guard let ticket = ticket else { return } // Ensure ticket exists

        // Populate UI elements with ticket information
        lblEventName.title = ticket.eventName
        lblTotal.text = String(format: "$%.2f", ticket.totalPrice) // Display total price
        lblQuantity.text = "\(ticket.quantity)" // Display quantity

        // Format and display the start date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        lblDate.text = dateFormatter.string(from: ticket.startTimeStamp)

        // Format and display the event time range
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "hh:mm a"
        lblTime.text = "\(timeFormatter.string(from: ticket.startTimeStamp)) - \(timeFormatter.string(from: ticket.endTimeStamp))" // Display start and end times

        // Generate and display the QR code for the ticket
        if let qrImage = generateQRCode(from: ticket.ticketID) {
            qrCode.image = qrImage
        } else {
            qrCode.image = nil // Clear QR code if generation fails
        }
    }

    // Function to delete the ticket with a confirmation alert
    private func deleteTicket() {
        let alertController = UIAlertController(
            title: "Confirm Cancelation",
            message: "Are you sure you want to cancel this ticket?",
            preferredStyle: .alert
        )

        // Action for confirming ticket deletion
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
            Task {
                guard var ticketToDelete = self.ticket else { return }
                ticketToDelete.status = .refunded // Update ticket status to refunded
                try await TicketsManager.updateTicket(ticket: ticketToDelete) // Update ticket in Firestore
                self.navigationController?.popViewController(animated: true) // Navigate back
                self.ticketDeletedCallback?() // Notify that the ticket was deleted
            }
            self.lblBtnCancelTicket.isHidden = true // Hide cancel button after deletion
        }

        // Action for canceling deletion
        let noAction = UIAlertAction(title: "No", style: .cancel)
        alertController.addAction(yesAction) // Add yes action to alert
        alertController.addAction(noAction) // Add no action to alert
        self.present(alertController, animated: true, completion: nil) // Present alert
    }

    // Function to generate a QR code from the ticket ID
    private func generateQRCode(from ticketID: String) -> UIImage? {
        guard let data = ticketID.data(using: .ascii) else { return nil } // Convert ticket ID to data

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage") // Set QR code input message
            filter.setValue("H", forKey: "inputCorrectionLevel") // Set error correction level
            
            if let outputImage = filter.outputImage {
                let transform = CGAffineTransform(scaleX: 10, y: 10) // Scale the QR code
                let scaledImage = outputImage.transformed(by: transform)
                let context = CIContext()
                if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                    return UIImage(cgImage: cgImage) // Return generated QR code image
                }
            }
        }
        return nil // Return nil if QR code generation fails
    }
}
