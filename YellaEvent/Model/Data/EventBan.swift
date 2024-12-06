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
        
    init?(documentID: String) async throws {
        self = try await Self.fetch(from: K.FStore.EventBans.collectionName, documentID: documentID)
    }
}
