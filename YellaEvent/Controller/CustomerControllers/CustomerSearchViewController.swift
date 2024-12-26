//
//  CustomerSearchViewController.swift
//  YellaEvent
//
//  Created by meme on 25/11/2024.
//

import FirebaseFirestore
import UIKit

class CustomerSearchViewController: UIViewController {

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
    var age: Int = 4
    var price: Int = 5

    override func viewDidLoad() {
        super.viewDidLoad()

        prevSearch = userDefaults.array(forKey: "prevSearch") as? [String] ?? []
        filteredSearch = prevSearch.reversed()

        // check whether the user in filter or in search page
        if tableView != nil {
            tableView.register(
                UINib(nibName: "EventSummaryTableViewCell", bundle: nil),
                forCellReuseIdentifier: "EventSummaryTableViewCell")
            // in the tabele page
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
            categoriesCollectioView.setSelectedInterests(selectedFilters)
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
                print("Unwind segue source is not of type CustomerSearchViewController")
                return
            }

            // Safely retrieve age and price
            if let ageText = sourceVC.ageTextField.text, let ageValue = Int(ageText) {
                self.age = ageValue
            }

            if let priceText = sourceVC.priceTextField.text, let priceValue = Int(priceText) {
                self.price = priceValue
            }

            // Retrieve the selected filters from the source view controller
            self.selectedFilters = sourceVC.categoriesCollectioView.getInterests()
            print("Unwind apply filters:", self.selectedFilters)
        }
    }



    @IBAction func applyFliteringunwind(_ unwindSegue: UIStoryboardSegue) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "filter" {
            print("prepare", self.selectedFilters)
            if let vc = segue.destination as? CustomerSearchViewController {
                _ = vc.view // Force the view to load

                // Pass the selected filters
                vc.selectedFilters = self.selectedFilters
                
                vc.ageTextField.text = String(self.age)
                vc.priceTextField.text = String(self.price)
                vc.ageSlider.value = Float(self.age)
                vc.priceSlider.value = Float(self.price)

                // Update the collection view's selected interests
                vc.categoriesCollectioView.selectForCustomer = false
                vc.categoriesCollectioView.setSelectedInterests(vc.selectedFilters)
            }
        }
    }

    // Search button logic
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Hide keyboard and UI elements
        //        searchBar.resignFirstResponder()
        showHide(condition: true)
        if prevSearch.count >= 5 {
            // Keep only the last 4 elements
            prevSearch = Array(prevSearch.suffix(4))
        }

        // Append the new search text
        prevSearch.append(searchBar.text ?? "")
        filteredSearch = prevSearch.reversed()
        // Save the updated array to UserDefaults
        UserDefaults.standard.set(prevSearch, forKey: "prevSearch")
        

        searchMade()

        //        changesMade = true
        //        tableView.reloadData()
    }

    func searchMade() {
        changesMade = true
        Task {
            guard let searchText = searchBar.text, !searchText.isEmpty else {
                print("Search text is empty")
                return
            }

            let normalizedSearchText = searchText.lowercased()
            do {
                let snapshot = try await Firestore.firestore()
                    .collection(K.FStore.Events.collectionName)
                    .whereField("status", isEqualTo: "ongoing")
                    .getDocuments()

                // Process and filter documents locally
                let tempEventsList = await withTaskGroup(of: EventSummary?.self)
                { group -> [EventSummary] in
                    for doc in snapshot.documents {
                        group.addTask {
                            let event = try? await EventSummary(
                                from: doc.data())
                            // filter to check if the event is ongoing

                            // Filter locally for partial matches
                            if let eventName = event?.name.lowercased(),
                                eventName.contains(normalizedSearchText)
                            {
                                return event
                            }
                            return nil
                        }
                    }

                    var results: [EventSummary] = []
                    for await event in group {
                        if let event = event {
                            results.append(event)
                        }
                    }
                    return results
                }

                // Update UI on the main thread
                DispatchQueue.main.async {
                    self.eventsList = tempEventsList
                    self.tableView.reloadData()
                }
            } catch {
                print("Error fetching events: \(error)")
            }
        }

        print("search")

    }

    // Cancel button logic
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filteredSearch = prevSearch.reversed()

        // Hide the keyboard and restore UI
        searchBar.resignFirstResponder()
        showHide(condition: false)
        changesMade = false
        tableView.reloadData()
        print("cancel")
    }

    // Perform search from selected cell
    func performSearch(for text: String) {
        // Update the search bar text with the selected cell's content
        searchBar.text = text
        showHide(condition: true)
    }

    func showHide(condition: Bool) {
        if condition {
            previousLbl.text = "Results"
        } else {
            previousLbl.text = "Previous Search"
        }
        //        tableView.isHidden = condition
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

            // Perform the search logic here
            performSearch(for: selectedText)
            searchMade()

            // Optional: Deselect the cell after selection
            tableView.deselectRow(at: indexPath, animated: true)
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
