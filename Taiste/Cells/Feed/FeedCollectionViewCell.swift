//
//  FeedCollectionViewCell.swift
//  Taiste
//
//  Created by Malik Muhammad on 3/2/22.
//

import UIKit
import AVFoundation
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_Theming
import MaterialComponents.MaterialTextControls_FilledTextAreasTheming
import MaterialComponents.MaterialTextControls_FilledTextFieldsTheming
import MaterialComponents.MaterialTextControls_OutlinedTextAreasTheming
import MaterialComponents.MaterialTextControls_OutlinedTextFieldsTheming

class FeedCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var likeText: UILabel!

    @IBOutlet weak var commentText: UILabel!
    @IBOutlet weak var shareText: UILabel!
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var videoDescription: UILabel!
    @IBOutlet weak var playImage: UIImageView!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    var player : AVQueuePlayer!
    var playerLooper: AVPlayerLooper!
    var queuePlayer: AVQueuePlayer!
    @IBOutlet weak var videoView: UIView!
    
    @IBOutlet weak var playPauseButton: UIButton!
    
    
    var likeButtonTapped : (() -> ()) = {}
    var commentButtonTapped: (() -> ()) = {}
    var shareButtonTapped: (() -> ()) = {}
    var playPauseButtonTapped: (() -> ()) = {}
    var backButtonTapped: (() -> ()) = {}
    var deleteButtonTapped: (() -> ()) = {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userName.text = ""
        videoDescription.text = ""
        
        
        
    }
    
    public func configure(model: VideoModel) {
        player = AVQueuePlayer()
        let playerLayer = AVPlayerLayer(player: player)
        let playerItem = AVPlayerItem(url: URL(string: model.dataUri)!)
        playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = contentView.bounds
        videoView.layer.addSublayer(playerLayer)
      
    }

    @IBAction func deleteButtonPressed(_ sender: Any) {
        deleteButtonTapped()
    }
    @IBAction func backButtonPressed(_ sender: Any) {
        backButtonTapped()
    }
    
    @IBAction func likeButtonPressed(_ sender: UIButton) {
        likeButtonTapped()
    }
    
    @IBAction func commentButtonPressed(_ sender: Any) {
        commentButtonTapped()
    }
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        shareButtonTapped()
    }
    
    @IBAction func playPauseButtonPressed(_ sender: Any) {
        playPauseButtonTapped()
    }
    
    
}
