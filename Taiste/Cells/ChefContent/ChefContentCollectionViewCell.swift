//
//  ChefCollectionViewCell.swift
//  Taiste
//
//  Created by Malik Muhammad on 3/1/22.
//

import UIKit
import AVFoundation

class ChefContentCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var viewText: UILabel!
    
    
    var player : AVPlayer!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    public func configure(model: VideoModel) {
        player = AVPlayer(url: URL(string: model.dataUri)!)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = contentView.bounds
        videoView.layer.addSublayer(playerLayer)
      
    }
    
}