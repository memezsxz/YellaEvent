//
//  Category.swift
//  YellaEvent
//
//  Created by meme on 30/11/2024.
//

import Foundation
import FirebaseFirestore

struct Category : Codable {
    var categoryID : String
    var name : String
    var icon : String

    init(categoryID: String, name: String, icon: String) {
        self.categoryID = categoryID
        self.name = name
        self.icon = icon
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.categoryID = try container.decode(String.self, forKey: .categoryID)
        self.name = try container.decode(String.self, forKey: .name)
        self.icon = try container.decode(String.self, forKey: .icon)
    }
    
    init?(documentID: String) async throws {
        let firestore = Firestore.firestore()
        let documentRef = firestore.collection(K.FStore.Categories.collectionName).document(documentID)
        
        let documentSnapshot = try await documentRef.getDocument()
        
        guard let documentData = documentSnapshot.data() else {
            throw NSError(domain: "Category", code: 404, userInfo: [NSLocalizedDescriptionKey: "Document not found or empty."])
        }
        
        let decoder = Firestore.Decoder()
        guard let category = try? decoder.decode(Category.self, from: documentData) else {
            throw NSError(domain: "Category", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to decode category data."])
        }
        
        self = category
        self.categoryID = documentID
    }

}
