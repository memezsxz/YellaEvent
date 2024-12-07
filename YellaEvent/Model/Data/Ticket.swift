//
//  Tickets.swift
//  YellaEvent
//
//  Created by meme on 30/11/2024.
//

import Foundation

struct Ticket : Codable {
    var ticketID : String
    var eventID : String
    var userID : String
    var eventName : String
    var organizerName : String
    var startTimeStamp : Date
    var didAttend : Bool
    var totalPrice : Double
    var locationURL : String
    var quantity : Int

    init (ticketID: String = "Default", eventID: String, userID: String, eventName: String, organizerName: String, startTimeStamp: Date, didAttend: Bool, totalPrice: Double, locationURL: String, quantity: Int) {
        self.ticketID = ticketID
        self.eventID = eventID
        self.userID = userID
        self.eventName = eventName
        self.organizerName = organizerName
        self.startTimeStamp = startTimeStamp
        self.didAttend = didAttend
        self.totalPrice = totalPrice
        self.locationURL = locationURL
        self.quantity = quantity
    }
    
    func toFirestoreData() -> [String: Any] {
        return [
            K.FStore.Tickets.ticketID: self.ticketID,
            K.FStore.Tickets.eventID: self.eventID,
            K.FStore.Tickets.userID: self.userID,
            K.FStore.Tickets.eventName: self.eventName,
            K.FStore.Tickets.organizerName: self.organizerName,
            K.FStore.Tickets.startTimeStamp: self.startTimeStamp,
            K.FStore.Tickets.didAttend: self.didAttend,
            K.FStore.Tickets.totalPrice: self.totalPrice,
            K.FStore.Tickets.locationURL: self.locationURL,
            K.FStore.Tickets.quantity: self.quantity,
        ]
    }

    
    init(from data: [String: Any]) async throws {
        self.ticketID = data[K.FStore.Tickets.ticketID] as? String ?? ""
        self.eventID = data[K.FStore.Tickets.eventID] as? String ?? ""
        self.userID = data[K.FStore.Tickets.userID] as? String ?? ""
        
        do {
            let event = try await EventsManager.getEvent(eventID: self.eventID)
            self.eventName = event.name
            self.organizerName = event.organizerName
            self.locationURL = event.locationURL
            self.startTimeStamp = event.startTimeStamp
        }
       catch {
           self.eventName = data[K.FStore.Tickets.eventName] as? String ?? ""
           self.organizerName = data[K.FStore.Tickets.organizerName] as? String ?? ""
           self.locationURL = data[K.FStore.Tickets.locationURL] as? String ?? ""
           self.startTimeStamp = (data[K.FStore.Tickets.startTimeStamp] as? Date) ?? Date()
       }
            
        self.didAttend = (data[K.FStore.Tickets.didAttend] as? Bool) ?? false
        self.totalPrice = data[K.FStore.Tickets.totalPrice] as? Double ?? 0.0
        self.quantity = data[K.FStore.Tickets.quantity] as? Int ?? 0
    }
    
    init?(documentID: String) async throws {
        self = try await Self.fetch(from: K.FStore.Tickets.collectionName, documentID: documentID)
        self.ticketID = documentID
    }
}
