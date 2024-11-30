//
//  Event.swift
//  YellaEvent
//
//  Created by meme on 30/11/2024.
//

import Foundation
import FirebaseFirestore

enum EventStatus : String, Codable {
    case ongoing
    case cancelled
    case completed
    case banned
}

struct Event : Codable {
    var eventID : String
    var organizerID : String
    var name : String
    var description : String
    
    var startDate : Date
    var endDate : Date
    
    var startTime : Date
    var endTime : Date
    var status : EventStatus

    var category : String // Category ID
    
    var locationURL  : String
    
    var maximumTickets : Int
    var price : Double
    
// the first value in the meadiaArray wil be the cover image
    var mediaArray : [String] // references to the paths of uploaded photos

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.eventID = try container.decode(String.self, forKey: .eventID)
        self.organizerID = try container.decode(String.self, forKey: .organizerID)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
        self.startDate = try container.decode(Date.self, forKey: .startDate)
        self.endDate = try container.decode(Date.self, forKey: .endDate)
        self.startTime = try container.decode(Date.self, forKey: .startTime)
        self.endTime = try container.decode(Date.self, forKey: .endTime)
        self.status = try container.decode(EventStatus.self, forKey: .status)
        self.category = try container.decode(String.self, forKey: .category)
        self.locationURL = try container.decode(String.self, forKey: .locationURL)
        self.maximumTickets = try container.decode(Int.self, forKey: .maximumTickets)
        self.price = try container.decode(Double.self, forKey: .price)
        self.mediaArray = try container.decode([String].self, forKey: .mediaArray)
    }
    
    init(eventID: String, organizerID: String, name: String, description: String, startDate: Date, endDate: Date, startTime: Date, endTime: Date, status: EventStatus, category: String, locationURL: String, maximumTickets: Int, price: Double, mediaArray: [String]) {
        self.eventID = eventID
        self.organizerID = organizerID
        self.name = name
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.startTime = startTime
        self.endTime = endTime
        self.status = status
        self.category = category
        self.locationURL = locationURL
        self.maximumTickets = maximumTickets
        self.price = price
        self.mediaArray = mediaArray
    }
    
    init?(documentID: String) async throws {
        let firestore = Firestore.firestore()
        let documentRef = firestore.collection(K.FStore.Events.collectionName).document(documentID)
        
        let documentSnapshot = try await documentRef.getDocument()
        
        guard let documentData = documentSnapshot.data() else {
            throw NSError(domain: "Event", code: 404, userInfo: [NSLocalizedDescriptionKey: "Document not found or empty."])
        }
        
        let decoder = Firestore.Decoder()
        guard let event = try? decoder.decode(Event.self, from: documentData) else {
            throw NSError(domain: "Event", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to decode event data."])
        }
        
        self = event
        self.eventID = documentID
    }

}
