//
//  K.swift
//  YellaEvent
//
//  Created by meme on 25/11/2024.
//

struct K {
    static let appName = "Yella Event"
    
    
    struct BrandColors {
        static let purple = "BrandPurple"
        static let lightPurple = "BrandLightPurple"
        static let darkPurple = "BrandDarkPurple"
        static let blue = "BrandBlue"
        static let backgroundGray = "BackgroundGray"
        
    }
    
    
    struct FStore {
        struct Users {
            static let collectionName = "users"
            static let id = "id"
            static let firstName = "firstName"
            static let lastName = "lastName"
            static let dob = "dob"
            static let phoneNumber = "phoneNumber"
            static let badgesArray = "badgesArray" // array of ids to the badges they have
            static let type = "type"
        }
        struct Events {
            static let collectionName = "events"
            static let id = "id"
            static let organizerID = "organizerID"
            static let name = "name"
            static let description = "description"
            
            static let startDate = "startDate"
            static let endDate = "endDate"
            
            static let startTime = "startTime"
            static let endTime = "endTime"
            static let status = "status"

            static let category = "category"
            
            static let locationURL = "locationURL"
            
            static let maximumTickets = "maximumTickets"
            static let price = "price"
            
            static let coverImageURL = "coverImageURL"
            static let mediaArray = "mediaArray" // references to the paths of uploaded photos
        }
        
        struct Tickets {
            static let collectionName = "tickets"
            static let id = "id"
            static let eventID = "eventID"
            static let userID = "userID"
            static let attendanceStatus = "attendanceStatus"
            static let price = "price"
        }
        
        struct Rattings {
            static let collectionName = "ratings"
            static let userID = "userID"
            static let eventID = "eventID"
            static let rating = "rating"
        }
        
        struct Badges {
            static let collectionName = "badges"
            static let id = "id"
            static let image = "image"
            static let eventID = "eventID" // maybe we want to delete the event, but we do not want the badge to be removed from users // delete or not?
            static let eventName = "eventName"
            static let catigory = "category"
        }
        
        struct Categories {
            static let collectionName = "categories"
            static let id = "id"
            static let name = "name"
            static let icon = "icon"
        }
        
        struct UserBans {
            static let collectionName = "userBans"
            static let userID = "userID"
            static let descroption = "descroption"
            static let adminID = "adminID"
            static let startDate = "startDate"
            static let endDate = "endDate"
        }
        
        struct EventBans {
            static let collectionName = "eventBans"
            static let eventID = "eventID"
            static let descroption = "descroption"
            static let adminID = "adminID"
            static let organizerID = "organizerID"
        }
    }
}
