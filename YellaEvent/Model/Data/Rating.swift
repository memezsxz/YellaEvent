//
//  Rating.swift
//  YellaEvent
//
//  Created by meme on 12/12/2024.
//

import Foundation

struct Rating : Codable  {
    var userID : String
    var eventID : String
    var organizerID : String
    var rating : Double

    init (userID : String , eventID : String , organizerID : String , rating : Double){
        self.userID = userID
        self.eventID = eventID
        self.organizerID = organizerID
        self.rating = rating
    }
    
    init?(documentID: String) async throws {
        self = try await Self.fetch(from: K.FStore.Ratings.collectionName, documentID: documentID)
    }
}
