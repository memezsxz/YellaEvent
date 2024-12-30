import UIKit

class OrganizerCreateEventViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    var delegate : OrganizerCreateEventViewController? = nil
    
    
    let imagePickerController = UIImagePickerController()
    var Coverimage : UIImage?
    var Badgeimage : UIImage?
    var imagePickerSource: String?
    var organizer: Organizer?

//    @IBOutlet var startDateTextField: UITextField!
    @IBOutlet weak var createEventButton: UIButton!
    @IBOutlet weak var eventTitleTextField: UITextField!
    @IBOutlet weak var eventDescriptionTextView: UITextView!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var startTimeTextField: UITextField!
    @IBOutlet weak var endTimeTextField: UITextField!
    
    @IBOutlet weak var categoryButton: UIButton!  // UIButton to trigger UIMenu
    
    var categoryList: [Category] = []
    var StringCategoryList: [String] = []
    var selectedCategory: Category?
    
    @IBOutlet weak var ticketPriceTextField: UITextField!
    @IBOutlet weak var maxTicketsTextField: UITextField!
    @IBOutlet weak var minAgeTextField: UITextField!
    @IBOutlet weak var locationURLTextField: UITextField!
    
    // Error outlets
    @IBOutlet weak var lblErrorEventTitle: UILabel!
    @IBOutlet weak var lblErrorDescription: UILabel!

    @IBOutlet var lblErrorStartDate: UILabel!
    
    @IBOutlet weak var lblErrorEndDate: UILabel!
    @IBOutlet weak var lblErrorStartTime: UILabel!
    @IBOutlet weak var lblErrorEndTime: UILabel!
    @IBOutlet weak var lblErrorTicketPrice: UILabel!
    @IBOutlet weak var lblErrorMaxTickets: UILabel!
    @IBOutlet weak var lblErrorMinAge: UILabel!
    @IBOutlet weak var lblErrorLocation: UILabel!
    @IBOutlet weak var lblErrorEventCover: UILabel!
    @IBOutlet var lblErrorCategory: UILabel!
    
    @IBOutlet weak var lblErrorBadgeCover: UILabel!
    
    @IBOutlet var VanueNameTextField: UITextField!
    
    @IBOutlet var lblErrorVenueName: UILabel!
    
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
    
    @IBAction func catogarymenue(_ sender: Any) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        UserDefaults.standard.set("0VtULKI77gvWkSnnHF45", forKey: K.bundleUserID) // this will be removed after seting the application

        // Load categories asynchronously
        Task {
            
            self.organizer = try await UsersManager.getOrganizer(organizerID: UserDefaults.standard.string(forKey: K.bundleUserID)!)
            
            do {
                self.categoryList = try await CategoriesManager.getActiveCatigories()
                print(self.categoryList) // Debugging: Check if categories are loaded correctly
                self.StringCategoryList = self.categoryList.compactMap({ $0.name })
                // Update the category menu after loading the data
//                self.showDropdown(options: self.StringCategoryList, for: self.categoryButton, title: "Select Category")
               
                if let categoryButton = categoryButton {
                    categoryButton.setTitle("Select Category", for: .normal)
                }
                
            } catch {
                print("Failed to fetch categories: \(error.localizedDescription)")
            }
        }
        
        // Set up date pickers and time pickers
        setupDatePickers()
    }
    
    @IBAction func categoryBtnClicked(_ sender: UIButton) {
        showDropdown(options: StringCategoryList, for: sender, title: "Select Category")
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
        
        
        // Create the menu and assign it to the button
        let menu = UIMenu(title: "", children: menuActions)
        button.menu = menu
        button.showsMenuAsPrimaryAction = true
        button.setTitle("Select Category", for: .normal)

    }

    
    func highlightField(_ textField: UIView?) {
            textField?.layer.borderWidth = 1
            textField?.layer.borderColor = UIColor.red.cgColor
            textField?.layer.cornerRadius = 5
        }

        func resetFieldHighlight(_ textField: UIView?) {
            textField?.layer.borderWidth = 0
            textField?.layer.borderColor = UIColor.clear.cgColor
        }
    
    
    // Function to update the menu with the selected option
    func updateMenuWithSelection(selectedOption: String, options: [String], button: UIButton) {
        // Ensure the selected option is valid
        guard options.contains(selectedOption) else {
            print("Invalid selected option: \(selectedOption).")
            return
        }

        // Update the button's title to the selected option
        button.setTitle(selectedOption, for: .normal)
    }
    
    // Category selection
//    @IBAction func optionSelection(_ sender: UIAction) {
//        let title = sender.title
//        print(title)
//        
//        if let button = self.categoryButton {
////            button.setTitle(title, for: .normal)
//        } else {
//            print("categoryButton is nil")
//        }
//    }
    
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

//        endDateTextField.inputView = endDatePicker
//        endDateTextField.inputAccessoryView = createToolbar()
        
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
        guard validateCreateFields() else {
            return
        }
        
        // Trimmed inputs
        let et = eventTitleTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let ed = eventDescriptionTextView.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let sd = startDateTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let st = startTimeTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let ett = endTimeTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let tp = Double(ticketPriceTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0.0
        let maxTicket = Int(maxTicketsTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        let minAge = Int(minAgeTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        let lu = locationURLTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let vnn = VanueNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        // Ensure start and end date and time strings are converted to Date objects
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none

        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short

        guard let startDate = dateFormatter.date(from: sd),
              let endDate = dateFormatter.date(from: sd),
              let startTime = timeFormatter.date(from: st),
              let endTime = timeFormatter.date(from: ett) else {
            print("Invalid date or time format")
            return
        }

        let calendar = Calendar.current

        // Combine date and time
        let startDateTime = calendar.date(bySettingHour: calendar.component(.hour, from: startTime),
                                          minute: calendar.component(.minute, from: startTime),
                                          second: 0,
                                          of: startDate)

        let endDateTime = calendar.date(bySettingHour: calendar.component(.hour, from: endTime),
                                        minute: calendar.component(.minute, from: endTime),
                                        second: 0,
                                        of: endDate)

        guard let validStartDateTime = startDateTime, let validEndDateTime = endDateTime else {
            print("Failed to combine date and time")
            return
        }

        for seletcted in categoryList{
            if seletcted.name == categoryButton.titleLabel?.text{
                selectedCategory = seletcted
                break
            }
        }
        // Assuming `selectedCategory` is already set
        guard let category = selectedCategory else {
            print("Category is not selected")
            return
        }

        // Create Event object
        var newEvent = Event(
            organizerID: organizer!.userID,
            organizerName: organizer!.fullName, // Replace with actual name
            name: et,
            description: ed,
            startTimeStamp: validStartDateTime,
            endTimeStamp: validEndDateTime,
            status: .ongoing,
            category: category,
            locationURL: lu,
            venueName: vnn, // Replace with actual venue name
            minimumAge: minAge,
            maximumAge: 100,
            maximumTickets: maxTicket,
            price: tp,
            coverImageURL: "", // Replace with actual cover image URL
            mediaArray: [] // Add media URLs as needed
        )
        
        Task{
            
           let id = try await EventsManager.createNewEvent(event: newEvent)
            newEvent.eventID = id
            
            PhotoManager.shared.uploadPhoto(self.Coverimage!, to: "events/\(organizer!.userID)/\(id)/", withNewName: "CoverImage", completion: { result in
                switch result {
                case .success(let url):
                    
                    newEvent.coverImageURL = url
                    
                    Task{
                        try await EventsManager.updateEvent(event: newEvent)
                    }
                    
                case .failure(let error):
                    let alert = UIAlertController(title: "Unable to upload image", message: error.localizedDescription, preferredStyle: .alert)
                    
                    alert.addAction(
                        UIAlertAction(title: "OK", style: .default, handler: { action in
                        }))
                    self.present(alert, animated: true, completion: {})
                }
            })
            
            
            //badge image
            PhotoManager.shared.uploadPhoto(self.Badgeimage!, to: "events/\(organizer!.userID)/\(id)/", withNewName: "Badge", completion: { result in
                switch result {
                case .success(let url):
                    
                    let newBadge = Badge(image: "\(url)", eventID: "\(newEvent.eventID)", eventName: "\(newEvent.name)", category: newEvent.category)
                    
                    Task{
                        try await BadgesManager.createNewBadge(badge: newBadge)
                    }
                    
                case .failure(let error):
                    let alert = UIAlertController(title: "Unable to upload image", message: error.localizedDescription, preferredStyle: .alert)
                    
                    alert.addAction(
                        UIAlertAction(title: "OK", style: .default, handler: { action in
                        }))
                    self.present(alert, animated: true, completion: {})
                }
            })
            
            
        }
        

        print("Event successfully created: \(newEvent)")
        let alert = UIAlertController(
            title: "Event Created",
            message: "Your event has been successfully created.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(
            title: "OK",
            style: .default,
            handler: { _ in
                // Navigate to the previous page
                self.navigationController?.popViewController(animated: true)
            }
        ))

        self.present(alert, animated: true, completion: nil)
    }
    
    
    func saveEventToDatabase(event: Event) {
        print("Event saved to database: \(event)")
        navigationController?.popViewController(animated: true)
    }
    
//    func showAlert(message: String) {
//        let alert = UIAlertController(title: "Validation Error", message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//
    @IBAction func EventCoverBtn(_ sender: Any) {
        imagePickerSource = "cover"
        presentImageImagePicker()

    }
    
    @IBAction func EventBadgeBtn(_ sender: Any) {
        imagePickerSource = "badge"
        presentImageImagePicker()
    }
    
    func presentImageImagePicker() {
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {return}

        if let source = imagePickerSource {
                switch source {
                case "cover":
                    // Handle cover image selection
                    Coverimage = selectedImage
                    lblErrorEventCover.text = "EventCover.jpg"
                    lblErrorEventCover.textColor = .brandBlue
                case "badge":
                    // Handle location image selection
                    // Set the image for location (example: locationImage)
                    Badgeimage = selectedImage
                    lblErrorBadgeCover.text = "Badgeimage.jpg"
                    lblErrorBadgeCover.textColor = .brandBlue
                default:
                    break
                }
            }
            
            dismiss(animated: true, completion: nil)

    }
    
    
    func validateCreateFields() -> Bool {
            var isValid = true

            // Event Title Validation
            if let eventName = eventTitleTextField?.text, eventName.isEmpty {
                lblErrorEventTitle.text = "Event name is required."
                highlightField(eventTitleTextField)
                isValid = false
            } else {
                lblErrorEventTitle.text = ""
                resetFieldHighlight(eventTitleTextField)
            }

            // Event Description Validation
            if let eventDescription = eventDescriptionTextView?.text, eventDescription.isEmpty {
                lblErrorDescription.text = "Event description is required."
                highlightField(eventDescriptionTextView)
                isValid = false
            } else {
                lblErrorDescription.text = ""
                resetFieldHighlight(eventDescriptionTextView)
            }

            // Start Date Validation
            if let startDate = startDateTextField?.text, startDate.isEmpty {
                lblErrorStartDate.text = "Start date is required."
                highlightField(startDateTextField)
                isValid = false
            } else {
                lblErrorStartDate.text = ""
                resetFieldHighlight(startDateTextField)
            }
        
        if let catogarybutton = categoryButton?.titleLabel?.text, catogarybutton == "Select Category" {
            lblErrorCategory.text = "Category is required."
            highlightField(categoryButton)
            isValid = false
        }else {
            lblErrorCategory.text = ""
            resetFieldHighlight(categoryButton)
        }

            
        if let vn = VanueNameTextField?.text, vn.isEmpty {
                lblErrorVenueName.text = "Venue name is required."
            highlightField(VanueNameTextField)
            isValid = false
        }else{
            resetFieldHighlight(VanueNameTextField)
            lblErrorVenueName.text = ""
        }
            // Start Time Validation
            if let startTime = startTimeTextField?.text, startTime.isEmpty {
                lblErrorStartTime.text = "Start time is required."
                highlightField(startTimeTextField)
                isValid = false
            } else {
                lblErrorStartTime.text = ""
                resetFieldHighlight(startTimeTextField)
            }

            // End Time Validation
            if let endTime = endTimeTextField?.text, endTime.isEmpty {
                lblErrorEndTime.text = "End time is required."
                highlightField(endTimeTextField)
                isValid = false
            } else {
                lblErrorEndTime.text = ""
                resetFieldHighlight(endTimeTextField)
            }

            // Ticket Price Validation
            if let ticketPriceText = ticketPriceTextField?.text, ticketPriceText.isEmpty {
                lblErrorTicketPrice.text = "Ticket price is required."
                highlightField(ticketPriceTextField)
                isValid = false
            } else {
                lblErrorTicketPrice.text = ""
                resetFieldHighlight(ticketPriceTextField)
            }

            // Max Tickets Validation
            if let maxTicketsText = maxTicketsTextField?.text, maxTicketsText.isEmpty {
                lblErrorMaxTickets.text = "Maximum tickets are required."
                highlightField(maxTicketsTextField)
                isValid = false
            } else {
                lblErrorMaxTickets.text = ""
                resetFieldHighlight(maxTicketsTextField)
            }

        
        if let eventcover = lblErrorEventCover.text, eventcover.isEmpty || eventcover == "Cover is required." {
            lblErrorEventCover.textColor = .red
            lblErrorEventCover.text = "Cover is required."
                isValid = false
        }
        
        
        if let eventBadge = lblErrorBadgeCover.text, eventBadge.isEmpty || eventBadge == "Badge is required." {
            lblErrorBadgeCover.textColor = .red
            lblErrorBadgeCover.text = "Badge is required."
                isValid = false
        }
        
            // Min Age Validation
            if let minAgeText = minAgeTextField?.text, minAgeText.isEmpty {
                lblErrorMinAge.text = "Minimum age is required."
                highlightField(minAgeTextField)
                isValid = false
            } else {
                lblErrorMinAge.text = ""
                resetFieldHighlight(minAgeTextField)
            }

            // Location URL Validation
            if let locationURL = locationURLTextField?.text, locationURL.isEmpty {
                lblErrorLocation.text = "Location URL is required."
                highlightField(locationURLTextField)
                isValid = false
            } else {
                lblErrorLocation.text = ""
                resetFieldHighlight(locationURLTextField)
            }

            return isValid
        }
    
    
    
    }
