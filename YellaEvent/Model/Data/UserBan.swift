//
//  UserBan.swift
//  YellaEvent
//
//  Created by meme on 30/11/2024.
//

import FirebaseFirestore

struct UserBan : Codable {
    var userID : String
    var descroption : String
    var adminID : String
    var startDate : Date
    var endDate : Date

    init(userID: String, descroption: String, adminID: String, startDate: Date, endDate: Date) {
        self.userID = userID
        self.descroption = descroption
        self.adminID = adminID
        self.startDate = startDate
        self.endDate = endDate
    }
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userID = try container.decode(String.self, forKey: .userID)
        self.descroption = try container.decode(String.self, forKey: .descroption)
        self.adminID = try container.decode(String.self, forKey: .adminID)
        self.startDate = try container.decode(Date.self, forKey: .startDate)
        self.endDate = try container.decode(Date.self, forKey: .endDate)
    }
    
    init?(documentID: String) async throws {
        let firestore = Firestore.firestore()
        let documentRef = firestore.collection(K.FStore.UserBans.collectionName).document(documentID)
        
        let documentSnapshot = try await documentRef.getDocument()
        
        guard let documentData = documentSnapshot.data() else {
            throw NSError(domain: "UserBan", code: 404, userInfo: [NSLocalizedDescriptionKey: "Document not found or empty."])
        }
        
        let decoder = Firestore.Decoder()
        guard let userBan = try? decoder.decode(UserBan.self, from: documentData) else {
            throw NSError(domain: "UserBan", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to decode user ban data."])
        }
        
        self = userBan
    }
}
