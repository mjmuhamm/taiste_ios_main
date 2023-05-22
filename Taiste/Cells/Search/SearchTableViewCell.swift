//
//  SearchTableViewCell.swift
//  Taiste
//
//  Created by Malik Muhammad on 5/3/23.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userFullName: UILabel!
    
    var userProfileTapped : (() -> ()) = {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func profileButtonPressed(_ sender: Any) {
        userProfileTapped()
    }
    
}
