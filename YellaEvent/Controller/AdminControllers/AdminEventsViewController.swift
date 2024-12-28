//
//  AdminEventsViewController.swift
//  YellaEvent
//
//  Created by meme on 25/11/2024.
//

import UIKit
import FirebaseFirestore
import SwiftUI
class AdminEventsViewController: UIViewController  {
    
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var eventsStatusSegment: MainUISegmentedControl!
    @IBOutlet var tableView: UITableView!
    var currentSegment : EventStatus? = nil
    
    var orgName: String?{
        didSet {
            if let orgName{
                setOrganizerName(orgName)
            }
        }
    }
    
    var events : [(eventID: String, eventName : String, organizerID: String, status: String)] = []
    var segmentEvents : [(eventID: String, eventName : String, organizerID: String, status: String)] = []
    var searchEvents : [(eventID: String, eventName : String, organizerID: String, status: String)] = []


    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "MainTableViewCell", bundle: .main), forCellReuseIdentifier: "MainTableViewCell")
        
        searchBar.delegate = self
        
        
        
        Task {
        EventsManager.getAllEvents { snapshot, error in
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
                }
                
            }
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let orgName = orgName{
            setOrganizerName(orgName)
            searchBar(searchBar, textDidChange: searchBar.text ?? "")
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
    
    func setSegmentEvents() {
        if let currentSegment = currentSegment  {
            segmentEvents = events.filter { $0.status == currentSegment.rawValue}
        } else {
            segmentEvents  = events
        }
        searchBar(searchBar, textDidChange: searchBar.text ?? "")
    }
}

// MARK: table view
extension AdminEventsViewController : UITableViewDelegate, UITableViewDataSource {
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
}

// MARK: searchbar
extension AdminEventsViewController : UISearchBarDelegate {
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
    
    
    func setOrganizerName(_ name: String?){
        
        if let name = name{
            if let searchBar = searchBar{
                searchBar.text = name
            }
        }
    }
    
}
