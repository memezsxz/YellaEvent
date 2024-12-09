//
//  Storage.swift
//  YellaEvent
//
//  Created by meme on 30/11/2024.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore

final class PhotoManager {
    static let shared = PhotoManager()

    private let storage = Storage.storage()
    private let firestore = Firestore.firestore()
    
    private init() {}
    
    // need to add throws to all methods for handelling
    
    func fetchPhoto(fromDocument documentID: String,
                    inCollection collectionPath: String,
                    fieldName: String,
                    completion: @escaping (Result<UIImage, Error>) -> Void) {

        let documentRef = firestore.collection(collectionPath).document(documentID)
        
        documentRef.getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists else {
                completion(.failure(NSError(domain: "PhotoManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Document does not exist."])))
                return
            }
            
            // Retrieve the image URL from the specified field
            if let imageUrlString = document.get(fieldName) as? String,
               let imageUrl = URL(string: imageUrlString) {
                self.downloadImage(from: imageUrl, completion: completion)
            } else {
                completion(.failure(NSError(domain: "PhotoManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid or missing URL in Firestore document."])))
            }
        }
    }
    
    public func downloadImage(from url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
        let storageRef = storage.reference(forURL: url.absoluteString)
        
        storageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                completion(.success(image))
            } else {
                completion(.failure(NSError(domain: "PhotoManager", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to convert data to UIImage."])))
            }
        }
    }

    // the result string is the download url
    func uploadPhoto(
        _ image: UIImage,
        to storagePath: String,
        withNewName newName: String? = nil,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let fileName: String
        if let newName = newName {
            fileName = newName
        } else {
            fileName = UUID().uuidString
        }

        let newStoragePath = "\(storagePath)/\(fileName).jpg"

        guard let imageData = image.jpegData(compressionQuality: 0.1) else {
            let error = NSError(domain: "PhotoManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to convert UIImage to JPEG data."])
            completion(.failure(error))
            return
        }

        let storageRef = storage.reference().child(newStoragePath)
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let url = url {
                    completion(.success(url.absoluteString))
                } else {
                    let error = NSError(domain: "PhotoManager", code: 500, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred while generating download URL."])
                    completion(.failure(error))
                }
            }
        }
    }

//    func uploadPhotoAndSaveURL(_ image: UIImage,
//                                   toStoragePath storagePath: String,
//                                   firestoreCollectionPath firestorePath: String,
//                                   documentID: String,
//                                   fieldName: String,
//                                   completion: @escaping (Result<Void, Error>) -> Void) {
//            uploadPhoto(image, to: storagePath) { result in
//                switch result {
//                case .success(let downloadURL):
//                    let documentRef = self.firestore.collection(firestorePath).document(documentID)
//                    documentRef.updateData([fieldName: downloadURL]) { error in
//                        if let error = error {
//                            completion(.failure(error))
//                        } else {
//                            completion(.success(()))
//                        }
//                    }
//                case .failure(let error):
//                    completion(.failure(error))
//                }
//            }
//        }
}
