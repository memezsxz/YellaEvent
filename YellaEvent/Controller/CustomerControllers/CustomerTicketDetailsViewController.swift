import UIKit
import FirebaseFirestore

class CustomerTicketDetailsViewController: UIViewController {
    var ticket: Ticket? // Property to hold the selected ticket
    var ticketDeletedCallback: (() -> Void)? // Callback to notify when a ticket is deleted

    @IBOutlet weak var lblBtnCancelTicket: UIBarButtonItem! // Cancel ticket button
    @IBOutlet weak var lblEventName: UINavigationItem! // Label for the event name
    @IBOutlet weak var lblTotal: UILabel! // Label for the total price
    @IBOutlet weak var lblQuantity: UILabel! // Label for the quantity of tickets
    @IBOutlet weak var lblDate: UILabel! // Label for the event date
    @IBOutlet weak var lblTime: UILabel! // Label for the event time
    @IBOutlet weak var qrCode: UIImageView! // QR code image view

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI() // Update user interface with ticket details

        // Hide cancel button if the ticket has expired
        if let ticket = ticket, ticket.endTimeStamp < Date() {
            lblBtnCancelTicket.isHidden = true
        }

        // Disable cancel button if the ticket is not paid
        if let ticketStatus = ticket?.status, ticketStatus != .paid {
            lblBtnCancelTicket.isEnabled = false
        }
    }

    @IBAction func cancelBTN(_ sender: Any) {
        self.deleteTicket() // Call function to delete the ticket
    }

    @IBAction func btnLocation(_ sender: Any) {
        guard let url = URL(string: ticket?.locationURL ?? "") else {
            print("Invalid location URL.")
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    private func updateUI() {
        print ("here 1")
        guard let ticket = ticket else { return }
        print ("here 2")
        lblEventName.title = ticket.eventName
        lblTotal.text = String(format: "$%.2f", ticket.totalPrice) // Display total price
        lblQuantity.text = "\(ticket.quantity)" // Display quantity

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        lblDate.text = dateFormatter.string(from: ticket.startTimeStamp) // Display start date

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "hh:mm a"
        lblTime.text = "\(timeFormatter.string(from: ticket.startTimeStamp)) - \(timeFormatter.string(from: ticket.endTimeStamp))" // Display start and end times

        if let qrImage = generateQRCode(from: ticket.ticketID) {
            qrCode.image = qrImage
        } else {
            qrCode.image = nil
        }
    }

    private func deleteTicket() {
        let alertController = UIAlertController(
            title: "Confirm Cancelation",
            message: "Are you sure you want to cancel this ticket?",
            preferredStyle: .alert
        )
        
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
            Task {
                guard var ticketToDelete = self.ticket else { return }
                ticketToDelete.status = .refunded // Update ticket status to refunded
                try await TicketsManager.updateTicket(ticket: ticketToDelete) // Update ticket in Firestore
                self.navigationController?.popViewController(animated: true)
                self.ticketDeletedCallback?()
            }
            self.lblBtnCancelTicket.isHidden = true
        }
        
        let noAction = UIAlertAction(title: "No", style: .cancel)
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        self.present(alertController, animated: true, completion: nil)
    }

    private func fetchLocationURL(for eventID: String) {
        guard let url = URL(string: ticket?.locationURL ?? "") else {
            print("Invalid URL.")
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    private func generateQRCode(from ticketID: String) -> UIImage? {
        guard let data = ticketID.data(using: .ascii) else { return nil }

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("H", forKey: "inputCorrectionLevel")
            
            if let outputImage = filter.outputImage {
                let transform = CGAffineTransform(scaleX: 10, y: 10)
                let scaledImage = outputImage.transformed(by: transform)
                let context = CIContext()
                if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                    return UIImage(cgImage: cgImage)
                }
            }
        }
        return nil
    }
}
