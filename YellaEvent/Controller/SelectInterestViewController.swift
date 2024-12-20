//
//  SelectInterestViewController.swift
//  YellaEvent
//
//  Created by Ahmed Ali on 15/12/2024.
//

import UIKit

class SelectInterestViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    let interests = [
        "Painting 🎨", "Pop 🎹", "Food 🍔", "Music 🎵",
        "Cooking 🔍", "Yoga 🧘‍♀️", "Reading 📚", "Art 🎨",
        "Fitness and Exercise 🏋️‍♂️", "Creative Coding 💻"
    ]
    var selectedIndices: Set<Int> = []
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
          collectionView.delegate = self
          collectionView.dataSource = self
        let nib = UINib(nibName: "InterestChipCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "InterestChipCell")
          collectionView.backgroundColor = .clear
      }
    

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension SelectInterestViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return interests.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InterestChipCell", for: indexPath) as? InterestChipCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: interests[indexPath.item])
        if selectedIndices.contains(indexPath.item) {
            cell.setSelected(true)
        } else {
            cell.setSelected(false)
        }
        
        return cell
    }
}

        // MARK: - UICollectionViewDelegate
extension SelectInterestViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedIndices.contains(indexPath.item) {
            selectedIndices.remove(indexPath.item)
        } else {
            selectedIndices.insert(indexPath.item)
        }
        
        // Reload the specific cell to update its appearance
        collectionView.reloadItems(at: [indexPath])
        
        // Print selected indices
        print("Selected Indices: \(Array(selectedIndices))")
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SelectInterestViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let collectionWidth = collectionView.frame.width
            let spacing: CGFloat = 10
            let inset: CGFloat = 0
            let width = (collectionWidth - inset * 2 - spacing) / 2

            if indexPath.item >= interests.count - 2 {
                // Last two cells take full width
                return CGSize(width: collectionWidth - inset * 2, height: 60)
            } else {
                // All other cells are half-width
                return CGSize(width: width, height: 60)
            }
        }

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 10
        }

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 0
        }
}
