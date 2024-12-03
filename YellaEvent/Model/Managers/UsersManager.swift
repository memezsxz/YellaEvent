//
//  UserManager.swift
//  YellaEvent
//
//  Created by meme on 30/11/2024.
//

import FirebaseFirestore

final class UsersManager {
    private static var instence : UsersManager?
    private init() {}
    
    
    static func getInstence () -> UsersManager {
        if instence == nil {
            instence = UsersManager()
        }
        return instence!
    }
    
    // always kill when view is disapeard
    static func killInstence() {
        guard instence != nil else { return }
        
        for listener in instence!.listeners.values {
            listener.remove()
        }
        
        instence = nil
    }
    
    private let userCollection = Firestore.firestore().collection(K.FStore.Users.collectionName)
    private var listeners: [String : ListenerRegistration] = [:]
    
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
    
    
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    func createNewUser(user: User) async throws {
        Task {
            try userDocument(userId: user.userID).setData(encoder.encode(user), merge: false)
        }
    }
    
    func getUser(userId: String) async throws -> User{
        try await userDocument(userId: userId).getDocument(as : User.self)
    }
    
    func updateUser(userId: String, fields: [String: Any]) async throws {
        try await userDocument(userId: userId).updateData(fields)
    }
    
    func updateUser(user: User) async throws {
        try await userDocument(userId: user.userID).updateData(encoder.encode(user))
    }
    
//    func updateUser(user: User, fields: [String: Any]) async throws {
//        try await userDocument(userId: user.id).updateData(fields)
//    }
//
    
    // important -- better add a listner snapshot
    
    
    
    
//    func getAllUsers() async throws -> [User] {
//        return try await userCollection
//            .order(by: K.FStore.Users.dateCreated).getDocuments().documents.compactMap
//        { document in
//            try document.data(as: User.self)
//        }
//    }
//    
//    func getAllOrganizers() async throws -> [User] {
//        return try await userCollection
//            .whereField(K.FStore.Users.type, isEqualTo: UserType.organizer.rawValue)
//            .order(by: K.FStore.Users.dateCreated).getDocuments().documents.compactMap
//        { document in
//            try document.data(as: User.self)
//        }
//    }
    
    // better be added individually
//    func addListener(documentID: String, listener: @escaping (QuerySnapshot?, Error?) -> Void) {
//        listeners[documentID] =
//        userCollection.addSnapshotListener(listener)
//    }
    
    // use documentID as the listener ideantifier
    func addListener(documentID: String, listener: ListenerRegistration) {
        listeners[documentID] = listener
        }

    func removeListener(documentID: String) {
        listeners.removeValue(forKey: documentID)
    }
}
