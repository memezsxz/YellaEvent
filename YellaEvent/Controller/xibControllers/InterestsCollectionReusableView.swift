//
//  InterestsCollectionReusableView.swift
//  YellaEvent
//
//  Created by meme on 05/12/2024.
//

import UIKit

class InterestsCollectionReusableView: UICollectionReusableView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource,
    UICollectionViewDelegate{
    // Collection view reference
    @IBOutlet weak var collectionView: UICollectionView!
    
    // Categories data array
    var categories = [Category]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Setup collection view
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Fetch categories from Firestore
        Task {
         try await   CategoriesManager.getAllCategories { snapshot, error in
//                guard let snapshot = snapshot, error == nil else {
//                    print("Error fetching categories: \(error?.localizedDescription ?? "Unknown error")")
//                    return
//                }
//                
                // Decode documents into Category objects
             self.categories = snapshot!.documents.compactMap {
                 
                 print("Categories: \(self.categories)")

                 return try? $0.data(as: Category.self)
             }
                
                // Reload collection view data on the main thread
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }

        }
    }
    
    // MARK: - UICollectionView DataSource Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Dequeue the reusable cell
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "InterestsCollectionViewCell",
            for: indexPath
        ) as? InterestsCollectionViewCell else {
            fatalError("Unable to dequeue CategoryCollectionViewCell.")
        }
        
        // Configure the cell
        let category = categories[indexPath.item]
        cell.label.titleLabel?.text = category.name + " " + category.icon
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout Methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = categories[indexPath.item]
        
        // Calculate width (example: half-width with padding)
        let width = (collectionView.bounds.width - 30) / 2
        
        // Calculate height dynamically based on content
        let height = calculateHeight(for: item, width: width)
        
        return CGSize(width: width, height: height)
    }
    
    private func calculateHeight(for item: Category, width: CGFloat) -> CGFloat {
        // Example: Create a dummy label to measure height
        let dummyLabel = UILabel()
        dummyLabel.text = item.name
        dummyLabel.numberOfLines = 0
        dummyLabel.lineBreakMode = .byWordWrapping
        dummyLabel.font = UIFont.systemFont(ofSize: 16)
        dummyLabel.frame = CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude)
        dummyLabel.sizeToFit()
        
        return dummyLabel.frame.height + 20 // Add padding
    }
}

