//
//  CustomerBadgesViewController.swift
//  YellaEvent
//
//  Created by Noorcurlyfries on 27/12/2024.
//

import UIKit

class CustomerBadgesViewController: UIViewController, UICollectionViewDelegate,
    UICollectionViewDataSource
{
    @IBOutlet var collectionView: UICollectionView!

    var badges: [Badge] = []
    var userID: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self

        // Setup the collection view layout
        collectionView.collectionViewLayout = generateGridLayout()

        collectionView.register(
            UINib(nibName: "BadgeCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "BadgeCollectionViewCell")
        loadBadges()

    }

    func loadBadges() {
        Task {
            do {
                // Fetch customer using userID
                let customer = try await UsersManager.getCustomer(
                    customerID: userID)

                // Use Task Groups to fetch all badges concurrently
                let fetchedBadges = try await fetchBadgesConcurrently(
                    badgeIDs: customer.badgesArray)

                // Update the badges array and reload the collection view on the main thread
                DispatchQueue.main.async {
                    self.badges = fetchedBadges
                    self.collectionView.reloadData()
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

    func collectionView(
        _ collectionView: UICollectionView, numberOfItemsInSection section: Int
    ) -> Int {
        return badges.count
    }

    func collectionView(
        _ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let badge = badges[indexPath.row]
        print(badge)
        let cell =
            collectionView.dequeueReusableCell(
                withReuseIdentifier: "BadgeCollectionViewCell", for: indexPath)
            as! BadgeCollectionViewCell
        cell.update(with: badge)
        return cell
    }

    func generateGridLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()

        // Define the spacing between items and rows
        let spacing: CGFloat = 10  // Adjust as needed
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing

        // Define the size of the cells
        let numberOfItemsPerRow: CGFloat = 2
        let totalSpacing = spacing * (numberOfItemsPerRow + 1)  // Total spacing = spaces between + insets
        let itemWidth =
            (UIScreen.main.bounds.width - totalSpacing) / numberOfItemsPerRow

        layout.itemSize = CGSize(
            width: itemWidth, height: itemWidth + itemWidth / 8)  // Equal width and height
        layout.sectionInset = UIEdgeInsets(
            top: spacing, left: spacing, bottom: spacing, right: spacing)

        return layout
    }

}
