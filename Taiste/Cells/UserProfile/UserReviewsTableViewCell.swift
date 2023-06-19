//
//  UserReviewsTableViewCell.swift
//  Taiste
//
//  Created by Malik Muhammad on 3/1/22.
//

import UIKit

class UserReviewsTableViewCell: UITableViewCell {
    @IBOutlet weak var reviewDate: UILabel!
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var review: UILabel!
    
    @IBOutlet weak var recommend: UILabel!
    @IBOutlet weak var chefImage: UIImageView!
    @IBOutlet weak var chefImageButton: UIButton!
    
    @IBOutlet weak var expectationsMetRating: UILabel!
    @IBOutlet weak var qualityRating: UILabel!
    @IBOutlet weak var chefRating: UILabel!
    @IBOutlet weak var likeText: UILabel!
    
    @IBOutlet weak var likeImage: UIImageView!
    
    var chefImageButtonTapped : (() -> ()) = {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        reviewDate.text = ""
        itemTitle.text = ""
        review.text = ""
        recommend.text = ""
        
        
        chefImage.layer.borderWidth = 1
        chefImage.layer.masksToBounds = false
        chefImage.layer.borderColor = UIColor.white.cgColor
        chefImage.layer.cornerRadius = chefImage.frame.height/2
        chefImage.clipsToBounds = true
        likeImage.isHighlighted = true
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    @IBAction func chefImageButtonPressed(_ sender: Any) {
        
        chefImageButtonTapped()
    }
    
}
