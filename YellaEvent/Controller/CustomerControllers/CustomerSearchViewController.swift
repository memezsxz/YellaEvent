//
//  CustomerSearchViewController.swift
//  YellaEvent
//
//  Created by meme on 25/11/2024.
//

import FirebaseFirestore
import UIKit

class CustomerSearchViewController: UIViewController, InterestsCollectionViewDelegate {

    

    @IBOutlet weak var previousLbl: UILabel!

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var priceSlider: UISlider!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var ageSlider: UISlider!

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet var categoriesCollectioView: InterestsCollectionView!

    @IBOutlet weak var catButtons: UIStackView!
    

    var prevSearch: [String] = []
    let userDefaults = UserDefaults.standard
    var filteredSearch: [String] = []
    var eventsList: [EventSummary] = []
    var filteredEventsList: [EventSummary] = []
    var selectedFilters: [String] = []
    var changesMade: Bool = false
    var age: Int = 5
    var price: Int = 5
    var filterApplied: Bool = false
    var selectedEventID : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prevSearch = userDefaults.array(forKey: "prevSearch") as? [String] ?? []
        filteredSearch = prevSearch.reversed()

        // check if user in filter or in search page
        if tableView != nil {
            // in the tabele page
            tableView.register(
                UINib(nibName: "EventSummaryTableViewCell", bundle: nil),
                forCellReuseIdentifier: "EventSummaryTableViewCell")
            tableView.delegate = self
            tableView.dataSource = self
            if prevSearch.isEmpty {
                tableView.isHidden = true
                previousLbl.isHidden = true
            }

        } else {
            // in the filter page
            priceTextField.text = String(Int(priceSlider.value))
            ageTextField.text = String(Int(ageSlider.value))
            categoriesCollectioView.controllerDelegate = self
        }

    }

    @IBAction func sliderChanges(_ sender: Any) {
        priceTextField.text = String(Int(priceSlider.value))
    }

    @IBAction func ageSliderChange(_ sender: Any) {
        ageTextField.text = String(Int(ageSlider.value))
    }

    @IBAction func fliteringunwind(_ unwindSegue: UIStoryboardSegue) {
        if unwindSegue.identifier == "apply" {
            guard let sourceVC = unwindSegue.source as? CustomerSearchViewController else {
                return
            }

            if let ageText = sourceVC.ageTextField.text, let ageValue = Int(ageText) {
                self.age = ageValue
            }

            if let priceText = sourceVC.priceTextField.text, let priceValue = Int(priceText) {
                self.price = priceValue
            }

            self.selectedFilters = sourceVC.categoriesCollectioView.getInterests()
            self.filterApplied = true
            searchMade()
        }
    }

    
    @IBAction func applyFliteringunwind(_ unwindSegue: UIStoryboardSegue) {
    }
    
    @IBAction func resetFilter(_ unwindSegue: UIStoryboardSegue) {
        filterApplied = false
        selectedFilters = []
        age = 5
        price = 5
        searchMade()
    }

    func setInterests() {
        categoriesCollectioView.setSelectedInterests(self.selectedFilters)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchMade()
    }

    func searchMade() {
        Task {
            // Allow empty input if filterApplied is true
            if !filterApplied {
                guard let searchBar = searchBar, let searchText = searchBar.text, !searchText.isEmpty else {
                    return
                }
            }
            
            searchBar.resignFirstResponder()

            if prevSearch.count >= 5 {
                prevSearch = Array(prevSearch.suffix(4)) // Keep only the last 4 elements
            }

            if let searchText = searchBar.text, !searchText.isEmpty {
                prevSearch.append(searchText)
                filteredSearch = prevSearch.reversed()
                UserDefaults.standard.set(prevSearch, forKey: "prevSearch")
            }

            changesMade = true
            showHide(condition: true)

            let normalizedSearchText = searchBar.text?.lowercased() ?? ""
            do {
                let snapshot = try await Firestore.firestore()
                    .collection(K.FStore.Events.collectionName)
                    .whereField("status", isEqualTo: "ongoing")
                    .getDocuments()

                let tempEventsList = await withTaskGroup(of: EventSummary?.self) { group -> [EventSummary] in
                    for doc in snapshot.documents {
                        group.addTask {
                            return try? await EventSummary(from: doc.data())
                        }
                    }

                    var results: [EventSummary] = []
                    for await event in group {
                        if let event = event {
                            // Filter by search text if filterApplied is false
                            let matchesSearchText = normalizedSearchText.isEmpty || event.name.lowercased().contains(normalizedSearchText)
                            if matchesSearchText {
                                if filterApplied {
                                    let matchesCategory = selectedFilters.isEmpty || selectedFilters.contains(event.categoryID)
                                    let matchesAge = age >= 0
                                    let matchesPrice = price >= Int(event.price)
                                    if matchesCategory && matchesAge && matchesPrice {
                                        results.append(event)
                                    }
                                } else {
                                    results.append(event)
                                }
                            }
                        }
                    }
                    return results
                }

                DispatchQueue.main.async {
                    self.eventsList = tempEventsList
                    self.tableView.reloadData()
                }
            } catch {
                
            }
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filteredSearch = prevSearch.reversed()

        searchBar.resignFirstResponder()
        showHide(condition: false)
        changesMade = false
        tableView.reloadData()
    }

    func performSearch(for text: String) {
        searchBar.text = text
        showHide(condition: true)
    }

    func showHide(condition: Bool) {
        if condition {
            previousLbl.text = "Results"
        } else {
            previousLbl.text = "Previous Search"
        }
        searchBar.showsCancelButton = condition
    }


}

extension CustomerSearchViewController: UITableViewDelegate,
    UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        if changesMade {
            return eventsList.count
        }
        return filteredSearch.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        if changesMade {
            let cell =
                tableView.dequeueReusableCell(
                    withIdentifier: "EventSummaryTableViewCell", for: indexPath)
                as! EventSummaryTableViewCell
            cell.setup(with: eventsList[indexPath.row])
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = filteredSearch[indexPath.row]
            return cell
        }
    }

    func tableView(
        _ tableView: UITableView, didSelectRowAt indexPath: IndexPath
    ) {
        if !changesMade {
            let selectedText = filteredSearch[indexPath.row]

            performSearch(for: selectedText)
            searchMade()

            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            selectedEventID = eventsList[indexPath.row].eventID
            let storyboard = UIStoryboard(name: "CustomerEventView", bundle: nil)
                    guard let customerEventVC = storyboard.instantiateViewController(withIdentifier: "CustomerEventView") as? CustomerEventViewController else { return }
            customerEventVC.eventID = selectedEventID!
                    customerEventVC.delegate = self
                    navigationController?.pushViewController(customerEventVC, animated: true)
        }
        
    }

    func tableView(
        _ tableView: UITableView, heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        if changesMade {
            return tableView.frame.width / 2
        }
        return 50
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "filter" {
            InterestsCollectionView.selectForCustomer = false
            if let vc = segue.destination as? CustomerSearchViewController {
                _ = vc.view

                vc.selectedFilters = self.selectedFilters
                
                vc.ageTextField.text = String(self.age)
                vc.priceTextField.text = String(self.price)
                vc.ageSlider.value = Float(self.age)
                vc.priceSlider.value = Float(self.price)
            }
        }
        
    }
    
}

extension CustomerSearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !changesMade {
            if searchText == "" {
                filteredSearch = prevSearch.reversed()
            } else {
                filteredSearch = prevSearch.filter { item in
                    item.lowercased().contains(searchText.lowercased())
                }
            }
            tableView.reloadData()
        }
    }
}

func getEvents() async throws -> [EventSummary]? {
    let events = try await EventsManager.searchEvents(byOrganizerID: "4")
    return events
}
