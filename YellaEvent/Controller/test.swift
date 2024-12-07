//
//  AuthenticationViewController.swift
//  YellaEvent
//
//  Created by meme on 25/11/2024.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import Firebase
import FirebaseStorage
import UniformTypeIdentifiers

class test: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventSummaryTableViewCell", for: indexPath) as! EventSummaryTableViewCell
        //        cell.convert(event)
        cell.setup(with: events[indexPath.row])
//        print("cell")
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  tableView.frame.width / 2
    }
    //    let formatter = ISO8601DateFormatter()
    //    //
    //    //    let manager =         UsersManager()
    let db = Firestore.firestore()
    //
    //    @IBOutlet weak var photo: UIImageView!
    //    let dateFormatter : DateFormatter = {
    //        let formatter = DateFormatter()
    //        formatter.dateFormat = "yyyy-MM-dd"
    //        return formatter
    //    }()
    //
    //    let imagePicker = UIImagePickerController()
    //    var selectedImage: UIImage?
    //
    var events : [EventSummary] = []
    
    
    
    override func viewDidLoad()  {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "EventSummaryTableViewCell", bundle: .main), forCellReuseIdentifier: "EventSummaryTableViewCell")
        //        Task {
        //            EventsManager.getInstence().getAllEvents(listener: { snapshot, error in
        //                guard let snapshot else { return }
        //                self.events = []
        //                for doc in snapshot.documents {
        //                    do {
        //                        self.events.append(try doc.data(as: Event.self))
        //                    } catch {
        //                        print(error)
        //                    }
        //                }
        //                DispatchQueue.main.async {
        ////                    print(self.events)
        //                    print("self.events")
        //                    self.tableView.reloadData()
        //                }
        //            })
        
        
        //            try await UsersManager
        
        //        }
        
        //                Task {
        //                            try await EventsManager.createNewEvent(event: Event(organizerID: "212``2", organizerName: "dsfngf", name: "event name sample", description: "WARNING: All log messages before absl::InitializeLog() is called are written to STDERR I0000 00:00:1733511573.674274  681235 config.cc:230] gRPC experiments enabled: call_status_override_on_cancellation, http2_stats_fix, monitoring_experiment, pick_first_new, trace_record_callops, work_serializer_clears_time_cache", startTimeStamp: Date.now, endTimeStamp: Date.now, status: .ongoing, categoryID: "eXJFsGAC8odTjj74FYxP", categoryName: "Music", categoryIcon: "🎵", locationURL: "location", minimumAge: 1123, maximumAge: 31213, rattingsArray: [:], maximumTickets: 321, price: 32.23, coverImageURL: "https://firebasestorage.googleapis.com/v0/b/yellaevent.firebasestorage.app/o/lN1LrxyBfnNjr45KRmz5VPc4cw13%2FProfile.jpg?alt=media&token=14905f26-66a5-41cb-9bda-77ab6a7bcb74", mediaArray: []))
        //
        //                                    try await EventsManager.createNewEvent(event: Event(organizerID: "event 2", organizerName: "dsfngf", name: "final hope", description: "descreption", startTimeStamp: Date.now, endTimeStamp: Date.now, status: .ongoing, categoryID: "l6QT2ZIphKNnSDNcee1v", categoryName: "Art", categoryIcon: "🎨", locationURL: "location", minimumAge: 12, maximumAge: 12, rattingsArray: [:], maximumTickets: 321, price: 3.23, coverImageURL: "https://firebasestorage.googleapis.com/v0/b/yellaevent.firebasestorage.app/o/lN1LrxyBfnNjr45KRmz5VPc4cw13%2FProfile.jpg?alt=media&token=14905f26-66a5-41cb-9bda-77ab6a7bcb74", mediaArray: []))
        //                }
        //
        
        //        Task {
        //        try await    TicketsManager.createNewTicket(ticket: Ticket(eventID: "2GZvRmpKp47kFThJ5dVj", userID: "sdfsd", eventName: "event name sample", organizerName: "dsfngf", startTimeStamp: Date.now, didAttend: false, totalPrice: 12.12, locationURL: "sadsd", quantity: 2))
        //           try await EventsManager.updateEventsCategory(category: Category(documentID: "2GZvRmpKp47kFThJ5dVj")!)
        
        //            try await BadgesManager.createNewBadge(badge: Badge(image: "fdefwfwe", eventID: "2GZvRmpKp47kFThJ5dVj", eventName: "event name sample", catigoryName: "Music", catigoryIcon: "🎵"))
        //            try await CategoriesManager.updateCategorie(category: Category(categoryID: "eXJFsGAC8odTjj74FYxP", name: "Songs", icon: "🎵", isActive: true))
        //        }
        
//        Task {
//            let cat = Category(name: "Education", icon: "✏️", status: .enabled)
//            try await CategoriesManager.createNewCategory(category: cat)
//
//            try await EventsManager.createNewEvent(event:
//            Event(organizerID: "212``2", organizerName: "dsfngf", name: "test 121", description: "safafafa safas fas fa", startTimeStamp: Date.now, endTimeStamp: Date.now, status: .ongoing, category: CategoriesManager.getCategory(categorieID: "nb9swHtZ6rZ5NTTc8oYl"), locationURL: "dasda dsa", minimumAge: 21, maximumAge: 324, rattingsArray: [:], maximumTickets: 123, price: 15.3, coverImageURL: "https://firebasestorage.googleapis.com/v0/b/yellaevent.firebasestorage.app/o/lN1LrxyBfnNjr45KRmz5VPc4cw13%2FProfile.jpg?alt=media&token=14905f26-66a5-41cb-9bda-77ab6a7bcb74", mediaArray: []))
            
//           try await BadgesManager.createNewBadge(badge: Badge(image: "sadsa", eventID: "Y3tLzfy1kdb27If4f1KG", eventName: "test 121", category: CategoriesManager.getCategory(categorieID: "nb9swHtZ6rZ5NTTc8oYl")))
     
//            try await TicketsManager.createNewTicket(ticket: Ticket(eventID: "Y3tLzfy1kdb27If4f1KG", userID: "sdfsd", eventName: "test 121", organizerName: "dsfngf", startTimeStamp: Date.now, didAttend: false, totalPrice: 12.6, locationURL: "sffssfffs", quantity: 12))

//        }
        
//        Task {
//           var event = try await EventsManager.getEvent(eventID: "Y3tLzfy1kdb27If4f1KG")
////            event.startTimeStamp = Date.now
//            event.category = try await CategoriesManager.getCategory(categorieID: "IAghDlatAhV2HHce4BXH")
//           try await EventsManager.updateEvent(event: event)
//        }
//        
        EventsManager.getAllEvents { snapshot, error in
            guard error == nil else { return }
            
            if let snapshot {
                self.events = []
                Task {
                    for doc in snapshot.documents {
                        do {
                            let event = try await EventSummary(from: doc.data())
                            self.events.append(event)
                        } catch {
                            print("Error converting event: \(error)")
                        }
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }

        
        
        
        
        //        if UserDefaults.standard.string(forKey: "dev.maryam.yellaevent.userid") == nil {
        //            Auth.auth().signIn(withEmail: "retyyu@fxdscdsgfgdsdxzgx.com", password: "pxzcass2102") { [weak self] authResult, error in
        //                guard let strongSelf = self else { return }
        //
        //                UserDefaults.standard.set("\(String(describing: authResult?.user.uid)) \(Int.random(in: 1...100)))", forKey: "dev.maryam.yellaevent.userid")
        //
        //                self!.ju.text = "\(UserDefaults.standard.string(forKey: "dev.maryam.yellaevent.userid")!)"
        //
        //            }
        //        } else {
        //            ju.text = "\(UserDefaults.standard.string(forKey: "dev.maryam.yellaevent.userid")!)"
        //
        //        }
        
        
        //        Auth.auth().signIn(withEmail: "retyyu@fxdscdsgfgdsdxzgx.com", password: "pxzcass2102") { [weak self] authResult, error in
        //          guard let strongSelf = self else { return }
        //            if var infoDictionary = Bundle.main.infoDictionary {
        //                infoDictionary["User ID"] = authResult?.user.uid
        //                print(infoDictionary["User ID"])
        //            }
        
        //                   if error != nil {
        //                       print(error?.localizedDescription)
        //                   } else {
        //                       self.db.collection(K.FStore.Users.collectionName).addDocument(data:
        //                       [
        //                           K.FStore.Users.id : authResult!.user.uid,
        //                           K.FStore.Users.firstName : "FirstName",
        //                           K.FStore.Users.lastName : "LastName",
        //                           K.FStore.Users.phoneNumber : "+380999999999",
        //                           K.FStore.Users.badgesArray : [Badge](),
        //                           K.FStore.Users.dob : Date.now,
        //                           K.FStore.Users.email : authResult!.user.email,
        //                           K.FStore.Users.type : "Customer",
        //                       ]
        //                       )
        //                   }
        //               }
        //
        //        UsersManager().fetchUsers { result in
        //            switch result {
        //            case .success(let users):
        //                print("Fetched \(users.count) users")
        //                for user in users {
        //                    print("User ID: \(user.id ?? "N/A") - \(user.firstName) \(user.lastName)")
        //                }
        //
        //            case .failure(let error):
        //                print("Error fetching users: \(error.localizedDescription)")
        //            }
        //        }
        //
        //        //        print(db)
        //        //        Task(operation: manager.getMultipleAll)
        //
        ////        Auth.auth().createUser(withEmail: "saas@tdssasest.com", password: "pass2102") { authResult, error in
        ////            if error != nil {
        ////                print(error?.localizedDescription)
        ////            } else {
        ////                self.db.collection(K.FStore.Users.collectionName).addDocument(data:
        ////                [
        ////                    K.FStore.Users.id : authResult!.user.uid,
        ////                    K.FStore.Users.firstName : "FirstName",
        ////                    K.FStore.Users.lastName : "LastName",
        ////                    K.FStore.Users.phoneNumber : "+380999999999",
        ////                    K.FStore.Users.dob : Date.now,
        ////                    K.FStore.Users.type : "Customer",
        ////
        ////
        ////                ]
        ////                )
        ////            }
        ////        }
        
        //        let users = [User]()
        //        let org = [User]()
        //
        //        db.collection(K.FStore.Users.collectionName).addSnapshotListener {
        //            snapshot, error in
        //            guard error == nil else {return}
        //
        //            if snapshot?.documents.isEmpty ?? true {return}
        
        //            for doc in snapshot!.documents {
        //                Task {
        //                    let user =   try doc.data(as: User.self) as User
        //                    switch (user.type) {
        //                    case .admin:
        //
        //                    case .customer:
        //
        //                    case .organizer:
        //                        org.append(user)
        //                    }
        //                }
        //
        //            }
        //        }
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    @IBAction func joinusclicked(_ sender: UIButton) {
        
        //        presentImagePicker()
        
        
        
        //        Auth.auth().createUser(withEmail: "retyyu@fxdscdsgfgdsdxzgx.com", password: "pxzcass2102") { authResult, error in
        //            guard error == nil  else {
        //                print(error!.localizedDescription)
        //                return
        //            }
        //
        //            Task() {
        //
        //                do {
        //                    try await UserManager.getInstence().createNewUser(
        //
        //                        user: User(id: "\(authResult!.user.uid)", firstName: "firestname", lastName: "fsdf", email: authResult!.user.email!,dob: Date.now, dateCreated:  Date.now, phoneNumber: 12231312, badgesArray: [Badge](), type: .organizer)
        //
        //
        //                    )
        //                        } catch {
        //                            print ("error")
        //                        }
        //
        //
        //
        //                }}
        
        
        
        
    }
    
    
    //    private func presentImagePicker() {
    //        imagePicker.delegate = self
    //        imagePicker.sourceType = .photoLibrary // Or .camera for capturing photos
    //        present(imagePicker, animated: true, completion: nil)
    //    }
    
    
    //    @IBAction func loginclicked(_ sender: UIButton) {
    //
    //    }
}

//extension test: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//
//        picker.dismiss(animated: true, completion: nil)
//
//        if let image = info[.originalImage] as? UIImage {
//            self.selectedImage = image
//            uploadImageToFirebase(image: image)
//        }
//    }
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        // Handle the user canceling the image picker, if needed.
//        dismiss(animated: true, completion: nil)
//    }
//
//    func uploadImageToFirebase(image: UIImage) {
//        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
//            print("Failed to convert image to data.")
//            return
//        }
//
//        // Create a unique filename
//        //        let uniqueFileName = UUID().uuidString
//        //        let storageRef = Storage.storage().reference().child("images/\(uniqueFileName).jpg")
//        //
//        //        // Upload the image
//        //        storageRef.putData(imageData, metadata: nil) { metadata, error in
//        //            if let error = error {
//        //                print("Error uploading image: \(error.localizedDescription)")
//        //                return
//        //            }
//
//        // Get the download URL
//        //            storageRef.downloadURL { url, error in
//        //                if let error = error {
//        //                    print("Error getting download URL: \(error.localizedDescription)")
//        //                } else if let url = url {
//        //                    let reff = self.db.collection("test").addDocument(data: ["image": url.absoluteString])
//        //
//        //                    let ref = Firestore.firestore().collection("test").document(reff.documentID)
//        //
//        //
//        //                    PhotoManager.shared.fetchPhoto(fromDocument: reff.documentID, inCollection: "test", fieldName: "image") { result in
//        //                        DispatchQueue.main.async {
//        //                            switch result {
//        //                            case .success(let image):
//        //                                self.photo.image = image
//        //                            case .failure(let error):
//        //                                print("Error fetching image: \(error.localizedDescription)")
//        //                            }
//        //                        }
//        //                    }
//        //                }                    // Fetch the document
//        //                print("Image uploaded successfully. Download URL: \(url)")
//        //            }
//
//    }
//
//
//}
//


