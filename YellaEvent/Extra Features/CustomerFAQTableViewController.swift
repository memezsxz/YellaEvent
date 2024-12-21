//
//  CustomerFAQTableViewController.swift
//  YellaEvent
//
//  Created by Admin User on 21/12/2024.
//

import UIKit



class CustomerFAQTableViewController: UITableViewController {

    var list: [FAQ] = []
    var type: String = ""
    var faqObject: FAQ?
    override func viewDidLoad() {
        super.viewDidLoad()
    

        do{
            let nibName = "FAQUsers"
            guard Bundle.main.path(forResource: nibName, ofType: "nib") != nil else {
                throw RuntimeError("Nib file \(nibName) not found in the bundle.")
            }

            tableView.register(UINib(nibName: nibName, bundle: Bundle.main), forCellReuseIdentifier: "FAQUsers")
        }catch {
            print("Error setting up tableView: \(error.localizedDescription)")
        }
        
        
            faqUpdate()
        
    }

    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return list.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FAQUsers", for: indexPath) as! FAQUsers
        
        cell.question.text = list[indexPath.row].question
        cell.answer.text = list[indexPath.row].answer

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        faqObject = list[indexPath.row]
        
        if type == "Customer" {
            performSegue(withIdentifier: "showCustomerFAQ", sender: self)
        }else if (type == "Admin"){
            performSegue(withIdentifier: "showFAQ", sender: self)

        }else{
            performSegue(withIdentifier: "showOrganizerFAQ", sender: self)
        }

    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFAQ"{
            (segue.destination as! AdminProfileViewController).FAQobject = faqObject
        }else if segue.identifier == "showCustomerFAQ"{
            (segue.destination as! CustomerProfileViewController).FAQobject = faqObject
        }else if segue.identifier == "showOrganizerFAQ"{
            (segue.destination as! OrganizerProfileViewController).FAQobject = faqObject

        }
    }
    
    
    
    func faqUpdate() {
        Task {
            do {
                var fetchedFAQs: [FAQ]
                switch type {
                case "Customer":
                    fetchedFAQs = try await FAQsManager.getFAQs(forUserType: .customer)
                case "Admin":
                    fetchedFAQs = try await FAQsManager.getFAQs(forUserType: .admin)
                case "Organizer":
                    fetchedFAQs = try await FAQsManager.getFAQs(forUserType: .organizer)
                default:
                    fetchedFAQs = try await FAQsManager.getFAQs(forUserType: .all)
                }
                
                // get faq for all
                var all: [FAQ] = try await FAQsManager.getFAQs(forUserType: .all)
            
                
                // Update the `list` and reload the table view on the main thread
                DispatchQueue.main.async {
                    self.list = fetchedFAQs
                    
                    //add the all in the list
                    if !(all.isEmpty){
                        self.list.append(contentsOf: all)
                    }
                   
                    
                    self.tableView.reloadData()
                }
            } catch {
                print("Error fetching FAQs: \(error.localizedDescription)")
            }
        }
    }
  
    
    @IBAction func unwindToCustomerFAQTableViewController(segue: UIStoryboardSegue) {
        
    }
    

}
