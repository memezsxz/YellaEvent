//
//  FAQTableViewController.swift
//  YellaEvent
//
//  Created by Admin User on 18/12/2024.
//




import UIKit




class FAQTableViewController: UITableViewController {

  var selectedFAQ: FAQ?
  var list: [FAQ] = []

// MARK: Actions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do{
            let nibName = "FAQTableViewCell"
            guard Bundle.main.path(forResource: nibName, ofType: "nib") != nil else {
                throw RuntimeError("Nib file \(nibName) not found in the bundle.")
            }

            tableView.register(UINib(nibName: nibName, bundle: Bundle.main), forCellReuseIdentifier: "FAQTableViewCell")
        }catch {
            print("Error setting up tableView: \(error.localizedDescription)")
        }
        
        
            faqUpdate()
            
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        faqUpdate()
        tableView.reloadData()

       
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return list.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FAQTableViewCell", for: indexPath) as! FAQTableViewCell

        let faq = list[indexPath.row]
        // chnage the name to the user name and the email to the user email
        
        cell.title.text = faq.question
        cell.subtext.text = "\(faq.userType)"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.width / 6
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedFAQ = list[indexPath.row]
        performSegue(withIdentifier: "edit", sender: self)
    }
    
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "edit", let indexPath = tableView.indexPathForSelectedRow {
//            (segue.destination as? EditAddTableViewController)?.FAQObject = list[indexPath.row]
//        }
//    }
    
    
    
    @IBSegueAction func add(_ coder: NSCoder, sender: Any?) -> EditAddTableViewController? {
  
        return EditAddTableViewController(coder: coder, faq: nil)
    }
    
    
    @IBSegueAction func edit(_ coder: NSCoder, sender: Any?) -> EditAddTableViewController? {
        if let selectedFAQ = selectedFAQ {
            return EditAddTableViewController(coder: coder, faq: selectedFAQ )
        }
        return EditAddTableViewController(coder: coder, faq: nil)
    }
    
    
    
    @IBAction func unWindeToFAQTableViewController(segue: UIStoryboardSegue){
        
        if (segue.identifier == "save" || segue.identifier == "delete"), let sourceCode = segue.source as? EditAddTableViewController, let _ = sourceCode.FAQObject{
            
            faqUpdate()
            tableView.reloadData()
            
        }
    }
    
    
    func faqUpdate() {
        Task {
            do {
                // Fetch FAQs asynchronously
                let fetchedFAQs = try await FAQsManager.getAllFAQs()
                
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

        
    }
 
    

