//
//  TabBarControllerViewController.swift
//  YellaEvent
//
//  Created by meme on 25/11/2024.
//

import UIKit

class CentralTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.selectedIndex = 0
        UITabBar.appearance().unselectedItemTintColor = UIColor(named: K.BrandColors.purple)
        UITabBar.appearance().tintColor = UIColor(named: K.BrandColors.blue)

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
