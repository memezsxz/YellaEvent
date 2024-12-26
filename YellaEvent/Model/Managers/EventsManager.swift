//
//  EventsManager.swift
//  YellaEvent
//
//  Created by meme on 03/12/2024.
//

import Foundation
import FirebaseFirestore

class EventsManager {
    private init() {}
    
    private static let eventsCollection = Firestore.firestore().collection(K.FStore.Events.collectionName)
    private static let badgesCollection = Firestore.firestore().collection(K.FStore.Badges.collectionName)
    private static var listener: ListenerRegistration?
    
    private static func eventDocument(eventID: String) -> DocumentReference {
        eventsCollection.document(eventID)
    }
    
    static func createNewEvent(event: Event) async throws -> String {
            let doc = try await eventsCollection.addDocument(data: event.toFirestoreData())
            try await doc.updateData([K.FStore.Events.eventID: doc.documentID])
//            var badge = try await BadgesManager.getBadge(eventID: event.eventID)
//            badge.eventID = doc.documentID
//            try await BadgesManager.updateBadge(badge: badge)
        return doc.documentID
    }
    
    static func getEvent(eventID: String) async throws -> Event {
        try await Event (from: eventDocument(eventID: eventID).getDocument().data()!)
    }
    
    static func updateEvent(event: Event) async throws {
        //        let oldEvent =  try await Event(from: try eventDocument(eventID: event.eventID).getDocument().data()!)
        //            .setData(try K.encoder.encode(event), merge: true)
        //        if oldEvent.category.categoryID != event.category.categoryID {
        //            var badge = try await BadgesManager.getBadge(eventID: event.eventID)
        //
        //             badge.eventName = event.name
        //            badge.category = event.category
        //
        //            try await BadgesManager.updateBadge(badge: badge)
        //        }
        //        if oldEvent.startTimeStamp != event.startTimeStamp {
        //            try await TicketsManager.updateEventStartTimeStamp(eventID: event.eventID, startTimeStamp: event.startTimeStamp)
        //        }
        
        try await eventDocument(eventID: event.eventID).updateData((event.toFirestoreData()))
    }
    
    static func getOrganizerEvents(organizerID: String, listener: @escaping (QuerySnapshot?, Error?) -> Void) {
        self.listener?.remove()
        self.listener = eventsCollection
            .whereField(K.FStore.Events.organizerID, isEqualTo: organizerID)
            .whereField(K.FStore.Events.isDeleted, isEqualTo: false)
            .order(by: K.FStore.Events.startTimeStamp)
            .addSnapshotListener(listener)
    }
    
    private static func getOrganizerEvents(organizerID: String) async throws -> QuerySnapshot {
        try await eventsCollection
            .whereField(K.FStore.Events.organizerID, isEqualTo: organizerID)
            .whereField(K.FStore.Events.isDeleted, isEqualTo: false)
            .getDocuments()
    }
    
    static func getOrganizerOngoingEvents(organizerID: String, listener: @escaping (QuerySnapshot?, Error?) -> Void) {
             eventsCollection
            .whereField(K.FStore.Events.organizerID, isEqualTo: organizerID)
            .whereField(K.FStore.Events.isDeleted, isEqualTo: false)
            .whereField(K.FStore.Events.status, isEqualTo: EventStatus.ongoing.rawValue)
            .order(by: K.FStore.Events.startTimeStamp)
            .addSnapshotListener(listener)
    }

    
    //    static func updateEventOrganizer(organizer: Organizer) async throws {
    //        let snapshot = try await getOrganizerEvents(organizerID: organizer.userID)
    //
    //        for document in snapshot.documents {
    //            try await document.reference.updateData([
    //                K.FStore.Events.organizerID: organizer.fullName
    //            ])
    //        }
    //    }
    
    static func OrganizerBanedHandler(organizerID: String) async throws {
        let snapshot = try await getOrganizerEvents(organizerID: organizerID)
        
        for document in snapshot.documents {
            try await document.reference.updateData([
                K.FStore.Events.status: EventStatus.cancelled.rawValue
            ])
        }
        
    }
    static func getOrganizer(organizerID: String) async throws -> Organizer {
        try await UsersManager.getOrganizer(organizerID: organizerID)
    }
    
    static func getAllEvents (listener: @escaping (QuerySnapshot?, Error?) -> Void) {
        self.listener?.remove()
        self.listener = eventsCollection
            .order(by: K.FStore.Events.startTimeStamp)
            .whereField(K.FStore.Events.isDeleted, isEqualTo: false)
            .addSnapshotListener(listener)
    }
    
    static func deleteEvent(eventID: String) async throws {
        try await eventDocument(eventID: eventID).setData([K.FStore.Events.isDeleted: true], merge: false)
    }
    
    static func banEvent(event: Event, reason: String,  description : String) async throws {
        try Firestore.firestore().collection(K.FStore.EventBans.collectionName).addDocument(from: EventBan(eventID: event.eventID, descroption: description, adminID: UserDefaults.standard.string(forKey: K.bundleUserID)!, organizerID: event.organizerID))
        
        try await eventDocument(eventID: event.eventID).updateData([K.FStore.Events.status: EventStatus.banned])
    }
    
    static func unbanEvent(eventID: String) async throws {
        let eventBansCollection = Firestore.firestore().collection(K.FStore.EventBans.collectionName)
        
        try await eventBansCollection.document(eventID).delete()
        //        for doc in snapshot.documents {
        //            try await doc.reference.delete()
        //        }
        
        try await eventDocument(eventID: eventID).updateData([K.FStore.Events.status : EventStatus.ongoing])
    }
    
    static func isEventBanned(eventID: String) async throws -> EventBan? {
        let eventBansCollection = Firestore.firestore().collection(K.FStore.EventBans.collectionName)
        
        let doc = eventBansCollection.document(eventID)
        
        do {
            return try await doc.getDocument().data(as: EventBan.self)
        }
        catch {
            return nil
        }
    }
    
    static func getEventBans() async throws -> [EventBan] {
        try await Firestore.firestore().collection(K.FStore.EventBans.collectionName).getDocuments().documents.compactMap { doc in
            try doc.data(as: EventBan.self)
        }
    }
    
    
    // replacement for search by name when admin clicks on view orginizer events
    static func searchEvents(byOrganizerID id: String) async throws -> [EventSummary] {
        let snapshot = try await eventsCollection
            .whereField(K.FStore.Events.organizerID, isEqualTo: id)
            .whereField(K.FStore.Events.isDeleted, isEqualTo: false)
            .order(by: K.FStore.Events.name)
            .getDocuments()
        
        var events: [EventSummary] = []
        for document in snapshot.documents {
            let event = try await EventSummary(from: document.data())
            events.append(event)
        }
        return events
    }
    
    //    static func searchEvents(byEventName name: String) async throws -> [EventSummary] {
    //        let events = try await eventsCollection
    //            .order(by: K.FStore.Events.name)
    //            .getDocuments()
    //            .documents
    //            .compactMap { try $0.data(as: EventSummary.self) }
    //
    //        return events.filter { event in
    //            event.name.lowercased()
    //                .split(separator: " ")
    //                .contains { $0.hasPrefix(name.lowercased()) }
    //        }
    //    }
    
    static func searchEvents(byText name: String) async throws -> [EventSummary] {
        let name = name.lowercased()
        let snapshot = try await eventsCollection
            .whereField(K.FStore.Events.isDeleted, isEqualTo: false)
            .whereField(K.FStore.Events.status, isEqualTo: EventStatus.ongoing.rawValue)
            .getDocuments()
        
        var results: [EventSummary] = []
        for document in snapshot.documents {
            let eventSummary = try await EventSummary(from: document.data())
            if eventSummary.name.lowercased().contains(name) || eventSummary.organizerName.lowercased().contains(name) {
                results.append(eventSummary)
            }
        }
        return results
    }
    
    static func searchEvents(byText name: String, price: Int, age: Int, categories: [String]) async throws -> [EventSummary] {
        let name = name.lowercased()
        
        let snapshot = try await eventsCollection
            .whereField(K.FStore.Events.status, isEqualTo: EventStatus.ongoing.rawValue)
            .whereField(K.FStore.Events.price, isGreaterThanOrEqualTo: price)
            .whereField(K.FStore.Events.minimumAge, isGreaterThanOrEqualTo: age)
            .whereField(K.FStore.Events.categoryID, in: categories)
            .getDocuments()
        
        var results: [EventSummary] = []
        
        for document in snapshot.documents {
            do {
                let eventSummary = try await EventSummary(from: document.data())
                if eventSummary.name.lowercased().contains(name) || eventSummary.organizerName.lowercased().contains(name) {
                    results.append(eventSummary)
                }
            } catch {
                print("Failed to decode document \(document.documentID): \(error.localizedDescription)")
                throw error
            }
        }
        
        return results
    }
    
    
    // only for category updates
    static func getEvents(byCategory categoryID: String) async throws -> [Event] {
        let snapshot = try await eventsCollection
            .whereField(K.FStore.Events.categoryID, isEqualTo: categoryID)
            .getDocuments()
        
        var events: [Event] = []
        for document in snapshot.documents {
            let event = try await Event(from: document.data())
            events.append(event)
        }
        return events
    }
    
    // only used when a catagory is updated
    static func updateEventsCategory(category: Category) async throws {
        let events = try await eventsCollection
            .whereField(K.FStore.Events.categoryID, isEqualTo: category.categoryID)
            .getDocuments()
        
        for document in events.documents {
            let eventID = document.data()[K.FStore.Events.eventID] as! String
            var badge = try await BadgesManager.getBadge(eventID: eventID)
            badge.category = category
            try await BadgesManager.updateBadge(badge: badge)
        }
        
    }
    
    static func getNumEvents(withCategoryID categoryID: String) async throws -> Int {
        try await eventsCollection.whereField(K.FStore.Events.categoryID, isEqualTo: categoryID).getDocuments().documents.count
    }
    
    static func getDashboardStats(
        organizerID: String,
        completion: @escaping (Int, Int, Int, Int, Int, Double, Double, Int) -> Void
    ) async throws {
        // Initialize variables
        var numOngoingEvents = 0
        var numCancelledEvents = 0
        var numCompletedEvents = 0
        var totalAttendance = 0
        var totalRevenue = 0.0
        var soldTickets = 0
        var totalRating = 0.0
        var numAllEvents = 0
        var averageRating = 0.0
        
        // DispatchGroup to wait for asynchronous tasks
        let dispatchGroup = DispatchGroup()
        
        // Fetch events asynchronously
        Task {
            let events = try await EventsManager.getOrganizerEvents(organizerID: organizerID)
            
            for eventDocument in events.documents {
                let event = try await Event(from: eventDocument.data())
                
                // Update event stats
                switch event.status {
                case .ongoing: numOngoingEvents += 1
                case .cancelled: numCancelledEvents += 1
                case .completed: numCompletedEvents += 1
                default: break
                }
                
                // Fetch tickets for each event
                let tickets = try await TicketsManager.getEventTickets(eventID: event.eventID)
                for ticket in tickets {
                    if (event.status == .ongoing || event.status == .completed) && ticket.didAttend {
                        soldTickets += ticket.quantity
                    }
                    if ticket.didAttend {
                        totalAttendance += ticket.quantity
                        totalRevenue += ticket.totalPrice
                    }
                }
            }
            
            // Add task to DispatchGroup for getting organizer rating
            dispatchGroup.enter()
            RatingManager.getOrganizerRating(organizerID: organizerID) { result in
                switch result {
                case .success(let rating):
                    totalRating = rating
                case .failure(let error):
                    print("Error fetching rating: \(error.localizedDescription)")
                    totalRating = 0.0
                }
                dispatchGroup.leave()
            }
            
            // Wait for all tasks in DispatchGroup to finish
            dispatchGroup.notify(queue: .main) {
                numAllEvents = numOngoingEvents + numCancelledEvents + numCompletedEvents
                averageRating = events.documents.isEmpty ? 0.0 : totalRating 
                
                // Call the completion handler with updated stats
                completion(
                    numCancelledEvents,
                    numCompletedEvents,
                    numOngoingEvents,
                    numAllEvents,
                    totalAttendance,
                    totalRevenue,
                    averageRating,
                    soldTickets
                )
            }
        }
    }

    
    
    // re do
    //    func getEventRating(eventID: String) async throws -> Double {
    //        var count = 0.0
    //        var sum = 0.0
    //        try await Firestore.firestore().collection(K.FStore.Rattings.collectionName).whereField(K.FStore.EventBans.eventID, isEqualTo: eventID).getDocuments().documents.forEach { doc in
    //            sum +=  try doc.data(as: Ratting.self).rating
    //            count += 1
    //        }
    //        return sum / count
    //    }
    
    static func getEventsSum() async throws  -> Int {
        try await eventsCollection.whereField(K.FStore.Events.isDeleted, isEqualTo: false).getDocuments().documents.count
    }
    
    //    static func getEventsSum() async throws -> Int {
    //        let aggregateQuery = eventsCollection.aggregate([AggregateField.count()])
    //
    //        do {
    //            let snapshot = try await aggregateQuery.getAggregation(source: .server)
    //
    //            return snapshot.get(AggregateField.count()) as? Int ?? 0
    //        } catch {
    //            // Handle errors appropriately
    //            throw error
    //        }
    //    }
}
