//
//  CustomerTicketsViewController.swift
//  YellaEvent
//
//  Created by meme on 25/11/2024.
//

import UIKit

class CustomerTicketsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        tickets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TicketsTableViewCell", for: indexPath) as! TicketsTableViewCell
        let ticket = tickets[indexPath.row]
        
        cell.title.text = ticket.eventID
        cell.subtext.text = "12.12.2024 - Aldana Amohitheater"
        return cell 
        
    }
    
var tickets = [Ticket] ()
    override func viewDidLoad() {
        super.viewDidLoad()
    tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib (nibName:"TicketsTableViewCell", bundle: .main), forCellReuseIdentifier: "TicketsTableViewCell")
        
        Task{
           try await TicketsManager.getInstence().createNewTicket(ticket: Ticket(ticketID: "ticket", eventID: "event1", userID: "1", didAttend: false, price: 12.12))
            
            
        }
        Task{
            self.tickets = try await  TicketsManager.getInstence().getUserTickets(userId: "1")
            DispatchQueue.main.async{
                self.tableView.reloadData()
            }
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.frame.width/6
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
