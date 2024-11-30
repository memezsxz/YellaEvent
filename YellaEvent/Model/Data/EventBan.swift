//
//  EventBan.swift
//  YellaEvent
//
//  Created by meme on 30/11/2024.
//

import FirebaseFirestore

struct EventBan : Codable {
    var eventID : String
    var descroption : String
    var adminID : String
    var organizerID : String

    init(eventID: String, descroption: String, adminID: String, organizerID: String) {
        self.eventID = eventID
        self.descroption = descroption
        self.adminID = adminID
        self.organizerID = organizerID
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.eventID = try container.decode(String.self, forKey: .eventID)
        self.descroption = try container.decode(String.self, forKey: .descroption)
        self.adminID = try container.decode(String.self, forKey: .adminID)
        self.organizerID = try container.decode(String.self, forKey: .organizerID)
    }
    
    init?(documentID: String) async throws {
        let firestore = Firestore.firestore()
        let documentRef = firestore.collection(K.FStore.EventBans.collectionName).document(documentID)
        
        let documentSnapshot = try await documentRef.getDocument()
        
        guard let documentData = documentSnapshot.data() else {
            throw NSError(domain: "EventBan", code: 404, userInfo: [NSLocalizedDescriptionKey: "Document not found or empty."])
        }
        
        let decoder = Firestore.Decoder()
        guard let eventBan = try? decoder.decode(EventBan.self, from: documentData) else {
            throw NSError(domain: "EventBan", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to decode event ban data."])
        }
        
        self = eventBan
    }
}
