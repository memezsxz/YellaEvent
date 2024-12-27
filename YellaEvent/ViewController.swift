//
//  ViewController.swift
//  YellaEvent
//
//  Created by meme on 25/11/2024.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.requestNotificationPermissions()
        }
        // Do any additional setup after loading the view.
    }


}

