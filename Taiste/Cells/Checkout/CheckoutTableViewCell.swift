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
    
    //4.5
    //41
    
    @IBOutlet weak var noteConstant: NSLayoutConstraint!
    @IBOutlet weak var noteToChef: UILabel!
    @IBOutlet weak var eventCost: UILabel!
    
    @IBOutlet weak var allergies: UILabel!
    @IBOutlet weak var additionalRequests: UILabel!
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
    
    @IBAction func clickHere(_ sender: Any) {
        orderDetailButtonTapped()
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
