//
//  NotificationsTableViewCell.swift
//  Taiste
//
//  Created by Malik Muhammad on 5/31/23.
//

import UIKit

class NotificationsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var message2: UILabel!
    @IBOutlet weak var buttonConstant: NSLayoutConstraint!
    @IBOutlet weak var userImageButton: UIButton!
    
    var userImageTapped : (() -> ()) = {}
    var notificationTapped : (() -> ()) = {}
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
    @IBAction func userImageButtonPressed(_ sender: Any) {
        userImageTapped()
    }
    
    @IBAction func message2ButtonPressed(_ sender: Any) {
        notificationTapped()
    }
}
