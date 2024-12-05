//
//  OrganizerEventsViewController.swift
//  YellaEvent
//
//  Created by meme on 25/11/2024.
//

import UIKit

class OrganizerEventsViewController: UIViewController {

    @IBOutlet weak var TextLable: UILabel!
    @IBOutlet weak var SegmentedControlOutlet: UISegmentedControl!
    
    
    @IBAction func SegmentedControlAction(_ sender: UISegmentedControl) {
        
        switch SegmentedControlOutlet.selectedSegmentIndex{
            
        case 0:
            TextLable.text = "All"
        case 1:
            TextLable.text = "On-Going"
        case 2:
            TextLable.text = "Over"
        case 3:
            TextLable.text = "Cancelled"
        default:
            break
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
