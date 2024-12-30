//
//  OrganizerEventsViewController.swift
//  YellaEvent
//
//  Created by meme on 25/11/2024.
//

import UIKit

class OrganizerEventsViewController: UIViewController {

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var eventsStatusSegment: UISegmentedControl!
    var currentSegment : EventStatus? = nil
    
    var events : [(eventID: String, eventName : String, organizerID: String, status: String)] = []
    var segmentEvents : [(eventID: String, eventName : String, organizerID: String, status: String)] = []
    var searchEvents : [(eventID: String, eventName : String, organizerID: String, status: String)] = []

    var selectedEventID : String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // just for now, remove for final / testing
//        UserDefaults.standard.set("0VtULKI77gvWkSnnHF45", forKey: K.bundleUserID)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "MainTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "MainTableViewCell")
        
        searchBar.delegate = self
        
        Task {
            EventsManager.getOrganizerEvents(organizerID: UserDefaults.standard.string(forKey: K.bundleUserID)!) { snapshot, error in
                guard error == nil else{
                    let alert = UIAlertController(title: "Unable To Fetch Events", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
            
                guard let snapshot else { return }
                
                self.events.removeAll()
                
                for document in snapshot.documents {

                    let id = document.documentID
                    let data = document.data()
                    let eventName = data[K.FStore.Events.name] as! String
                    let organizerId = data[K.FStore.Events.organizerID] as! String
                    let status = data[K.FStore.Events.status] as! String
                    
                    self.events.append((id, eventName, organizerId, status))
                }
                
                DispatchQueue.main.async {
                    self.setSegmentEvents()
                    self.moveToSelection()
                }
                
            }
            
        }

    }
    
    @IBAction func segmentClick(_ sender: Any) {
        
        switch eventsStatusSegment.selectedSegmentIndex {
        case 0: currentSegment = nil
        case 1: currentSegment = .ongoing
        case 2: currentSegment = .completed
        case 3: currentSegment = .cancelled
        default:
            currentSegment = nil
        }
        
        setSegmentEvents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        moveToSelection()
    }
    
    func setSegmentEvents() {
        if let currentSegment = currentSegment  {
            segmentEvents = events.filter { $0.status == currentSegment.rawValue}
        } else {
            segmentEvents  = events
        }
        searchBar(searchBar, textDidChange: searchBar.text ?? "")
    }

    func moveToSelection() {
        if selectedEventID != nil {
            let index = searchEvents.firstIndex { $0.eventID == selectedEventID! }
            if index == nil { return }
//            print(index, selectedEventID, searchEvents)
            tableView.selectRow(at: IndexPath(row: index!, section: 0), animated: true, scrollPosition: .middle)
            selectedEventID = nil
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toViewEvent" {
            let viewEventV = segue.destination as! OrganizerViewEventView
            viewEventV.setup(eventID: searchEvents[tableView.indexPathForSelectedRow!.row].eventID)
        }
    }
}



// MARK: table view
extension OrganizerEventsViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  searchEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath) as! MainTableViewCell
        cell.title.text = "\(searchEvents[indexPath.row].eventName)"
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.frame.width / 6
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = searchEvents[indexPath.row]
        print("hjj", event.eventID)
        performSegue(withIdentifier: "toViewEvent", sender: self)
    }
}

// MARK: searchbar
extension OrganizerEventsViewController : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchText.trimmingCharacters(in: CharacterSet(charactersIn: " "))
        guard !searchText.isEmpty else {
            searchEvents = segmentEvents
            tableView.reloadData()
            return
        }
        
        searchEvents = segmentEvents.filter {
            $0.eventName.contains(searchText) ||
            $0.eventName.split(separator: " ").filter {$0.contains(searchText)}.count > 0
        }
        tableView.reloadData()
    }
}
