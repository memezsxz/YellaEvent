//
//  User.swift
//  YellaEvent
//
//  Created by meme on 29/11/2024.
//

import FirebaseFirestore
import Foundation

enum UserType: String, Codable {
    case admin = "admin"
    case customer = "customer"
    case organizer = "organizer"
}


//static let dateFormatter : DateFormatter = {
//    let formatter = DateFormatter()
//    formatter.dateFormat = "yyyy-MM-dd"
//    return formatter
//}()



struct User : Codable {
    var userID : String
    var firstName : String
    var lastName : String
    var email : String
    var dob : Date
    var dateCreated : Date
    var phoneNumber : Int
    var profileImageURL : String
    var badgesArray : [String] // array of ids to the badges they have
    var type : UserType
    
    init(id: String, firstName: String, lastName: String, email: String, dob: Date, dateCreated : Date, phoneNumber: Int, badgesArray: [String], profileImageURL: String,  type: UserType) {
        self.userID = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.dob = dob
        self.dateCreated = dateCreated
        self.phoneNumber = phoneNumber
        self.profileImageURL = profileImageURL
        self.badgesArray = badgesArray
        self.type = type
    }
    
    init(from decoder: any Decoder) throws{
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userID = try container.decode(String.self, forKey: .userID)
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String.self, forKey: .lastName)
        self.email = try container.decode(String.self, forKey: .email)
        self.dob = try container.decode(Date.self, forKey: .dob)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        self.phoneNumber = try container.decode(Int.self, forKey: .phoneNumber)
        self.badgesArray = try container.decode([String].self, forKey: .badgesArray)
        self.profileImageURL = try container.decode(String.self, forKey: .profileImageURL)
        self.type = try container.decode(UserType.self, forKey: .type)
    }
    
    init?(documentID: String) async throws {
        let firestore = Firestore.firestore()
        let documentRef = firestore.collection(K.FStore.Users.collectionName).document(documentID)
        
        let documentSnapshot = try await documentRef.getDocument()
        
        guard let documentData = documentSnapshot.data() else {
            throw NSError(domain: "User", code: 404, userInfo: [NSLocalizedDescriptionKey: "Document not found or empty."])
        }
        
        let decoder = Firestore.Decoder()
        guard let user = try? decoder.decode(User.self, from: documentData) else {
            throw NSError(domain: "User", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to decode user data."])
        }
        
        self = user
        self.userID = documentID
    }

}


