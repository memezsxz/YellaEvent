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
        try await badgeDocument(eventID: badge.eventID).setData(badge.toFirestoreData(), merge: false)
    }
    
    static func getBadge(eventID: String) async throws -> Badge{
        try await Badge(from: badgeDocument(eventID: eventID).getDocument().data()!)
    }
    
    static func getUserBadges(badgesArray: [String]) async throws -> [Badge] {
        let snapshot = try await badgesCollection.whereField(K.FStore.Badges.badgeID, in: badgesArray).getDocuments()

        var badges: [Badge] = []
        for doc in snapshot.documents {
            let badge = try await Badge(from: doc.data())
            badges.append(badge)
        }
        return badges
    }

    static func updateBadge(badge: Badge) async throws {
        try await badgeDocument(eventID: badge.eventID).setData(badge.toFirestoreData(), merge: true)
    }
    
    static func updateBadge(eventID: String, image : String) async throws {
        try await badgeDocument(eventID: eventID).updateData([K.FStore.Badges.image : image])
    }
    
    static func getNumBadges(withCategoryID categoryID: String) async throws -> Int {
       try await badgesCollection.whereField(K.FStore.Badges.categoryID, isEqualTo: categoryID).getDocuments().documents.count
    }
}




