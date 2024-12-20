//
//  FAQ.swift
//  YellaEvent
//
//  Created by meme on 07/12/2024.
//

import Foundation


enum FAQUserType: String, Codable {
    case all = "all"
    case admin = "admin"
    case customer = "customer"
    case organizer = "organizer"
}
struct FAQ : Codable {
    var faqID : String
    var question : String
    var answer : String
    var userType : FAQUserType

    init(question: String, answer: String, userType: FAQUserType) {
        self.faqID = "faqID"
        self.question = question
        self.answer = answer
        self.userType = userType
    }
    
    init?(documentID: String) async throws {
        self = try await Self.fetch(from: K.FStore.FAQs.collectionName, documentID: documentID)
        self.faqID = documentID
    }
}
