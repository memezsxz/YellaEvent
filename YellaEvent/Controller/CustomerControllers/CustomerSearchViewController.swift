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
    
    
    @IBOutlet weak var catButtons: UIStackView!
    
    
    
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
            
            let testHor = UIStackView()
            testHor.axis = .horizontal
            testHor.distribution = .fillEqually
            
            let testBtn = UIButton()
            testBtn.setTitle("test", for: .normal)
            testBtn.setTitleColor(.white, for: .normal)
            testBtn.layer.cornerRadius = 10
            testBtn.layer.masksToBounds = true
            testBtn.backgroundColor = .darkGray
            testBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            testHor.addArrangedSubview(testBtn)
            
            let testBtn2 = UIButton()
            testBtn2.setTitle("test2", for: .normal)
            testBtn2.setTitleColor(.white, for: .normal)
            testBtn2.layer.cornerRadius = 10
            testBtn2.layer.masksToBounds = true
            testBtn2.backgroundColor = .darkGray
            testBtn2.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            testHor.addArrangedSubview(testBtn2)
            
            let testBtn3 = UIButton()
            testBtn3.setTitle("test3", for: .normal)
            testBtn3.setTitleColor(.white, for: .normal)
            testBtn3.layer.cornerRadius = 10
            testBtn3.layer.masksToBounds = true
            testBtn3.backgroundColor = .darkGray
            testBtn3.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            testHor.addArrangedSubview(testBtn3)
            
//            catButtons.addArrangedSubview(testHor)
            
            
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
