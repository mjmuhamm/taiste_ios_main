//
//  UserChefsTableViewCell.swift
//  Taiste
//
//  Created by Malik Muhammad on 3/1/22.
//

import UIKit

class UserChefsTableViewCell: UITableViewCell {
    @IBOutlet weak var chefPassion: UILabel!
    @IBOutlet weak var chefImageButton: UIButton!
    @IBOutlet weak var chefImage: UIImageView!
    
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeText: UILabel!
    @IBOutlet weak var orderText: UILabel!
    @IBOutlet weak var ratingText: UILabel!
    @IBOutlet weak var chefPassionConstant: NSLayoutConstraint!
    // with timesLiked 67.5
    // without 43.5
    
    var chefImageButtonTapped : (() -> ()) = {}
    var chefLikeButtonTapped : (() -> ()) = {}
    
    @IBOutlet weak var timesLikedText: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        likeImage.isHighlighted = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    @IBAction func chefImageButtonPressed(_ sender: Any) {
        chefImageButtonTapped()
    }
    @IBAction func chefLikeButton(_ sender: Any) {
        chefLikeButtonTapped()
        
    }
}
