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
        
        for listener in instence!.listeners.values {
            listener.remove()
        }
        
        instence = nil
    }
    
    private let eventsCollection = Firestore.firestore().collection(K.FStore.Events.collectionName)
    private var listeners: [String : ListenerRegistration] = [:]
    
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
            try eventDocument(eventID: event.eventID).setData(encoder.encode(event), merge: false)
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

}
