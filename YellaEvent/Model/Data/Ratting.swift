//
//  Ratting.swift
//  YellaEvent
//
//  Created by meme on 30/11/2024.
//

import Foundation
import FirebaseFirestore

struct Ratting : Codable {
    var userID : String
    var eventID : String
    var organizerID : String
    var rating : Double

    init(userID: String, eventID: String, organizerID: String, rating: Double) {
        self.userID = userID
        self.eventID = eventID
        self.organizerID = organizerID
        self.rating = rating
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userID = try container.decode(String.self, forKey: .userID)
        self.eventID = try container.decode(String.self, forKey: .eventID)
        self.organizerID = try container.decode(String.self, forKey: .organizerID)
        self.rating = try container.decode(Double.self, forKey: .rating)
    }
    
    init?(documentID: String) async throws {
        let firestore = Firestore.firestore()
        let documentRef = firestore.collection(K.FStore.Rattings.collectionName).document(documentID)
        
        let documentSnapshot = try await documentRef.getDocument()
        
        guard let documentData = documentSnapshot.data() else {
            throw NSError(domain: "Ratting", code: 404, userInfo: [NSLocalizedDescriptionKey: "Document not found or empty."])
        }
        
        let decoder = Firestore.Decoder()
        guard let ratting = try? decoder.decode(Ratting.self, from: documentData) else {
            throw NSError(domain: "Ratting", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to decode ratting data."])
        }
        
        self = ratting
    }
}
