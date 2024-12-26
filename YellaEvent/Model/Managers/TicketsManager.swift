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
            let doc = ticketsCollection.addDocument(data: ticket.toFirestoreData())
            doc.updateData([K.FStore.Tickets.ticketID: doc.documentID])
        }
    }
    
    static func getTicket(ticketId: String) async throws -> Ticket{
        try await Ticket(from: ticketDocument(ticketId: ticketId).getDocument().data()!)
    }
    
    static func updateAttendenceStatus(ticketId: String) async throws {
        try await ticketDocument(ticketId: ticketId).updateData([K.FStore.Tickets.didAttend: true])
    }
    
    static func getUserTickets(userId: String) async throws -> [Ticket] {
        let snapshop = try await ticketsCollection.whereField(K.FStore.Tickets.customerID, isEqualTo: userId).getDocuments()
        
        var tickets: [Ticket] = []
        for doc in snapshop.documents {
            tickets.append( try await Ticket(from: doc.data()))
        }
        return tickets
    }
    
    
    static func getUserTickets(userId: String, listener: @escaping (QuerySnapshot?, Error?) -> Void)  {
        ticketsCollection.whereField(K.FStore.Tickets.customerID, isEqualTo: userId).addSnapshotListener(listener)
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
                        let ticket = try await Ticket(from: doc.data())
                        do {
                            let user = try await UsersManager.getUser(userID: ticket.customerID)
                            usersDec[user.email] = user.fullName
                            if ticket.didAttend {attendedTickets += 1}
                            totalTickets += 1
                        } catch {
                            print("Error fetching user for userId \(ticket.customerID): \(error)")
                            throw error
                        }
                    } catch {
                        print("Error decoding Ticket: \(error)")
                        throw error
                    }
                }
                completion(usersDec, totalTickets, attendedTickets) 
            }
        }
    }
    
    static func getEventTickets(eventID: String) async throws -> [Ticket] {
        let snapshot = try await ticketsCollection.whereField(K.FStore.Tickets.eventID, isEqualTo: eventID).getDocuments()
        var tickets: [Ticket] = []

        for document in snapshot.documents {
            do {
                let ticket = try await Ticket(from: document.data())
                tickets.append(ticket)
            } catch {
                print("Failed to decode document \(document.documentID): \(error.localizedDescription)")
                throw error
            }
        }

        return tickets
    }

    
    static func updateEventStartTimeStamp(eventID: String, startTimeStamp: Date) async throws {
        let tickets = try await getEventTickets(eventID: eventID)
//        for ticket in tickets {
//            try await ticketDocument(ticketId: ticket.ticketID).updateData([
//                K.FStore.Tickets.startTimeStamp: startTimeStamp,
//            ])
//        }
    }
    
    
    static func updateTicket(ticket: Ticket) async throws {
        try await ticketDocument(ticketId:  ticket.ticketID).updateData(K.encoder.encode(ticket))
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
