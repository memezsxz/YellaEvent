//
//  TicketsManager.swift
//  YellaEvent
//
//  Created by meme on 03/12/2024.
//

import FirebaseFirestore

final class TicketsManager {
    private static var instence : TicketsManager?
    private init() {}
    
    static func getInstence () -> TicketsManager {
        if instence == nil {
            instence = TicketsManager()
        }
        return instence!
    }
    
    // always kill when view is disapeard
    static func killInstence() {
        guard instence != nil else { return }
        instence?.listener?.remove()
        instence = nil
    }
    
    private let ticketsCollection = Firestore.firestore().collection(K.FStore.Tickets.collectionName)
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
    
    
    private func ticketDocument(ticketId: String) -> DocumentReference {
        ticketsCollection.document(ticketId)
    }
    
    func createNewTicket(ticket: Ticket) async throws {
        Task {
            let doc = try ticketsCollection.addDocument(data: encoder.encode(ticket))
            doc.updateData([K.FStore.Tickets.ticketID: doc.documentID])
        }
    }
    
    func getTicket(ticketId: String) async throws -> Ticket{
        try await ticketDocument(ticketId: ticketId).getDocument(as : Ticket.self)
    }
    
    func updateAttendenceStatus(ticketId: String) async throws {
        try await ticketDocument(ticketId: ticketId).updateData([K.FStore.Tickets.didAttend: true])
    }
    
    func getUserTickets(userId: String) async throws -> [Ticket] {
        try await ticketsCollection.whereField(K.FStore.Tickets.userID, isEqualTo: userId).getDocuments().documents.compactMap { doc in
            try doc.data(as: Ticket.self)
        }
    }
    
    // not tested
    func getEventAttendance(eventId: String, completion: @escaping ([User]) -> Void) async {
        self.listener?.remove()
        
        self.listener = ticketsCollection.whereField(K.FStore.Tickets.eventID, isEqualTo: eventId).addSnapshotListener { snapshot, error in
            guard error == nil else {
                print("Error fetching tickets: \(error!.localizedDescription)")
                return
            }
            
            guard let snapshot = snapshot else {
                print("Snapshot is nil.")
                return
            }
            
            var usersArray: [User] = [] // Create a local array to hold users
            
            Task {
                for doc in snapshot.documents {
                    do {
                        // Decode the document into a Ticket
                        let ticket = try doc.data(as: Ticket.self)
                        
                        // Fetch the user asynchronously
                        do {
                            let user = try await UsersManager.getInstence().getUser(userId: ticket.userID)
                            usersArray.append(user)
                        } catch {
                            print("Error fetching user for userId \(ticket.userID): \(error)")
                        }
                    } catch {
                        print("Error decoding Ticket: \(error)")
                    }
                }
                completion(usersArray) // Return the updated users array
            }
        }
    }
    
}




