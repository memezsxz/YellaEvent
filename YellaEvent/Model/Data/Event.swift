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

struct Event : EventProtocol, Codable {
    var eventID : String
    var organizerID : String
    var organizerName : String
    var name : String
    var description : String
    
    var startTimeStamp : Date
    var endTimeStamp : Date
    
    var status : EventStatus
    
    var category : Category
    
    var locationURL  : String
    
    var minimumAge  : Int
    var maximumAge  : Int
    
    var rattingsArray : [String: Double]// two dimintional array with user id and a double
    var maximumTickets : Int
    var price : Double
    
    var coverImageURL : String
    var mediaArray : [String] // references to the paths of uploaded photos
    //            static let badgeID = "badgeID"  // we might not need
    
    init (organizerID: String, organizerName: String, name: String, description: String, startTimeStamp: Date, endTimeStamp: Date, status: EventStatus, category: Category, locationURL: String, minimumAge: Int, maximumAge: Int, rattingsArray: [String: Double], maximumTickets: Int, price: Double, coverImageURL: String, mediaArray: [String]) {
        self.eventID = "Default"
        self.organizerID = organizerID
        self.organizerName = organizerName
        self.name = name
        self.description = description
        self.startTimeStamp = startTimeStamp
        self.endTimeStamp = endTimeStamp
        self.status = status
        self.category = category
        self.locationURL = locationURL
        self.minimumAge = minimumAge
        self.maximumAge = maximumAge
        self.rattingsArray = rattingsArray
        self.maximumTickets = maximumTickets
        self.price = price
        self.coverImageURL = coverImageURL
        self.mediaArray = mediaArray
    }
    
    
    func toFirestoreData() -> [String: Any] {
        return [
            K.FStore.Events.eventID: self.eventID,
            K.FStore.Events.organizerID: self.organizerID,
            K.FStore.Events.name: self.name,
            K.FStore.Events.description: self.description,
            K.FStore.Events.startTimeStamp: self.startTimeStamp,
            K.FStore.Events.endTimeStamp: self.endTimeStamp,
            K.FStore.Events.status: self.status.rawValue,
            K.FStore.Events.categoryID: self.category.categoryID,
            //            K.FStore.Events.badgeID: self.badgeID,
            K.FStore.Events.locationURL: self.locationURL,
            K.FStore.Events.minimumAge: self.minimumAge,
            K.FStore.Events.maximumAge: self.maximumAge,
            K.FStore.Events.rattingsArray: self.rattingsArray,
            K.FStore.Events.maximumTickets: self.maximumTickets,
            K.FStore.Events.price: self.price,
            K.FStore.Events.coverImageURL: self.coverImageURL,
            K.FStore.Events.mediaArray: self.mediaArray
        ]
    }
    
    init(from data: [String: Any]) async throws {
        self.eventID = data[K.FStore.Events.eventID] as? String ?? ""
        self.organizerID = data[K.FStore.Events.organizerID] as? String ?? ""
        self.organizerName = try await UsersManager.getOrganizer(organizerID: self.organizerID).fullName
        self.name = data[K.FStore.Events.name] as? String ?? ""
        self.description = data[K.FStore.Events.description] as? String ?? ""
        self.startTimeStamp = (data[K.FStore.Events.startTimeStamp] as? Date) ?? Date()
        self.endTimeStamp = (data[K.FStore.Events.endTimeStamp] as? Date) ?? Date()
        self.status = {
            switch data[K.FStore.Events.status] as? String ?? "" {
            case EventStatus.ongoing.rawValue:
                return .ongoing
            case EventStatus.completed.rawValue:
                return .completed
            case EventStatus.cancelled.rawValue:
                return .cancelled
            case EventStatus.banned.rawValue:
                return .banned
            default:
                return .banned
            }
        }()
        self.category = try await CategoriesManager.getCategory(categorieID: data[K.FStore.Events.categoryID] as? String ?? "")
        self.locationURL = data[K.FStore.Events.locationURL] as? String ?? ""
        self.minimumAge = data[K.FStore.Events.minimumAge] as? Int ?? 0
        self.maximumAge = data[K.FStore.Events.maximumAge] as? Int ?? 0
        self.rattingsArray = data[K.FStore.Events.rattingsArray] as? [String: Double] ?? [:]
        self.maximumTickets = data[K.FStore.Events.maximumTickets] as? Int ?? 0
        self.price = data[K.FStore.Events.price] as? Double ?? 0.0
        self.coverImageURL = data[K.FStore.Events.coverImageURL] as? String ?? ""
        self.mediaArray = data[K.FStore.Events.mediaArray] as? [String] ?? []
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
    
    init(from data: [String: Any]) async throws {
        self.eventID = data[K.FStore.Events.eventID] as? String ?? ""
        self.organizerName = try await UsersManager.getOrganizer(organizerID: data[K.FStore.Events.organizerID] as? String ?? "").fullName
        self.name = data[K.FStore.Events.name] as? String ?? ""
        self.description = data[K.FStore.Events.description] as? String ?? ""
        self.startTimeStamp = (data[K.FStore.Events.startTimeStamp] as? Date) ?? Date()
        self.categoryID = data[K.FStore.Events.categoryID] as? String ?? ""
        let catigory = try await CategoriesManager.getCategory(categorieID: categoryID)
        self.categoryIcon = catigory.icon
        self.categoryName = catigory.name
        self.rattingsArray = data[K.FStore.Events.rattingsArray] as? [String: Double] ?? [:]
        self.price = data[K.FStore.Events.price] as? Double ?? 0.0
        self.coverImageURL = data[K.FStore.Events.coverImageURL] as? String ?? ""
    }
    
}
