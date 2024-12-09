//
//  OrganizerEventsViewController.swift
//  YellaEvent
//
//  Created by meme on 25/11/2024.
//

import UIKit

class OrganizerEventsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var SegmentedControlOutlet: UISegmentedControl!
    
    
    @IBAction func SegmentedControlAction(_ sender: UISegmentedControl) {
        
        
    }
    var eventSummarys = [EventSummary]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "MainTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "MainTableViewCell")
        
        Task {
            
             EventsManager.getOrganizerEvents(organizerID: "4") { snapshot, error in
                guard error == nil else {
                    
                    print(error!.localizedDescription)
                    
                    return
                }
                
                if let snapshot = snapshot {
                    Task {
                        for doc in snapshot.documents {
                            self.eventSummarys.append(try await EventSummary(from: doc.data()))
                        }
                        DispatchQueue.main.async{
                            self.tableView.reloadData()
                        }
                    }
                }
                else{
                    print("not events found for organizer")
                }
            }
        }
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


extension OrganizerEventsViewController: UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.width / 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        eventSummarys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell") as! MainTableViewCell
        
        cell.setup(event: eventSummarys[indexPath.row])
        return cell
        
        
    }
    
    
    
}
