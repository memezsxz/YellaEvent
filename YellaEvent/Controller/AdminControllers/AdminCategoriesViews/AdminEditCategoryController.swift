//
//  AdminEditCategoryController.swift
//  YellaEvent
//
//  Created by Ahmed Ali on 24/12/2024.
//

import UIKit

class AdminEditCategoryController: UIViewController {

    @IBOutlet weak var nameErrorLabel: UILabel!
    @IBOutlet weak var iconErrorLabel: UILabel!
    @IBOutlet weak var txtIcon: UITextField!
    @IBOutlet weak var txtName: UITextField!
    
    var currentCategory: Category?
    override func viewDidLoad() {
        super.viewDidLoad()

        if let selectedCategory = currentCategory {
            txtName.text = selectedCategory.name
            txtIcon.text = selectedCategory.icon
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        iconErrorLabel.text = ""
        nameErrorLabel.text = ""
        
        iconErrorLabel.isHidden = true
        nameErrorLabel.isHidden = true
    }
    

    @IBAction func deleteCategory(_ sender: Any) {
        
        
        // Create the alert controller
        let alertController = UIAlertController(
            title: "Delete Category",
            message: "Are you sure you want to delete this category? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        // Add the Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        // Add the Delete action
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            // Add your deletion logic here
            Task{
                try await CategoriesManager.deleteCategorie(categorieID: self.currentCategory!.categoryID)
            }
            
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(deleteAction)
        
        // Present the alert controller
        self.present(alertController, animated: true, completion: nil)
   
        


    }
    @IBAction func updateCategory(_ sender: Any) {
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

        // Proceed with updating the category
        guard let name = txtName.text, let icon = txtIcon.text else { return }
        var category = currentCategory
        category?.name = name
        category?.icon = icon

        Task {
            try await CategoriesManager.updateCategorie(category: category!)
        }

        let alertController = UIAlertController(
            title: "Save Changes",
            message: "Your changes have been saved successfully.",
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
