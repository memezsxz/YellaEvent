//
//  UserBan.swift
//  YellaEvent
//
//  Created by meme on 30/11/2024.
//

import FirebaseFirestore

struct UserBan : Codable {
    var userID : String
    var reason : String
    var descroption : String
    var adminID : String
    var startDate : Date
    var endDate : Date
    
    init(userID: String, reason: String, descroption: String, adminID: String, startDate: Date, endDate: Date) {
        self.userID = userID
        self.reason = reason
        self.descroption = descroption
        self.adminID = adminID
        self.startDate = startDate
        self.endDate = endDate
    }
    
    init? (documentID: String) async throws {
        self = try await Self.fetch(from: K.FStore.UserBans.collectionName, documentID: documentID)
    }
}
