//
//  ChefItemTableViewCell.swift
//  Taiste
//
//  Created by Malik Muhammad on 2/25/22.
//

import UIKit

class ChefItemTableViewCell: UITableViewCell {

    @IBOutlet weak var editImage: UIButton!
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var itemImage: UIImageView!
    
    @IBOutlet weak var itemDescription: UILabel!
    
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var likeText: UILabel!
    @IBOutlet weak var orderText: UILabel!
    
    @IBOutlet weak var ratingText: UILabel!
    @IBOutlet weak var itemPrice: UILabel!
    
    var editButtonTapped : (() -> ()) = {}
    var itemImageButtonTapped : (() -> ()) = {}
    var likeImageButtonTapped : (() -> ()) = {}
    var orderButtonTapped : (() -> ()) = {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        itemImage.layer.cornerRadius = 4
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func itemImageButton(_ sender: Any) {
        itemImageButtonTapped()
        
    }

    @IBAction func likeImageButton(_ sender: Any) {
        likeImageButtonTapped()
    }
    
    @IBAction func editButton(_ sender: Any) {
        editButtonTapped()
    }
    
    
    @IBAction func orderButton(_ sender: Any) {
        orderButtonTapped()
    }
    
}
