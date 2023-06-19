//
//  HomeTableViewCell.swift
//  Taiste
//
//  Created by Malik Muhammad on 2/24/22.
//

import UIKit

class HomeTableViewCell: UITableViewCell {

    @IBOutlet weak var chefImage: UIImageView!
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemDescription: UILabel!
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
        itemPrice.text = ""
        chefImage.layer.borderWidth = 1
        chefImage.layer.masksToBounds = false
        chefImage.layer.borderColor = UIColor.white.cgColor
        chefImage.layer.cornerRadius = chefImage.frame.height/2
        chefImage.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func chefImageButtonPressed(_ sender: UIButton) {
        chefImageButtonTapped()
    }
    
    @IBAction func itemImageButtonPressed(_ sender: UIButton) {
        itemImageButtonTapped()
    }
    
    @IBAction func likeImagePressed(_ sender: UIButton) {
        likeImageButtonTapped()
    }
    
    @IBAction func orderButtonPressed(_ sender: UIButton) {
        orderButtonTapped()
    }
    
}
