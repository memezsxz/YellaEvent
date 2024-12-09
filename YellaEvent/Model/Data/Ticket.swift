//
//  Tickets.swift
//  YellaEvent
//
//  Created by meme on 30/11/2024.
//

import Foundation

/// Represents the status of a ticket in the system.
///
/// This enum is used to track the current state of a ticket, such as whether it has been paid,
/// cancelled, refunded, or affected by an event deletion.
enum TicketStatus: String, Codable {
    /// The ticket has been paid for.
    case paied = "paied"
    
    /// The event associated with the ticket was deleted or banned.
    case cancelled = "cancelled"
    
    /// The ticket has been refunded. after you alert the user for the deleted/baned event, change the status to refunded
    case refunded = "refunded"
}

struct Ticket : Codable {
    var ticketID : String
    var eventID : String
    var customerID : String
    var organizerID : String
    var eventName : String
    var organizerName : String
    var startTimeStamp : Date
    var didAttend : Bool
    var totalPrice : Double
    var locationURL : String
    var quantity : Int
    var status : TicketStatus
    
    init(ticketID: String, eventID: String, customerID: String, organizerID: String, eventName: String, organizerName: String, startTimeStamp: Date, didAttend: Bool, totalPrice: Double, locationURL: String, quantity: Int, status: TicketStatus) {
        self.ticketID = ticketID
        self.eventID = eventID
        self.customerID = customerID
        self.organizerID = organizerID
        self.eventName = eventName
        self.organizerName = organizerName
        self.startTimeStamp = startTimeStamp
        self.didAttend = didAttend
        self.totalPrice = totalPrice
        self.locationURL = locationURL
        self.quantity = quantity
        self.status = status
    }
    
    func toFirestoreData() -> [String: Any] {
        return [
            K.FStore.Tickets.ticketID: self.ticketID,
            K.FStore.Tickets.eventID: self.eventID,
            K.FStore.Tickets.customerID: self.customerID,
            K.FStore.Tickets.organizerID: self.organizerID,
            //            K.FStore.Tickets.eventName: self.eventName,
            //            K.FStore.Tickets.organizerName: self.organizerName,
            //            K.FStore.Tickets.startTimeStamp: self.startTimeStamp,
            K.FStore.Tickets.didAttend: self.didAttend,
            K.FStore.Tickets.totalPrice: self.totalPrice,
            //            K.FStore.Tickets.locationURL: self.locationURL,
            K.FStore.Tickets.quantity: self.quantity,
            K.FStore.Tickets.status: self.status.rawValue
        ]
    }
    
    
    init(from data: [String: Any]) async throws {
        self.ticketID = data[K.FStore.Tickets.ticketID] as? String ?? ""
        self.eventID = data[K.FStore.Tickets.eventID] as? String ?? ""
        self.customerID = data[K.FStore.Tickets.customerID] as? String ?? ""
        
        do {
            let event = try await EventsManager.getEvent(eventID: self.eventID)
            self.eventName = event.name
            self.organizerID = event.organizerID
            self.organizerName = event.organizerName
            self.locationURL = event.locationURL
            self.startTimeStamp = event.startTimeStamp
        }
        catch {
            //           self.eventName = data[K.FStore.Tickets.eventName] as? String ?? ""
            //           self.organizerName = data[K.FStore.Tickets.organizerName] as? String ?? ""
            //           self.locationURL = data[K.FStore.Tickets.locationURL] as? String ?? ""
            //           self.startTimeStamp = (data[K.FStore.Tickets.startTimeStamp] as? Date) ?? Date()
            self.eventName = ""
            self.organizerID = ""
            self.organizerName = ""
            self.locationURL = ""
            self.startTimeStamp = Date()
        }
        
        self.didAttend = (data[K.FStore.Tickets.didAttend] as? Bool) ?? false
        self.totalPrice = data[K.FStore.Tickets.totalPrice] as? Double ?? 0.0
        self.quantity = data[K.FStore.Tickets.quantity] as? Int ?? 0
        
        switch data[K.FStore.Tickets.status] as! String {
        case TicketStatus.paied.rawValue:
            self.status =  .paied
        case TicketStatus.cancelled.rawValue:
            self.status =  .cancelled
        case TicketStatus.refunded.rawValue:
            self.status =  .paied
        default:
            self.status =  .paied
        }
    }
    
    init?(documentID: String) async throws {
        self = try await Self.fetch(from: K.FStore.Tickets.collectionName, documentID: documentID)
        self.ticketID = documentID
    }
}
