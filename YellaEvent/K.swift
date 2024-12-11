//
//  K.swift
//  YellaEvent
//
//  Created by meme on 25/11/2024.
//
import FirebaseFirestore

struct K {
    static let appName = "Yella Event"
    static let bundleUserID = "dev.maryam.yellaevent.userid"
    static let HSizeclass = UIScreen.main.traitCollection.horizontalSizeClass
    
    static let VSizeclass = UIScreen.main.traitCollection.verticalSizeClass

    struct BrandColors {
        static let purple = "BrandPurple"
        static let lightPurple = "BrandLightPurple"
        static let darkPurple = "BrandDarkPurple"
        static let blue = "BrandBlue"
        static let backgroundGray = "BackgroundGray"
    }
    
    static let DFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = DateFormatter.Style.none
        formatter .dateStyle = DateFormatter.Style.short
        return formatter
    }()
    
    static let TSFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = DateFormatter.Style.short
        formatter.dateStyle = DateFormatter.Style.short
        return formatter
    }()
    
    static let encoder : Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .useDefaultKeys
        return encoder
    }()
    
    static let decoder : Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        return decoder
    }()
    
    struct FStore {
        struct User {
            static let userID = "userID"
            static let fullName = "fullName"
            static let email = "email"
            static let dateCreated = "dateCreated"
            static let phoneNumber = "phoneNumber"
            static let profileImageURL = "profileImageURL"
            static let type = "type"
        }
        
        struct Admins {
            static let collectionName = "admins"
        }
        
        struct Organizers {
            static let collectionName = "organizers"
            
            static let startDate = "startDate"
            static let endDate = "endDate"
            static let LicenseDocumentURL = "LicenseDocumentURL"
        }
        
        struct Customers {
            
            static let collectionName = "customers"
            
            static let dob = "dob"
            static let badgesArray = "badgesArray" // array of ids to the badges they have
            static let intrestArray = "intrestArray" // array of ids to the badges they have
        }
        
        struct Events {
            static let collectionName = "events"
            static let eventID = "eventID"
            static let organizerID = "organizerID"
            static let name = "name"
            static let description = "description"
            
            static let startTimeStamp = "startTimeStamp"
            static let endTimeStamp = "endTimeStamp"
            
            static let status = "status"
            
            static let categoryID = "categoryID"
            
            static let locationURL = "locationURL"
            
            static let minimumAge = "minimumAge"
            static let maximumAge = "maximumAge"
            
            static let rattingsArray = "rattingsArray" // two dimintional array with user id and a double
            static let maximumTickets = "maximumTickets"
            static let price = "price"
            
            static let coverImageURL = "coverImageURL"
            static let mediaArray = "mediaArray" // references to the paths of uploaded photos
            static let isDeleted = "isDeleted" // bool
            
            //            static let badgeID = "badgeID"  // we might not need
        }
        
        struct Tickets {
            static let collectionName = "tickets"
            static let ticketID = "ticketID"
            
            static let eventID = "eventID"
            //            static let eventName = "eventName"
            static let organizerID = "organizerID"
            //            static let organizerName = "organizerName"
            //            static let startTimeStamp = "startTimeStamp"
            
            static let quantity = "quantity"
            static let customerID = "customerID"
            static let didAttend = "didAttend" // bool
            static let totalPrice = "totalPrice"
            static let status = "status"
            //            static let locationURL = "locationURL"
        }
        
        //        struct Rattings {
        //            static let collectionName = "ratings"
        //            static let userID = "userID"
        //            static let eventID = "eventID"
        //            static let organizerID = "organizerID"
        //            static let rating = "rating"
        //        }
        
        struct Badges {
            static let collectionName = "badges"
            static let badgeID = "badgeID"
            static let image = "image"
            static let eventID = "eventID" // maybe we want to delete the event, but we do not want the badge to be removed from users // delete or not?
            //            static let eventName = "eventName"
            static let categoryID = "categoryID"
        }
        
        struct Categories {
            static let collectionName = "categories"
            static let categoryID = "categoryID"
            static let name = "name"
            static let icon = "icon"
            static let status = "status"
        }
        
        struct UserBans {
            static let collectionName = "userBans"
            static let userID = "userID"
            static let adminID = "adminID"
            static let reason = "reason"
            static let descroption = "descroption"
            static let startDate = "startDate"
            static let endDate = "endDate"
        }
        
        struct EventBans {
            static let collectionName = "eventBans"
            static let eventID = "eventID"
            static let adminID = "adminID"
            static let organizerID = "organizerID"
            
            static let reason = "reason"
            static let descroption = "descroption"
        }
        
        struct FAQs {
            static let collectionName = "faqs"
            static let faqID = "faqID"
            static let question = "question"
            static let answer = "answer"
            static let userType = "userType"
        }
    }
}
