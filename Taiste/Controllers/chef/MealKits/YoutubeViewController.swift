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
import AVFoundation

class YoutubeViewController: UIViewController {

    @IBOutlet weak var exampleText: UILabel!
    var example = ""
    var image : UIImage?
    var videoUrl = ""
    
    var player : AVQueuePlayer!
    var playerLooper: AVPlayerLooper!
    var queuePlayer: AVQueuePlayer!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var playerView: YTPlayerView!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var playPauseButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        if example == "fullMealKitVideo" {
            playerView.isHidden = false
            imageView.isHidden = true
            contentView.isHidden = true
            playerView.load(withVideoId: "Xz07nEBT7FQ")
        } else if example == "contentVideo" {
            playerView.isHidden = false
            imageView.isHidden = true
            contentView.isHidden = true
            playerView.load(withVideoId: "H0MC0mB0bUo")
        } else if example == "uploadIngredient" {
            playerView.isHidden = true
            imageView.isHidden = false
            contentView.isHidden = true
            imageView.image = image!
        } else if example == "prepGuide" {
            playerView.isHidden = true
            imageView.isHidden = false
            contentView.isHidden = true
            imageView.image = image!
        } else if example == "videoContent" {
            playerView.isHidden = true
            imageView.isHidden = true
            contentView.isHidden = false
            playPauseButton.isHidden = false
            self.configure(url: videoUrl)
        } else {
            playerView.isHidden = true
            imageView.isHidden = false
            contentView.isHidden = true
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
    
    @IBAction func playPauseButtonPressed(_ sender: Any) {
        if playPauseButton.imageView?.image == UIImage(systemName: "play.fill") {
            playPauseButton.imageView?.image = UIImage()
            player.play()
        } else {
            playPauseButton.imageView?.image = UIImage(systemName: "play.fill")
            player.pause()
        }
        
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    private func configure(url: String) {
        player = AVQueuePlayer()
        let playerLayer = AVPlayerLayer(player: player)
        let playerItem = AVPlayerItem(url: URL(string: url)!)
        playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = contentView.bounds
        contentView.layer.addSublayer(playerLayer)
      
    }

}
