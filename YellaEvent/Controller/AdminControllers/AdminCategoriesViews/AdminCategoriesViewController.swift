//
//  AdminCategoriesViewController.swift
//  YellaEvent
//
//  Created by meme on 25/11/2024.
//

import UIKit
import FirebaseFirestore

class AdminCategoriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var noDatFoundLbl: UILabel!
    var categories: [Category] = []
    var filteredCategories: [Category] = []
    @IBOutlet weak var searchBar: UISearchBar!
    private var searchWorkItem: DispatchWorkItem?
    @IBOutlet weak var categoriesTable: UITableView!
    @IBOutlet weak var txtCreateIcon: UITextField!
    @IBOutlet weak var txtCreateName: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        categoriesTable.dataSource = self
        categoriesTable.delegate = self
        categoriesTable.register(UINib(nibName: "CategoryViewCell", bundle: nil), forCellReuseIdentifier: "CategoryViewCell")
        

        categoriesTable.showsVerticalScrollIndicator = false
        categoriesTable.showsHorizontalScrollIndicator = false
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadDataFromFirebase()
        searchBar.text = ""
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            // Cancel any previous work
            searchWorkItem?.cancel()
            
            let workItem = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                
                DispatchQueue.global(qos: .userInitiated).async {
                    let filteredResults: [Category]
                    if searchText.isEmpty {
                        filteredResults = self.categories
                    } else {
                        filteredResults = self.categories.filter { $0.name.lowercased().contains(searchText.lowercased()) }
                    }
                    
                    DispatchQueue.main.async {
                        self.filteredCategories = filteredResults
                      
                        self.categoriesTable.reloadData()
                        if self.filteredCategories.count == 0 {
                            self.categoriesTable.isHidden = true
                            self.noDatFoundLbl.isHidden = false
                        }else{
                            self.categoriesTable.isHidden = false
                            self.noDatFoundLbl.isHidden = true
                        }
                    }
                }
            }
            
            // Execute the work item with a delay to debounce
            searchWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
        }


        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
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

extension AdminCategoriesViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredCategories.count
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//            return tableView.frame.width / 8
//    }
    
    func loadDataFromFirebase() {
        CategoriesManager.getActiveCatigories{ snapshot, error in
            if let error = error {
                print("Error occurred during fetching categories: \(error.localizedDescription)")
                return
            }
            
            guard let snapshot = snapshot else {
                print("No data available.")
                return
            }
            
            self.categories = [] // Clear previous data
            
            for doc in snapshot.documents {
                do {
                    let category = try doc.data(as: Category.self)
                    self.categories.append(category)
                } catch {
                    print("Failed to decode category: \(error.localizedDescription)")
                }
            }
        
            DispatchQueue.main.async {
                self.filteredCategories = self.categories
                if self.filteredCategories.count == 0 {
                    self.categoriesTable.isHidden = true
                    self.noDatFoundLbl.isHidden = false
                }else{
                    self.categoriesTable.isHidden = false
                    self.noDatFoundLbl.isHidden = true

                }
                
                self.categoriesTable.reloadData() // Reload table with updated data
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryViewCell") as? CategoryViewCell else { return UITableViewCell() }
        let category = filteredCategories[indexPath.row]
        cell.categoryIcon.text = category.icon
        cell.categoryLabel.text = category.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = filteredCategories[indexPath.row]
        let storyboard = UIStoryboard(name: "AdminCategoriesView", bundle: nil)
        if let editCategory = storyboard.instantiateViewController(withIdentifier: "AdminEditCategoryView") as? AdminEditCategoryController {
                    
            editCategory.title = "Edit " + category.name

            editCategory.currentCategory = category
                        
            self.navigationController?.pushViewController(editCategory, animated: true)
                    } else {
                        print("Failed to instantiate UserListViewController")
                    }
    }
    
    
    
    func listner()  -> ((QuerySnapshot?, (any Error)?) -> Void)  {
        self.categories = []

        return { snapshot, error in
            guard error == nil else {
                print("Error: \(error!)")
                return
            }
            
            guard let snapshot = snapshot else {
                print("No data available.")
                return
            }
            
            for doc in snapshot.documents {
                do {
                    let category: Category
    
                    category = try doc.data(as: Category.self)
             
                    self.categories.append(category)
                } catch {
                    print(error.localizedDescription)
                }
            }
            
            DispatchQueue.main.async {
                //                self.searchBar(self.searchbar, textDidChange: self.searchbar.text ?? "")
            }
        }
    }
    
}
