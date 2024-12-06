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
    
    init?(documentID: String) async throws {
        self = try await Self.fetch(from: K.FStore.Tickets.collectionName, documentID: documentID)
        self.ticketID = documentID
    }
}
