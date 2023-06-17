//
//  YoutubeViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 6/16/23.
//

import UIKit
import youtube_ios_player_helper
import MaterialComponents.MaterialButtons
import MaterialComponents

class YoutubeViewController: UIViewController {

    @IBOutlet weak var exampleText: UILabel!
    var example = ""
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var playerView: YTPlayerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if example == "fullMealKitVideo" {
            playerView.isHidden = false
            imageView.isHidden = true
            playerView.load(withVideoId: "Xz07nEBT7FQ")
        } else if example == "contentVideo" {
            playerView.isHidden = false
            imageView.isHidden = true
            playerView.load(withVideoId: "H0MC0mB0bUo")
        } else {
            playerView.isHidden = true
            imageView.isHidden = false
            if example == "menuItemPost" {
                imageView.image = UIImage(named: "Menu Item Post")!
            } else if example == "ingredients" {
                imageView.image = UIImage(named: "Ingredients List")!
            } else if example == "preperation" {
                imageView.image = UIImage(named: "Preperation Guide")!
            } else if example == "ingredientsWrapping" {
                imageView.image = UIImage(named: "Ingredients Wrapping")!
                exampleText.text = "Search 'Food Wraps' and 'Food Storage Containers' at Walmart."
                exampleText.isHidden = false
            } else if example == "shipping" {
                imageView.image = UIImage(named: "Shipping")!
                exampleText.text = "Search 'Food Shipping Boxes' at Walmart."
                exampleText.isHidden = false
            }
        }
     
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    

}
