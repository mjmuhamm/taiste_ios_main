//
//  CommentsTableViewCell.swift
//  Taiste
//
//  Created by Malik Muhammad on 5/9/23.
//

import UIKit

class CommentsTableViewCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var thoughtsText: UILabel!
    @IBOutlet weak var userImageButton: UIButton!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var likeText: UILabel!
    
    var userlikedTapped : (() -> ()) = {}
    var userProfileTapped : (() -> ()) = {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImage.layer.borderWidth = 1
        userImage.layer.masksToBounds = false
        userImage.layer.borderColor = UIColor.white.cgColor
        userImage.layer.cornerRadius = userImage.frame.height/2
        userImage.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func likeButtonPressed(_ sender: Any) {
        userlikedTapped()
    }
    
    @IBAction func userImageButtonPressed(_ sender: Any) {
        userProfileTapped()
    }
}
