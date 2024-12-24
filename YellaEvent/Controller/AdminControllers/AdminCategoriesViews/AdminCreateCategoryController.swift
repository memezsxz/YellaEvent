//
//  AdminCreateCategoryController.swift
//  YellaEvent
//
//  Created by Ahmed Ali on 24/12/2024.
//

import UIKit

class AdminCreateCategoryController: UIViewController {

    @IBOutlet weak var iconErrorLabel: UILabel!
    @IBOutlet weak var nameErrorLabel: UILabel!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtIcon: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        iconErrorLabel.text = ""
        nameErrorLabel.text = ""
        
        iconErrorLabel.isHidden = true
        nameErrorLabel.isHidden = true
    }
    
    @IBAction func createCategoryAction(_ sender: Any) {
        var hasErrors = false

        // Validate name
        if let name = txtName.text, name.isEmpty {
            nameErrorLabel.text = "Name is required."
            nameErrorLabel.isHidden = false
            hasErrors = true
        } else if let name = txtName.text, name.count < 3 {
            nameErrorLabel.text = "Name must be at least 3 characters."
            nameErrorLabel.isHidden = false
            hasErrors = true
        } else {
            nameErrorLabel.isHidden = true
        }

        // Validate icon
        if let icon = txtIcon.text, icon.isEmpty {
            iconErrorLabel.text = "Icon is required."
            iconErrorLabel.isHidden = false
            hasErrors = true
        } else if let icon = txtIcon.text, icon.count != 1 || !icon.unicodeScalars.first!.properties.isEmojiPresentation {
            iconErrorLabel.text = "Icon must be a valid emoji."
            iconErrorLabel.isHidden = false
            hasErrors = true
        } else {
            iconErrorLabel.isHidden = true
        }

        // Stop execution if there are validation errors
        if hasErrors {
            return
        }

        // Proceed with creating the category
        Task {
            try await CategoriesManager.createNewCategory(category: Category(name: txtName.text!, icon: txtIcon.text!))
        }

        let alertController = UIAlertController(
            title: "Category Created",
            message: "The category has been created successfully.",
            preferredStyle: .alert
        )

        // Add the OK action
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            // Perform the segue here
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(okAction)

        // Present the alert controller
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
