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

class test: UIViewController {
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
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        let users = [User]()
        let org = [User]()

        db.collection(K.FStore.Users.collectionName).addSnapshotListener {
            snapshot, error in
            guard error == nil else {return}
            
//            if snapshot?.documents.isEmpty ?? true {return}
            
            for doc in snapshot!.documents {
                Task {
                    let user =   try doc.data(as: User.self) as User
//                    switch (user.type) {
//                    case .admin:
//                        
//                    case .customer:
//                        
//                    case .organizer:
//                        org.append(user)
//                    }

                }
                
            }
        }
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


