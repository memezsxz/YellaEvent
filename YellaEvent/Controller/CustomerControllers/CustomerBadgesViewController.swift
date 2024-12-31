//
//  CustomerBadgesViewController.swift
//  YellaEvent
//
//  Created by Noorcurlyfries on 27/12/2024.
//

import UIKit

class CustomerBadgesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet var collectionView: UICollectionView!
    
    var badges: [Badge?] = []
    var userID: String = ""
    
    @IBOutlet weak var badgesCount: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.collectionViewLayout = generateGridLayout()
        
        collectionView.register(UINib(nibName: "BadgeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BadgeCollectionViewCell")
        
        loadPlaceholders()
        loadBadges()
    }
    
    func loadPlaceholders() {
        badges = Array(repeating: nil, count: 10)
        collectionView.reloadData()
    }
    
    func loadBadges() {
        Task {
            do {
                let customer = try await UsersManager.getCustomer(customerID: userID)
                
                DispatchQueue.main.async {
                    self.badges = Array(repeating: nil, count: customer.badgesArray.count)
                    self.collectionView.reloadData()
                    self.badgesCount.text = "You own \(customer.badgesArray.count) Badges"
                }
                
                let fetchedBadges = try await fetchBadgesConcurrently(badgeIDs: customer.badgesArray)
                
                for (index, badge) in fetchedBadges.enumerated() {
                    DispatchQueue.main.async {
                        self.badges[index] = badge
                        let indexPath = IndexPath(item: index, section: 0)
                        self.collectionView.reloadItems(at: [indexPath])
                    }
                }
            } catch {
            }
        }
    }

    func fetchBadgesConcurrently(badgeIDs: [String]) async throws -> [Badge] {
        return await withTaskGroup(of: Badge?.self) { group in
            for badgeID in badgeIDs {
                group.addTask {
                    try? await BadgesManager.getBadge(eventID: badgeID)
                }
            }
            
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
            cell.update(with: badge)
        } else {
            cell.showPlaceholder()
        }
        
        return cell
    }

    func generateGridLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()

        let spacing: CGFloat = 10
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing

        let numberOfItemsPerRow: CGFloat = 2
        let totalSpacing = spacing * (numberOfItemsPerRow + 1)
        let itemWidth = (UIScreen.main.bounds.width - totalSpacing) / numberOfItemsPerRow

        layout.itemSize = CGSize(width: itemWidth, height: itemWidth + itemWidth / 8)
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)

        return layout
    }
}
