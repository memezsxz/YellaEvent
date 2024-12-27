//
//  CustomerBadgesViewController.swift
//  YellaEvent
//
//  Created by Noorcurlyfries on 27/12/2024.
//

import UIKit

class CustomerBadgesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet var collectionView: UICollectionView!
    
    var badges: [Badge?] = [] // Array to hold optional Badge data
    var userID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self

        // Setup the collection view layout
        collectionView.collectionViewLayout = generateGridLayout()
        
        collectionView.register(UINib(nibName: "BadgeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BadgeCollectionViewCell")
        
        // Show placeholder cells
        loadPlaceholders()
        
        // Fetch badges using Task Groups
        loadBadges()
    }
    
    func loadPlaceholders() {
        // Add placeholder items to the badges array (e.g., 10 empty slots)
        badges = Array(repeating: nil, count: 10)
        collectionView.reloadData()
    }
    
    func loadBadges() {
        Task {
            do {
                // Fetch customer using userID
                let customer = try await UsersManager.getCustomer(customerID: userID)
                
                // Update the badges array size to match the number of badges
                DispatchQueue.main.async {
                    self.badges = Array(repeating: nil, count: customer.badgesArray.count)
                    self.collectionView.reloadData()
                }
                
                // Fetch badges concurrently using Task Groups
                let fetchedBadges = try await fetchBadgesConcurrently(badgeIDs: customer.badgesArray)
                
                // Update the badges array with the fetched data
                for (index, badge) in fetchedBadges.enumerated() {
                    DispatchQueue.main.async {
                        self.badges[index] = badge
                        // Reload individual cell to update the placeholder
                        let indexPath = IndexPath(item: index, section: 0)
                        self.collectionView.reloadItems(at: [indexPath])
                    }
                }
            } catch {
                print("Failed to load badges: \(error.localizedDescription)")
            }
        }
    }

    func fetchBadgesConcurrently(badgeIDs: [String]) async throws -> [Badge] {
        return try await withTaskGroup(of: Badge?.self) { group in
            // Add tasks for each badge ID
            for badgeID in badgeIDs {
                group.addTask {
                    try? await BadgesManager.getBadge(eventID: badgeID)
                }
            }
            
            // Collect all results
            var results: [Badge] = []
            for await badge in group {
                if let badge = badge {
                    results.append(badge)
                }
            }
            return results
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return badges.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BadgeCollectionViewCell", for: indexPath) as! BadgeCollectionViewCell
        
        if let badge = badges[indexPath.row] {
            // Update cell with actual badge data
            cell.update(with: badge)
        } else {
            // Show placeholder cell
            cell.showPlaceholder()
        }
        
        return cell
    }

    func generateGridLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()

        // Define the spacing between items and rows
        let spacing: CGFloat = 10
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing

        // Define the size of the cells
        let numberOfItemsPerRow: CGFloat = 2
        let totalSpacing = spacing * (numberOfItemsPerRow + 1)
        let itemWidth = (UIScreen.main.bounds.width - totalSpacing) / numberOfItemsPerRow

        layout.itemSize = CGSize(width: itemWidth, height: itemWidth + itemWidth / 8)
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)

        return layout
    }
}
