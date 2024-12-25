//
//  EventSummaryTableViewCell.swift
//  YellaEvent
//
//  Created by Admin User on 04/12/2024.
//

import UIKit

class EventSummaryTableViewCell: UITableViewCell {

    //    @IBOutlet var loading: UIActivityIndicatorView!
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
        catagoryWrapper.layer.cornerRadius = catagoryWrapper.frame.width / 8
        catagoryWrapper.layer.allowsEdgeAntialiasing = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setup(with event: EventSummary) {
        self.eventImage.image = UIImage(named: "placeholder")  // Set a placeholder while loading

        let find = "@"
        let text =
            "\(K.TSFormatter.string(from: event.startTimeStamp)) @ \(event.venueName)"
        descriptionLabel.text = text

        let attributedString = NSMutableAttributedString(string: text)
        if let range = text.range(of: find) {
            let nsRange = NSRange(range, in: text)
            attributedString.addAttribute(
                .font,
                value: UIFont.systemFont(
                    ofSize: descriptionLabel.font.pointSize, weight: .black),
                range: nsRange
            )
        }

        descriptionLabel.attributedText = attributedString

        // Load the image using the caching method
        self.eventImage.loadImageUsingCache(
            withUrlString: event.coverImageURL,
            placeholder: UIImage(named: "placeholder"))

        eventName.text = event.name
        priceLabel.text = "\(event.price)BD"
        catagoryLabel.text = "\(event.categoryName) \(event.categoryIcon)"
    }

}
let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    func loadImageUsingCache(
        withUrlString urlString: String, placeholder: UIImage? = nil
    ) {
        // Set placeholder image if provided
        self.image = placeholder

        // Check if the image is already cached
        if let cachedImage = imageCache.object(
            forKey: NSString(string: urlString))
        {
            self.image = cachedImage
            return
        }

        // Download the image
        guard let url = URL(string: urlString) else {
            print("Invalid URL string")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error loading image: \(error)")
                return
            }

            guard let data = data, let downloadedImage = UIImage(data: data)
            else {
                print("Error decoding image data")
                return
            }

            // Cache the image
            imageCache.setObject(
                downloadedImage, forKey: NSString(string: urlString))

            // Update UI on the main thread
            DispatchQueue.main.async {
                self.image = downloadedImage
            }
        }.resume()
    }
}
