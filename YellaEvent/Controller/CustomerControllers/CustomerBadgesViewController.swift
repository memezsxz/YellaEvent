//
//  CustomerBadgesViewController.swift
//  YellaEvent
//
//  Created by Noorcurlyfries on 27/12/2024.
//


import UIKit

class CustomerBadgesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet var collectionView: UICollectionView!

    
    var badges: [Badge] = []
    var userID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self

        // Setup the collection view layout
        collectionView.collectionViewLayout = generateGridLayout()
        
        collectionView.register(UINib(nibName: "BadgeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BadgeCollectionViewCell")
        loadBadges()
        
    }
    
    func loadBadges() {
            Task {
                do {
                    // Fetch the customer
                    let customer = try await UsersManager.getCustomer(customerID: userID)
                    
                    // Fetch badges based on the customer's badge IDs
                    for badgeID in customer.badgesArray {
                        if let badge = try? await BadgesManager.getBadge(eventID: badgeID) {
                            badges.append(badge)
                        }
                    }
                    
                    // Reload the collection view on the main thread
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                } catch {
                    print("Failed to load badges: \(error.localizedDescription)")
                }
            }
        }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return badges.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let badge = badges[indexPath.row]
        print(badge)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BadgeCollectionViewCell", for: indexPath) as! BadgeCollectionViewCell
        cell.update(with: badge)
        return cell
    }

    func generateGridLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()

        // Define the spacing between items and rows
        let spacing: CGFloat = 10 // Adjust as needed
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing

        // Define the size of the cells
        let numberOfItemsPerRow: CGFloat = 2
        let totalSpacing = spacing * (numberOfItemsPerRow + 1) // Total spacing = spaces between + insets
        let itemWidth = (UIScreen.main.bounds.width - totalSpacing) / numberOfItemsPerRow

        layout.itemSize = CGSize(width: itemWidth, height: itemWidth + itemWidth / 8) // Equal width and height
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)

        return layout
    }

}
