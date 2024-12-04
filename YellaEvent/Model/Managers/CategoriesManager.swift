//
//  CategoriesManager.swift
//  YellaEvent
//
//  Created by meme on 04/12/2024.
//

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
    
    // always kill when view is disapeard
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
    
    
    private func categorieDocument(categorieID: String) -> DocumentReference {
        categoriesCollection.document(categorieID)
    }
    
    func createNewCategorie(categorie: Category) async throws {
        Task {
            let doc = try categoriesCollection.addDocument(data: encoder.encode(categorie))
            doc.setData([K.FStore.Categories.categoryID: doc.documentID])
        }
    }
    
    func getCategorie(categorieID: String) async throws -> Category {
        try await categorieDocument(categorieID: categorieID).getDocument(as : Category.self)
    }
    
    func updateCategorie(categorieID: String, fields: [String: Any]) async throws {
        try await categorieDocument(categorieID: categorieID).updateData(fields)
    }
    
    func updateCategorie(categorie: Category) async throws {
        try await categorieDocument(categorieID: categorie.categoryID).updateData(encoder.encode(categorie))
    }
    
    func getAllCategories(listener: @escaping (QuerySnapshot?, Error?) -> Void) async throws {
        self.listener?.remove()
        self.listener = categoriesCollection
            .order(by: K.FStore.Categories.name)
            .addSnapshotListener(listener)
    }
    
    // do not use for now
    func deleteCategorie(categorieID: String) async throws {
        try await categorieDocument(categorieID: categorieID).delete()
    }
}
