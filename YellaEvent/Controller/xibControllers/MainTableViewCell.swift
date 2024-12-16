//
//  MainTableViewCell.swift
//  YellaEvent
//
//  Created by meme on 03/12/2024.
//

import UIKit

class MainTableViewCell: UITableViewCell {

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var arrowPhoto: UIImageView!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(named:K.BrandColors.purple)?.cgColor
        view.layer.cornerRadius = contentView.frame.height / 5
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup (event: EventSummary){
        
        title.text = event.name
    }
}
