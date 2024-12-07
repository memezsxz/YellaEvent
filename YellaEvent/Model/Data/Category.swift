//
//  Category.swift
//  YellaEvent
//
//  Created by meme on 30/11/2024.
//

import Foundation

enum CategoryStaus : String, Codable {
    case enabled = "enabled" // being used
    case disabled = "disabled" // deleted or disabled by admin, should not show up in search fillter 
    case history = "history"
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
