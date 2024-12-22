//
//  OrganizerCreateEventViewController.swift
//  YellaEvent
//
//  Created by meme on 22/12/2024.
//

import UIKit

class OrganizerCreateEventViewController: UITableViewController {
    
    @IBOutlet weak var createEventButton: UIButton!
    
    
    @IBOutlet weak var eventTitleTextField: UITextField!
    @IBOutlet weak var eventDescriptionTextView: UITextView!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var startTimeTextField: UITextField!
    @IBOutlet weak var endTimeTextField: UITextField!
    //@IBOutlet weak var categoryDropdown: UIPickerView!
    @IBOutlet weak var ticketPriceTextField: UITextField!
    @IBOutlet weak var maxTicketsTextField: UITextField!
    @IBOutlet weak var minAgeTextField: UITextField!
    @IBOutlet weak var locationURLTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func createEventBtnClicked(_ sender: UIButton) {
//        createEvent()
        
        // if valid details
//        Task {
//            do {
//                try await EventsManager.createNewEvent(event: event);
//                
//                // when done
                navigationController?.popViewController(animated: true)
//            } catch {
//                let alert = UIAlertController(title: "Error Creating Event", message: error.localizedDescription, preferredStyle: .alert)
//                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//                alert.addAction(okAction)
//                present(alert, animated: true, completion: nil)
//            }
//        }
        
    }
}

extension OrganizerCreateEventViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func createEvent() {
        guard let eventName = eventTitleTextField.text, !eventName.isEmpty else {
            showAlert(message: "Please enter the event name.")
            return
        }
        
        guard let eventDescription = eventDescriptionTextView.text, !eventDescription.isEmpty else {
            showAlert(message: "Please enter the event description.")
            return
        }
        
        guard let startDate = startDateTextField.text, !startDate.isEmpty else {
            showAlert(message: "Please enter the start date.")
            return
        }
        
        guard let endDate = endDateTextField.text, !endDate.isEmpty else {
            showAlert(message: "Please enter the end date.")
            return
        }
        
        guard let startTime = startTimeTextField.text, !startTime.isEmpty else {
            showAlert(message: "Please enter the start time.")
            return
        }
        
        guard let endTime = endTimeTextField.text, !endTime.isEmpty else {
            showAlert(message: "Please enter the end time.")
            return
        }
        
        guard let ticketPrice = ticketPriceTextField.text, !ticketPrice.isEmpty else {
            showAlert(message: "Please enter the ticket price.")
            return
        }
        
        guard let maxTickets = maxTicketsTextField.text, !maxTickets.isEmpty else {
            showAlert(message: "Please enter the maximum number of tickets.")
            return
        }
        
        guard let minAge = minAgeTextField.text, !minAge.isEmpty else {
            showAlert(message: "Please enter the minimum age requirement.")
            return
        }
        
        guard let locationURL = locationURLTextField.text, !locationURL.isEmpty else {
            showAlert(message: "Please enter the location URL.")
            return
        }
        
        // If all required fields are valid, proceed to create the event
        
        // Create an Event object with the provided information
        // let event = Event(name: eventName, description: eventDescription, startDate: startDate, endDate: endDate, startTime: startTime, endTime: endTime, ticketPrice: ticketPrice, maxTickets: maxTickets, minAge: minAge, locationURL: locationURL, attendees: [])
        
        print("event is valid")
        // Add the event object to Firebase or the appropriate data store
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Validation Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    
}
