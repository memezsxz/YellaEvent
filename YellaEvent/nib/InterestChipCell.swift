//
//  InterestChipCell.swift
//  SelectHits
//
//  Created by Ahmed Ali on 15/12/2024.
//

import UIKit

class InterestChipCell: UICollectionViewCell {
    
    @IBOutlet weak var interestLabel: UILabel!
    @IBOutlet weak var backgroundViewContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    private func setupView() {
        backgroundViewContainer.layer.cornerRadius = 25
        backgroundViewContainer.layer.masksToBounds = true
        backgroundViewContainer.backgroundColor = UIColor.brandLightPurple
    }
    
    func configure(with interest: String) {
        interestLabel.text = interest
        interestLabel.textColor = .white
    }
    
    func setSelected(_ selected: Bool) {
        if selected {
            backgroundViewContainer.backgroundColor = UIColor.brandDarkPurple
            interestLabel.textColor = .white
        } else {
            backgroundViewContainer.backgroundColor = UIColor.brandLightPurple
            interestLabel.textColor = .white
        }
    }
    
}
