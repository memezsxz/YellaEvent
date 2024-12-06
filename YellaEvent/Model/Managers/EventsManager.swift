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
    
    static func createNewEvent(event: Event) async throws {
        Task {
            let doc = try eventsCollection.addDocument(data: K.encoder.encode(event))
            doc.updateData([K.FStore.Events.eventID: doc.documentID])
        }
    }
    
    static func getEvent(eventID: String) async throws -> Event {
        try await eventDocument(eventID: eventID).getDocument(as : Event.self)
    }
    
    static func updateEvent(event: Event) async throws {
        let oldEvent =  try await eventDocument(eventID: event.eventID).getDocument().data(as: Event.self)
//            .setData(try K.encoder.encode(event), merge: true)
        
        if oldEvent.categoryID != event.categoryID {
            var badge = try await BadgesManager.getBadge(eventID: event.eventID)
             
             badge.eventName = event.name
             badge.categoryIcon = event.categoryIcon
             badge.categoryName = event.categoryName

            try await BadgesManager.updateBadge(badge: badge)

            
            try await TicketsManager.updateEventStartTimeStamp(eventID: event.eventID, startTimeStamp: event.startTimeStamp)
        }
        
        try await eventDocument(eventID: event.eventID).setData(try K.encoder.encode(event), merge: true)
    }

    static func getOrganizerEvents(organizerID: String, listener: @escaping (QuerySnapshot?, Error?) -> Void) {
        self.listener?.remove()
        self.listener = eventsCollection
            .whereField(K.FStore.Events.organizerID, isEqualTo: organizerID)
            .order(by: K.FStore.Events.startTimeStamp)
            .addSnapshotListener(listener)
    }
    
    private static func getOrganizerEvents(organizerID: String) async throws -> QuerySnapshot {
        try await eventsCollection
            .whereField(K.FStore.Events.organizerID, isEqualTo: organizerID)
            .getDocuments()
    }
    
    static func updateEventOrganizer(organizer: Organizer) async throws {
        let snapshot = try await getOrganizerEvents(organizerID: organizer.userID)
        
        for document in snapshot.documents {
            try await document.reference.updateData([
                K.FStore.Events.organizerName: organizer.fullName
            ])
        }
    }

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
            .addSnapshotListener(listener)
    }
    
    static func deleteEvent(eventID: String) async throws {
        try await eventDocument(eventID: eventID).delete()
    }
    
    static func banEvent(event: Event, reason: String,  description : String) async throws {
        try Firestore.firestore().collection(K.FStore.EventBans.collectionName).addDocument(from: EventBan(eventID: event.eventID, descroption: description, adminID: UserDefaults.standard.string(forKey: K.bundleUserID)!, organizerID: event.organizerID))
    }
    
    static func unbanEvent(eventID: String) async throws {
        let eventBansCollection = Firestore.firestore().collection(K.FStore.EventBans.collectionName)
        
        let snapshot = try await eventBansCollection.whereField(K.FStore.EventBans.eventID, isEqualTo: eventID).getDocuments()
        for doc in snapshot.documents {
            try await doc.reference.delete()
        }
    }
    
    static func isEventBanned(userID: String) async throws -> EventBan? {
        let eventBansCollection = Firestore.firestore().collection(K.FStore.EventBans.collectionName)
        
        let snapshot = try await eventBansCollection.whereField(K.FStore.EventBans.eventID, isEqualTo: userID).getDocuments()
        
        if snapshot.documents.isEmpty {
            return nil
        } else {
            return try snapshot.documents[0].data(as: EventBan.self)
        }
    }

    static func getEventBans() async throws -> [EventBan] {
        try await Firestore.firestore().collection(K.FStore.EventBans.collectionName).getDocuments().documents.compactMap { doc in
            try doc.data(as: EventBan.self)
        }
    }

    
    static func searchEvents(byOrganizerName name: String) async throws -> [EventSummary] {
        try await eventsCollection
            .whereField(K.FStore.Events.organizerName, isEqualTo: name)
            .order(by: K.FStore.Events.name)
            .getDocuments().documents.compactMap { try $0.data(as: EventSummary.self) }
        //            .sorted {
        //                Event.getRatting(from: $0.rattingsArray) > Event.getRatting(from: $1.rattingsArray)
        //            }
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
       return try await eventsCollection
            .whereField(K.FStore.Events.status, isEqualTo: EventStatus.ongoing.rawValue)
            .getDocuments().documents.compactMap { try $0.data(as: EventSummary.self) }
            .filter { event in
                return event.name.lowercased().contains(name) || event.organizerName.lowercased().contains(name)
            }
    }
    
    static func searchEvents(byText name: String, price: Int, age: Int, categories: [String]) async throws -> [EventSummary] {
        let name = name.lowercased()
       return try await eventsCollection
            .whereField(K.FStore.Events.status, isEqualTo: EventStatus.ongoing.rawValue)
            .whereField(K.FStore.Events.price, isGreaterThanOrEqualTo: price)
            .whereField(K.FStore.Events.minimumAge, isGreaterThanOrEqualTo: age)
            .whereField(K.FStore.Events.categoryID, in: categories)
            .getDocuments().documents.compactMap { try $0.data(as: EventSummary.self) }
            
            .filter { event in
                return event.name.lowercased().contains(name) || event.organizerName.lowercased().contains(name)
            }
    }

    
    // only for category updates
    static func getEvents(byCategory categoryID: String) async throws -> [Event] {
        return try await eventsCollection
            .whereField(K.FStore.Events.categoryID, isEqualTo: categoryID)
            .getDocuments().documents.compactMap { doc in
                try doc.data(as: Event.self)
            }
    }
    
    // only used when a catagory is updated
    static func updateEventsCategory(category: Category) async throws {
        let events = try await eventsCollection
            .whereField(K.FStore.Events.categoryID, isEqualTo: category.categoryID)
            .getDocuments()
        
        for document in events.documents {
            var event = try document.data(as: Event.self)
            event.categoryIcon = category.icon
            event.categoryName = category.name
            try await updateEvent(event: event)
            var badge = try await BadgesManager.getBadge(eventID: event.eventID)
            badge.categoryIcon = category.icon
            badge.categoryName = category.name
            try await BadgesManager.updateBadge(badge: badge)
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
}
