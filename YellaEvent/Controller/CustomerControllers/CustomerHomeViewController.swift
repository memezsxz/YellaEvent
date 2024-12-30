//
//  CustomerHomeViewController.swift
//  YellaEvent
//
//  Created by meme on 25/11/2024.
//

import UIKit
import FirebaseFirestore

class CustomerHomeViewController: UITableViewController {
    let db = Firestore.firestore()
    let userID = UserDefaults.standard.string(forKey: K.bundleUserID)!
    var debug = false
    var user : Customer?
    var currentIndex = 0
    var allRecommendedEvents: [DocumentReference] = []
    var newEvent : [EventSummary] = []
    var events: [EventSummary] = []
    var selectedEventID : String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
//                UserDefaults.standard.set("1OJ9cN1iMAG5pjNocI7Z", forKey: K.bundleUserID) // this will be removed after seting the application

        
        tableView.register(UINib(nibName: "EventSummaryTableViewCell", bundle: .main), forCellReuseIdentifier: "EventSummaryTableViewCell")
        
        Task {
            user =  try await  UsersManager.getCustomer(customerID:userID)

        }
        
        Task { // get the latest 5 evnts
            do {
                let snapshot = try await Firestore.firestore()
                    .collection(K.FStore.Events.collectionName)
                    .whereField(K.FStore.Events.status, isEqualTo: EventStatus.ongoing.rawValue)
                    .order(by: K.FStore.Events.startTimeStamp)
                    .limit(to: 5)
                    .getDocuments()
                
                for doc in snapshot.documents {
                    do {
                        let eventSummary = try await EventSummary(from: doc.data())
                        DispatchQueue.main.async {
                            self.newEvent.append(eventSummary)
                            self.tableView.insertRows(at: [IndexPath(row: self.newEvent.count - 1, section: 1)], with: .bottom)
                        }
                    } catch {
                        print("Error creating EventSummary for document \(doc.documentID): \(error)")
                    }
                }
            } catch {
                print("Error fetching documents: \(error)")
            }
        }
        
        
        
        calculateCategoryScores(userID: userID) { categoryScores in
            
            if self.debug {
                print("Category Scores:")
                self.displayCatogoriesranking(categoryScores: categoryScores)
                print("")
            }
            
            self.fetchRecommendedEvents(userID: self.userID, categoryScores: categoryScores) { events in
                
                
                self.allRecommendedEvents = events
                self.loadMoreEvents()
                
                if self.debug {
                    self.displayEvents(events: self.events)
                }
                
            }
        }
    }
    
    // 1
    func calculateCategoryScores(userID: String, completion: @escaping ([String: Double]) -> Void) {
        fetchCategories { initialScores in
            self.updateScoresForInterests(userID: userID, categoryScores: initialScores) { scoresAfterInterests in
                self.updateScoresForTickets(userID: userID, categoryScores: scoresAfterInterests) { scoresAfterTickets in
                    self.updateScoresForRatings(userID: userID, categoryScores: scoresAfterTickets) { finalScores in
                        completion(finalScores)
                    }
                }
            }
        }
    }
    
    // 2 - getting all the catigories and inisializing them to 1
    func fetchCategories(completion: @escaping ([String: Double]) -> Void) {
        let categoriesRef = db.collection(K.FStore.Categories.collectionName)
        
        categoriesRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching categories: \(error)")
                completion([:])
                return
            }
            
            var categoryScores: [String: Double] = [:]
            
            snapshot?.documents.forEach { doc in
                if let categoryID = doc.documentID as String? {
                    categoryScores[categoryID] = 1 // Initialize each category with 1 point
                }
            }
            completion(categoryScores)
        }
    }
    
    // 3 -
    func updateScoresForInterests(userID: String, categoryScores: [String: Double], completion: @escaping ([String: Double]) -> Void) {
        var updatedScores = categoryScores // Create a local copy of the scores
        let userRef = db.collection(K.FStore.Customers.collectionName).document(userID)
        
        if debug {
            print("updateScoresForInterests: ")
        }
        userRef.getDocument { (document, error) in
            if let document = document, let userData = document.data(),
               let interests = userData[K.FStore.Customers.intrestArray] as? [String] {
                for interest in interests {
                    updatedScores[interest, default: 0] += 5
                    if self.debug {
                        print(interest, updatedScores[interest]!)
                    }
                }
            }
            completion(updatedScores)
        }
    }
    
    // 4 - checks if the the user booked an event in a spicific category (+1) checks if the user attende theat event (+1)
    func updateScoresForTickets(userID: String, categoryScores: [String: Double], completion: @escaping ([String: Double]) -> Void) {
        var updatedScores = categoryScores // Create a local copy of the scores
        let ticketsRef = db.collection(K.FStore.Tickets.collectionName)
        
        ticketsRef.whereField(K.FStore.Tickets.customerID, isEqualTo: userID).getDocuments { (snapshot, error) in
            if let documents = snapshot?.documents {
                let group = DispatchGroup() // To handle async fetches for events
                if self.debug {
                    print("updateScoresForTickets: ")
                }
                for doc in documents {
                    if let eventID = doc[K.FStore.Tickets.eventID] as? String {
                        let didAttend = doc[K.FStore.Tickets.didAttend] as? Bool ?? false
                        
                        group.enter() // Enter the dispatch group
                        // Fetch event details
                        self.db.collection(K.FStore.Events.collectionName).document(eventID).getDocument { (eventDoc, _) in
                            if let eventDoc = eventDoc, let eventData = eventDoc.data(),
                               let categoryID = eventData[K.FStore.Events.categoryID] as? String {
                                updatedScores[categoryID, default: 0] += 1 // Add 1 point for booking
                                
                                if didAttend {
                                    updatedScores[categoryID, default: 0] += 1 // Add another point for attendance
                                    
                                }
                                if self.debug {
                                    print(categoryID, updatedScores[categoryID, default: 0])
                                }
                            }
                            group.leave() // Leave the dispatch group
                        }
                    }
                }
                
                group.notify(queue: .main) { // Wait for all fetches to complete
                    completion(updatedScores)
                }
            } else {
                completion(updatedScores)
            }
        }
    }
    
    // 5 checks if the user has ratted an event that they attended, if they have it multiplies the catigory score by 1.(user rating)
    func updateScoresForRatings(userID: String, categoryScores: [String: Double], completion: @escaping ([String: Double]) -> Void) {
        var updatedScores = categoryScores // Create a local copy of the scores
        let ratingsRef = db.collection(K.FStore.Ratings.collectionName)
        
        ratingsRef.whereField(K.FStore.Ratings.customerID, isEqualTo: userID).getDocuments { (snapshot, error) in
            if let documents = snapshot?.documents {
                let group = DispatchGroup() // To handle async fetches for events
                
                if self.debug {
                    print("updateScoresForRatings: ")
                }
                
                for doc in documents {
                    if let eventID = doc[K.FStore.Ratings.eventID] as? String,
                       let rating = doc[K.FStore.Ratings.rating] as? Double {
                        
                        group.enter() // Enter the dispatch group
                        
                        // Fetch event details
                        self.db.collection(K.FStore.Events.collectionName).document(eventID).getDocument { (eventDoc, _) in
                            if let eventDoc = eventDoc, let eventData = eventDoc.data(),
                               let categoryID = eventData[K.FStore.Events.categoryID] as? String {
                                
                                if self.debug {
                                    print("before", eventData[K.FStore.Events.name] as! String, rating, categoryID, updatedScores[categoryID]!)
                                }
                                
                                updatedScores[categoryID] = updatedScores[categoryID, default: 0] * (1 + (rating * 0.1))
                                
                                if self.debug {
                                    print("after", eventData[K.FStore.Events.name] as! String, rating, categoryID, updatedScores[categoryID]!)
                                }

                            }
                            group.leave() // Leave the dispatch group
                        }
                    }
                }
                group.notify(queue: .main) { // Wait for all fetches to complete
                    completion(updatedScores)
                }
                
            } else {
                completion(updatedScores)
            }
        }
    }
    
    // 6
    func fetchRecommendedEvents(userID: String, categoryScores: [String: Double], completion: @escaping ([DocumentReference]) -> Void) {
        fetchAttendedEvents(userID: userID) { attendedEvents in
            self.fetchAllEvents(attendedEvents: attendedEvents) { events in
                self.fetchRatingsAndCalculateScores(events: events, categoryScores: categoryScores, completion: completion)
            }
        }
    }
    
    // 7 - gets the events the user have attended -- for later exclution
    func fetchAttendedEvents(userID: String, completion: @escaping (Set<String>) -> Void) {
        var attendedEvents: Set<String> = []
        
        db.collection(K.FStore.Tickets.collectionName)
            .whereField(K.FStore.Tickets.customerID, isEqualTo: userID)
            .whereField(K.FStore.Tickets.didAttend, isEqualTo: true)
            .getDocuments { (snapshot, error) in
                if let documents = snapshot?.documents {
                    attendedEvents = Set(documents.compactMap { $0[K.FStore.Tickets.eventID] as? String })
                }
                completion(attendedEvents)
            }
    }
    
    // 8 - gets all the events and removes attended events from them
    func fetchAllEvents(attendedEvents: Set<String>, completion: @escaping ([QueryDocumentSnapshot]) -> Void) {
        db.collection(K.FStore.Events.collectionName)
            .whereField(K.FStore.Events.isDeleted, isEqualTo: false)
            .whereField(K.FStore.Events.status, isEqualTo: EventStatus.ongoing.rawValue)
            .getDocuments { (snapshot, error) in
                guard let documents = snapshot?.documents else {
                    completion([]) // No events to fetch
                    return
                }
                
                let filteredEvents = documents.filter { doc in
                    let eventID = doc.documentID
                    return !attendedEvents.contains(eventID)
                }
                completion(filteredEvents)
            }
    }
    
    // 9 - to get the event score (order), gets the avarage rating of the events and multiplies 1.(avarage) by the category score
    func fetchRatingsAndCalculateScores(events: [QueryDocumentSnapshot], categoryScores: [String: Double], completion: @escaping ([DocumentReference]) -> Void) {
        var recommendedEvents: [(event: DocumentReference, value: Double)] = []
        let group = DispatchGroup()
        
        for doc in events {
            let eventID = doc.documentID
            let eventData = doc.data()
            guard let categoryID = eventData[K.FStore.Events.categoryID] as? String else { continue }
            
            let categoryScore = categoryScores[categoryID, default: 0]
            group.enter()
            
            // Use Firestore aggregation to calculate the average rating
            let ratingsQuery = db.collection(K.FStore.Ratings.collectionName)
                .whereField(K.FStore.Ratings.eventID, isEqualTo: eventID)
            
            let aggregateQuery = ratingsQuery.aggregate([AggregateField.average(K.FStore.Ratings.rating)])
            
            Task {
                do {
                    let snapshot = try await aggregateQuery.getAggregation(source: .server)
                    let averageRating = snapshot.get(AggregateField.average(K.FStore.Ratings.rating)) as? Double ?? 0.0
                    
                    let value = categoryScore * (1 + (1 / max(averageRating, 1)) )// to not devide by 0
//                    print(value, categoryScore, (1 + (1 / max(averageRating, 1))), (1 / max(averageRating, 1)), max(averageRating, 1), averageRating )
                        recommendedEvents.append((event: doc.reference, value: value))
                } catch {
                    print("Error calculating average rating for event \(eventID): \(error)")
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            let sortedEvents = recommendedEvents.sorted { $0.value > $1.value }
            if self.debug {
                print("Sorted Events:")
                print(sortedEvents)
            }
            completion(sortedEvents.map { $0.event })
        }
    }
    
    
    
    func displayEvents(events: [EventSummary]) {
        events.forEach { event in
            print("Event Name: \(event.name) , \(event.categoryID)")
        }
    }
    
    func displayCatogoriesranking(categoryScores: [String: Double]) {
        categoryScores.forEach { category, score in
            print("Category: \(category) , Score: \(score)")
        }
    }
}


// MARK: Table view work
extension CustomerHomeViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return newEvent.count
        }
        if section == 2 {
                        return events.count
        }

        return 1
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
                if indexPath.section == 2 && (indexPath.row+1 == events.count) {
                    loadMoreEvents()
                }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
             let cell = tableView.dequeueReusableCell(withIdentifier: "EventSummaryTableViewCell", for: indexPath) as! EventSummaryTableViewCell
            
            cell.setup(with: newEvent[indexPath.row])
            return cell
        }

        if indexPath.section == 2 {
             let cell = tableView.dequeueReusableCell(withIdentifier: "EventSummaryTableViewCell", for: indexPath) as! EventSummaryTableViewCell
            
            cell.setup(with: events[indexPath.row])
            return cell
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomerHayCell
        
        Task {
            self.user =  try await  UsersManager.getCustomer(customerID:self.userID)
            cell.hayLabel.text = "Hey \(user!.fullName.split(separator: " ")[0]) 👋🏻"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            selectedEventID =  newEvent[indexPath.row].eventID
        }
        
        if indexPath.section == 2 {
            selectedEventID =  events[indexPath.row].eventID
        }
        
        performSegue(withIdentifier: "toEvent", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "New Events"
        }
        if section == 2 {
            return "Suggested Events"
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if section == 1 {
            return
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            return super.tableView(tableView, viewForHeaderInSection: section)
        }
        // Find the UILabel inside the default header view (if it exists)
        let headerView = UIView()
        headerView.backgroundColor = .clear
        
        // Add a new UILabel
        let label = UILabel()
        if section == 1 {
            label.text =  "New Events"
        }
        if section == 2 {
            label.text = "Suggested Events"
        }
        let HSizeClass = UIScreen.main.traitCollection.horizontalSizeClass
        let VSizeClass = UIScreen.main.traitCollection.verticalSizeClass
        if HSizeClass == .regular && VSizeClass == .regular {
            label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        } else {
            label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        }
        label.textColor = UIColor(named: K.BrandColors.darkPurple)
        //                label.textAlignment = .center
        
        // Add the label to the header view
        headerView.addSubview(label)
        
        
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: headerView.topAnchor),
            label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -20)
        ])
        
        
        return headerView
        
        
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        
        return K.HSizeclass == .regular && K.VSizeclass == .regular ? 45 : 40
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {return K.HSizeclass == .regular && K.VSizeclass == .regular ? 65 : tableView.frame.width / 6.3}
        return  tableView.frame.width / 2
    }
    
    func loadMoreEvents(interval: Int = 2) {
//        let currentIndex = events.count
        guard currentIndex < allRecommendedEvents.count else { return } // Prevent out-of-bounds
        
        let finalIndex = min(currentIndex + interval, allRecommendedEvents.count)
        
//        print("Loading events from index \(currentIndex) to \(finalIndex)")
        
            for index in currentIndex..<finalIndex {
                Task {
                do {
                    let document = try await allRecommendedEvents[index].getDocument()
                    if let data = document.data() {
                        let eventSummary = try await EventSummary(from: data)
                        await MainActor.run {
                            print(index)
                            self.tableView.beginUpdates()
                            self.events.append(eventSummary)
                            self.tableView.insertRows(at: [IndexPath(row: self.events.count - 1, section: 2)], with: .bottom)
                            self.tableView.endUpdates()

                        }
                    }
                } catch {
                    print("Error loading event \(allRecommendedEvents[index].documentID): \(error)")
                }
            }
        }
        currentIndex = finalIndex

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEvent" {
            let vc = (segue.destination as! UINavigationController).topViewController as! CustomerEventViewController
            navigationController?.pushViewController(vc, animated: true)
            vc.delegate = self
            vc.eventID = selectedEventID!
        }
    }
    
//    override func unwindToCustomrHome(for unwindSegue: UIStoryboardSegue, towards subsequentVC: UIViewController) {
//        
//    }
    


}

class CustomerHayCell: UITableViewCell {
    @IBOutlet weak var hayLabel: UILabel!
}

