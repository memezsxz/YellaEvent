//
//  EventsManager.swift
//  YellaEvent
//
//  Created by meme on 03/12/2024.
//

import Foundation
import FirebaseFirestore

class EventsManager {
    private static var instence : EventsManager?
    private init() {}
    
    
    static func getInstence () -> EventsManager {
        if instence == nil {
            instence = EventsManager()
        }
        return instence!
    }
    
    // always kill when view is disapeard
    static func killInstence() {
        guard instence != nil else { return }
        instence?.listener?.remove()
        instence = nil
    }
    
    private let eventsCollection = Firestore.firestore().collection(K.FStore.Events.collectionName)
    private var listener: ListenerRegistration?
    
    private let encoder : Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .useDefaultKeys
        return encoder
    }()
    
    private let decoder : Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        return decoder
    }()
    
    
    private func eventDocument(eventID: String) -> DocumentReference {
        eventsCollection.document(eventID)
    }
    
    func createNewEvent(event: Event) async throws {
        Task {
            let doc = try eventsCollection.addDocument(data: encoder.encode(event))
            doc.updateData([K.FStore.Events.eventID: doc.documentID])
        }
    }
    
    func getEvent(eventID: String) async throws -> Event {
        try await eventDocument(eventID: eventID).getDocument(as : Event.self)
    }
    
    func updateEvent(eventID: String, fields: [String: Any]) async throws {
        try await eventDocument(eventID: eventID).updateData(fields)
    }
    
    func updateEvent(eventID: String, event: Event) async throws {
        try await eventDocument(eventID: eventID).updateData(encoder.encode(event))
    }
    
    func getOrganizerEvents(organizerID: String, listener: @escaping (QuerySnapshot?, Error?) -> Void) {
        self.listener?.remove()
        self.listener = eventsCollection
            .whereField(K.FStore.Events.organizerID, isEqualTo: organizerID)
            .order(by: K.FStore.Events.startDate)
            .addSnapshotListener(listener)
    }
    
    func getOrganizer(organizerID: String) async throws -> User {
       try await UsersManager.getInstence().getUser(userId: organizerID)
    }
    
    func getAllEvents (listener: @escaping (QuerySnapshot?, Error?) -> Void) {
        self.listener?.remove()
        self.listener = eventsCollection
            .order(by: K.FStore.Events.startDate)
            .addSnapshotListener(listener)
    }
    
    func deleteEvent(eventID: String) async throws {
        try await eventDocument(eventID: eventID).delete()
    }
    
    func banEvent(event: Event, description : String) async throws {
        try Firestore.firestore().collection(K.FStore.EventBans.collectionName).addDocument(from: EventBan(eventID: event.eventID, descroption: description, adminID: UserDefaults.standard.string(forKey: K.bundleUserID)!, organizerID: event.organizerID))
    }
    
    func getEventRating(eventID: String) async throws -> Double {
        var count = 0.0
        var sum = 0.0
        try await Firestore.firestore().collection(K.FStore.Rattings.collectionName).whereField(K.FStore.EventBans.eventID, isEqualTo: eventID).getDocuments().documents.forEach { doc in
            sum +=  try doc.data(as: Ratting.self).rating
            count += 1
        }
        return sum / count
    }
}
