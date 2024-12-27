//
//  MainTableViewCell.swift
//  YellaEvent
//
//  Created by meme on 03/12/2024.
//

import UIKit

protocol LeaderboardTableViewCellDelegate: AnyObject {
    func didTapMyBadges(for userID: String)
}

class LeaderboardTableViewCell: UITableViewCell {

    @IBOutlet weak var view: UIView!

    @IBOutlet weak var badgesBtn: UIButton!

    @IBOutlet weak var username: UILabel!

    @IBOutlet weak var rankLabel: UILabel!

    @IBOutlet weak var rankingBack: UIImageView!

    weak var delegate: LeaderboardTableViewCellDelegate?  // Add delegate
    private var userID: String = ""  // Store userID for the cell

    override func awakeFromNib() {
        super.awakeFromNib()
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.backgroundGray.cgColor
        view.layer.cornerRadius = contentView.frame.height / 4
        // Initialization code
    }

    func setup(
        rank: Int, username: String, score: String, isCurrentUser: Bool,
        userID: String
    ) {
        self.userID = userID
        rankLabel.text = "\(rank)"
        self.username.text = username
        self.badgesBtn.isEnabled = isCurrentUser

        if isCurrentUser {
            let blackFont = UIFont.systemFont(
                ofSize: self.badgesBtn.titleLabel?.font.pointSize ?? 17,
                weight: .black)
            let blackTitle = NSAttributedString(
                string: "My Badges",
                attributes: [
                    .font: blackFont
                ])
            self.badgesBtn.setAttributedTitle(blackTitle, for: .normal)
            self.rankingBack.tintColor = UIColor(named: K.BrandColors.blue)
            self.view.backgroundColor = UIColor(
                named: K.BrandColors.backgroundGray)
        } else {
            self.badgesBtn.setTitle(score, for: .disabled)
            self.rankingBack.tintColor = UIColor(named: K.BrandColors.purple)
            self.view.backgroundColor = .white
        }
    }

    @IBAction func badgesButtonTapped(_ sender: UIButton) {
        delegate?.didTapMyBadges(for: userID)  // Notify delegate
    }

}
