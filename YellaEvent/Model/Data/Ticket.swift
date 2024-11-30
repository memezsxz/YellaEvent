//
//  Tickets.swift
//  YellaEvent
//
//  Created by meme on 30/11/2024.
//

import Foundation
import FirebaseFirestore

struct Ticket : Codable {
    var ticketID : String
    var eventID : String
    var userID : String
    var didAttend : Bool
    var price : Double

    init(ticketID: String, eventID: String, userID: String, didAttend: Bool, price: Double) {
        self.ticketID = ticketID
        self.eventID = eventID
        self.userID = userID
        self.didAttend = didAttend
        self.price = price
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.ticketID = try container.decode(String.self, forKey: .ticketID)
        self.eventID = try container.decode(String.self, forKey: .eventID)
        self.userID = try container.decode(String.self, forKey: .userID)
        self.didAttend = try container.decode(Bool.self, forKey: .didAttend)
        self.price = try container.decode(Double.self, forKey: .price)
    }
    
    init?(documentID: String) async throws {
        let firestore = Firestore.firestore()
        let documentRef = firestore.collection(K.FStore.Tickets.collectionName).document(documentID)
        
        let documentSnapshot = try await documentRef.getDocument()
        
        guard let documentData = documentSnapshot.data() else {
            throw NSError(domain: "Ticket", code: 404, userInfo: [NSLocalizedDescriptionKey: "Document not found or empty."])
        }
        
        let decoder = Firestore.Decoder()
        guard let ticket = try? decoder.decode(Ticket.self, from: documentData) else {
            throw NSError(domain: "Ticket", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to decode ticket data."])
        }
        
        self = ticket
        self.ticketID = documentID
    }
}
