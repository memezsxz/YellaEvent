//
//  BadgesManager.swift
//  YellaEvent
//
//  Created by meme on 06/12/2024.
//

import Foundation
import FirebaseFirestore
final class BadgesManager {
    private init() {}
    
    private static let badgesCollection = Firestore.firestore().collection(K.FStore.Badges.collectionName)
    private static var listener: ListenerRegistration?
        
    private static func badgeDocument(eventID: String) -> DocumentReference {
        badgesCollection.document(eventID)
    }
    
    static func createNewBadge(badge: Badge) async throws {
        try await badgeDocument(eventID: badge.eventID).setData(K.encoder.encode(badge), merge: false)
    }
    
    static func getBadge(eventID: String) async throws -> Badge{
        try await badgeDocument(eventID: eventID).getDocument(as : Badge.self)
    }
    
    static func getUserBadges(badgesArray: [String]) async throws -> [Badge] {
        try await badgesCollection.whereField(K.FStore.Badges.badgeID, in: badgesArray).getDocuments().documents.compactMap { doc in
            try  doc.data(as: Badge.self)
        }
    }
    
    static func updateBadge(badge: Badge) async throws {
        try await badgeDocument(eventID: badge.eventID).setData(try K.encoder.encode(badge), merge: true)
    }
    
    static func updateBadge(eventID: String, image : String) async throws {
        try await badgeDocument(eventID: eventID).updateData([K.FStore.Badges.image : image])
    }
}




