//
//  PersonalChefTableViewCell.swift
//  Taiste
//
//  Created by Malik Muhammad on 6/4/23.
//

import UIKit
import MaterialComponents.MaterialButtons
import MaterialComponents

class PersonalChefTableViewCell: UITableViewCell {

    @IBOutlet weak var chefImage: UIImageView!
    @IBOutlet weak var chefName: UILabel!
    
    @IBOutlet weak var signatureImage: UIImageView!
    @IBOutlet weak var briefIntro: UILabel!
    @IBOutlet weak var specialDishText: UILabel!
    @IBOutlet weak var itemDetailButton2: UIButton!
    
    @IBOutlet weak var expectations1: UIImageView!
    @IBOutlet weak var expectations2: UIImageView!
    @IBOutlet weak var expectations3: UIImageView!
    @IBOutlet weak var expectations4: UIImageView!
    @IBOutlet weak var expectations5: UIImageView!
    
    @IBOutlet weak var quality1: UIImageView!
    @IBOutlet weak var quality2: UIImageView!
    @IBOutlet weak var quality3: UIImageView!
    @IBOutlet weak var quality4: UIImageView!
    @IBOutlet weak var quality5: UIImageView!
    
    @IBOutlet weak var chefRating1: UIImageView!
    @IBOutlet weak var chefRating2: UIImageView!
    @IBOutlet weak var chefRating3: UIImageView!
    @IBOutlet weak var chefRating4: UIImageView!
    @IBOutlet weak var chefRating5: UIImageView!
    
    
    @IBOutlet weak var editInfoButton: UIButton!
    
    @IBOutlet weak var chefLikesButton: UIButton!
    @IBOutlet weak var chefLikes: UILabel!
    @IBOutlet weak var chefOrders: UILabel!
    @IBOutlet weak var chefRating: UILabel!
    
    @IBOutlet weak var servicePrice: UILabel!
    @IBOutlet weak var orderButton: UIButton!
    @IBOutlet weak var likeImage: UIImageView!
    
    
    var chefImageButtonTapped : (() -> ()) = {}
    var itemImageButtonTapped : (() -> ()) = {}
    var editInfoButtonTapped : (() -> ()) = {}
    var orderButtonTapped : (() -> ()) = {}
    var likeButtonTapped : (() -> ()) = {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        chefImage.layer.cornerRadius = 6
        signatureImage.layer.cornerRadius = 6
    }
    
    
    @IBAction func likeButtonPressed(_ sender: Any) {
        likeButtonTapped()
    }
    
    @IBAction func orderButtonPressed(_ sender: Any) {
        orderButtonTapped()
    }
    
    @IBAction func chefImageButtonPressed(_ sender: Any) {
        chefImageButtonTapped()
    }
    
    @IBAction func itemDetailButtonPressed(_ sender: Any) {
        itemImageButtonTapped()
    }
    
    @IBAction func itemDetailButton2Pressed(_ sender: Any) {
        itemImageButtonTapped()
    }
    
    @IBAction func editInfoButtonPressed(_ sender: Any) {
        editInfoButtonTapped()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
}
