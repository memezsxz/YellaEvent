//
//  AdminStatisticsViewController.swift
//  YellaEvent
//
//  Created by meme on 25/11/2024.
//

import UIKit

class AdminStatisticsViewController:UITableViewController{
    
    @IBOutlet var eventsSumLabel: UILabel!
    
    @IBOutlet var usersSumLabel: UILabel!
    
    @IBOutlet var organizersSumLabel: UILabel!
    
    @IBOutlet var categoriesSumLabel: UILabel!
    
    @IBOutlet var faqsSumLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getData()
    }
    func getData() {
        Task {
            async let updateEventsSum: () = {
                let eventsSum = try await EventsManager.getEventsSum()
                await MainActor.run {
                    self.eventsSumLabel.text = "\(eventsSum)"
                }
            }()
            
            async let updateUsersSum: () = {
                let usersSum = try await UsersManager.getCustomersSum()
                await MainActor.run {
                    self.usersSumLabel.text = "\(usersSum)"
                }
            }()
            
            async let updateOrganizersSum: () = {
                let organizersSum = try await UsersManager.getOrganizersSum()
                await MainActor.run {
                    self.organizersSumLabel.text = "\(organizersSum)"
                }
            }()
            
            async let updateCategoriesSum: () = {
                let categoriesSum = try await CategoriesManager.getCategoriesSum()
                await MainActor.run {
                    self.categoriesSumLabel.text = "\(categoriesSum)"
                }
            }()
            
            async let updateFAQsSum: () = {
                let faqsSum = try await FAQsManager.getFAQsSum()
                await MainActor.run {
                    self.faqsSumLabel.text = "\(faqsSum)"
                }
            }()
            
//           _ = try await (updateEventsSum, updateUsersSum, updateOrganizersSum, updateCategoriesSum)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if K.HSizeclass == .regular && K.VSizeclass == .regular {
            if indexPath.section == 0 {
               return  tableView.frame.width / 16
            }
           return tableView.frame.width / 6
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            tabBarController?.selectedIndex = 2
        } else if indexPath.section == 2  || indexPath.section == 3 || indexPath.section == 5 {

            let usersNavigationController = self.tabBarController?.viewControllers?[1] as! UINavigationController
            
            
            if let viewcontroller = usersNavigationController.viewControllers.first as? AdminUsersViewController {
                
                _ = viewcontroller.view // loading the view if it is not loaded yet

                if indexPath.section == 5 {
                    viewcontroller.performSegue(withIdentifier: "GoToFAQs", sender: viewcontroller)
                }
                else if indexPath.section == 3 {
                    viewcontroller.userListSections.selectedSegmentIndex = 2
                    viewcontroller.clickOnSegment(viewcontroller.userListSections!)

                } else if indexPath.section == 2{
                    viewcontroller.userListSections.selectedSegmentIndex = 1
                    viewcontroller.clickOnSegment(viewcontroller.userListSections!)

                }
            }
            
            self.tabBarController?.selectedViewController = usersNavigationController
            

        } else if indexPath.section == 4 {
            tabBarController?.selectedIndex = 3
        }
    }
    
}


    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

