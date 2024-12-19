//
//  CustomerHomeViewController.swift
//  YellaEvent
//
//  Created by meme on 25/11/2024.
//

import UIKit
import FirebaseFirestore

class CustomerHomeViewController: UITableViewController {
    var debug = true
    var currentPage = 0
    var allRecommendedEvents: [DocumentReference] = []
    var events: [EventSummary] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userID = "bvHZAtqQ0OAVh3GmW25Y"
        tableView.register(UINib(nibName: "EventSummaryTableViewCell", bundle: .main), forCellReuseIdentifier: "EventSummaryTableViewCell")
        
        calculateCategoryScores(userID: userID) { categoryScores in
            
            if self.debug {
                print("Category Scores:")
                self.displayCatogoriesranking(categoryScores: categoryScores)
                print("")
            }
            
            self.fetchRecommendedEvents(userID: userID, categoryScores: categoryScores) { events in
                
                
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
    
    // 2
    func fetchCategories(completion: @escaping ([String: Double]) -> Void) {
        let db = Firestore.firestore()
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
    
    // 3
    func updateScoresForInterests(userID: String, categoryScores: [String: Double], completion: @escaping ([String: Double]) -> Void) {
        var updatedScores = categoryScores // Create a local copy of the scores
        let db = Firestore.firestore()
        let userRef = db.collection(K.FStore.Customers.collectionName).document(userID)
        
        userRef.getDocument { (document, error) in
            if let document = document, let userData = document.data(),
               let interests = userData[K.FStore.Customers.intrestArray] as? [String] {
                for interest in interests {
                    updatedScores[interest, default: 0] += 5
                }
            }
            completion(updatedScores)
        }
    }
    
    // 4
    func updateScoresForTickets(userID: String, categoryScores: [String: Double], completion: @escaping ([String: Double]) -> Void) {
        var updatedScores = categoryScores // Create a local copy of the scores
        let db = Firestore.firestore()
        let ticketsRef = db.collection(K.FStore.Tickets.collectionName)
        
        ticketsRef.whereField(K.FStore.Tickets.customerID, isEqualTo: userID).getDocuments { (snapshot, error) in
            if let documents = snapshot?.documents {
                let group = DispatchGroup() // To handle async fetches for events
                
                for doc in documents {
                    if let eventID = doc[K.FStore.Tickets.eventID] as? String {
                        let didAttend = doc[K.FStore.Tickets.didAttend] as? Bool ?? false
                        
                        group.enter() // Enter the dispatch group
                        // Fetch event details
                        db.collection(K.FStore.Events.collectionName).document(eventID).getDocument { (eventDoc, _) in
                            if let eventDoc = eventDoc, let eventData = eventDoc.data(),
                               let categoryID = eventData[K.FStore.Events.categoryID] as? String {
                                updatedScores[categoryID, default: 0] += 1 // Add 1 point for booking
                                
                                if didAttend {
                                    updatedScores[categoryID, default: 0] += 1 // Add another point for attendance
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
    // 5
    func updateScoresForRatings(userID: String, categoryScores: [String: Double], completion: @escaping ([String: Double]) -> Void) {
        var updatedScores = categoryScores // Create a local copy of the scores
        let db = Firestore.firestore()
        let ratingsRef = db.collection(K.FStore.Ratings.collectionName)
        
        ratingsRef.whereField(K.FStore.Ratings.customerID, isEqualTo: userID).getDocuments { (snapshot, error) in
            if let documents = snapshot?.documents {
                let group = DispatchGroup() // To handle async fetches for events
                
                if self.debug {
                    print("updateScoresForRatings: event the user have rated: ")
                }
                
                for doc in documents {
                    if let eventID = doc[K.FStore.Ratings.eventID] as? String,
                       let rating = doc[K.FStore.Ratings.rating] as? Double {
                        
                        group.enter() // Enter the dispatch group
                        
                        // Fetch event details
                        db.collection(K.FStore.Events.collectionName).document(eventID).getDocument { (eventDoc, _) in
                            if let eventDoc = eventDoc, let eventData = eventDoc.data(),
                               let categoryID = eventData[K.FStore.Events.categoryID] as? String {
                                
                                if self.debug {
                                    print(eventData[K.FStore.Events.name] as! String, rating)
                                }
                                
                                updatedScores[categoryID] = updatedScores[categoryID, default: 0] * (1 + (rating * 0.1))
                            }
                            group.leave() // Leave the dispatch group
                        }
                    }
                }
                group.notify(queue: .main) { // Wait for all fetches to complete
                    if self.debug {
                        print("")
                    }
                    
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
    
    // 7
    func fetchAttendedEvents(userID: String, completion: @escaping (Set<String>) -> Void) {
        let db = Firestore.firestore()
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
    
    // 8
    func fetchAllEvents(attendedEvents: Set<String>, completion: @escaping ([QueryDocumentSnapshot]) -> Void) {
        let db = Firestore.firestore()
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
    
    // 9
    func fetchRatingsAndCalculateScores(events: [QueryDocumentSnapshot], categoryScores: [String: Double], completion: @escaping ([DocumentReference]) -> Void) {
        let db = Firestore.firestore()
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
//                    print(categoryScore, averageRating, value, max(averageRating, 1))
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
        // Implement your tableView.reloadData() or collectionView.reloadData() here.
        // For now, just print the event names.
        events.forEach { event in
            print("Event Name: \(event.name) , \(event.categoryID)")
        }
    }
    
    func displayCatogoriesranking(categoryScores: [String: Double]) {
        categoryScores.forEach { category, score in
            print("Category: \(category) , Score: \(score)")
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(events)
    }
}


// MARK: Table view work
extension CustomerHomeViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            print(2, events.count)
            return events.count
        }
        
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if indexPath.section == 2 && (indexPath.row+1 == events.count) {
//            loadMoreEvents()
//        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellfor row at",indexPath.section, indexPath.row)
        if indexPath.section == 2 {
            print("cellfor row at section 2 ", indexPath.row , events.count)

            do {
                
                
              let  cell = try tableView.dequeueReusableCell(withIdentifier: "EventSummaryTableViewCell", for: indexPath) as? EventSummaryTableViewCell
                
                    print(events[indexPath.row])
                    cell!.setup(with: events[indexPath.row])
                    return cell!
            }
            catch {
                print(error.localizedDescription)
                return super.tableView(tableView, cellForRowAt: indexPath)
            }
        }
        
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    func loadMoreEvents(interval: Int = 5) {
        let currentIndex = events.count
        
        if currentIndex >= allRecommendedEvents.count { return } // no more events to load

        let finalIndex = min(currentIndex + interval, allRecommendedEvents.count)
        print(finalIndex, allRecommendedEvents.count)

        for index in currentIndex..<finalIndex {
            Task {
                do {
                    
                    let document = try await allRecommendedEvents[index].getDocument()
                    if let data = document.data() {
                        let eventSummary = try await EventSummary(from: data)

                        DispatchQueue.main.async {
                            self.events.append(eventSummary)
                            self.tableView.reloadData() // Reload after appending
                        }
                    }
                } catch {
                    print("Error loading event \(allRecommendedEvents[index].documentID): \(error)")
                }
            }
        }
    }

}
