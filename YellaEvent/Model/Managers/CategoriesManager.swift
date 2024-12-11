//
//  CategoriesManager.swift
//  YellaEvent
//
//  Created by meme on 04/12/2024.
//

import FirebaseFirestore

class CategoriesManager {
    private init() {}
    
    private static let categoriesCollection = Firestore.firestore().collection(K.FStore.Categories.collectionName)
    private static var listener: ListenerRegistration?
    
    private static func categorieDocument(categorieID: String) -> DocumentReference {
        categoriesCollection.document(categorieID)
    }
    
    static func createNewCategory(category: Category) async throws {
        Task {
            let doc = try categoriesCollection.addDocument(data: K.encoder.encode(category))
            doc.updateData([K.FStore.Categories.categoryID: doc.documentID])
        }
    }
    
    static func getCategory(categorieID: String) async throws -> Category {
        try await categorieDocument(categorieID: categorieID).getDocument(as : Category.self)
    }
        
    static func updateCategorie(category: Category) async throws {
        try await categorieDocument(categorieID: category.categoryID).updateData(K.encoder.encode(category))
        try await EventsManager.updateEventsCategory(category: category)
    }
    
    static func getAllCategories(listener: @escaping (QuerySnapshot?, Error?) -> Void) async throws {
        self.listener?.remove()
        self.listener = categoriesCollection
            .order(by: K.FStore.Categories.name)
            .addSnapshotListener(listener)
    }
    
    static func getActiveCatigories(listener: @escaping (QuerySnapshot?, Error?) -> Void) async throws {
        self.listener?.remove()
        self.listener = categoriesCollection
            .whereField(K.FStore.Categories.status, isEqualTo: CategoryStaus.enabled.rawValue)
            .order(by: K.FStore.Categories.name)
            .addSnapshotListener(listener)
    }
    
    static func getActiveCatigories() async throws -> [Category] {
        try await categoriesCollection.whereField(K.FStore.Categories.status, isEqualTo: CategoryStaus.enabled.rawValue).getDocuments().documents.compactMap { doc in
            try doc.data(as: Category.self)
        }
    }

    static func getInactiveCatigories(listener: @escaping (QuerySnapshot?, Error?) -> Void) async throws {
        self.listener?.remove()
        self.listener = categoriesCollection
            .whereField(K.FStore.Categories.status, isEqualTo: CategoryStaus.enabled.rawValue)
            .order(by: K.FStore.Categories.name)
            .addSnapshotListener(listener)
    }

    // do not use for now
    static func deleteCategorie(categorieID: String) async throws {
        try await categorieDocument(categorieID: categorieID).delete()
    }
    
    static func getUserSelectedCatigories(userID: String) async throws -> [Category] {
        try await categoriesCollection.whereField(K.FStore.Categories.status, isEqualTo: CategoryStaus.enabled.rawValue).getDocuments().documents.compactMap { doc in
            try doc.data(as: Category.self)
        }
    }

    static func getUserSelectedCatigories(categoriesIDsList: [String]) async throws -> [Category] {
        try await categoriesCollection.whereField(K.FStore.Categories.categoryID, in: categoriesIDsList).getDocuments().documents.compactMap { doc in
            try doc.data(as: Category.self)
        }
    }
    
    static func getCategoriesSum() async throws  -> Int {
        try await categoriesCollection.whereField(K.FStore.Categories.status, isNotEqualTo: CategoryStaus.history.rawValue).getDocuments().documents.count
    }
}
