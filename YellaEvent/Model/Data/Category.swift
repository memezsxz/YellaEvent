//
//  Category.swift
//  YellaEvent
//
//  Created by meme on 30/11/2024.
//

import Foundation

struct Category : Codable {
    var categoryID : String
    var name : String
    var icon : String
    var isActive : Bool

    init (categoryID : String = "Default", name : String, icon : String, isActive : Bool = true) {
        self.categoryID = categoryID
        self.name = name
        self.icon = icon
        self.isActive = isActive
    }

    init?(documentID: String) async throws {
        self = try await Self.fetch(from: K.FStore.Categories.collectionName, documentID: documentID)
        self.categoryID = documentID
    }
}
