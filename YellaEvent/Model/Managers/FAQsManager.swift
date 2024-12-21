//
//  FAQsManager.swift
//  YellaEvent
//
//  Created by meme on 07/12/2024.
//

import Foundation
import FirebaseFirestore

final class FAQsManager {
    private init() {}
    
    private static let FAQsCollection = Firestore.firestore().collection(K.FStore.FAQs.collectionName)
    private static var listener: ListenerRegistration?

    private static func FAQDocument(FAQID: String) -> DocumentReference {
        FAQsCollection.document(FAQID)
    }
    
    static func createNewFAQ(FAQ: FAQ) async throws {
        Task {
            let doc = try FAQsCollection.addDocument(data: K.encoder.encode(FAQ))
            doc.updateData([K.FStore.FAQs.faqID: doc.documentID])
        }
    }
    
    static func getFAQ(FAQID: String) async throws -> FAQ {
        try await FAQDocument(FAQID: FAQID).getDocument(as : FAQ.self)
    }
    
    static func getFAQs(forUserType type: FAQUserType) async throws -> [FAQ] {
        try await FAQsCollection.whereField(K.FStore.FAQs.userType, isEqualTo: type.rawValue).getDocuments().documents.compactMap { doc in
            try  doc.data(as: FAQ.self)
        }
    }
    
    static func getAllFAQs() async throws -> [FAQ] {
        try await FAQsCollection.getDocuments().documents.compactMap { doc in
            try  doc.data(as: FAQ.self)
        }
    }

    static func updateFAQ(FAQ: FAQ) async throws {
        try await FAQDocument(FAQID: FAQ.faqID).setData(try K.encoder.encode(FAQ), merge: true)
    }
    
    static func deleteFAQ(FAQID: String) async throws {
        try await FAQDocument(FAQID: FAQID).delete()
    }
    
    static func getFAQsSum() async throws  -> Int {
        try await FAQsCollection.getDocuments().documents.count
    }
}
