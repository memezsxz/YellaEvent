//
//  User.swift
//  YellaEvent
//
//  Created by meme on 29/11/2024.
//

import FirebaseFirestore
import Foundation

// MARK: UserType
enum UserType: String, Codable {
    case admin
    case customer
    case organizer
}

// MARK: Firestore Fetch
extension Decodable {
    static func fetch<T: Decodable>(from collection: String, documentID: String) async throws -> T {
        let firestore = Firestore.firestore()
        let documentRef = firestore.collection(collection).document(documentID)
        let snapshot = try await documentRef.getDocument()
        
        guard let data = snapshot.data() else {
            throw NSError(domain: "\(T.self)", code: 404, userInfo: [NSLocalizedDescriptionKey: "Document not found or empty."])
        }
        
        let decoder = Firestore.Decoder()
        guard let decoded = try? decoder.decode(T.self, from: data) else {
            throw NSError(domain: "\(T.self)", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to decode data."])
        }
        
        return decoded
    }
}

// MARK: User Protocol
protocol User: Decodable {
    var userID: String { get }
    var fullName: String { get }
    var email: String { get }
    var dob: Date { get }
    var dateCreated: Date { get }
    var phoneNumber: Int { get }
    var profileImageURL: String { get }
    var type: UserType { get }
}


// MARK: Admin
struct Admin: User , Codable {
    var userID: String
    var fullName: String
    var email: String
    var dob: Date
    var dateCreated: Date
    var phoneNumber: Int
    var profileImageURL: String
    var type: UserType = .admin
    
    init(userID: String, fullName: String, email: String, dob: Date, dateCreated: Date, phoneNumber: Int, profileImageURL: String) {
        self.userID = userID
        self.fullName = fullName
        self.email = email
        self.dob = dob
        self.dateCreated = dateCreated
        self.phoneNumber = phoneNumber
        self.profileImageURL = profileImageURL
    }
    
    init?(documentID: String) async throws {
        self = try await Self.fetch(from: K.FStore.Admins.collectionName, documentID: documentID)
        self.userID = documentID
    }
}

// MARK: Organizer
struct Organizer: User, Codable {
    var userID: String
    var fullName: String
    var email: String
    var dob: Date
    var dateCreated: Date
    var phoneNumber: Int
    var profileImageURL: String
    var type: UserType = .organizer
    
    var startDate: Date
    var endDate: Date
    var LicenseDocumentURL : String
    
    init(userID: String = "Default", fullName: String, email: String, dob: Date, dateCreated: Date, phoneNumber: Int, profileImageURL: String, startDate: Date, endDate: Date, LicenseDocumentURL: String) {
        self.userID = userID
        self.fullName = fullName
        self.email = email
        self.dob = dob
        self.dateCreated = dateCreated
        self.phoneNumber = phoneNumber
        self.profileImageURL = profileImageURL
        
        self.startDate = startDate
        self.endDate = endDate
        self.LicenseDocumentURL = LicenseDocumentURL
    }
    
    init?(documentID: String) async throws {
        self = try await Self.fetch(from: K.FStore.Organizers.collectionName, documentID: documentID)
    }
}

// MARK: Customer
struct Customer: User, Codable {
    var userID: String
    var fullName: String
    var email: String
    var dob: Date
    var dateCreated: Date
    var phoneNumber: Int
    var profileImageURL: String
    var type: UserType = .customer 
    
    var badgesArray: [String]
    var interestsArray: [String]
    
    init(userID: String, fullName: String, email: String, dob: Date, dateCreated: Date, phoneNumber: Int, profileImageURL: String, badgesArray: [String], interestsArray: [String]) {
        self.userID = userID
        self.fullName = fullName
        self.email = email
        self.dob = dob
        self.dateCreated = dateCreated
        self.phoneNumber = phoneNumber
        self.profileImageURL = profileImageURL
        
        self.badgesArray = badgesArray
        self.interestsArray = interestsArray
    }
    
    init?(documentID: String) async throws {
        self = try await Self.fetch(from: K.FStore.Customers.collectionName, documentID: documentID)
    }
}
