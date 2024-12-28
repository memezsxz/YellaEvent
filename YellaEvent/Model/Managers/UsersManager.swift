//
//  UserManager.swift
//  YellaEvent
//
//  Created by meme on 30/11/2024.
//

import FirebaseFirestore

final class UsersManager {
    private init() {}
    
    //    static func getInstence () -> UsersManager {
    //        if instence == nil {
    //            instence = UsersManager()
    //        }
    //        return instence!
    //    }
    //
    //    // always kill when view is disapeard
    //    static func killInstence() {
    //        guard instence != nil else { return }
    //        instence?.listener?.remove()
    //        instence = nil
    //    }
    
    private static let adminsCollection = Firestore.firestore().collection(K.FStore.Admins.collectionName)
    private static let customersCollection = Firestore.firestore().collection(K.FStore.Customers.collectionName)
    private static let organizersCollection = Firestore.firestore().collection(K.FStore.Organizers.collectionName)
    
    private static var listeners = [ListenerRegistration] ()
    
    private static func adminDocument(userID: String) -> DocumentReference {
        adminsCollection.document(userID)
    }
    
    private static func customerDocument(userID: String) -> DocumentReference {
        customersCollection.document(userID)
    }
    
    private static func organizerDocument(userID: String) -> DocumentReference {
        organizersCollection.document(userID)
    }
    
    static func createNewUser(user: User) async throws {
        Task {
            switch user.type {
            case .admin:
                Task {
                    try adminDocument(userID: user.userID).setData(K.encoder.encode(user as! Admin), merge: false)
                }
            case .customer:
                Task {
                    try customerDocument(userID: user.userID).setData(K.encoder.encode(user as! Customer), merge: false)
                }
            case .organizer:
                Task {
                    try organizerDocument(userID: user.userID).setData(K.encoder.encode(user as! Organizer), merge: false)
                }
            }
        }
    }
    
    static func getCustomer(customerID: String) async throws -> Customer {
        return try await customerDocument(userID: customerID).getDocument(as : Customer.self)
    }
    
    static func getOrganizer(organizerID: String) async throws -> Organizer {
        return try await organizerDocument(userID: organizerID).getDocument(as : Organizer.self)
    }
    
    static func getAdmin(adminID: String) async throws -> Admin {
        return try await adminDocument(userID: adminID).getDocument(as : Admin.self)
    }
    
    static func getUser(userID: String) async throws -> User {
        if let customer = try? await getCustomer(customerID: userID) {
            return customer
        }
        
        if let admin = try? await getAdmin(adminID: userID) {
            return admin
        }
        
        if let organizer = try? await getOrganizer(organizerID: userID) {
            return organizer
        }
        
        throw NSError(
            domain: "UserFetchError",
            code: 404,
            userInfo: [NSLocalizedDescriptionKey: "User with ID \(userID) not found."]
        )
    }
    
    static func updateUser(user : User) async throws {
        switch user {
        case is Customer:
            try await customerDocument(userID: user.userID).updateData(K.encoder.encode(user as! Customer))
        case is Organizer:
            try await organizerDocument(userID: user.userID).updateData(K.encoder.encode(user as! Organizer))
//            try await EventsManager.updateEventOrganizer(organizer: user as! Organizer)
        case is Admin:
            try await adminDocument(userID: user.userID).updateData(K.encoder.encode(user as! Admin))
        default:
            throw NSError(
                domain: "UnrecognizedUserType",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "User Type \(user) not recognized."]
            )
        }
    }
    
    static func updateUser(user: User, fields: [String: Any]) async throws {
        switch user {
        case is Customer:
            try await customerDocument(userID: user.userID).updateData(fields)
        case is Organizer:
            try await organizerDocument(userID: user.userID).updateData(fields)
//            try await EventsManager.updateEventOrganizer(organizer: user as! Organizer)
        case is Admin:
            try await adminDocument(userID: user.userID).updateData(fields)
        default:
            throw NSError(
                domain: "UnrecognizedUserType",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "User Type \(user) not recognized."]
            )
        }
    }
    
    
    // important -- better add a listner snapshot
    
    static func addUsersListener(userType: UserType, listener: @escaping (QuerySnapshot?, Error?) -> Void) {
        
        for listener in listeners {
            listener.remove()
        }

        var collection : CollectionReference {
            switch userType {
            case .customer:
                return customersCollection
            case .admin :
                return adminsCollection
            case .organizer:
                return organizersCollection
            }
        }
        listeners.append(collection.order(by: K.FStore.User.fullName).addSnapshotListener(listener))
    }
    
    static func getAllUsers(listener: @escaping (QuerySnapshot?, Error?) -> Void) {
        for listener in listeners {
            listener.remove()
        }
        listeners.append(customersCollection.order(by: K.FStore.User.fullName).addSnapshotListener(listener))
        listeners.append(adminsCollection.order(by: K.FStore.User.fullName).addSnapshotListener(listener))
        listeners.append(organizersCollection.order(by: K.FStore.User.fullName).addSnapshotListener(listener))
    }
    
    static func getAllUsers() async throws -> [User] {
        var users : [any User] = []
        
        var snapshot = try await customersCollection.getDocuments()
        users.append(contentsOf: try convertToUsers(snapshot: snapshot, ofType: Customer.self))
        
        snapshot = try await adminsCollection.getDocuments()
        users.append(contentsOf: try convertToUsers(snapshot: snapshot, ofType: Admin.self))

        snapshot = try await organizersCollection.getDocuments()
        users.append(contentsOf: try convertToUsers(snapshot: snapshot, ofType: Organizer.self))

        return users
    }
    
    // This function expects a specific User type
    static func getUsers(ofType type: UserType) async throws -> [User] {
        switch type {
        case .admin:
            return try await getUsers(ofType: Admin.self)
        case .customer:
            return try await getUsers(ofType: Customer.self)
        case .organizer:
            return try await getUsers(ofType: Organizer.self)
        }
    }

   private static func getUsers<T: User>(ofType type: T.Type) async throws -> [T] {
        let collection: CollectionReference
        
        switch type {
        case is Admin.Type:
            collection = adminsCollection
        case is Customer.Type:
            collection = customersCollection
        case is Organizer.Type:
            collection = organizersCollection
        default:
            throw NSError(domain: "UnrecognizedUserType", code: 404, userInfo: [NSLocalizedDescriptionKey: "User Type \(T.self) not recognized."])
        }
        
        let snapshot = try await collection.order(by: K.FStore.User.fullName).getDocuments()
        
        var users = [T]()
        for doc in snapshot.documents {
            if let user = try? doc.data(as: T.self) {
                users.append(user)
            }
        }
        
        return users
    }

    // Convert snapshot to an array of `User`
//    private static func convertToUsers<T: User & Decodable>(snapshot: QuerySnapshot) throws -> [T] {
//        var users = [T]()
//        for doc in snapshot.documents {
//            // Decode the document into the specified user type
//            users.append(try doc.data(as: T.self))
//        }
//        return users
//    }
    
    // Convert snapshot to an array of specific `User` type
    private static func convertToUsers<T: User & Decodable>(snapshot: QuerySnapshot, ofType userType: T.Type) throws -> [T] {
        var users = [T]()
        for doc in snapshot.documents {
            // Decode the document into the specified user type
            users.append(try doc.data(as: T.self))
        }
        return users
    }
    
    
    static public func searchUsers(userType: UserType?, searchText: String) async throws -> [User] {
        // Declare a variable to store the users
        let users: [User]
        
        // Switch on the userType to fetch the appropriate users
        switch userType {
        case .admin:
            users = try await getUsers(ofType: Admin.self)
        case .customer:
            users = try await getUsers(ofType: Customer.self)
        case .organizer:
            users = try await getUsers(ofType: Organizer.self)
        case nil:
            users = try await getAllUsers()  // If nil, get all users
        }
        
        // Filter the users by the search text
        return users.filter { user in
            let nameComponents = user.fullName.lowercased().split(separator: " ")
            let emailParts = user.email.lowercased().split(separator: "@")

            let matchesName = nameComponents.contains { word in
                word.starts(with: searchText.lowercased())
            }
            let matchesEmail = emailParts.contains { part in
                part.starts(with:searchText.lowercased())
            }

            return matchesName || matchesEmail
        }
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
    
    static func deleteUser(userID: String, userType: UserType) async throws {
        switch userType {
            case .organizer:
                try await organizerDocument(userID: userID).delete() // return organizer document
        case .admin:
            try await adminDocument(userID: userID).delete() // return admin document
        case .customer:
            try await customerDocument(userID: userID).delete()
        }
    }
    
    static func banUser(userID: String, userType: UserType, reason: String, description: String, startDate: Date, endDate: Date) throws {
        let userBansCollection = Firestore.firestore().collection(K.FStore.UserBans.collectionName)
        
        userBansCollection.addDocument(data: try K.encoder.encode(UserBan(userID: userID, reason: reason, descroption: description, adminID: UserDefaults.standard.string(forKey: K.bundleUserID)!, startDate: startDate, endDate: endDate)))
        
        if userType == .organizer {
            Task {
                try await EventsManager.OrganizerBanedHandler(organizerID: userID)
            }
        }
    }
    
    static func unbanUser(userID: String) async throws {
        let userBansCollection = Firestore.firestore().collection(K.FStore.UserBans.collectionName)
        
        let snapshot = try await userBansCollection.whereField(K.FStore.UserBans.userID, isEqualTo: userID).getDocuments()
        for doc in snapshot.documents {
            try await doc.reference.delete()
        }
    }
    
    

    static func isUserBanned(userID: String) async throws -> Bool {
        try await  Firestore.firestore().collection(K.FStore.UserBans.collectionName).whereField(K.FStore.UserBans.userID, isEqualTo: userID).getDocuments().documents.isEmpty
    }
    
    static func getUserBans() async throws -> [UserBan] {
       try await Firestore.firestore().collection(K.FStore.UserBans.collectionName).getDocuments().documents.compactMap { doc in
            try doc.data(as: UserBan.self)
        }
    }
    
    static func getCustomersSum() async throws  -> Int {
        try await customersCollection.getDocuments().documents.count
        }
    
    static func getOrganizersSum() async throws -> Int {
        try await organizersCollection.getDocuments().documents.count
        }
}
