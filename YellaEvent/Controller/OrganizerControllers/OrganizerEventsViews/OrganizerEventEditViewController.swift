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
    @IBOutlet var textMinAge: UITextField!
    @IBOutlet var btnDelete: UIButton!
    
   
    
    //error lables
    
    @IBOutlet var lblErrorEventTitle: UILabel!
    
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
    
}
