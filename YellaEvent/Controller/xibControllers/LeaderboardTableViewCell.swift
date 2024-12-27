//
//  MainTableViewCell.swift
//  YellaEvent
//
//  Created by meme on 03/12/2024.
//

import UIKit

class LeaderboardTableViewCell: UITableViewCell {

    @IBOutlet weak var view: UIView!

    @IBOutlet weak var badgesBtn: UIButton!
    
    @IBOutlet weak var username: UILabel!
    
    @IBOutlet weak var rankLabel: UILabel!
    
    @IBOutlet weak var rankingBack: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.backgroundGray.cgColor
        view.layer.cornerRadius = contentView.frame.height / 4
        // Initialization code
    }
    
    func setup(rank: Int, username: String, score: String, isCurrentUser: Bool) {
        rankLabel.text = "\(rank)"
        self.username.text = username
        self.badgesBtn.setTitle(isCurrentUser ? "Badges" : score, for: .normal)
        self.badgesBtn.isEnabled = isCurrentUser
        self.badgesBtn.titleLabel?.textColor = isCurrentUser ? UIColor(named: K.BrandColors.purple) : .brandPurple
        self.rankingBack.tintColor = isCurrentUser ? UIColor(named: K.BrandColors.blue) : UIColor(named: K.BrandColors.purple)
        self.view.backgroundColor = isCurrentUser ? UIColor(named: K.BrandColors.backgroundGray) : .white
    }
    
}
