//
//  ReviewsTableViewCell.swift
//  Taiste
//
//  Created by Malik Muhammad on 5/8/23.
//

import UIKit

class ReviewsTableViewCell: UITableViewCell {

    @IBOutlet weak var reviewDate: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var thoughtsText: UILabel!
    
    @IBOutlet weak var expectectationsText: UILabel!
    @IBOutlet weak var qualityText: UILabel!
    @IBOutlet weak var chefRatingText: UILabel!
    @IBOutlet weak var recommendText: UILabel!
    @IBOutlet weak var likesText: UILabel!
    @IBOutlet weak var likeImage: UIImageView!
    
    
    var userlikedTapped : (() -> ()) = {}
    var userProfileTapped : (() -> ()) = {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userImage.layer.borderWidth = 1
        userImage.layer.masksToBounds = false
        userImage.layer.borderColor = UIColor.white.cgColor
        userImage.layer.cornerRadius = userImage.frame.height/2
        userImage.clipsToBounds = true
        
        thoughtsText.text = ""
        expectectationsText.text = ""
        qualityText.text = ""
        reviewDate.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func userImagePressed(_ sender: Any) {
        userProfileTapped()
    }
    
    @IBAction func userLikedButtonPressed(_ sender: Any) {
        userlikedTapped()
    }
}
