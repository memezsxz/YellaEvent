//
//  CollectionViewCell.swift
//  fwifhks
//
//  Created by meme on 07/12/2024.
//

import UIKit

class InterstsCollectionViewCell: UICollectionViewCell{
    static let identifier = "InterstsCollectionViewCell"
        
    static var fontSize : CGFloat {
        K.VSizeclass == .regular && K.HSizeclass == .regular ? 24 : 14
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
        label.textColor = .white
//        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

        override init(frame: CGRect) {
            super.init(frame: frame)
            contentView.addSubview(titleLabel)
            contentView.backgroundColor = UIColor.systemPurple
//            contentView.layer.masksToBounds = true
            
            // Set up constraints between the content view of the cell and the label
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
            ])
            
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        titleLabel.frame = contentView.bounds.insetBy(dx: 10, dy: 5) // Adjust for padding
        contentView.layer.cornerRadius = contentView.frame.height / 2.3
        contentView.clipsToBounds = true // to ensure contents respect the rounded corners
}

    func configure(with category: Category, isSelected: Bool) {
        titleLabel.text = "\(category.name) \(category.icon)"
        contentView.backgroundColor = isSelected ? UIColor(named: K.BrandColors.darkPurple) : UIColor(named: K.BrandColors.lightPurple)
        }

}
