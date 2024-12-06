//
//  TicketsManager.swift
//  YellaEvent
//
//  Created by meme on 03/12/2024.
//

import FirebaseFirestore

final class TicketsManager {
    private init() {}
    
    private static let ticketsCollection = Firestore.firestore().collection(K.FStore.Tickets.collectionName)
    private static var listener: ListenerRegistration?
    
    private static func ticketDocument(ticketId: String) -> DocumentReference {
        ticketsCollection.document(ticketId)
    }
    
    static func createNewTicket(ticket: Ticket) async throws {
        Task {
            let doc = try ticketsCollection.addDocument(data: K.encoder.encode(ticket))
            doc.updateData([K.FStore.Tickets.ticketID: doc.documentID])
        }
    }
    
    static func getTicket(ticketId: String) async throws -> Ticket{
        try await ticketDocument(ticketId: ticketId).getDocument(as : Ticket.self)
    }
    
    static func updateAttendenceStatus(ticketId: String) async throws {
        try await ticketDocument(ticketId: ticketId).updateData([K.FStore.Tickets.didAttend: true])
    }
    
    static func getUserTickets(userId: String) async throws -> [Ticket] {
        try await ticketsCollection.whereField(K.FStore.Tickets.userID, isEqualTo: userId).getDocuments().documents.compactMap { doc in
            try doc.data(as: Ticket.self)
        }
    }
    
    // not tested
    static func getEventAttendance(eventId: String, completion: @escaping ([String: String], Int, Int) -> Void) async {
        self.listener?.remove()
        
        self.listener = ticketsCollection.whereField(K.FStore.Tickets.eventID, isEqualTo: eventId).addSnapshotListener { snapshot, error in
//            guard error == nil else {
//                print("Error fetching tickets: \(error!.localizedDescription)")
//                return
//            }
            
            guard let snapshot = snapshot else {
                completion([:], 0, 0)
                return
            }
            
            var usersDec: [String: String] = [:]
            var totalTickets = 0
            var attendedTickets = 0
            
            Task {
                for doc in snapshot.documents {
                    do {
                        let ticket = try doc.data(as: Ticket.self)
                        do {
                            let user = try await UsersManager.getUser(userID: ticket.userID)
                            usersDec[user.email] = user.fullName
                            if ticket.didAttend {attendedTickets += 1}
                            totalTickets += 1
                        } catch {
                            print("Error fetching user for userId \(ticket.userID): \(error)")
                        }
                    } catch {
                        print("Error decoding Ticket: \(error)")
                    }
                }
                completion(usersDec, totalTickets, attendedTickets) 
            }
        }
    }
    
    static func getEventTickets(eventID: String) async throws -> [Ticket] {
       try await ticketsCollection.whereField(K.FStore.Tickets.eventID, isEqualTo: eventID).getDocuments().documents.compactMap { doc in
           try doc.data(as: Ticket.self)
        }
    }
    
    static func updateEventStartTimeStamp(eventID: String, startTimeStamp: Date) async throws {
        let tickets = try await getEventTickets(eventID: eventID)
        for ticket in tickets {
            try await ticketDocument(ticketId: ticket.ticketID).updateData([
                K.FStore.Tickets.startTimeStamp: startTimeStamp,
            ])
        }
    }
    
//    static func updateEventCategory(eventID: String, categoryIcon : String, categoryName : String) async throws {
//        let tickets = try await getEventTickets(eventID: eventID)
//        for ticket in tickets {
//            try await ticketDocument(ticketId: ticket.ticketID).updateData([
//                K.FStore.Categories.icon: categoryIcon,
//                K.FStore.Categories.name: categoryName
//            ])
//        }
//    }

}
