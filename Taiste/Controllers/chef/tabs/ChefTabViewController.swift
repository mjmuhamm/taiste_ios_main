//
//  ChefTabViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 2/25/22.
//

import UIKit

class ChefTabViewController: UITabBarController {
    var whereTo = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedIndex = 2
        if whereTo == "home" {
            selectedIndex = 0
        } else if whereTo == "orders" {
            selectedIndex = 3
        }
        ;
        // Do any additional setup after loading the view.
    }
    
    

}
