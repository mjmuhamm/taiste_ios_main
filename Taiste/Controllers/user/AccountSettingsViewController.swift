//
//  AccountSettingsChefViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 3/4/22.
//

import UIKit
import Firebase
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_Theming
import MaterialComponents.MaterialTextControls_FilledTextAreasTheming
import MaterialComponents.MaterialTextControls_FilledTextFieldsTheming
import MaterialComponents.MaterialTextControls_OutlinedTextAreasTheming
import MaterialComponents.MaterialTextControls_OutlinedTextFieldsTheming

class AccountSettingsViewController: UIViewController {

    @IBOutlet weak var logoutButton: MDCButton!
    
    @IBOutlet weak var deleteAccountButton: MDCButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        logoutButton.applyOutlinedTheme(withScheme: globalContainerScheme())
        deleteAccountButton.applyOutlinedTheme(withScheme: secondGlobalContainerScheme())
        logoutButton.layer.cornerRadius = 7
        deleteAccountButton.layer.cornerRadius = 7
        
        
        logoutButton.setTitleColor(UIColor.white, for: .normal)
        logoutButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dataPrivacyButtonPressed(_ sender: Any) {
    }
    @IBAction func termsOfServiceButtonPressed(_ sender: Any) {
    }
    
    @IBAction func reportAnIssueButtonPressed(_ sender: Any) {
    }
    
    @IBAction func logoutButtonPressed(_ sender: MDCButton) {
        
        try? Auth.auth().signOut()
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "Start") as? StartViewController  {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func deleteAccountButtonPressed(_ sender: MDCButton) {
        Auth.auth().currentUser!.delete { error in
            if error == nil {
                self.showToastCompletion(message: "Your account has been deleted.", font: .systemFont(ofSize: 12))
            } else {
                self.showToast(message: "Something went wrong. Please try again.", font: .systemFont(ofSize: 12))
            }
        }
    }
    
    
    func showToast(message : String, font: UIFont) {
        
        let toastLabel = UILabel(frame: CGRect(x: 0, y: self.view.frame.size.height-180, width: (self.view.frame.width), height: 70))
        toastLabel.backgroundColor = UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.numberOfLines = 4
        toastLabel.layer.cornerRadius = 1;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    
    func showToastCompletion(message : String, font: UIFont) {
        
        let toastLabel = UILabel(frame: CGRect(x: 0, y: self.view.frame.size.height-180, width: (self.view.frame.width), height: 70))
        toastLabel.backgroundColor = UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.numberOfLines = 4
        toastLabel.layer.cornerRadius = 1;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "Start") as? StartViewController  {
                self.present(vc, animated: true, completion: nil)
            }
            toastLabel.removeFromSuperview()
        })
    }
}

