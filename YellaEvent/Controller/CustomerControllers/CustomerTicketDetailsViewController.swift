import UIKit

class CustomerTicketDetailsViewController: UIViewController {

    // Property to hold the selected ticket
    var ticket: Ticket? // Make sure Ticket is defined in your project

    @IBOutlet weak var lblEventName: UINavigationItem!
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var lblQuantity: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTime: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        updateUI()
    }

    @IBAction func btnLocation(_ sender: Any) {
        // Handle location button action
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
}
