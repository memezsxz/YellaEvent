//
//  OrganizerEventsViewController.swift
//  YellaEvent
//
//  Created by meme on 25/11/2024.
//

import UIKit

class OrganizerEventsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var SegmentedControlOutlet: UISegmentedControl!
    
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

    @IBAction func SegmentedControlAction(_ sender: UISegmentedControl) {
    }

    var selectedEventID: String?
    var eventSummarys = [EventSummary]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "MainTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "MainTableViewCell")
        
        Task {
            EventsManager.getOrganizerEvents(organizerID: "3") { snapshot, error in
                guard error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                
                if let snapshot = snapshot {
                    Task {
                        for doc in snapshot.documents {
                            self.eventSummarys.append(try await EventSummary(from: doc.data()))
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.moveToSelection()
                        }
                    }
                } else {
                    print("No events found for organizer")
                }
            }
        }
        
        createEventButton.addTarget(self, action: #selector(createEventButtonTapped), for: .touchUpInside)
    }
    
    @objc func createEventButtonTapped() {
            createEvent()
        }

}

extension OrganizerEventsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.width / 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventSummarys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell") as! MainTableViewCell
        cell.setup(event: eventSummarys[indexPath.row])
        return cell
    }
    
    func moveToSelection() {
        if selectedEventID != nil {
            let index = eventSummarys.firstIndex { $0.eventID == selectedEventID! }
            print(index, selectedEventID, eventSummarys)
            tableView.selectRow(at: IndexPath(row: index!, section: 0), animated: true, scrollPosition: .middle)
            selectedEventID = nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

extension OrganizerEventsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
        
        // Add the event object to Firebase or the appropriate data store
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Validation Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }


   
}
