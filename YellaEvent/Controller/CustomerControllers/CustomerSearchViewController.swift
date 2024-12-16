//
//  CustomerSearchViewController.swift
//  YellaEvent
//
//  Created by meme on 25/11/2024.
//

import UIKit

class CustomerSearchViewController: UIViewController {
    
    @IBOutlet weak var previousLbl: UILabel!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var priceSlider: UISlider!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var ageSlider: UISlider!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var catButtons: UIStackView!
    
    
    var prevSearch: [String] = []
    let userDefaults = UserDefaults.standard
    
    var filteredSearch: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prevSearch = userDefaults.array(forKey: "prevSearch") as? [String] ?? []
        
        filteredSearch = prevSearch
        if tableView != nil {
            tableView.delegate = self
            tableView.dataSource = self
            if prevSearch.isEmpty{
                tableView.isHidden = true
                previousLbl.isHidden = true
            }
        } else{
            priceTextField.text = String(Int( priceSlider.value))
            ageTextField.text = String(Int( ageSlider.value))
        }
        
    }
    
    
    @IBAction func sliderChanges(_ sender: Any) {
        priceTextField.text = String(Int( priceSlider.value))
    }
    
    @IBAction func ageSliderChange(_ sender: Any) {
        ageTextField.text = String(Int( ageSlider.value))
    }
    
    
    @IBAction func fliteringunwind(_ unwindSegue: UIStoryboardSegue) {
    }
    
    // Search button logic
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Hide keyboard and UI elements
        searchBar.resignFirstResponder()
        showHide(condition: true)
        prevSearch.append(searchBar.text ?? "")
        UserDefaults.standard.set(prevSearch, forKey: "prevSearch")
    }

    // Cancel button logic
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filteredSearch = prevSearch
        tableView.reloadData()

        // Hide the keyboard and restore UI
        searchBar.resignFirstResponder()
        showHide(condition: false)
    }

    // Perform search from selected cell
    func performSearch(for text: String) {
        // Update the search bar text with the selected cell's content
        searchBar.text = text
        showHide(condition: true)
    }
    
    func showHide(condition: Bool){
        previousLbl.isHidden = condition
        tableView.isHidden = condition
        searchBar.showsCancelButton = condition
    }

}


extension CustomerSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredSearch.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = filteredSearch[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedText = filteredSearch[indexPath.row]
        
        // Perform the search logic here
        performSearch(for: selectedText)
        
        // Optional: Deselect the cell after selection
        tableView.deselectRow(at: indexPath, animated: true)
    }
}



extension CustomerSearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" { filteredSearch = prevSearch} else {
            filteredSearch = prevSearch.filter { item in item.lowercased().contains(searchText.lowercased())
                    }
        }
        
        tableView.reloadData()
    }
    
    
}
