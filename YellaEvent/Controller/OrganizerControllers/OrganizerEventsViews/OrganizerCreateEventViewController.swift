import UIKit

class OrganizerCreateEventViewController: UITableViewController {
    
    @IBOutlet weak var createEventButton: UIButton!
    @IBOutlet weak var eventTitleTextField: UITextField!
    @IBOutlet weak var eventDescriptionTextView: UITextView!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var startTimeTextField: UITextField!
    @IBOutlet weak var endTimeTextField: UITextField!
    
    @IBOutlet weak var categoryButton: UIButton!  // UIButton to trigger UIMenu
   
    var selectedCategory: Category?
    
    @IBOutlet weak var ticketPriceTextField: UITextField!
    @IBOutlet weak var maxTicketsTextField: UITextField!
    @IBOutlet weak var minAgeTextField: UITextField!
    @IBOutlet weak var locationURLTextField: UITextField!
    
    // Date Pickers and Time Pickers
    var startDatePicker: UIDatePicker!
    var endDatePicker: UIDatePicker!
    var startTimePicker: UIDatePicker!
    var endTimePicker: UIDatePicker!
    
    
    // Custom Picker Container
    var pickerContainerView: UIView!
    
    
    @IBOutlet weak var eventCoverButton: UIButton!
    @IBOutlet weak var eventBadgeButton: UIButton!
    @IBOutlet weak var manageMediaButton: UIButton!

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up date pickers and time pickers
        setupDatePickers()
    }
    
    
    //category
    
    @IBAction func optionSelection(_ sender: UIAction) {
        let title = sender.title
        print(title)
        
        if let button = self.categoryButton {
            button.setTitle(title, for: .normal)
        } else {
            print("categoryButton is nil")
        }
    }

    func setupDatePickers() {
        // Initialize the date and time pickers
        startDatePicker = UIDatePicker()
        startDatePicker.datePickerMode = .date
        startDatePicker.preferredDatePickerStyle = .wheels
        startDateTextField.inputView = startDatePicker
        startDateTextField.inputAccessoryView = createToolbar()
        
        endDatePicker = UIDatePicker()
        endDatePicker.datePickerMode = .date
        endDatePicker.preferredDatePickerStyle = .wheels
        endDateTextField.inputView = endDatePicker
        endDateTextField.inputAccessoryView = createToolbar()
        
        startTimePicker = UIDatePicker()
        startTimePicker.datePickerMode = .time
        startTimePicker.preferredDatePickerStyle = .wheels
        startTimeTextField.inputView = startTimePicker
        startTimeTextField.inputAccessoryView = createToolbar()
        
        endTimePicker = UIDatePicker()
        endTimePicker.datePickerMode = .time
        endTimePicker.preferredDatePickerStyle = .wheels
        endTimeTextField.inputView = endTimePicker
        endTimeTextField.inputAccessoryView = createToolbar()
    }
    
    func createToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // Create the Done button
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissPicker))
        toolbar.setItems([doneButton], animated: false)
        return toolbar
    }
    
    @objc func dismissPicker() {
        // Hide the picker when "Done" is clicked
        view.endEditing(true)
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        // Check which picker is active and update the corresponding text field
        if startDateTextField.isFirstResponder {
            startDateTextField.text = formatter.string(from: startDatePicker.date)
        } else if endDateTextField.isFirstResponder {
            endDateTextField.text = formatter.string(from: endDatePicker.date)
        } else if startTimeTextField.isFirstResponder {
            startTimeTextField.text = formatter.string(from: startTimePicker.date)
        } else if endTimeTextField.isFirstResponder {
            endTimeTextField.text = formatter.string(from: endTimePicker.date)
        }
    }
    
    // Action methods for showing pickers (if needed for additional control)
    @IBAction func startDateTapped(_ sender: UITextField) {
        startDateTextField.inputView = startDatePicker // Ensure the date picker is shown for start date
    }
    
    @IBAction func endDateTapped(_ sender: UITextField) {
        endDateTextField.inputView = endDatePicker // Ensure the date picker is shown for end date
    }
    
    @IBAction func startTimeTapped(_ sender: UITextField) {
        startTimeTextField.inputView = startTimePicker // Ensure the time picker is shown for start time
    }
    
    @IBAction func endTimeTapped(_ sender: UITextField) {
        endTimeTextField.inputView = endTimePicker // Ensure the time picker is shown for end time
    }
    
    
    // Action when Create Event button is clicked
    @IBAction func createEventBtnClicked(_ sender: UIButton) {
        createEvent()
    }
    
    func createEvent() {
        // Validation for required fields
        guard let eventName = eventTitleTextField.text, !eventName.isEmpty else {
            showAlert(message: "Please enter the event name.")
            return
        }
        
        guard let eventDescription = eventDescriptionTextView.text, !eventDescription.isEmpty else {
            showAlert(message: "Please enter the event description.")
            return
        }
        
        guard let startDate = startDatePicker?.date, !startDateTextField.text!.isEmpty else {
            showAlert(message: "Please select the start date.")
            return
        }
        
        guard let endDate = endDatePicker?.date, !endDateTextField.text!.isEmpty else {
            showAlert(message: "Please select the end date.")
            return
        }
        
        guard let startTime = startTimePicker?.date, !startTimeTextField.text!.isEmpty else {
            showAlert(message: "Please enter the start time.")
            return
        }
        
        guard let endTime = endTimePicker?.date, !endTimeTextField.text!.isEmpty else {
            showAlert(message: "Please enter the end time.")
            return
        }
        
        guard let ticketPriceText = ticketPriceTextField.text, !ticketPriceText.isEmpty, let ticketPrice = Double(ticketPriceText) else {
            showAlert(message: "Please enter a valid ticket price.")
            return
        }
        
        guard let maxTicketsText = maxTicketsTextField.text, !maxTicketsText.isEmpty, let maxTickets = Int(maxTicketsText) else {
            showAlert(message: "Please enter the maximum number of tickets.")
            return
        }
        
        guard let minAgeText = minAgeTextField.text, !minAgeText.isEmpty, let minAge = Int(minAgeText) else {
            showAlert(message: "Please enter the minimum age requirement.")
            return
        }
        
        guard let locationURL = locationURLTextField.text, !locationURL.isEmpty else {
            showAlert(message: "Please enter the location URL.")
            return
        }
        
        guard let category = selectedCategory else {
            showAlert(message: "Please select a category.")
            return
        }
        
        // Create the event object
        let event = Event(
            organizerID: "organizerID", // Replace with actual organizer ID
            organizerName: "Organizer Name", // Replace with actual organizer name
            name: eventName,
            description: eventDescription,
            startTimeStamp: startDate,
            endTimeStamp: endDate,
            status: .ongoing, // Change if needed
            category: category,
            locationURL: locationURL,
            venueName: "Venue Name", // Replace with actual venue name
            minimumAge: minAge,
            maximumAge: 100, // Adjust max age if needed
            maximumTickets: maxTickets,
            price: ticketPrice,
            coverImageURL: "your_image_url", // Replace with actual cover image URL
            mediaArray: ["your_image_url"], // Replace with actual media URL(s)
            isDeleted: false
        )
        
        // Handle event saving (Firebase or local storage)
        saveEventToDatabase(event: event)
    }
    
    func saveEventToDatabase(event: Event) {
        print("Event saved to database: \(event)")
        navigationController?.popViewController(animated: true)
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Validation Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
