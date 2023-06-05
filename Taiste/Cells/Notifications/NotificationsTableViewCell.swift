//
//  NotificationsTableViewCell.swift
//  Taiste
//
//  Created by Malik Muhammad on 5/31/23.
//

import UIKit

class NotificationsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var notification: UILabel!
    @IBOutlet weak var notificationDate: UILabel!
    var notificationTapped : (() -> ()) = {}
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func notificationClickButton(_ sender: Any) {
        notificationTapped()
    }
}
