//
//  Badge.swift
//  YellaEvent
//
//  Created by meme on 28/11/2024.
//

import Foundation
import FirebaseFirestore

struct Badge : Codable {
    var badgeID : String
    var image : String
    var eventID : String // maybe we want to delete the event, but we do not want the badge to be removed from users
    var eventName : String
    var catigoryID : String
    
    init(badgeID: String, image: String, eventID: String, eventName: String, catigoryID: String) {
        self.badgeID = badgeID
        self.image = image
        self.eventID = eventID
        self.eventName = eventName
        self.catigoryID = catigoryID
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.badgeID = try container.decode(String.self, forKey: .badgeID)
        self.image = try container.decode(String.self, forKey: .image)
        self.eventID = try container.decode(String.self, forKey: .eventID)
        self.eventName = try container.decode(String.self, forKey: .eventName)
        self.catigoryID = try container.decode(String.self, forKey: .catigoryID)
    }
    
    init?(documentID: String) async throws {
        let firestore = Firestore.firestore()
        let documentRef = firestore.collection(K.FStore.Badges.collectionName).document(documentID)
        
        let documentSnapshot = try await documentRef.getDocument()
        
        guard let documentData = documentSnapshot.data() else {
            throw NSError(domain: "Badge", code: 404, userInfo: [NSLocalizedDescriptionKey: "Document not found or empty."])
        }
        
        let decoder = Firestore.Decoder()
        guard let badge = try? decoder.decode(Badge.self, from: documentData) else {
            throw NSError(domain: "Badge", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to decode badge data."])
        }
        
        self = badge
        self.badgeID = documentID
    }

}
