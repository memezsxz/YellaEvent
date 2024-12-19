//
//  EditAddTableViewController.swift
//  YellaEvent
//
//  Created by Admin User on 19/12/2024.
//

import UIKit

class EditAddTableViewController: UITableViewController {

    var FAQObject: FAQ?
    let pickerChoices = ["all","admin", "customer", "organizer"]
    var pickerView: UIPickerView!

    // MARK: - Outlets
    @IBOutlet weak var txtQue: UITextField!
    @IBOutlet var txtAnswer: UITextView!
    @IBOutlet weak var txtType: UITextField!
    @IBOutlet var btnDelete: UIButton!
    @IBOutlet var txtTitle: UINavigationItem!
    
    @IBOutlet weak var lblErrorQue: UILabel!
    @IBOutlet weak var lblErrorAnswer: UILabel!
    @IBOutlet weak var lblErrorFAQ: UILabel!
    
    // MARK: - Initializers
    init?(coder: NSCoder, faq: FAQ?) {
        self.FAQObject = faq
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ensure picker is prepared regardless of FAQObject
        prepareChoices()
        
        // Populate fields if FAQObject exists
        if let faq = FAQObject {
            txtQue.text = faq.question
            txtAnswer.text = faq.answer
            txtType.text = faq.userType.rawValue // Assuming userType is an enum with `rawValue`
            btnDelete.isHidden = false
            txtTitle.title = "Edit FAQ"
            
        } else {
            txtTitle.title = "Add FAQ"
            txtType.text = "all"
            btnDelete.isHidden = true
        }
    }

    
    @IBAction func cancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: Delete
    @IBAction func deleteFAQ(_ sender: UIButton) {
        if let faq = FAQObject {
            let saveAlert = UIAlertController(
                title: "Delete FAQ",
                message: "Are you sure you want to delete this FAQ? This action is permanent and cannot be undone.",
                preferredStyle: .alert
            )
            
            // Cancel action
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            
            // Delete action
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                Task {
                    do {
                        // Perform the delete operation
                        try await FAQsManager.deleteFAQ(FAQID: faq.faqID)
                        
                        // Trigger the unwind segue after successful deletion
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "delete", sender: self)
                        }
                    } catch {
                        // Handle any errors during deletion
                        print("Error deleting FAQ: \(error.localizedDescription)")
                    }
                }
            }
            
            // Add actions to the alert
            saveAlert.addAction(cancelAction)
            saveAlert.addAction(deleteAction)
            
            // Present the alert
            present(saveAlert, animated: true)
        }
    }

    
   
    
    
    // MARK: - Save Info
    @IBAction func saveInfo(_ sender: UIButton) {
        var isValid = true
        
        // Validate question field
        if let question = txtQue.text, question.isEmpty {
            lblErrorQue.text = "Question is required"
            isValid = false
        } else {
            lblErrorQue.text = ""
        }
        
        // Validate answer field
        if let answer = txtAnswer.text, answer.isEmpty {
            lblErrorAnswer.text = "Answer is required"
            isValid = false
        } else {
            lblErrorAnswer.text = ""
        }
        
        // Validate user type field
        if let type = txtType.text, type.isEmpty {
            lblErrorFAQ.text = "User Type is required"
            isValid = false
        } else {
            lblErrorFAQ.text = ""
        }
        
        if isValid {
            let que = txtQue.text!
            let ans = txtAnswer.text!
            let type = txtType.text!
            var choice: FAQUserType = .all
            
            if type == "admin" {
                choice = .admin
            } else if type == "customer" {
                choice = .customer
            } else if type == "organizer" {
                choice = .organizer
            } else {
                choice = .all
            }
            
            // Create or update the FAQ
            Task {
                do {
                    if FAQObject == nil {
                        let newFAQ = FAQ(question: que, answer: ans, userType: choice)
                        try await FAQsManager.createNewFAQ(FAQ: newFAQ)
                    } else {
                        FAQObject?.question = que
                        FAQObject?.answer = ans
                        FAQObject?.userType = choice
                        try await FAQsManager.updateFAQ(FAQ: FAQObject!)
                    }
                    
                    // Trigger unwind segue after successful operation
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "save", sender: self)
                    }
                } catch {
                    print("Error saving FAQ: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Picker Setup
    func prepareChoices() {
        pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        
        // Set picker view as input view for txtType
        txtType.inputView = pickerView
        
        // Add toolbar with Done button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePicker))
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        txtType.inputAccessoryView = toolbar
    }
    
    @objc func donePicker() {
        txtType.resignFirstResponder()
    }
}

// MARK: - UIPickerViewDelegate and UIPickerViewDataSource
extension EditAddTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // Single column
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerChoices.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerChoices[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        txtType.text = pickerChoices[row]
    }
    
    
    
}
