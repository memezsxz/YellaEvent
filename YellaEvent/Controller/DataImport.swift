//
//  DataImport.swift
//  YellaEvent
//
//  Created by meme on 13/12/2024.
//

import Foundation
import FirebaseFirestore
final class DataImport {
    static private var idMappings: [String: String] = [:] // Stores mappings for all referenced IDs (userID, eventID, badgeID, etc.)
    static private let db = Firestore.firestore()
    
    static func uploadData() {
        // Locate the JSON file in the app bundle
        guard let path = Bundle.main.path(forResource: "file", ofType: "json") else {
            print("JSON file not found.")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        
        do {
            // Read the JSON file
            let data = try Data(contentsOf: url)
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                // Start uploading collections in the correct order
                uploadAdmins(json: json) {
                    self.uploadOrganizers(json: json) {
                        self.uploadCategories(json: json) {
                            self.uploadEvents(json: json) {
                                self.uploadBadges(json: json) {
                                    self.uploadCustomers(json: json) {
                                        self.uploadRatings(json: json) {
                                            self.uploadTickets(json: json) {
                                                self.uploadUserBans(json: json) {
                                                    self.uploadEventBans(json: json) {
                                                        self.uploadFAQs(json: json)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } catch {
            print("Error reading or parsing JSON: \(error.localizedDescription)")
        }
    }
    
    // Method to upload Admins and update IDs
    static private func uploadAdmins(json: [String: Any], completion: @escaping () -> Void) {
        guard let admins = json["admins"] as? [[String: Any]] else {
            print("No admins data found.")
            completion()
            return
        }
        
        for admin in admins {
            
            var updatedAdmin = admin
            if let dateCreated = admin[K.FStore.User.dateCreated] as? String {
                updatedAdmin[K.FStore.User.dateCreated] = K.DFormatter.date(from: dateCreated)!
            }
            
            
            let ref = db.collection(K.FStore.Admins.collectionName).addDocument(data: updatedAdmin) { error in
                if let error = error {
                    print("Error uploading admin: \(error.localizedDescription)")
                } else {
                    print("Successfully uploaded an admin.")
                }
            }
            
            ref.getDocument { (document, error) in
                if let documentID = document?.documentID {
                    ref.updateData(["userID": documentID])
                    let oldUserID = admin["userID"] as? String ?? ""
                    self.idMappings[oldUserID] = documentID // Mapping the old userID to the new document ID
                }
            }
        }
        completion()
    }
    
    // Method to upload Organizers and update IDs
    static private func uploadOrganizers(json: [String: Any], completion: @escaping () -> Void) {
        guard let organizers = json["organizers"] as? [[String: Any]] else {
            print("No organizers data found.")
            completion()
            return
        }
        
        let dispatchGroup = DispatchGroup()  // Create a DispatchGroup
        
        for organizer in organizers {
            dispatchGroup.enter()  // Enter the DispatchGroup before starting the async task
            var updatedOrganizer = organizer
            if let dateCreated = organizer[K.FStore.User.dateCreated] as? String {
                updatedOrganizer[K.FStore.User.dateCreated] = K.DFormatter.date(from: dateCreated)!
            }
            
            if let startDate = organizer[K.FStore.Organizers.startDate] as? String {
                updatedOrganizer[K.FStore.Organizers.startDate] = K.DFormatter.date(from: startDate)!
            }
            
            if let endDate = organizer[K.FStore.Organizers.endDate] as? String {
                updatedOrganizer[K.FStore.Organizers.endDate] = K.DFormatter.date(from: endDate)!
            }
            
            let ref = db.collection(K.FStore.Organizers.collectionName).addDocument(data: updatedOrganizer) { error in
                if let error = error {
                    print("Error uploading organizer: \(error.localizedDescription)")
                } else {
                    print("Successfully uploaded an organizer.")
                }
            }
            
            ref.getDocument { (document, error) in
                if let documentID = document?.documentID {
                    ref.updateData(["userID": documentID])
                    let oldUserID = organizer["userID"] as? String ?? ""
                    self.idMappings[oldUserID] = documentID
                    print("Mapped old organizer ID \(oldUserID) to new document ID \(documentID)")
                }
                dispatchGroup.leave()  // Leave the DispatchGroup after the async task completes
            }
        }
        
        // Wait for all tasks to complete before calling the completion closure
        dispatchGroup.notify(queue: .main) {
            completion()  // This will be called once all organizers have been processed
        }
    }
    
    // Method to upload Customers and update references
    static private func uploadCustomers(json: [String: Any], completion: @escaping () -> Void) {
        guard let customers = json["customers"] as? [[String: Any]] else {
            print("No customers data found.")
            completion()
            return
        }
        
        let dispatchGroup = DispatchGroup()  // Create a DispatchGroup
        
        for customer in customers {
            dispatchGroup.enter()  // Enter the DispatchGroup before starting the async task
            
            var updatedCustomer = customer
            
            if let dateCreated = customer[K.FStore.User.dateCreated] as? String {
                updatedCustomer[K.FStore.User.dateCreated] = K.DFormatter.date(from: dateCreated)!
            }
            
            if let dob = customer[K.FStore.Customers.dob] as? String {
                updatedCustomer[K.FStore.Customers.dob] = K.DFormatter.date(from: dob)!
            }
            
            // Map badgeIDs if present
            if let badgeIDs = customer["badgesArray"] as? [String] {
                let newBadgeIDs = badgeIDs.compactMap { idMappings[$0] }
                updatedCustomer["badgesArray"] = newBadgeIDs
            }
            
            // Map categoryIDs if present
            if let categoryIDs = customer["interestArray"] as? [String] {
                let newCategoryIDs = categoryIDs.compactMap { idMappings[$0] }
                updatedCustomer["interestArray"] = newCategoryIDs
            }
            
            let ref = db.collection(K.FStore.Customers.collectionName).addDocument(data: updatedCustomer) { error in
                if let error = error {
                    print("Error uploading customer: \(error.localizedDescription)")
                } else {
                    print("Successfully uploaded a customer.")
                }
            }
            
            ref.getDocument { (document, error) in
                if let documentID = document?.documentID {
                    ref.updateData(["userID": documentID])
                    let oldUserID = customer["userID"] as? String ?? ""
                    self.idMappings[oldUserID] = documentID // Mapping the old userID to the new document ID
                }
                dispatchGroup.leave()  // Leave the DispatchGroup after the async task completes
            }
        }
        
        // Wait for all tasks to complete before calling the completion closure
        dispatchGroup.notify(queue: .main) {
            completion()  // This will be called once all customers have been processed
        }
    }
    
    // Method to upload Categories and update IDs
    static private func uploadCategories(json: [String: Any], completion: @escaping () -> Void) {
        guard let categories = json["categories"] as? [[String: Any]] else {
            print("No categories data found.")
            completion()
            return
        }
        
        // Ensure completion is called only after all uploads are done
        let dispatchGroup = DispatchGroup()
        
        for category in categories {
            dispatchGroup.enter() // Start tracking an operation
            
            let ref = db.collection(K.FStore.Categories.collectionName).addDocument(data: category) { error in
                if let error = error {
                    print("Error uploading category: \(error.localizedDescription)")
                } else {
                    print("Successfully uploaded a category.")
                }
            }
            
            ref.getDocument { (document, error) in
                if let documentID = document?.documentID {
                    ref.updateData([K.FStore.Categories.categoryID: documentID])
                    let oldUserID = category[K.FStore.Categories.categoryID] as? String ?? ""
                    self.idMappings[oldUserID] = documentID // Mapping the old userID to the new document ID
                }
                
                dispatchGroup.leave() // Finish tracking this operation
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion() // Ensure completion is called only after all uploads are finished
        }
    }
    
    // Method to upload Events and update IDs
    static private func uploadEvents(json: [String: Any], completion: @escaping () -> Void) {
        guard let events = json["events"] as? [[String: Any]] else {
            print("No events data found.")
            completion()
            return
        }
        
        // Ensure completion is called only after all uploads are done
        let dispatchGroup = DispatchGroup()
        
        for event in events {
            dispatchGroup.enter() // Start tracking an operation
            
            var updatedEvent = event
            if let organizerID = event[K.FStore.Events.organizerID] as? String {
                updatedEvent[K.FStore.Events.organizerID] = idMappings[organizerID] ?? organizerID
            }
            
            if let startDate = event[K.FStore.Events.startTimeStamp] as? String {
                updatedEvent[K.FStore.Events.startTimeStamp] = K.DFormatter.date(from: startDate)!
            }
            
            if let endDate = event[K.FStore.Events.endTimeStamp] as? String {
                updatedEvent[K.FStore.Events.endTimeStamp] = K.DFormatter.date(from: endDate)!
            }
            
            if let categoryID = event[K.FStore.Events.categoryID] as? String {
                updatedEvent[K.FStore.Events.categoryID] = idMappings[categoryID] ?? categoryID
            }
            
            let ref = db.collection(K.FStore.Events.collectionName).addDocument(data: updatedEvent) { error in
                if let error = error {
                    print("Error uploading event: \(error.localizedDescription)")
                } else {
                    print("Successfully uploaded an event.")
                }
            }
            
            ref.getDocument { (document, error) in
                if let documentID = document?.documentID {
                    ref.updateData([K.FStore.Events.eventID: documentID])
                    let oldUserID = event[K.FStore.Events.eventID] as? String ?? ""
                    self.idMappings[oldUserID] = documentID // Mapping the old userID to the new document ID
                }
                
                dispatchGroup.leave() // Finish tracking this operation
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion() // Ensure completion is called only after all uploads are finished
        }
    }
    
    // Method to upload Tickets and update references
    static private func uploadTickets(json: [String: Any], completion: @escaping () -> Void) {
        guard let tickets = json["tickets"] as? [[String: Any]] else {
            print("No tickets data found.")
            completion()
            return
        }
        
        // Ensure completion is called only after all uploads are done
        let dispatchGroup = DispatchGroup()
        
        for ticket in tickets {
            dispatchGroup.enter() // Start tracking an operation
            
            var updatedTicket = ticket
            if let eventID = ticket[K.FStore.Tickets.eventID] as? String {
                updatedTicket[K.FStore.Tickets.eventID] = idMappings[eventID] ?? eventID
            }
            
            if let organizerID = ticket[K.FStore.Tickets.organizerID] as? String {
                updatedTicket[K.FStore.Tickets.organizerID] = idMappings[organizerID] ?? organizerID
            }
            
            if let customerID = ticket[K.FStore.Tickets.customerID] as? String {
                updatedTicket[K.FStore.Tickets.customerID] = idMappings[customerID] ?? customerID
            }
            
            let ref = db.collection(K.FStore.Tickets.collectionName).addDocument(data: updatedTicket) { error in
                if let error = error {
                    print("Error uploading ticket: \(error.localizedDescription)")
                } else {
                    print("Successfully uploaded a ticket.")
                }
            }
            
            ref.getDocument { (document, error) in
                if let documentID = document?.documentID {
                    ref.updateData([K.FStore.Tickets.ticketID: documentID])
                    let oldUserID = ticket[K.FStore.Tickets.ticketID] as? String ?? ""
                    self.idMappings[oldUserID] = documentID // Mapping the old userID to the new document ID
                }
                
                dispatchGroup.leave() // Finish tracking this operation
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion() // Ensure completion is called only after all uploads are finished
        }
    }
    
    // Method to upload Ratings and update references
    static private func uploadUserBans(json: [String: Any], completion: @escaping () -> Void) {
        guard let userBans = json["userBans"] as? [[String: Any]] else {
            print("No user bans data found.")
            completion()
            return
        }
        
        // Create a DispatchGroup to track async operations
        let dispatchGroup = DispatchGroup()
        
        for userBan in userBans {
            dispatchGroup.enter() // Start tracking an operation
            
            var updatedUserBan = userBan
            if let userID = userBan["userID"] as? String {
                updatedUserBan["userID"] = idMappings[userID] ?? userID
            }
            
            if let adminID = userBan["adminID"] as? String {
                updatedUserBan["adminID"] = idMappings[adminID] ?? adminID
            }
            
            if let startDate = userBan[K.FStore.UserBans.startDate] as? String {
                updatedUserBan[K.FStore.UserBans.startDate] = K.DFormatter.date(from: startDate)!
            }
            
            if let endDate = userBan[K.FStore.UserBans.endDate] as? String {
                updatedUserBan[K.FStore.UserBans.endDate] = K.DFormatter.date(from: endDate)!
            }
            
            
            db.collection(K.FStore.UserBans.collectionName).addDocument(data: updatedUserBan) { error in
                if let error = error {
                    print("Error uploading user ban: \(error.localizedDescription)")
                } else {
                    print("Successfully uploaded a user ban.")
                }
            }
            
            dispatchGroup.leave() // Finish tracking this operation
            
        }
        
        // Notify when all operations are complete
        dispatchGroup.notify(queue: .main) {
            completion() // Call completion after all uploads are finished
        }
    }
    
    // Method to upload Badges and update references
    static private func uploadBadges(json: [String: Any], completion: @escaping () -> Void) {
        guard let badges = json["badges"] as? [[String: Any]] else {
            print("No badges data found.")
            completion()
            return
        }
        
        // Create a DispatchGroup to track async operations
        let dispatchGroup = DispatchGroup()
        
        for badge in badges {
            dispatchGroup.enter() // Start tracking an operation
            
            var updatedBadge = badge
            if let eventID = badge["eventID"] as? String {
                updatedBadge["eventID"] = idMappings[eventID] ?? eventID
            }
            
            if let categoryID = badge[K.FStore.Badges.categoryID] as? String {
                updatedBadge[K.FStore.Events.categoryID] = idMappings[categoryID] ?? categoryID
            }
            
            let ref = db.collection(K.FStore.Badges.collectionName).addDocument(data: updatedBadge) { error in
                if let error = error {
                    print("Error uploading badge: \(error.localizedDescription)")
                } else {
                    print("Successfully uploaded a badge.")
                }
            }
            
            ref.getDocument { (document, error) in
                if let documentID = document?.documentID {
                    ref.updateData([K.FStore.Badges.badgeID: documentID])
                    let oldUserID = badge[K.FStore.Badges.badgeID] as? String ?? ""
                    self.idMappings[oldUserID] = documentID // Mapping the old userID to the new document ID
                }
                dispatchGroup.leave() // Finish tracking this operation
            }
        }
        
        // Notify when all operations are complete
        dispatchGroup.notify(queue: .main) {
            completion() // Call completion after all uploads are finished
        }
    }
    
    // Method to upload EventBans and update references
    static private func uploadEventBans(json: [String: Any], completion: @escaping () -> Void) {
        guard let eventBans = json["eventBans"] as? [[String: Any]] else {
            print("No event bans data found.")
            completion()
            return
        }
        
        // Create a DispatchGroup to track async operations
        let dispatchGroup = DispatchGroup()
        
        for eventBan in eventBans {
            dispatchGroup.enter() // Start tracking an operation
            
            var updatedEventBan = eventBan
            if let eventID = eventBan["eventID"] as? String {
                updatedEventBan["eventID"] = idMappings[eventID] ?? eventID
            }
            
            if let organizerID = eventBan["organizerID"] as? String {
                updatedEventBan["organizerID"] = idMappings[organizerID] ?? organizerID
            }
            
            if let adminID = eventBan["adminID"] as? String {
                updatedEventBan["adminID"] = idMappings[adminID] ?? adminID
            }
            
            db.collection(K.FStore.EventBans.collectionName).addDocument(data: updatedEventBan) { error in
                if let error = error {
                    print("Error uploading event ban: \(error.localizedDescription)")
                } else {
                    print("Successfully uploaded an event ban.")
                }
            }
            
            
            dispatchGroup.leave() // Finish tracking this operation
            
        }
        
        // Notify when all operations are complete
        dispatchGroup.notify(queue: .main) {
            completion() // Call completion after all uploads are finished
        }
    }
    
    static private func uploadRatings(json: [String: Any], completion: @escaping () -> Void) {
        guard let ratings = json["ratings"] as? [[String: Any]] else {
            print("No ratings data found.")
            completion()
            return
        }
        
        // Create a DispatchGroup to track async operations
        let dispatchGroup = DispatchGroup()
        
        for rating in ratings {
            dispatchGroup.enter() // Start tracking an operation
            
            var updatedRating = rating
            if let eventID = rating["eventID"] as? String {
                updatedRating["eventID"] = idMappings[eventID] ?? eventID
            }
            
            if let userID = rating["userID"] as? String {
                updatedRating["userID"] = idMappings[userID] ?? userID
            }
            
            if let organizerID = rating["organizerID"] as? String {
                updatedRating["organizerID"] = idMappings[organizerID] ?? organizerID
            }
            
            db.collection(K.FStore.Ratings.collectionName).document("\(updatedRating["eventID"]!)\(updatedRating["userID"]!)").setData(updatedRating) { error in
                if let error = error {
                    print("Error uploading rating: \(error.localizedDescription)")
                } else {
                    print("Successfully uploaded a rating.")
                }
                
                dispatchGroup.leave() // Finish tracking this operation
            }
        }
        
        // Notify when all operations are complete
        dispatchGroup.notify(queue: .main) {
            completion() // Call completion after all uploads are finished
        }
    }
    
    // Method to upload FAQs
    static private func uploadFAQs(json: [String: Any]) {
        guard let faqs = json["faqs"] as? [[String: Any]] else {
            print("No FAQs data found.")
            return
        }
        
        for faq in faqs {
            if let userType = faq["userType"] as? String {
                var updatedFAQ = faq
                updatedFAQ["userType"] = userType
                
                let ref = db.collection(K.FStore.FAQs.collectionName).addDocument(data: updatedFAQ) { error in
                    if let error = error {
                        print("Error uploading FAQ: \(error.localizedDescription)")
                    } else {
                        print("Successfully uploaded a FAQ.")
                    }
                }
                ref.getDocument { (document, error) in
                    if let documentID = document?.documentID {
                        ref.updateData([K.FStore.FAQs.faqID: documentID])
                        let oldUserID = faq[K.FStore.FAQs.faqID] as? String ?? ""
                        self.idMappings[oldUserID] = documentID // Mapping the old userID to the new document ID
                    }
                }
            }
        }
    }
}
