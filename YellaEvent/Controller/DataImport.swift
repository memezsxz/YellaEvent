//
//  DataImport.swift
//  YellaEvent
//
//  Created by meme on 13/12/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

final class DataImport {
    static private var idMappings: [String: String] = [:] // Stores mappings for all referenced IDs (userID, eventID, badgeID, etc.)
    static private let db = Firestore.firestore()
    static private let storage = Storage.storage()
    
    static private func uploadImage(localPath: String, storagePath: String, completion: @escaping (String?) -> Void) {
        guard let imageData = FileManager.default.contents(atPath: localPath) else {
            print("Image not found at path: \(localPath)")
            completion(nil)
            return
        }
        
        let storageRef = Storage.storage().reference().child(storagePath)
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                completion(nil)
            } else {
                storageRef.downloadURL { url, error in
                    if let error = error {
                        print("Error getting image URL: \(error.localizedDescription)")
                        completion(nil)
                    } else if let url = url {
                        completion(url.absoluteString)
                    }
                }
            }
        }
    }
    
    static func uploadData() {
        // Locate the JSON file in the app bundle
        guard let path = Bundle.main.path(forResource: "file2", ofType: "json") else {
            print("JSON file not found.")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        
        do {
            // Read the JSON file
            let data = try Data(contentsOf: url)
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                // Start uploading collections in the correct order
//                uploadAdmins(json: json) {
                    self.uploadOrganizers(json: json) {
                        //                        self.uploadCategories(json: json) {
                        //                            self.uploadEvents(json: json) {
                        //                                self.uploadBadges(json: json) {
                        //                                    self.uploadCustomers(json: json) {
                        //                                        self.uploadRatings(json: json) {
                        //                                            self.uploadTickets(json: json) {
                        //                                                self.uploadUserBans(json: json) {
                        //                                                    self.uploadEventBans(json: json) {
                        //                                                        self.uploadFAQs(json: json)
                        //                                                    }
                        //                                                }
                        //                                            }
                        //                                        }
                        //                                    }
                        //                                }
                        //                            }
                        //                        }
                    }
//                }
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
            
            Auth.auth().createUser(withEmail: admin[K.FStore.User.email] as! String, password: "123456") { result, error in
                guard let user = result?.user else {
                    if let error {
                        print("Error creating user: \(error.localizedDescription)")
                    }
                    return
                }
                
                let oldUserID = admin[K.FStore.User.userID] as? String ?? ""
                
                self.idMappings[oldUserID] = user.uid // Mapping the old userID to the new document ID
                updatedAdmin[K.FStore.User.userID] = user.uid
                
                db.collection(K.FStore.Admins.collectionName).document(user.uid).setData(updatedAdmin) { error in
                    if let localImagePath = updatedAdmin[K.FStore.User.profileImageURL] as? String {
                        let storagePath = "admins/\(user.uid)/profile.jpg"
                        uploadImage(localPath: localImagePath, storagePath: storagePath) { imageUrl in
                            if let imageUrl = imageUrl {
                                updatedAdmin[K.FStore.User.profileImageURL] = imageUrl
                                db.collection(K.FStore.Admins.collectionName).document(user.uid).updateData([K.FStore.User.profileImageURL: imageUrl])
                                print("Admin uploaded with ID: \(user.uid)")
                            }
                        }
                        
                    } else {
                        print("Admin uploaded with ID: \(user.uid) and no profile photo URL.")
                    }
                }
            }
            
            //            let ref = db.collection(K.FStore.Admins.collectionName).addDocument(data: updatedAdmin) { error in
            //                if let error = error {
            //                    print("Error uploading admin: \(error.localizedDescription)")
            //                } else {
            //                    print("Successfully uploaded an admin.")
            //                }
            //            }
            //
            //            ref.getDocument { (document, error) in
            //                if let documentID = document?.documentID {
            //                    ref.updateData([K.FStore.User.userID: documentID])
            //                    let oldUserID = admin[K.FStore.User.userID] as? String ?? ""
            //                    self.idMappings[oldUserID] = documentID // Mapping the old userID to the new document ID
            //
            //                    if let localImagePath = updatedAdmin[K.FStore.User.profileImageURL] as? String {
            //                        let storagePath = "admins/\(documentID)/profile.jpg"
            //                        uploadImage(localPath: localImagePath, storagePath: storagePath) { imageUrl in
            //                            if let imageUrl = imageUrl {
            //                                updatedAdmin[K.FStore.User.profileImageURL] = imageUrl
            //                                ref.updateData([K.FStore.User.profileImageURL: imageUrl])
            //                            }
            //                        }
            //
            //                    } else {
            //                        print("Admin uploaded with ID: \(documentID) and no profile photo URL.")
            //                    }
            //                }
            //            }
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
            
            
            Auth.auth().createUser(withEmail: updatedOrganizer[K.FStore.User.email] as! String, password: "123456") { result, error in
                guard let user = result?.user else {
                    if let error {
                        print("Error creating user: \(error.localizedDescription)")
                    }
                    return
                }
                
                let oldUserID = updatedOrganizer[K.FStore.User.userID] as? String ?? ""
                
                self.idMappings[oldUserID] = user.uid // Mapping the old userID to the new document ID
                
                updatedOrganizer[K.FStore.User.userID] = user.uid
                
                db.collection(K.FStore.Organizers.collectionName).document(user.uid).setData(updatedOrganizer) { error in
                    if let localImagePath = updatedOrganizer[K.FStore.User.profileImageURL] as? String {
                        let storagePath = "organizers/\(user.uid)/Profile.jpg"
                        uploadImage(localPath: localImagePath, storagePath: storagePath) { imageUrl in
                            if let imageUrl = imageUrl {
                                updatedOrganizer[K.FStore.User.profileImageURL] = imageUrl
                                db.collection(K.FStore.Organizers.collectionName).document(user.uid).updateData([K.FStore.User.profileImageURL: imageUrl])
                                print("Organizer uploaded with ID: \(user.uid)")
                            }
                        }
                        
                    } else {
                        print("Organizer uploaded with ID: \(user.uid) and no profile photo URL.")
                    }
                    
                    if let localImagePath = updatedOrganizer[K.FStore.Organizers.LicenseDocumentURL] as? String {
                        let storagePath = "organizers/\(user.uid)/Profile.jpg"
                        uploadImage(localPath: localImagePath, storagePath: storagePath) { imageUrl in
                            if let imageUrl = imageUrl {
                                updatedOrganizer[K.FStore.Organizers.LicenseDocumentURL] = imageUrl
                                db.collection(K.FStore.Organizers.collectionName).document(user.uid).updateData([K.FStore.Organizers.LicenseDocumentURL: imageUrl])
                                print("Organizer uploaded with ID: \(user.uid)")
                            }
                        }
                        
                    } else {
                        print("Organizer uploaded with ID: \(user.uid) and no profile photo URL.")
                    }

                }
            }
            
            dispatchGroup.leave()  // Leave the DispatchGroup after the async task completes
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
            if let badgeIDs = customer[K.FStore.Customers.badgesArray] as? [String] {
                let newBadgeIDs = badgeIDs.compactMap { idMappings[$0] }
                updatedCustomer[K.FStore.Customers.badgesArray] = newBadgeIDs
            }
            
            // Map categoryIDs if present
            if let categoryIDs = customer[K.FStore.Customers.intrestArray] as? [String] {
                let newCategoryIDs = categoryIDs.compactMap { idMappings[$0] }
                updatedCustomer[K.FStore.Customers.intrestArray] = newCategoryIDs
            }
            
            Auth.auth().createUser(withEmail: updatedCustomer[K.FStore.User.email] as! String, password: "123456") { result, error in
                guard let user = result?.user else {
                    if let error {
                        print("Error creating user: \(error.localizedDescription)")
                    }
                    return
                }
                
                let oldUserID = updatedCustomer[K.FStore.User.userID] as? String ?? ""
                
                self.idMappings[oldUserID] = user.uid // Mapping the old userID to the new document ID
                
                updatedCustomer[K.FStore.User.userID] = user.uid
                
                db.collection(K.FStore.Customers.collectionName).document(user.uid).setData(updatedCustomer) { error in
                    if let localImagePath = updatedCustomer[K.FStore.User.profileImageURL] as? String {
                        let storagePath = "customers/\(user.uid)/Profile.jpg"
                        uploadImage(localPath: localImagePath, storagePath: storagePath) { imageUrl in
                            if let imageUrl = imageUrl {
                                updatedCustomer[K.FStore.User.profileImageURL] = imageUrl
                                db.collection(K.FStore.Customers.collectionName).document(user.uid).updateData([K.FStore.User.profileImageURL: imageUrl])
                                print("Customer uploaded with ID: \(user.uid)")
                            }
                        }
                        
                    } else {
                        print("Customer uploaded with ID: \(user.uid) and no profile photo URL.")
                    }
                }
            }
            
            dispatchGroup.leave()  // Leave the DispatchGroup after the async task completes
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
                    
                    if let localImagePath = updatedEvent[K.FStore.Events.coverImageURL] as? String {
                        let storagePath = "events/\(updatedEvent[K.FStore.Events.organizerID] as! String)/\(documentID)/CoverImage.jpg"
                        uploadImage(localPath: localImagePath, storagePath: storagePath) { imageUrl in
                            if let imageUrl = imageUrl {
                                updatedEvent[K.FStore.Events.coverImageURL] = imageUrl
                                ref.updateData([K.FStore.Events.coverImageURL: imageUrl])
                            }
                        }
                    }
                    var mediaArray: [String] = []
                    var i = 0
                    (updatedEvent[K.FStore.Events.mediaArray] as? [String])?.forEach({ localImagePath in
                        let storagePath = "events/\(updatedEvent[K.FStore.Events.organizerID] as! String)/\(documentID)/media\(i).jpg"
                        i += 1
                        uploadImage(localPath: localImagePath, storagePath: storagePath) { imageUrl in
                            if let imageUrl = imageUrl {
                                mediaArray.append( imageUrl)
                                ref.updateData([K.FStore.Events.mediaArray: mediaArray])
                            }
                        }
                        
                    })
                    
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
            if let eventID = badge[K.FStore.Badges.eventID] as? String {
                let oldID = badge[K.FStore.Badges.badgeID] as? String ?? ""
                updatedBadge[K.FStore.Badges.eventID] = idMappings[eventID] ?? eventID
                updatedBadge[K.FStore.Badges.badgeID] = idMappings[eventID] ?? eventID
                self.idMappings[oldID] = idMappings[eventID] ?? eventID
            }
            
            
            if let categoryID = badge[K.FStore.Badges.categoryID] as? String {
                updatedBadge[K.FStore.Events.categoryID] = idMappings[categoryID] ?? categoryID
            }
            
            let ref: Void = db.collection(K.FStore.Badges.collectionName).document(updatedBadge[K.FStore.Badges.badgeID] as! String).setData(updatedBadge) { error in
                if let error = error {
                    print("Error uploading badge: \(error.localizedDescription)")
                } else {
                    if let localImagePath = updatedBadge[K.FStore.Badges.image] as? String {
                        let storagePath = "events/\(updatedBadge[K.FStore.Badges.eventID] as! String)/Badge.jpg"
                        uploadImage(localPath: localImagePath, storagePath: storagePath) { imageUrl in
                            if let imageUrl = imageUrl {
                                updatedBadge[K.FStore.Badges.image] = imageUrl
                                db.collection(K.FStore.Badges.collectionName).document(updatedBadge[K.FStore.Badges.badgeID] as! String).updateData([K.FStore.Badges.image: imageUrl])
                            }
                        }
                    }
                    print("Successfully uploaded a badge.")
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
            if let eventID = rating[K.FStore.Ratings.eventID] as? String {
                updatedRating[K.FStore.Ratings.eventID] = idMappings[eventID] ?? eventID
            }
            
            if let userID = rating[K.FStore.Ratings.customerID] as? String {
                updatedRating[K.FStore.Ratings.customerID] = idMappings[userID] ?? userID
            }
            
            if let organizerID = rating[K.FStore.Ratings.organizerID] as? String {
                updatedRating[K.FStore.Ratings.organizerID] = idMappings[organizerID] ?? organizerID
            }
            
            db.collection(K.FStore.Ratings.collectionName).addDocument(data: updatedRating) { error in
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
