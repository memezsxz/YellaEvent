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
    var category : Category

    init(image: String, eventID: String, eventName: String, category: Category) {
        self.image = image
        self.eventID = eventID
        self.eventName = eventName
        self.category = category
//        self.categoryID = catigoryID
//        self.categoryName = category.name
//        self.categoryIcon = ca
    }
    
    func toFirestoreData() -> [String: Any] {
        return [
            K.FStore.Badges.image: self.image,
            K.FStore.Badges.eventID: self.eventID,
            K.FStore.Badges.eventName: self.eventName,
            K.FStore.Badges.categoryID: self.category.categoryID,
        ]
    }

    init(from data: [String: Any]) async throws {
        self.image = data[K.FStore.Badges.image] as? String ?? ""
        self.eventID = data[K.FStore.Badges.eventID] as? String ?? ""
         do {
             self.eventName = try await EventsManager.getEvent(eventID: self.eventID).name }
        catch {
            self.eventName = data[K.FStore.Badges.eventName] as? String ?? ""
        }
        self.category = try await CategoriesManager.getCategory(categorieID: data[K.FStore.Badges.categoryID] as? String ?? "")
    }
    
    init?(documentID: String) async throws {
        self = try await Self.fetch(from: K.FStore.Badges.collectionName, documentID: documentID)
        self.eventID = documentID
    }
    
}
