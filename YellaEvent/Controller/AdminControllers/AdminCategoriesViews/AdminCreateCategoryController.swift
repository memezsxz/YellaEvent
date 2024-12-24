//
//  AdminCreateCategoryController.swift
//  YellaEvent
//
//  Created by Ahmed Ali on 24/12/2024.
//

import UIKit

class AdminCreateCategoryController: UIViewController {

    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtIcon: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func createCategoryAction(_ sender: Any) {
        guard let name = txtName.text else { return }
        guard let icon = txtIcon.text else {return}
        
        Task {
            try await CategoriesManager.createNewCategory(category: Category(name: name, icon: icon))

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
