//
//  MainTableViewCell.swift
//  YellaEvent
//
//  Created by meme on 03/12/2024.
//

import UIKit

class FAQTableViewCell: UITableViewCell {

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtext: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(named:K.BrandColors.purple)?.cgColor
        view.layer.cornerRadius = contentView.frame.height / 4
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
