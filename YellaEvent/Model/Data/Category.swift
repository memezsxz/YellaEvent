//
//  Category.swift
//  YellaEvent
//
//  Created by meme on 30/11/2024.
//

import Foundation

enum CategoryStaus : String, Codable {
    case enabled = "enabled" // being used
    case disabled = "disabled" // deleted or disabled by admin, should not show up in search fillter or when creating an event
    case history = "history" // will not be shown to the admin but some badges will depend on it so it will e kept in the database
}

struct Category : Codable {
    var categoryID : String
    var name : String
    var icon : String
    var status : CategoryStaus

    init (categoryID : String = "Default", name : String, icon : String, status : CategoryStaus = .enabled) {
        self.categoryID = categoryID
        self.name = name
        self.icon = icon
        self.status = status
    }

    init?(documentID: String) async throws {
        self = try await Self.fetch(from: K.FStore.Categories.collectionName, documentID: documentID)
        self.categoryID = documentID
    }
}
