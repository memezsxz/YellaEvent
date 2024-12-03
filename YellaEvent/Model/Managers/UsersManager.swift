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
        instence?.listener?.remove()
        instence = nil
    }
    
    private let userCollection = Firestore.firestore().collection(K.FStore.Users.collectionName)
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
    
    func updateUser(user : User) async throws {
        try await userDocument(userId: user.userID).updateData(encoder.encode(user))
    }
    
    //    func updateUser(user: User, fields: [String: Any]) async throws {
    //        try await userDocument(userId: user.id).updateData(fields)
    //    }
    //
    
    // important -- better add a listner snapshot
    
    func addUsersListener(userType: UserType, listener: @escaping (QuerySnapshot?, Error?) -> Void) {
        
        self.listener?.remove()
        self.listener = userCollection
            .whereField(K.FStore.Users.type, isEqualTo:userType.rawValue)
            .order(by: K.FStore.Users.firstName)
            .order(by: K.FStore.Users.lastName)
            .addSnapshotListener(listener)
    }
    
    func getAllUsers(listener: @escaping (QuerySnapshot?, Error?) -> Void) {
        
        self.listener?.remove()
        self.listener = userCollection.order(by: K.FStore.Users.firstName).order(by: K.FStore.Users.lastName).addSnapshotListener(listener)
    }
    
    func getAllUsers() async throws -> [User]{
        
        let snapshot = try await userCollection.order(by: K.FStore.Users.firstName).order(by: K.FStore.Users.lastName).getDocuments()
        
        
        return try convertToUsers(snapshot: snapshot)
    }
    
    func getUsersOfType(_ userType: UserType) async throws -> [User] {
        
        let snapshot = try await userCollection
            .whereField(K.FStore.Users.type, isEqualTo:userType.rawValue)
            .order(by: K.FStore.Users.firstName)
            .order(by: K.FStore.Users.lastName)
            .getDocuments()
        return try convertToUsers(snapshot: snapshot)
    }
    
    private func convertToUsers(snapshot: QuerySnapshot) throws -> [User] {
        var users = [User]()
        for doc in snapshot.documents {
            users.append(try doc.data(as: User.self))
        }
        return users
    }
    //    func searchText(text: String) async throws -> [User] {
    //        self.listener?.remove()
    //        do {
    //            let dbUsers = try await userCollection
    //                .order(by: K.FStore.Users.firstName)
    //                .order(by: K.FStore.Users.lastName)
    //                .getDocuments()
    //            var users = [User]()
    //
    //            guard dbUsers == dbUsers else { return users }
    //
    //            for doc in dbUsers.documents {
    //                let user = try doc.data(as: User.self)
    //                if user.firstName.lowercased().contains(text.lowercased()) || user.lastName.lowercased().contains(text.lowercased()) || user.email.lowercased().contains(text.lowercased()) {
    //                    users.append(user)
    //                }
    //            }
    //
    //            return users
    //        } catch {
    //            throw error
    //        }
    //    }
    
    //    func getAllUsers() async throws -> [User] {
    //        return try await userCollection
    //            .order(by: K.FStore.Users.firstName).order(by: K.FStore.Users.lastName).getDocuments().documents.compactMap
    //        { document in
    //            try document.data(as: User.self)
    //        }
    //    }
    //
    //    func getAllOrganizers() async throws -> [User] {
    //        return try await userCollection
    //            .whereField(K.FStore.Users.type, isEqualTo: String( describing:  UserType.organizer))
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
    //    func addListener(documentID: String, listener: ListenerRegistration) {
    //        listeners[documentID] = listener
    //        }
    //
    //    func removeListener(documentID: String) {
    //        listeners.removeValue(forKey: documentID)
    //    }
}
