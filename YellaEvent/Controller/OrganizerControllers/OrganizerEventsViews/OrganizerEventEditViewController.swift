//
//  OrganizerEventEditViewController.swift
//  YellaEvent
//
//  Created by meme on 26/12/2024.
//

import UIKit

class OrganizerEventEditViewController: UITableViewController {
    
    var event: Event?
    
    
    //outlets
    @IBOutlet var txtEventName: UITextField!
    @IBOutlet var textEventDescription: UITextView!
    @IBOutlet var textStartDate: UITextField!
    @IBOutlet var textStartTime: UIView!
    @IBOutlet var textEndTime: UITextField!
    @IBOutlet var btnCategory: UIButton!
    @IBOutlet var btnStatus: UIButton!
    @IBOutlet var textTicketPrice: UITextField!
    @IBOutlet var textVenueName: UITextField!
    @IBOutlet var textLocation: UITextField!
    @IBOutlet var textMaxTicketNum: UITextField!
    //    @IBOutlet weak var txtMinAge: UIStackView!
    //    @IBOutlet var textMinAge: UITextField!
    @IBOutlet weak var textMinAge: UITextField!
    @IBOutlet var btnDelete: UIButton!
    
    //error lables
    
    @IBOutlet var lblErrorEventTitle: UILabel!
    @IBOutlet weak var lblErrorDescription: UILabel!
    @IBOutlet var lblErrorStartDate: UILabel!
    @IBOutlet weak var lblErrorStartTime: UILabel!
    @IBOutlet weak var lblErrorEndTime: UILabel!
    @IBOutlet weak var lblErrorTicketPrice: UILabel!
    @IBOutlet weak var lblErrorMaxTickets: UILabel!
    @IBOutlet weak var lblErrorMinAge: UILabel!
    @IBOutlet weak var lblErrorLocation: UILabel!
    @IBOutlet weak var lblErrorEventCover: UILabel!
    @IBOutlet var lblErrorCategory: UILabel!
    @IBOutlet weak var lblErrorBadgeCover: UILabel!
    @IBOutlet var lblErrorVenueName: UILabel!
    
    
    var StringStatusList: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
        
    }
    
    
    func setup() {
        if let event = event {
            
            txtEventName.text = event.name
            print(event.isDeleted)
            
            if event.isDeleted {
                btnDelete.isEnabled = false
            }
            else {
                btnDelete.isEnabled = true
            }
        }
    }
    
    
    @IBAction func SaveChanges(_ sender: Any) {
    }
    
    
    @IBAction func DeleteEvent(_ sender: Any) {
        
        let alert = UIAlertController(
            title: "Delete Event",
            message: "Are you sure you want to delete this event? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        // Add the "Yes" action
        alert.addAction(UIAlertAction(
            title: "Yes",
            style: .destructive, // Destructive style for delete action
            handler: { _ in
                // Add your event deletion logic here
                print("Event deleted")
                
                self.event?.isDeleted = true
                Task{
                    try await EventsManager.updateEvent(event: self.event!)
                }
                // Optionally navigate back or update the UI
                self.navigationController?.popViewController(animated: true)
            }
        ))
        
        // Add the "Cancel" action
        alert.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil // Dismiss the alert without any action
        ))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func statusButtonTapped(_ sender: UIButton) {
        showDropdown(options: StringStatusList, for: sender, title: "Select Category")
    }
    
    @IBAction func statusButtonClicked(_ sender: UIButton) {
        showDropdown(options: StringStatusList, for: sender, title: "Select Category")
    }
    
    // Generalized function to show a dropdown with a list of items
    func showDropdown(options: [String], for button: UIButton, title: String) {
        // Ensure the options list is not empty
        guard !options.isEmpty else {
            print("The options list cannot be empty.")
            return
        }
        
        // Create UIActions from options
        let menuActions = options.map { option in
            UIAction(title: option, image: nil) { action in
                self.updateMenuWithSelection(selectedOption: option, options: options, button: button)
            }
        }
    }
    
    func updateMenuWithSelection(selectedOption: String, options: [String], button: UIButton) {
        // Ensure the selected option is valid
        guard options.contains(selectedOption) else {
            print("Invalid selected option: \(selectedOption).")
            return
        }
    }
}
    

