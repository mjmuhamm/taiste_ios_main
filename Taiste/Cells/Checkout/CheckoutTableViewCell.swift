//
//  CheckoutTableViewCell.swift
//  Taiste
//
//  Created by Malik Muhammad on 2/26/22.
//

import UIKit

class CheckoutTableViewCell: UITableViewCell {

    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var chefImage: UIImageView!
    
    @IBOutlet weak var eventTypeAndQuantity: UILabel!
    
    @IBOutlet weak var location: UILabel!
    
    @IBOutlet weak var dates: UILabel!
    
    @IBOutlet weak var noteToChef: UILabel!
    @IBOutlet weak var eventCost: UILabel!
    
    var chefImageButtonTapped : (() -> ()) = {}
    var cancelButtonTapped : (() -> ()) = {}
    var orderDetailButtonTapped : (() -> ()) = {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func orderDeailPressed(_ sender: Any) {
        orderDetailButtonTapped()
    }
    @IBAction func chefImageButtonPressed(_ sender: UIButton) {()
        chefImageButtonTapped()
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        cancelButtonTapped()
    }
    
}
