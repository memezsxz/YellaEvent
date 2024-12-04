//
//  CustomerSearchViewController.swift
//  YellaEvent
//
//  Created by meme on 25/11/2024.
//

import UIKit

class CustomerSearchViewController: UIViewController {
  
    
    @IBOutlet weak var priceSlider: UISlider!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var ageSlider: UISlider!
    
    @IBOutlet weak var tableView: UITableView!
    
    let prevSearch = ["Eminim", "AWS", "Fun", "GDG", "Swift"]
    var filteredSearch: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filteredSearch = prevSearch
        if tableView != nil {
            tableView.delegate = self
            tableView.dataSource = self
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
