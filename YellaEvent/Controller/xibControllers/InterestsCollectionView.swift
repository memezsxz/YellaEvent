//
//  IntrestsCollectionView.swift
//  fwifhks
//
//  Created by meme on 07/12/2024.
//

import UIKit

class InterestsCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private var interests: [Category] = []
    private var selectedIndices = Set<Int>()
    public var selectForCustomer = true
    // MARK: - setup
    
    var currentCustomer : Customer?
    
    // for init from code
    init(frame: CGRect, layout: UICollectionViewFlowLayout, interests: [Category]) {
        self.interests = interests
        super.init(frame: frame, collectionViewLayout: layout)
        setupCollectionView()
    }
    
    // to use directly in storyboard
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        delegate = self
        dataSource = self
        
        backgroundColor = UIColor(named: K.BrandColors.backgroundGray)
        register(InterstsCollectionViewCell.self, forCellWithReuseIdentifier: InterstsCollectionViewCell.identifier)
        //        alwaysBounceVertical = true
        //        showsVerticalScrollIndicator = true
        
        if let flowLayout = collectionViewLayout as? LeftAlignedFlowLayout {
            flowLayout.scrollDirection = .vertical
            flowLayout.minimumLineSpacing = 25 // between rows
            flowLayout.minimumInteritemSpacing = 20 // between columns
            flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            flowLayout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        }
        
        if selectForCustomer {
            Task {
                self.interests = try await  CategoriesManager.getActiveCatigories()
                self.currentCustomer =  try await UsersManager.getUser(userID: UserDefaults.standard.string(forKey: K.bundleUserID)!) as? Customer
                
                DispatchQueue.main.async {
                    if self.selectForCustomer {
                        
                        self.setSelectedInterests(self.currentCustomer?.interestsArray ?? [])
                    }
                    self.reloadData()
                        
                }
            }
        }
    }
    
    // MARK: - to get and se data
    
    func setInterests(_ interests: [Category]) {
        self.interests = interests
        reloadData()
    }
    
//    func getInterests() -> [Category] {
//        selectedIndices.compactMap { index in
//            interests[index]
//        }
//    }
//    
    func getInterests() -> [String] {
        selectedIndices.compactMap { index in
            interests[index].categoryID
        }
    }
    
    func setSelectedInterests(_ selectedInterests: [Category]) {
        selectedIndices.removeAll()
        
        selectedInterests.forEach { selectedCategory in
            interests.forEach { interest in
                if selectedCategory.categoryID == interest.categoryID {
                    if let index = interests.firstIndex(where: { $0.categoryID == interest.categoryID }) {
                        selectedIndices.insert(index)
                    }
                }
            }
        }
        
        reloadData()
    }
    
    func setSelectedInterests(_ selectedInterests: [String]) {
        selectedIndices.removeAll()

        let interestIndexMap = Dictionary(uniqueKeysWithValues: interests.enumerated().map { ($0.element.categoryID, $0.offset) })

        for selectedCategoryID in selectedInterests {
            if let index = interestIndexMap[selectedCategoryID] {
                selectedIndices.insert(index)
            }
        }
        
        reloadData()
    }

    // MARK: - data source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return interests.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = dequeueReusableCell(withReuseIdentifier: InterstsCollectionViewCell.identifier, for: indexPath) as? InterstsCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let isSelected = selectedIndices.contains(indexPath.item)
        cell.configure(with: interests[indexPath.item], isSelected: isSelected)
        return cell
    }
    
    // MARK: - delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedIndices.contains(indexPath.item) {
            selectedIndices.remove(indexPath.item)
        } else {
            selectedIndices.insert(indexPath.item)
        }
        reloadItems(at: [indexPath])
    }
    
    // MARK: - each item size
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let category = interests[indexPath.item]
//        let text = "\(category.name) \(category.icon)"
//        let font = UIFont.systemFont(ofSize: InterstsCollectionViewCell.fontSize, weight: .medium)
//        
//        // Calculate the size of the text
//        let maxSize = CGSize(width: frame.width - 40, height: CGFloat.greatestFiniteMagnitude)
//        let textBoundingBox = NSString(string: text).boundingRect(
//            with: maxSize,
//            options: .usesLineFragmentOrigin,
//            attributes: [.font: font],
//            context: nil
//        )
//        
//        let textWidth = ceil(textBoundingBox.width)
//        let width = max(textWidth, 150)
//        return CGSize(width: width, height: 120)
//    }
}

// MAARK: flow to the left
class LeftAlignedFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }
        
        var leftMargin: CGFloat = sectionInset.left
        var maxY: CGFloat = 1.0
        
        for layoutAttribute in attributes {
            if layoutAttribute.frame.origin.y >= maxY {
                // Reset left margin for new row
                leftMargin = sectionInset.left
            }
            
            layoutAttribute.frame.origin.x = leftMargin
            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY, maxY)
        }
        
        return attributes
    }
}
