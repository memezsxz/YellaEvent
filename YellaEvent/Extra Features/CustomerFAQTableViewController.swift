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
    
    
    
    
    func faqUpdate() {
        Task {
            do {
                let fetchedFAQs: [FAQ]
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
                
                // Fetch FAQs asynchronously
                 
                
                // Update the `list` and reload the table view on the main thread
                DispatchQueue.main.async {
                    self.list = fetchedFAQs
                    self.tableView.reloadData()
                }
            } catch {
                print("Error fetching FAQs: \(error.localizedDescription)")
            }
        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
