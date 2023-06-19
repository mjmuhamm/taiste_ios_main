//
//  ChefOrdersTableViewCell.swift
//  Taiste
//
//  Created by Malik Muhammad on 3/4/22.
//

import UIKit
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_Theming
import MaterialComponents.MaterialTextControls_FilledTextAreasTheming
import MaterialComponents.MaterialTextControls_FilledTextFieldsTheming
import MaterialComponents.MaterialTextControls_OutlinedTextAreasTheming
import MaterialComponents.MaterialTextControls_OutlinedTextFieldsTheming

class ChefOrdersTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemType: UILabel!
    @IBOutlet weak var orderDate: UILabel!
    
    
    @IBOutlet weak var showInfoView: UIView!
    @IBOutlet weak var showInfoLabel: UILabel!
    @IBOutlet weak var showInfoText: UILabel!
    @IBOutlet weak var showInfoOkButton: MDCButton!
    
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var eventTypeAndQauntity: UILabel!
    
    @IBOutlet weak var location: UILabel!
    
    @IBOutlet weak var showDatesButton: MDCButton!
    @IBOutlet weak var showNotesButton: MDCButton!
    
    @IBOutlet weak var messagesForTravelFeeButton: MDCButton!
    
    @IBOutlet weak var cancelButton: MDCButton!
    
    @IBOutlet weak var messagesButton: MDCButton!
    
    @IBOutlet weak var costOfEventText: UILabel!
    @IBOutlet weak var taxesAndFeesText: UILabel!
    @IBOutlet weak var takeHomeText: UILabel!
    
    
    @IBOutlet weak var showNotesConstraint: NSLayoutConstraint!
    @IBOutlet weak var cancelConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageConstraint: NSLayoutConstraint!
    //before 48 , after 37-29 = 8
    
    var showDatesButtonTapped : (() -> ()) = {}
    var showNotesButtonTapped : (() -> ()) = {}
    var messagesForTravelFeeButtonTapped : (() -> ()) = {}
    var cancelButtonTapped : (() -> ()) = {}
    var messagesButtonTapped : (() -> ()) = {}
    var showInfoOkButtonTapped : (() -> ()) = {}
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        showInfoText.text = ""
        itemTitle.text = ""
        eventTypeAndQauntity.text = ""
        location.text = ""
        costOfEventText.text = ""
        taxesAndFeesText.text = ""
        takeHomeText.text = ""
        
        
        showDatesButton.applyOutlinedTheme(withScheme: globalContainerScheme())
        showNotesButton.applyOutlinedTheme(withScheme: globalContainerScheme())
        showDatesButton.layer.cornerRadius = 2
        showNotesButton.layer.cornerRadius = 2
        
        messagesForTravelFeeButton.applyOutlinedTheme(withScheme: globalContainerScheme())
        cancelButton.applyOutlinedTheme(withScheme: secondGlobalContainerScheme())
        messagesForTravelFeeButton.layer.cornerRadius = 2
        cancelButton.layer.cornerRadius = 2
        
        messagesButton.applyOutlinedTheme(withScheme: globalContainerScheme())
        showInfoOkButton.applyOutlinedTheme(withScheme: globalContainerScheme())
        messagesButton.layer.cornerRadius = 2
        showInfoOkButton.layer.cornerRadius = 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func showDatesButtonPressed(_ sender: Any) {
        showDatesButtonTapped()
    }
    
    @IBAction func showNotesButtonPressed(_ sender: Any) {
        showNotesButtonTapped()
    }
    
    @IBAction func messagesForTravelFeePressed(_ sender: Any) {
        messagesForTravelFeeButtonTapped()
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        cancelButtonTapped()
    }
    @IBAction func messagesButtonPressed(_ sender: Any) {
        messagesButtonTapped()
    }
    
    @IBAction func showInfoOkButtonPressed(_ sender: Any) {
        showInfoOkButtonTapped()
    }
    
}
