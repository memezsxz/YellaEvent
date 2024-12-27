//
//  BadgeCollectionViewCell.swift
//  YellaEvent
//
//  Created by meme on 27/12/2024.
//

import UIKit

import UIKit

extension UIImageView {
    func clipToRoundedHexagon(cornerRadius: CGFloat) {
        let path = UIBezierPath()
        
        // Define the hexagon dimensions
        let width = self.bounds.width
        let height = self.bounds.height
        let sideLength = width / 2.0
        let radius = cornerRadius
        
        // Start drawing the rounded hexagon
        path.move(to: CGPoint(x: width / 2.0, y: 0)) // Top point
        path.addArc(withCenter: CGPoint(x: width - radius, y: height * 0.25),
                    radius: radius,
                    startAngle: CGFloat(-Double.pi / 2),
                    endAngle: 0,
                    clockwise: true) // Top-right corner
        path.addLine(to: CGPoint(x: width, y: height * 0.75 - radius))
        path.addArc(withCenter: CGPoint(x: width - radius, y: height * 0.75),
                    radius: radius,
                    startAngle: 0,
                    endAngle: CGFloat(Double.pi / 2),
                    clockwise: true) // Bottom-right corner
        path.addLine(to: CGPoint(x: width / 2.0 + radius, y: height))
        path.addArc(withCenter: CGPoint(x: width / 2.0, y: height - radius),
                    radius: radius,
                    startAngle: CGFloat(Double.pi / 2),
                    endAngle: CGFloat(Double.pi),
                    clockwise: true) // Bottom point
        path.addLine(to: CGPoint(x: radius, y: height * 0.75))
        path.addArc(withCenter: CGPoint(x: radius, y: height * 0.75),
                    radius: radius,
                    startAngle: CGFloat(Double.pi),
                    endAngle: CGFloat(Double.pi * 1.5),
                    clockwise: true) // Bottom-left corner
        path.addLine(to: CGPoint(x: 0, y: height * 0.25 + radius))
        path.addArc(withCenter: CGPoint(x: radius, y: height * 0.25),
                    radius: radius,
                    startAngle: CGFloat(Double.pi * 1.5),
                    endAngle: CGFloat(Double.pi * 2),
                    clockwise: true) // Top-left corner
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
        view.layer.borderColor = UIColor(named:K.BrandColors.purple)?.cgColor
        view.layer.cornerRadius = contentView.frame.height / (K.HSizeclass == .regular && K.VSizeclass == .regular ? 5 : 8)

        // Initialization code
    }

    
    // Update the cell with badge data
    func update(with badge: Badge) {
        // Set the image and title for the badge
        PhotoManager.shared.downloadImage(from: URL(string: badge.image)!) {result in
            switch result {
                case .success(let image):
                DispatchQueue.main.async {
                    self.badgeImageView.image = image
                    self.badgeImageView.clipToRoundedHexagon(cornerRadius: 5)
                }
            case .failure(let error):
                print("Error downloading badge image: \(error)")
            }
        }
        badgeTitleLabel.text = badge.eventName // assuming `Badge` has a `name` property
    }

}
