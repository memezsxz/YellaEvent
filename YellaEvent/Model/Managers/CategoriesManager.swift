//
//  CategoriesManager.swift
//  YellaEvent
//
//  Created by Ahmed Ali on 04/12/2024.
//



import Foundation
import FirebaseFirestore

class CategoriesManager {
    private static var instence : CategoriesManager?
    private init() {}
    
    
    static func getInstence () -> CategoriesManager {
        if instence == nil {
            instence = CategoriesManager()
        }
        return instence!
    }
    
    static func killInstence() {
        guard instence != nil else { return }
        instence?.listener?.remove()
        instence = nil
    }
    
    private let categoriesCollection = Firestore.firestore().collection(K.FStore.Categories.collectionName)
    private var listener: ListenerRegistration?
    
    private let encoder : Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .useDefaultKeys
        return encoder
    }()
    
    private let decoder : Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        return decoder
    }()
    
    
    private func categoryDocument(categoryId: String) -> DocumentReference {
        categoriesCollection.document(categoryId)
    }
    
    func createNewCategory(category: Category) async throws {
        Task {
            try categoryDocument(categoryId: category.categoryID).setData(encoder.encode(category), merge: false)
        }
    }
    
    func getCategory(categoryId: String) async throws -> Event {
        try await categoryDocument(categoryId: categoryId).getDocument(as : Event.self)
    }
    
    func updateCategory(categoryId: String, fields: [String: Any]) async throws {
        try await categoryDocument(categoryId: categoryId).updateData(fields)
    }
    
    func updateCategory(categoryId: String, category: Category) async throws {
        try await categoryDocument(categoryId: categoryId).updateData(encoder.encode(category))
    }
    
    
    func getAllCategories(listener: @escaping (QuerySnapshot?, Error?) -> Void) {
        self.listener?.remove()
        self.listener = categoriesCollection
            .addSnapshotListener(listener)
    }
    
    func deleteCategory(categoryId: String) async throws {
        try await categoryDocument(categoryId: categoryId).delete()
    }
    

    
}
