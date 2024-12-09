//
//  InterestsCollectionViewCell.swift
//  YellaEvent
//
//  Created by meme on 04/12/2024.
//

import UIKit

class InterestsCollectionViewCell: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var label: UIButton!
    
    override func layoutSubviews() {
        self.layer.cornerRadius = self.frame.height / 10
        self.layer.shadowOpacity = 0.5
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height), cornerRadius: self.frame.height / 10).cgPath
    }
    
       override init(frame: CGRect) {
           super.init(frame: frame)
           contentView.addSubview(label)
           label.translatesAutoresizingMaskIntoConstraints = false
           NSLayoutConstraint.activate([
               label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
               label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
               label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
               label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
           ])
       }

       required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }
}
