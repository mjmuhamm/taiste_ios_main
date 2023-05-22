//
//  UserOrderPostTableViewCell.swift
//  Taiste
//
//  Created by Malik Muhammad on 2/28/22.
//

import UIKit
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_Theming
import MaterialComponents.MaterialTextControls_FilledTextAreasTheming
import MaterialComponents.MaterialTextControls_FilledTextFieldsTheming
import MaterialComponents.MaterialTextControls_OutlinedTextAreasTheming
import MaterialComponents.MaterialTextControls_OutlinedTextFieldsTheming

class UserOrderPostTableViewCell: UITableViewCell {

    @IBOutlet weak var itemType: UILabel!
    
    
    @IBOutlet weak var orderDate: UILabel!
    
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var eventTypeAndQuantity: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var showDatesButton: MDCButton!
    @IBOutlet weak var showNotesButton: MDCButton!
    @IBOutlet weak var messagesForTravelFeeButton: MDCButton!
    
    @IBOutlet weak var cancelButtonPressed: MDCButton!
    @IBOutlet weak var messageButtonPressed: MDCButton!
    //before 48 , after 37-29 = 8
    
    @IBOutlet weak var cancelConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var messageConstraint: NSLayoutConstraint!
    @IBOutlet weak var showInfoView: UIView!
    @IBOutlet weak var showInfoLabel: UILabel!
    @IBOutlet weak var showInfoText: UILabel!
    @IBOutlet weak var showInfoOkButton: MDCButton!
    
    
    var showDatesButtonTapped : (() -> ()) = {}
    var showNotesButtonTapped : (() -> ()) = {}
    var messagesForTravelFeeButtonTapped : (() -> ()) = {}
    var cancelButtonTapped : (() -> ()) = {}
    var messagesButtonTapped : (() -> ()) = {}
    var showInfoOkButtonTapped : (() -> ()) = {}
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        showDatesButton.applyOutlinedTheme(withScheme: globalContainerScheme())
        showNotesButton.applyOutlinedTheme(withScheme: globalContainerScheme())
        showDatesButton.layer.cornerRadius = 2
        showNotesButton.layer.cornerRadius = 2
        
        messagesForTravelFeeButton.applyOutlinedTheme(withScheme: globalContainerScheme())
        cancelButtonPressed.applyOutlinedTheme(withScheme: secondGlobalContainerScheme())
        messagesForTravelFeeButton.layer.cornerRadius = 2
        cancelButtonPressed.layer.cornerRadius = 2
        
        messageButtonPressed.applyOutlinedTheme(withScheme: globalContainerScheme())
        showInfoOkButton.applyOutlinedTheme(withScheme: globalContainerScheme())
        messageButtonPressed.layer.cornerRadius = 2
        showInfoOkButton.layer.cornerRadius = 2
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    
    @IBAction func showDatesButtonPressed(_ sender: Any) {
        showDatesButtonTapped()
    }
    @IBAction func showNotesButtonPressed(_ sender: Any) {
        showNotesButtonTapped()
    }
    
    @IBAction func messagesForTravelFeeButtonPressed(_ sender: Any) {
        messagesForTravelFeeButtonTapped()
    }
    
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        cancelButtonTapped()
    }
    
    @IBAction func messageButtonPressed(_ sender: Any) {
        messagesButtonTapped()
    }
    
    
    @IBAction func showInfoOkButtonPressed(_ sender: Any) {
        showInfoOkButtonTapped()
    }
    
}
