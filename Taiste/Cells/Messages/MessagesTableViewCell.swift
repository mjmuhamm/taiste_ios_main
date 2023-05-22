//
//  MessagesTableViewCell.swift
//  Taiste
//
//  Created by Malik Muhammad on 5/2/23.
//

import UIKit

class MessagesTableViewCell: UITableViewCell {

    @IBOutlet weak var awayImage: UIImageView!
    @IBOutlet weak var awayMessage: UILabel!
    @IBOutlet weak var awayDate: UILabel!
    
    @IBOutlet weak var awayButton: UIButton!
    @IBOutlet weak var homeButton: UIButton!
    
    @IBOutlet weak var homeImage: UIImageView!
    @IBOutlet weak var homeMessage: UILabel!
    @IBOutlet weak var homeDate: UILabel!
    
    @IBOutlet weak var travelFeeMessage: UILabel!
    
    var profileButtonTapped : (() -> ()) = {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        awayImage.layer.borderWidth = 1
        awayImage.layer.masksToBounds = false
        awayImage.layer.borderColor = UIColor.white.cgColor
        awayImage.layer.cornerRadius = awayImage.frame.height/2
        awayImage.clipsToBounds = true
        
        
        homeImage.layer.borderWidth = 1
        homeImage.layer.masksToBounds = false
        homeImage.layer.borderColor = UIColor.white.cgColor
        homeImage.layer.cornerRadius = homeImage.frame.height/2
        homeImage.clipsToBounds = true
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func awayButtonPressed(_ sender: Any) {
        profileButtonTapped()
    }
    
    @IBAction func homeButtonPressed(_ sender: Any) {
        profileButtonTapped()
    }
}
