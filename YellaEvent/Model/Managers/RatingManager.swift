import FirebaseFirestore

class RatingManager {
    private init() {}
    
    private static let ratingCollection = Firestore.firestore().collection(K.FStore.Ratings.collectionName)
    
    private static func ratingDocument(userID: String) -> DocumentReference {
        ratingCollection.document(userID)
    }
    
    static func createNewRating(rating: Rating) async throws {
        try await ratingCollection.document(rating.eventID + rating.userID).updateData(K.encoder.encode(rating))
    }
    
    static func getRating(eventID: String, userID: String) async throws -> Rating {
        try await ratingCollection.document(eventID + userID).getDocument().data(as: Rating.self)
    }
    
    static func getOrganizerRating(organizerID: String, completion: @escaping (Result<Double, Error>) -> Void) {
        let query = ratingCollection
            .whereField(K.FStore.Ratings.organizerID, isEqualTo: organizerID)
            .aggregate([
                AggregateField.sum(K.FStore.Ratings.rating),
                AggregateField.count()
            ])
        
        query.getAggregation(source: .server) { result, error in
            if let error = error {
                completion(.failure(error)) // Handle the error
                return
            }
            
            if let result = result,
               let sum = result.get(AggregateField.sum(K.FStore.Ratings.rating)) as? Double,
               let count = result.get(AggregateField.count()) as? Double, count > 0 {
                let average = sum / Double(count)
                print("avarage", average)

                completion(.success(average)) // Successfully return the average
            } else {
                let error = NSError(domain: "com.app.rating", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch or parse the rating data."])
                print("error", error)

                completion(.failure(error)) // Handle unexpected cases
            }
        }
    }

    
    static func getOrganizerRating(organizerID: String) async throws -> Double {
        let query = ratingCollection
            .whereField(K.FStore.Ratings.organizerID, isEqualTo: organizerID)
            .aggregate([AggregateField.average(K.FStore.Ratings.rating)])
        
       return  try await query.getAggregation(source: .server).get(AggregateField.average(K.FStore.Ratings.rating)) as? Double ?? 0.0
        }
    
    static func getEventRating(eventID: String, completion: @escaping (Result<Double, Error>) -> Void) {
        let query = ratingCollection
            .whereField(K.FStore.Ratings.eventID, isEqualTo: eventID)
            .aggregate([
                AggregateField.sum(K.FStore.Ratings.rating),
                AggregateField.count()
            ])
        
        query.getAggregation(source: .server) { result, error in
            if let error = error {
                completion(.failure(error)) // Handle the error
                return
            }
            
            if let result = result,
               let sum = result.get(AggregateField.sum(K.FStore.Ratings.rating)) as? Double,
               let count = result.get(AggregateField.count()) as? Int, count > 0 {
                let average = sum / Double(count)
                completion(.success(average)) // Successfully return the average
            } else {
                let error = NSError(domain: "com.app.rating", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch or parse the rating data."])
                completion(.failure(error)) // Handle unexpected cases
            }
        }
    }

    //  YellaEvent
    //
    //  Created by meme on 12/12/2024.
    //
}
