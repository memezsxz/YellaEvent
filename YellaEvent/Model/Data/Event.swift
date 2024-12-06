//
//  Event.swift
//  YellaEvent
//
//  Created by meme on 30/11/2024.
//

import Foundation
import FirebaseFirestore

enum EventStatus : String, Codable {
    case ongoing = "ongoing"
    case cancelled = "cancelled"
    case completed  = "completed"
    case banned     = "banned"
}

protocol EventProtocol {
    var eventID : String { get }
    var organizerName : String { get }
    var name : String { get }
    var description : String { get }
    var startTimeStamp : Date { get }
}

struct Event : EventProtocol, Codable, Hashable {
    var eventID : String
    var organizerID : String
    var organizerName : String
    var name : String
    var description : String
    
    var startTimeStamp : Date
    var endTimeStamp : Date
    
    var status : EventStatus

    var categoryID  : String
    var categoryName  : String
    var categoryIcon  : String

    var locationURL  : String
    
    var minimumAge  : Int
    var maximumAge  : Int
    
    var rattingsArray : [String: Double]// two dimintional array with user id and a double
    var maximumTickets : Int
    var price : Double
    
    var coverImageURL : String
    var mediaArray : [String] // references to the paths of uploaded photos
//            static let badgeID = "badgeID"  // we might not need
    
    init (organizerID: String, organizerName: String, name: String, description: String, startTimeStamp: Date, endTimeStamp: Date, status: EventStatus, categoryID: String, categoryName: String, categoryIcon: String, locationURL: String, minimumAge: Int, maximumAge: Int, rattingsArray: [String: Double], maximumTickets: Int, price: Double, coverImageURL: String, mediaArray: [String]) {
        self.eventID = "Default"
        self.organizerID = organizerID
        self.organizerName = organizerName
        self.name = name
        self.description = description
        self.startTimeStamp = startTimeStamp
        self.endTimeStamp = endTimeStamp
        self.status = status
        self.categoryID = categoryID
        self.categoryName = categoryName
        self.categoryIcon = categoryIcon
        self.locationURL = locationURL
        self.minimumAge = minimumAge
        self.maximumAge = maximumAge
        self.rattingsArray = rattingsArray
        self.maximumTickets = maximumTickets
        self.price = price
        self.coverImageURL = coverImageURL
        self.mediaArray = mediaArray
    }
    
    init?(documentID: String) async throws {
        self = try await Self.fetch(from: K.FStore.Events.collectionName, documentID: documentID)
        self.eventID = documentID
    }
    
    static func getRatting(from ratingsArray: [String : Double]) -> Double {
        var rating : Double = 0
        for (_, value) in ratingsArray {
            rating += value
        }
        return rating / Double(ratingsArray.count)
    }
    
    static func getStats(event: Event) async -> (ticketsSold : Int, attendedTickets : Int, remainingTickets : Int, avarageRating : Double) {
       let ratting = getRatting(from: event.rattingsArray)
        
        var remainingTickets = 0
        var ticketsSold = 0
        var attendedTickets = 0

        await TicketsManager.getEventAttendance(eventId: event.eventID) { _, totalTickets, attendedTicketsTotal in
             remainingTickets = totalTickets - attendedTickets
             ticketsSold = totalTickets
            attendedTickets = attendedTicketsTotal
        }
        
        return (ticketsSold, attendedTickets, remainingTickets, ratting)
    }
}

struct EventSummary : EventProtocol, Decodable, Hashable {
    var eventID : String
    var organizerName : String
    var name : String
    var description : String
    
    var startTimeStamp : Date
    
    var categoryID  : String
    var categoryName  : String
    var categoryIcon  : String
    
    var rattingsArray : [String: Double]// two dimintional array with user id and a double
    var price : Double
    
    var coverImageURL : String
    
    init(eventID: String = "Defaults", organizerName: String, name: String, description: String, startTimeStamp: Date, categoryID: String, categoryName: String, categoryIcon: String, rattingsArray: [String: Double], price: Double, coverImageURL: String) {
        self.eventID = eventID
        self.organizerName = organizerName
        self.name = name
        self.description = description
        self.startTimeStamp = startTimeStamp
        self.categoryID = categoryID
        self.categoryName = categoryName
        self.categoryIcon = categoryIcon
        self.rattingsArray = rattingsArray
        self.price = price
        self.coverImageURL = coverImageURL
    }
    init?(documentID: String) async throws {
        self = try await Self.fetch(from: K.FStore.Events.collectionName, documentID: documentID)
        self.eventID = documentID
    }
}
