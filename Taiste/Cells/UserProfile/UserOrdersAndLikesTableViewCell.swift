//
//  UserOrdersAndLikesTableViewCell.swift
//  Taiste
//
//  Created by Malik Muhammad on 3/1/22.
//

import UIKit

class UserOrdersAndLikesTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageButton: UIButton!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var clickHereForDetailButton: UIButton!
    @IBOutlet weak var itemImageButton: UIButton!
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemDescription: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeImage: UIImageView!
    
    @IBOutlet weak var likeText: UILabel!
    @IBOutlet weak var orderText: UILabel!
    @IBOutlet weak var ratingText: UILabel!
    @IBOutlet weak var itemPrice: UILabel!
    
    
    var chefImageButtonTapped : (() -> ()) = {}
    var itemImageButtonTapped : (() -> ()) = {}
    var likeImageButtonTapped : (() -> ()) = {}
    var orderButtonTapped : (() -> ()) = {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        itemTitle.text = ""
        itemDescription.text = ""
        itemImage.layer.cornerRadius = 4
        
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
    
    @IBAction func orderButtonPressed(_ sender: Any) {
        orderButtonTapped()
    }
    
    @IBAction func userImageButtonPressed(_ sender: Any) {
        chefImageButtonTapped()
    }
    @IBAction func likeButtonPressed(_ sender: Any) {
        likeImageButtonTapped()
    }
    
    
    @IBAction func itemImageButtonPressed(_ sender: Any) {
        itemImageButtonTapped()
    }
    
    
    @IBAction func clickHereForDetailPressed(_ sender: Any) {
        itemImageButtonTapped()
    }
}
