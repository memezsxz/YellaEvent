//
//  AdminEditCategoryController.swift
//  YellaEvent
//
//  Created by Ahmed Ali on 24/12/2024.
//

import UIKit

class AdminEditCategoryController: UIViewController {

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
    

    @IBAction func deleteCategory(_ sender: Any) {
        Task{
            try await CategoriesManager.deleteCategorie(categorieID: currentCategory!.categoryID)
        }
        
        self.navigationController?.popViewController(animated: true)

    }
    @IBAction func updateCategory(_ sender: Any) {
        guard let name = txtName.text else {return}
        guard let icon = txtIcon.text else {return}
        var category = currentCategory
        category?.name = name
        category?.icon = icon
        Task{
            try await CategoriesManager.updateCategorie(category: category!)
        }
        self.navigationController?.popViewController(animated: true)

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
