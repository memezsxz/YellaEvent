//
//  CategoryViewCell.swift
//  YellaEvent
//
//  Created by Ahmed Ali on 24/12/2024.
//

import UIKit

class CategoryViewCell: UITableViewCell {

    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryIconContainer: UIView!
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var categoryIcon: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        categoryIconContainer.layer.cornerRadius = 22.5

        mainContainer.layer.cornerRadius = 15
        mainContainer.layer.borderWidth = 1
        mainContainer.layer.borderColor = UIColor.brandPurple.cgColor
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
