//
//  BadgeCollectionViewCell.swift
//  YellaEvent
//
//  Created by meme on 27/12/2024.
//

import UIKit

import UIKit

extension UIImageView {
    func clipToHexagon() {
        let path = UIBezierPath()
        
        // Define the hexagon path
        let width = self.bounds.width
        let height = self.bounds.height
        let sideLength = width / 2.0
        
        path.move(to: CGPoint(x: width / 2.0, y: 0))
        path.addLine(to: CGPoint(x: width, y: height * 0.25))
        path.addLine(to: CGPoint(x: width, y: height * 0.75))
        path.addLine(to: CGPoint(x: width / 2.0, y: height))
        path.addLine(to: CGPoint(x: 0, y: height * 0.75))
        path.addLine(to: CGPoint(x: 0, y: height * 0.25))
        path.close()
        
        // Create a shape layer mask
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}


class BadgeCollectionViewCell: UICollectionViewCell {
    @IBOutlet var badgeImageView: UIImageView!
    @IBOutlet var badgeTitleLabel: UILabel!

    @IBOutlet var view: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(named: K.BrandColors.purple)?.cgColor
        view.layer.cornerRadius = contentView.frame.height / 16
    }

    func update(with badge: Badge) {
        PhotoManager.shared.downloadImage(from: URL(string: badge.image)!) { result in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    self.badgeImageView.image = image
                    self.badgeImageView.clipToHexagon()
                }
            case .failure(let error):
                print("Error downloading badge image: \(error)")
            }
        }
        badgeTitleLabel.text = badge.eventName
    }

    func showPlaceholder() {
        badgeImageView.image = UIImage(named: "placeholder") // Placeholder image
        badgeTitleLabel.text = "Loading..." // Placeholder text
    }
}
