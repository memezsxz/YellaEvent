//
//  MainTableViewCell.swift
//  YellaEvent
//
//  Created by meme on 03/12/2024.
//

import UIKit

class FAQUsers: UITableViewCell {

    @IBOutlet weak var view: UIView!
    @IBOutlet var answer: UILabel!
    @IBOutlet var question: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(named:K.BrandColors.purple)?.cgColor
        view.layer.cornerRadius = contentView.frame.height / 10
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
