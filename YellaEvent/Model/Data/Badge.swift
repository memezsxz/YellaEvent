//
//  Badge.swift
//  YellaEvent
//
//  Created by meme on 28/11/2024.
//

import Foundation
import FirebaseFirestore

struct Badge : Codable {
    var image : String
    var eventID : String // maybe we want to delete the event, but we do not want the badge to be removed from users
    var eventName : String
//    var categoryID : String
    var categoryName : String
    var categoryIcon : String
    
    init(image: String, eventID: String, eventName: String, /*catigoryID: String,*/ catigoryName: String, catigoryIcon: String) {
        self.image = image
        self.eventID = eventID
        self.eventName = eventName
//        self.categoryID = catigoryID
        self.categoryName = catigoryName
        self.categoryIcon = catigoryIcon
    }
    
    init?(documentID: String) async throws {
        self = try await Self.fetch(from: K.FStore.Badges.collectionName, documentID: documentID)
        self.eventID = documentID
    }
    
}
