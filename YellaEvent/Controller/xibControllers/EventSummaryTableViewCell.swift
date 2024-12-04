//
//  EventSummaryTableViewCell.swift
//  YellaEvent
//
//  Created by Admin User on 04/12/2024.
//

import UIKit

class EventSummaryTableViewCell: UITableViewCell {

    @IBOutlet weak var catagoryWrapper: UIView!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var catagoryLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
//        view.layer.borderWidth = 1
//        view.layer.borderColor = UIColor(named:K.BrandColors.purple)?.cgColor
        view.layer.cornerRadius = contentView.frame.height / 9
//        catagoryLabel.layer.cornerRadius = catagoryLabel.frame.size.width / 9
        catagoryWrapper.layer.cornerRadius =  catagoryWrapper.frame.width / 8
        catagoryWrapper.layer.allowsEdgeAntialiasing = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(with event: Event) {
        descriptionLabel.text = "\(event.startDate) \(event.organizerID)"
        PhotoManager.shared.downloadImage(from: URL(string: event.mediaArray[0])!) { result in
            switch result {
                case .success(let image):
                self.eventImage.image = image
            case .failure(let error):
                print(error)
            }
        }
        
        eventName.text = event.name
        priceLabel.text = "\(event.price)BD"
        catagoryLabel.text = event.category
        
        print("done \(event.eventID)")
    }
}
