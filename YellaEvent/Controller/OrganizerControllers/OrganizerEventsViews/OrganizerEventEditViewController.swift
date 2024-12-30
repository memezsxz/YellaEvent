import UIKit

class OrganizerEventEditViewController: UITableViewController {

    var event: Event?
    var badge: Badge?

    // Outlets
    @IBOutlet var txtEventName: UITextField!
    @IBOutlet var textEventDescription: UITextView!
    @IBOutlet var textStartDate: UITextField!
    @IBOutlet weak var textStartTime: UITextField!
    @IBOutlet var textEndTime: UITextField!
    @IBOutlet var btnCategory: UIButton!
    @IBOutlet var btnStatus: UIButton!
    @IBOutlet var textTicketPrice: UITextField!
    @IBOutlet var textVenueName: UITextField!
    @IBOutlet var textLocation: UITextField!
    @IBOutlet var textMaxTicketNum: UITextField!
    @IBOutlet weak var textMinAge: UITextField!
    @IBOutlet weak var eventCoverButton: UIButton!
    @IBOutlet weak var eventBadgeButton: UIButton!
    @IBOutlet var btnDelete: UIButton!
    
    
    var eventID: String = "3jCdiZ7OrVUAksiBrZwr"
    
    var selectedCategory: Category?
    var organizer: Organizer?
    var categoryList: [Category] = []
    var StringCategoryList: [String] = []
    
    // Error labels
    @IBOutlet var lblErrorEventTitle: UILabel!
    @IBOutlet weak var lblErrorDescription: UILabel!
    @IBOutlet var lblErrorStartDate: UILabel!
    @IBOutlet weak var lblErrorStartTime: UILabel!
    @IBOutlet var lblErrorEndTime: UILabel!
    @IBOutlet weak var lblErrorTicketPrice: UILabel!
    @IBOutlet weak var lblErrorMaxTickets: UILabel!
    @IBOutlet weak var lblErrorMinAge: UILabel!
    @IBOutlet weak var lblErrorLocation: UILabel!
    @IBOutlet weak var lblErrorEventCover: UILabel!
    @IBOutlet var lblErrorCategory: UILabel!
    @IBOutlet var lblErrorStatus: UILabel!
    @IBOutlet weak var lblErrorBadgeCover: UILabel!
    @IBOutlet var lblErrorVenueName: UILabel!

    var StringStatusList: [String] = []
    private var imagePickerController = UIImagePickerController()
    private var imagePickerSource: String?
    private var Coverimage: UIImage?
    private var Badgeimage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let status = StringStatusList.first {
            btnStatus.setTitle(status, for: .normal)
        }
        
        Task {
                self.organizer = try await UsersManager.getOrganizer(organizerID: UserDefaults.standard.string(forKey: K.bundleUserID)!)
                
                if let status = StringStatusList.first {
                    btnStatus.setTitle(status, for: .normal)
                }

                do {
                    self.categoryList = try await CategoriesManager.getActiveCatigories()
                    print(self.categoryList) // Debugging: Check if categories are loaded correctly
                    self.StringCategoryList = self.categoryList.compactMap({ $0.name })
                    
                    DispatchQueue.main.async {
                        self.showDropdown(options: self.StringCategoryList, for: self.btnCategory, title: "Select Category")
                    }
                    
                } catch {
                    print("Failed to fetch categories: \(error.localizedDescription)")
                }
                
                // Load status options
                self.StringStatusList = ["Ongoing", "Completed", "Cancelled"]
                
                DispatchQueue.main.async {
                    self.showDropdown(options: self.StringStatusList, for: self.btnStatus, title: "Select Status")
                }
            
            
        
        setup()
    }

    func setup() {
        if let event = event {
            txtEventName.text = event.name
            btnDelete.isEnabled = !event.isDeleted
            textEventDescription.text = event.description

            // Set up date and time formatters
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none

            let timeFormatter = DateFormatter()
            timeFormatter.dateStyle = .none
            timeFormatter.timeStyle = .short

            // Populate date and time fields
            textStartDate.text = dateFormatter.string(from: event.startTimeStamp)
            textStartTime.text = timeFormatter.string(from: event.startTimeStamp)
            textEndTime.text = timeFormatter.string(from: event.endTimeStamp)

            btnCategory.setTitle(event.category.name, for: .normal)
            btnStatus.setTitle(event.status.rawValue, for: .normal)

            let priceFormatter = NumberFormatter()
            priceFormatter.numberStyle = .currency
            textTicketPrice.text = priceFormatter.string(from: NSNumber(value: event.price))

            textVenueName.text = event.venueName
            textMaxTicketNum.text = String(event.maximumTickets)
            textLocation.text = event.locationURL
            textMinAge.text = String(event.minimumAge)

            // Load event cover image if available
            Task {
                PhotoManager.shared.downloadImage(from: URL(string: event.coverImageURL)!) { result in
                    switch result {
                    case .success(let coverImage):
                        self.eventCoverButton.setBackgroundImage(coverImage, for: .normal)
                    case .failure(let error):
                        print("error", error.localizedDescription)
                    }
                }

            }

            // Load badge image if available
            Task {
                badge = try await BadgesManager.getBadgeForEvent(eventID: event.eventID)
                           if !badge!.image.isEmpty,
                              let badgeImage = UIImage(contentsOfFile: badge!.image) {
                               eventBadgeButton.setBackgroundImage(badgeImage, for: .normal)
                           } else {
                               eventBadgeButton.setBackgroundImage(UIImage(named: "defaultBadgeImage"), for: .normal)
                           }
            }
               }
        
               
        }
    }
    func setupDatePickers() {
        // Initialize the date and time pickers with wheel style
        let startDatePicker = UIDatePicker()
        startDatePicker.datePickerMode = .date
        startDatePicker.preferredDatePickerStyle = .wheels
        textStartDate.inputView = startDatePicker
        textStartDate.inputAccessoryView = createToolbar()

        let startTimePicker = UIDatePicker()
        startTimePicker.datePickerMode = .time
        startTimePicker.preferredDatePickerStyle = .wheels
        textStartTime.inputView = startTimePicker
        textStartTime.inputAccessoryView = createToolbar()

        let endTimePicker = UIDatePicker()
        endTimePicker.datePickerMode = .time
        endTimePicker.preferredDatePickerStyle = .wheels
        textEndTime.inputView = endTimePicker
        textEndTime.inputAccessoryView = createToolbar()

        // Add target actions to update text fields with selected dates/times
        startDatePicker.addTarget(self, action: #selector(startDatePickerChanged), for: .valueChanged)
        startTimePicker.addTarget(self, action: #selector(startTimePickerChanged), for: .valueChanged)
        endTimePicker.addTarget(self, action: #selector(endTimePickerChanged), for: .valueChanged)
        
    }

    @objc func startDatePickerChanged(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        textStartDate.text = dateFormatter.string(from: sender.date)
    }

    @objc func startTimePickerChanged(sender: UIDatePicker) {
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        textStartTime.text = timeFormatter.string(from: sender.date)
    }

    @objc func endTimePickerChanged(sender: UIDatePicker) {
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        textEndTime.text = timeFormatter.string(from: sender.date)
    }

    func createToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        toolbar.setItems([doneButton], animated: false)
        return toolbar
    }

    @objc func doneButtonTapped() {
        view.endEditing(true)
    }

    @IBAction func EventCoverBtn(_ sender: Any) {
        imagePickerSource = "cover"
        presentImagePicker()
    }

    @IBAction func EventBadgeBtn(_ sender: Any) {
        imagePickerSource = "badge"
        presentImagePicker()
    }

    func presentImagePicker() {
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else { return }

        if let source = imagePickerSource {
            switch source {
            case "cover":
                Coverimage = selectedImage
                lblErrorEventCover.text = "Cover image updated."
                lblErrorEventCover.textColor = .systemGreen
                print("Cover image selected: \(selectedImage)")
            case "badge":
                        Badgeimage = selectedImage
                        lblErrorBadgeCover.text = "Badge image updated."
                        lblErrorBadgeCover.textColor = .systemGreen
                        print("Badge image selected: \(selectedImage)")
                    default: break

            }
        }

        dismiss(animated: true, completion: nil)
    }

    @IBAction func SaveChanges(_ sender: Any) {
        guard validateCreateFields() else { return }

        // Trimmed inputs
        let et = txtEventName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let ed = textEventDescription.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let sd = textStartDate.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let st = textStartTime.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let ett = textEndTime.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let tp = Double(textTicketPrice.text!.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0.0
        let maxTicket = Int(textMaxTicketNum.text!.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        let minAge = Int(textMinAge.text!.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        let lu = textLocation.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let vnn = textVenueName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
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

        // Check if category is selected
        guard let category = selectedCategory else {
            print("Category is not selected")
            return
        }

        // Update the event object with new values
        event?.name = et
        event?.description = ed
        event?.startTimeStamp = validStartDateTime
        event?.endTimeStamp = validEndDateTime
        event?.price = tp
        event?.maximumTickets = maxTicket
        event?.minimumAge = minAge
        event?.locationURL = lu
        event?.venueName = vnn
        event?.category = category

        // Update the cover image URL if changed
        if let updatedCoverImage = Coverimage {
            PhotoManager.shared.uploadPhoto(updatedCoverImage, to: "events/\(organizer!.userID)/\(event!.eventID)/", withNewName: "CoverImage", completion: { result in
                switch result {
                case .success(let url):
                    self.event?.coverImageURL = url
                    
                    Task {
                        do {
                            // Save updated event to the database
                            try await EventsManager.updateEvent(event: self.event!)
                        } catch {
                            print("Error updating event: \(error)")
                        }
                    }
                case .failure(let error):
                    let alert = UIAlertController(title: "Unable to upload image", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }

        // Update the badge image URL if changed
        if let updatedBadgeImage = Badgeimage {
            PhotoManager.shared.uploadPhoto(updatedBadgeImage, to: "events/\(organizer!.userID)/\(event!.eventID)/", withNewName: "Badge", completion: { result in
                switch result {
                case .success(let url):
                    let newBadge = Badge(image: "\(url)", eventID: "\(self.event!.eventID)", eventName: "\(self.event!.name)", category: self.event!.category)
                    
                    Task {
                        do {
                            // Save updated badge
                            try await BadgesManager.createNewBadge(badge: newBadge)
                            
                            // Update the badge image button with the new badge image
                            DispatchQueue.main.async {
                                self.eventBadgeButton.setBackgroundImage(updatedBadgeImage, for: .normal)
                            }
                        } catch {
                            print("Error creating badge: \(error)")
                        }
                    }
                case .failure(let error):
                    let alert = UIAlertController(title: "Unable to upload image", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }

        print("Event successfully updated: \(event!)")
        
        let alert = UIAlertController(
            title: "Event Updated",
            message: "Your event has been successfully updated.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(
            title: "OK",
            style: .default,
            handler: { _ in
                self.navigationController?.popViewController(animated: true)
            }
        ))

        self.present(alert, animated: true, completion: nil)
    }


    @IBAction func DeleteEvent(_ sender: Any) {
        let alert = UIAlertController(
            title: "Delete Event",
            message: "Are you sure you want to delete this event? This action cannot be undone.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { _ in
            self.event?.isDeleted = true
            Task {
                try await EventsManager.updateEvent(event: self.event!)
            }
            self.navigationController?.popViewController(animated: true)
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true, completion: nil)
    }

    @IBAction func statusButtonTapped(_ sender: UIButton) {
        showDropdown(options: StringStatusList, for: sender, title: "Select Status")
    }

    func showDropdown(options: [String], for button: UIButton, title: String) {
        guard !options.isEmpty else {
            print("The options list cannot be empty.")
            return
        }

        let menuActions = options.map { option in
            UIAction(title: option) { _ in
                button.setTitle(option, for: .normal)
            }
        }

        button.menu = UIMenu(title: title, children: menuActions)
        button.showsMenuAsPrimaryAction = true

        // Set a default title for the button if it doesn't have one already
        if button.title(for: .normal) == nil {
            button.setTitle(options.first, for: .normal)
        }
    }


    func validateCreateFields() -> Bool {
        var isValid = true

        func highlightField(_ textField: UIView?) {
            textField?.layer.borderWidth = 1
            textField?.layer.borderColor = UIColor.red.cgColor
            textField?.layer.cornerRadius = 5
        }

        func resetFieldHighlight(_ textField: UIView?) {
            textField?.layer.borderWidth = 0
            textField?.layer.borderColor = UIColor.clear.cgColor
        }

        func isEmptyOrWhitespace(_ text: String?) -> Bool {
            return text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
        }


        if isEmptyOrWhitespace(txtEventName.text) {
            lblErrorEventTitle.text = "Event name is required and must be at least 3 characters."
            highlightField(txtEventName)
            isValid = false
        } else {
            lblErrorEventTitle.text = ""
            resetFieldHighlight(txtEventName)
        }

        if isEmptyOrWhitespace(textEventDescription.text) {
            lblErrorDescription.text = "Event description is required."
            highlightField(textEventDescription)
            isValid = false
        } else {
            lblErrorDescription.text = ""
            resetFieldHighlight(textEventDescription)
        }

        if isEmptyOrWhitespace(textStartDate.text) {
            lblErrorStartDate.text = "Start date is required."
            highlightField(textStartDate)
            isValid = false
        } else {
            lblErrorStartDate.text = ""
            resetFieldHighlight(textStartDate)
        }

        if textStartTime.text?.isEmpty ?? true {
            lblErrorStartTime.text = "Start time is required."
            highlightField(textStartTime)
            isValid = false
        } else {
            lblErrorStartTime.text = ""
            resetFieldHighlight(textStartTime)
        }

        if textEndTime.text?.isEmpty ?? true {
            lblErrorEndTime.text = "End time is required."
            highlightField(textEndTime)
            isValid = false
        } else {
            lblErrorEndTime.text = ""
            resetFieldHighlight(textEndTime)
        }

        if isEmptyOrWhitespace(textVenueName.text) {
            lblErrorVenueName.text = "Venue name is required."
            highlightField(textVenueName)
            isValid = false
        } else {
            lblErrorVenueName.text = ""
            resetFieldHighlight(textVenueName)
        }

        if textTicketPrice.text?.isEmpty ?? true {
            lblErrorTicketPrice.text = "Ticket price is required."
            highlightField(textTicketPrice)
            isValid = false
        } else {
            lblErrorTicketPrice.text = ""
            resetFieldHighlight(textTicketPrice)
        }

        if textMaxTicketNum.text?.isEmpty ?? true {
            lblErrorMaxTickets.text = "Maximum tickets are required."
            highlightField(textMaxTicketNum)
            isValid = false
        } else {
            lblErrorMaxTickets.text = ""
            resetFieldHighlight(textMaxTicketNum)
        }

        if textMinAge.text?.isEmpty ?? true {
            lblErrorMinAge.text = "Minimum age is required."
            highlightField(textMinAge)
            isValid = false
        } else {
            lblErrorMinAge.text = ""
            resetFieldHighlight(textMinAge)
        }

        if isEmptyOrWhitespace(textLocation.text) {
            lblErrorLocation.text = "Location is required."
            highlightField(textLocation)
            isValid = false
        } else {
            lblErrorLocation.text = ""
            resetFieldHighlight(textLocation)
        }

//        if eventCoverButton.currentBackgroundImage == nil {
//            lblErrorEventCover.textColor = .red
//            lblErrorEventCover.text = "Event cover image is required."
//            isValid = false
//        } else {
//            lblErrorEventCover.text = ""
//        }
//
//        if eventBadgeButton.currentBackgroundImage == nil {
//            lblErrorBadgeCover.textColor = .red
//            lblErrorBadgeCover.text = "Badge image is required."
//            isValid = false
//        } else {
//            lblErrorBadgeCover.text = ""
//        }
//
        
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
        
        if btnCategory.title(for: .normal) == nil || btnCategory.title(for: .normal)?.isEmpty ?? true {
            lblErrorCategory.text = "Category is required."
            lblErrorCategory.textColor = .red
            isValid = false
        } else {
            lblErrorCategory.text = ""
            lblErrorCategory.textColor = .clear
        }

        
        if btnStatus.title(for: .normal) == nil || btnStatus.title(for: .normal)?.isEmpty ?? true {
            lblErrorStatus.text = "Status is required."
            lblErrorStatus.textColor = .red
            isValid = false
        } else {
            lblErrorStatus.text = ""
            lblErrorStatus.textColor = .clear
        }

        return isValid
        
    }
}

extension OrganizerEventEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {}
