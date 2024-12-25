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
    
    // Category selection
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
        
        // Add target actions to update text fields with selected dates/times
        startDatePicker.addTarget(self, action: #selector(startDatePickerChanged), for: .valueChanged)
        endDatePicker.addTarget(self, action: #selector(endDatePickerChanged), for: .valueChanged)
        startTimePicker.addTarget(self, action: #selector(startTimePickerChanged), for: .valueChanged)
        endTimePicker.addTarget(self, action: #selector(endTimePickerChanged), for: .valueChanged)
    }
    
    // Date Picker Value Changed
    @objc func startDatePickerChanged() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        startDateTextField.text = formatter.string(from: startDatePicker.date)
    }
    
    @objc func endDatePickerChanged() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        endDateTextField.text = formatter.string(from: endDatePicker.date)
    }
    
    @objc func startTimePickerChanged() {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        startTimeTextField.text = formatter.string(from: startTimePicker.date)
    }
    
    @objc func endTimePickerChanged() {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        endTimeTextField.text = formatter.string(from: endTimePicker.date)
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
        
        guard let startDate = startDateTextField.text, !startDate.isEmpty else {
            showAlert(message: "Please select the start date.")
            return
        }
        
        guard let endDate = endDateTextField.text, !endDate.isEmpty else {
            showAlert(message: "Please select the end date.")
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
        
        // Prepare event details message
        let categoryTitle = selectedCategory?.name ?? "None"
        let eventPreviewMessage = """
        Event Name: \(eventName)
        Description: \(eventDescription)
        Category: \(categoryTitle)
        Start Date: \(startDate)
        End Date: \(endDate)
        Start Time: \(startTime)
        End Time: \(endTime)
        Price: $\(ticketPrice)
        """
        
        // Display event preview before saving
        let alert = UIAlertController(title: "Event Preview", message: eventPreviewMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { _ in
            // Convert startDate and endDate strings to Date objects
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateStyle = .none
            timeFormatter.timeStyle = .short
            
            // Parse date and time
            guard let startDateObject = dateFormatter.date(from: startDate),
                  let startTimeObject = timeFormatter.date(from: startTime),
                  let endDateObject = dateFormatter.date(from: endDate),
                  let endTimeObject = timeFormatter.date(from: endTime) else {
                self.showAlert(message: "Invalid date or time format.")
                return
            }
            
            // Combine date and time into a single Date object for start and end
            let calendar = Calendar.current
            let startDateTime = calendar.date(bySettingHour: calendar.component(.hour, from: startTimeObject),
                                              minute: calendar.component(.minute, from: startTimeObject),
                                              second: 0,
                                              of: startDateObject)
            let endDateTime = calendar.date(bySettingHour: calendar.component(.hour, from: endTimeObject),
                                            minute: calendar.component(.minute, from: endTimeObject),
                                            second: 0,
                                            of: endDateObject)
            
            // Ensure the combined Date objects are valid
            guard let validStartDateTime = startDateTime, let validEndDateTime = endDateTime else {
                self.showAlert(message: "Could not combine date and time.")
                return
            }
            
            // Proceed with event creation
            self.saveEventToDatabase(event: Event(
                organizerID: "organizerID", // Replace with actual organizer ID
                organizerName: "Organizer Name", // Replace with actual organizer name
                name: eventName,
                description: eventDescription,
                startTimeStamp: validStartDateTime,
                endTimeStamp: validEndDateTime,
                status: .ongoing,
                category: category,
                locationURL: locationURL,
                venueName: "Venue Name", // Replace with actual venue name
                minimumAge: minAge,
                maximumAge: 100,
                maximumTickets: maxTickets,
                price: ticketPrice,
                coverImageURL: "your_image_url", // Replace with actual cover image URL
                mediaArray: ["your_image_url"], // Replace with actual media URL(s)
                isDeleted: false
            ))
        }))
        alert.addAction(UIAlertAction(title: "Edit", style: .cancel))
        present(alert, animated: true)

        
        present(alert, animated: true)
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
