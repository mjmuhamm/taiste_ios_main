//
//  AccountSettingsChefViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 3/4/22.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_Theming
import MaterialComponents.MaterialTextControls_FilledTextAreasTheming
import MaterialComponents.MaterialTextControls_FilledTextFieldsTheming
import MaterialComponents.MaterialTextControls_OutlinedTextAreasTheming
import MaterialComponents.MaterialTextControls_OutlinedTextFieldsTheming

class AccountSettingsChefViewController: UIViewController {

    let db = Firestore.firestore()
    let storage = Storage.storage()
    
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
    
    @IBAction func personalButtonPressed(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChefPersonal") as? ChefPersonalViewController {
            vc.newOrEdit = "edit"
            self.present(vc, animated: true, completion: nil)
        }
       
    }
    
    @IBAction func businessButtonPressed(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChefBusiness") as? ChefBusinessViewController {
            vc.newOrEdit = "edit"
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func bankingButtonPressed(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChefBanking") as? ChefBankingViewController {
            vc.newAccountOrEditedAccount = "edit"
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    @IBAction func guideToPosting(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "GuideToPosting") as? GuideToPostingViewController  {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func dataPrivacyButtonPressed(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "PrivacyPolicy") as? PrivacyPolicyViewController {
            self.present(vc, animated: true, completion: nil)
        }
    }
    @IBAction func termsOfServiceButtonPressed(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "TermsOfService") as? TermsOfServiceViewController {
        self.present(vc, animated: true, completion: nil)
    }
    }
    
    @IBAction func regulationAgreementPressed(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "Disclaimer") as? DisclaimerViewController {
            vc.newOrEdit = "edit"
        self.present(vc, animated: true, completion: nil)
    }
    }
    
    @IBAction func reportAnIssueButtonPressed(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReportAnIssue") as? ReportAnIssueViewController  {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func caterItemsButtonPressed(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "GuideToCaterItems") as? GuideToCaterItemsViewController  {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func executiveItemButtonPressed(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "GuideToExecutiveItems") as? GuideToExecutiveItemsViewController  {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func mealKitsButtonPressed(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "GuideToMealKits") as? GuideToMealKitViewController  {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        if Reachability.isConnectedToNetwork(){
        print("Internet Connection Available!")
        
        try? Auth.auth().signOut()
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "Start") as? StartViewController  {
            self.present(vc, animated: true, completion: nil)
        }
        } else {
        self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
       }
    }
    
    @IBAction func deleteAccountButtonPressed(_ sender: Any) {
        if Reachability.isConnectedToNetwork(){
        print("Internet Connection Available!")
      
        let alert = UIAlertController(title: "Are you sure you want to delete your account?", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (handler) in
            let uid = Auth.auth().currentUser!.uid
            
            Auth.auth().currentUser!.delete { error in
                if error == nil {
                    self.db.collection("Usernames").document(uid).delete()
                    self.db.collection("Chef").document(uid).delete()
                    
                    Task {
                        try? await self.storage.reference().child("chefs/\(uid)").delete()
                    }
                    self.showToastCompletion(message: "Your account has been deleted.", font: .systemFont(ofSize: 12))
                    
                } else {
                    self.showToast(message: "Something went wrong. Please try again.", font: .systemFont(ofSize: 12))
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (handler) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
        } else {
        self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
       }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChefSettingsToHome" {
            let info = segue.destination as! StartViewController
            info.delete = "yes"
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
            self.performSegue(withIdentifier: "ChefSettingsToHome", sender: self)
            toastLabel.removeFromSuperview()
        })
    }
}

