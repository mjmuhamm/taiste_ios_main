//
//  DisclaimerViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 5/29/23.
//

import UIKit
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_Theming
import MaterialComponents.MaterialTextControls_FilledTextAreasTheming
import MaterialComponents.MaterialTextControls_FilledTextFieldsTheming
import MaterialComponents.MaterialTextControls_OutlinedTextAreasTheming
import MaterialComponents.MaterialTextControls_OutlinedTextFieldsTheming


class DisclaimerViewController: UIViewController {

    @IBOutlet weak var okButton: MDCButton!
    var newOrEdit = "new"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        okButton.applyOutlinedTheme(withScheme: globalContainerScheme())
        okButton.layer.cornerRadius = 2
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true)
        
    }
    
    @IBAction func okButtonPressed(_ sender: Any) {
        if newOrEdit == "new" {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChefPersonal") as? ChefPersonalViewController {
            self.present(vc, animated: true, completion: nil)
        }
        } else {
            self.dismiss(animated: true)
        }
    }
    

}
