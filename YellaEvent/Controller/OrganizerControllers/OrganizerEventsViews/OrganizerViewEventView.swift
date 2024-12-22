//
//  OrganizerViewEventView.swift
//  YellaEvent
//
//  Created by meme on 22/12/2024.
//

import UIKit

class OrganizerViewEventView: UIViewController {

    @IBOutlet var eventStatus: UILabel!
    @IBOutlet var eventTitle: UILabel!
    @IBOutlet var statusCircle: UIImageView!
    @IBOutlet var dayOfMonth: UILabel!
    @IBOutlet var Month: UILabel!
    @IBOutlet var dayOfweek: UILabel!
    @IBOutlet var startToEndTime: UILabel!
    @IBOutlet var minimumAge: UILabel!
    @IBOutlet var Venue: UILabel!
    
    @IBOutlet var ticketsSold: UILabel!
    @IBOutlet var avarageRating: UILabel!
    @IBOutlet var remainingTickets: UILabel!
    @IBOutlet var totalAttendens: UILabel!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setup(eventID: String) {
        
         Task {
            let event =  try await EventsManager.getEvent(eventID: eventID)
             print(event, "in organizer view event view")

             eventStatus.text = event.status.rawValue
             // fill event details
             // do not ferget that the event media array needs to be presented
                        
          
             
        }
    }
    
    
//    performSegue(withIdentifier: "toAttendees", sender: self)

}
