//
//  UserTabViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 2/25/22.
//

import UIKit

var userImageId = ""
var gUserName = ""
var gUserImage : UIImage? 
class UserTabViewController: UITabBarController {

    var whereTo = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        if whereTo == "home" {
            selectedIndex = 0
        } else if whereTo == "orders" {
            selectedIndex = 3
        }
        // Do any additional setup after loading the view.
    }
    

    
}
