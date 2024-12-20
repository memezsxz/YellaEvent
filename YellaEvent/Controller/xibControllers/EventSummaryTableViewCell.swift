//
//  EventSummaryTableViewCell.swift
//  YellaEvent
//
//  Created by Admin User on 04/12/2024.
//

import UIKit

class EventSummaryTableViewCell: UITableViewCell {
    
    @IBOutlet var loading: UIActivityIndicatorView!
    @IBOutlet weak var catagoryWrapper: UIView!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var catagoryLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        view.layer.cornerRadius = contentView.frame.height / 9
        catagoryWrapper.layer.cornerRadius =  catagoryWrapper.frame.width / 8
        catagoryWrapper.layer.allowsEdgeAntialiasing = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setup(with event: EventSummary) {
        if eventImage.image == nil {
        loading.startAnimating()
        let find = "@"
        
        let text = "\(K.TSFormatter.string(from: event.startTimeStamp)) @ \(event.venueName)"
        
        descriptionLabel.text = text
        
        let attributedString = NSMutableAttributedString(string: text)
        if let range = text.range(of: find) {
            let nsRange = NSRange(range, in: text)
            attributedString.addAttribute(.font,
                                          value: UIFont.systemFont(ofSize: descriptionLabel.font.pointSize, weight: .black),
                                          range: nsRange)
        }
        
        descriptionLabel.attributedText = attributedString
            PhotoManager.shared.downloadImage(from: URL(string: event.coverImageURL)!) { result in
                switch result {
                case .success(let image):
                    self.eventImage.image = image
                    self.loading.removeFromSuperview()
                    
                case .failure(let error):
                    print(error)
                }
            }
            
            eventName.text = event.name
            priceLabel.text = "\(event.price)BD"
            catagoryLabel.text = "\(event.categoryName) \(event.categoryIcon)"
        }
    }
}
