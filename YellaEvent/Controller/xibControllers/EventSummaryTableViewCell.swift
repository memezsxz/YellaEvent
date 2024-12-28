//
//  EventSummaryTableViewCell.swift
//  YellaEvent
//
//  Created by Admin User on 04/12/2024.
//

import UIKit

class EventSummaryTableViewCell: UITableViewCell {
    var image : UIImage? = nil
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
//        if self.image != nil {
//            self.eventImage.image = self.image
//        }
        if let cachedImage = ImageCache.shared.object(forKey: event.coverImageURL as NSString) {
            self.eventImage.image = cachedImage
            self.loading.removeFromSuperview()
        }
       else if let url = URL(string: event.coverImageURL) {
            
            task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
                guard let self = self, let data = data, let image = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    ImageCache.shared.setObject(image, forKey: event.coverImageURL as NSString)
                    self.eventImage.image = image
                    self.loading.removeFromSuperview()
                }
            }
            task?.resume()

//            PhotoManager.shared.downloadImage(from: url) { result in
//                    switch result {
//                    case .success(let image):
//                        self.eventImage.image = image
//                        self.loading.removeFromSuperview()
//                        self.image = image
//                    case .failure(let error):
//                        print(error)
//                    }
//                }
//                
            } else {
                print(event.coverImageURL)
                print(event)
                self.eventImage.image = UIImage(named: "circle")
                self.loading.removeFromSuperview()
            }
            
        eventName.text = event.name
        priceLabel.text = "\(event.price)BD"
        catagoryLabel.text = "\(event.categoryName) \(event.categoryIcon)"

    }
    
    private var task: URLSessionDataTask?

    override func prepareForReuse() {
        super.prepareForReuse()
        task?.cancel()
        eventImage.image = nil
    }
    
    class ImageCache {
        static let shared = NSCache<NSString, UIImage>()
    }

}
