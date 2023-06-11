//
//  AccountSettingsChefViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 3/4/22.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_Theming
import MaterialComponents.MaterialTextControls_FilledTextAreasTheming
import MaterialComponents.MaterialTextControls_FilledTextFieldsTheming
import MaterialComponents.MaterialTextControls_OutlinedTextAreasTheming
import MaterialComponents.MaterialTextControls_OutlinedTextFieldsTheming

class AccountSettingsViewController: UIViewController {

    let db = Firestore.firestore()
    let storage = Storage.storage()
    @IBOutlet weak var logoutButton: MDCButton!
    @IBOutlet weak var deleteAccountButton: MDCButton!
    
    @IBOutlet weak var privatizeYes: MDCButton!
    @IBOutlet weak var privatizeNo: MDCButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPrivatizeData()

        
        logoutButton.applyOutlinedTheme(withScheme: globalContainerScheme())
        deleteAccountButton.applyOutlinedTheme(withScheme: secondGlobalContainerScheme())
        logoutButton.layer.cornerRadius = 7
        deleteAccountButton.layer.cornerRadius = 7
        
        
        logoutButton.setTitleColor(UIColor.white, for: .normal)
        logoutButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
        // Do any additional setup after loading the view.
    }
    
    private func loadPrivatizeData() {
        if Auth.auth().currentUser != nil {
            db.collection("User").document(Auth.auth().currentUser!.uid).getDocument { document, error in
                if error == nil {
                    let data = document!.data()
                    
                    if let privatizeData = data!["privatizeData"] as? String {
                        
                        if privatizeData == "yes" {
                            self.privatizeYes.setTitleColor(UIColor.white, for: .normal)
                            self.privatizeYes.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
                            self.privatizeNo.backgroundColor = UIColor.white
                            self.privatizeNo.setTitleColor(UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1), for: .normal)
                        } else {
                            self.privatizeNo.setTitleColor(UIColor.white, for: .normal)
                            self.privatizeNo.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
                            self.privatizeYes.backgroundColor = UIColor.white
                            self.privatizeYes.setTitleColor(UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1), for: .normal)
                        }
                    }
                    
                }
            }
        } else {
            self.showToast(message: "Something went wrong. Please check your connection.", font: .systemFont(ofSize: 12))
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func profileButtonPressed(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserPersonal") as? UserPersonalViewController  {
            vc.newOrEdit = "edit"
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func privatizeYesPressed(_ sender: Any) {
        let data : [String: Any] = ["privatizeData" : "yes"]
        db.collection("User").document(Auth.auth().currentUser!.uid).updateData(data)
        privatizeYes.setTitleColor(UIColor.white, for: .normal)
        privatizeYes.backgroundColor =  UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
        privatizeNo.backgroundColor = UIColor.white
        privatizeNo.setTitleColor( UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1), for: .normal)
    }
    
    @IBAction func privatizeNoPressed(_ sender: Any) {
        let data : [String: Any] = ["privatizeData" : "no"]
        db.collection("User").document(Auth.auth().currentUser!.uid).updateData(data)
        privatizeNo.setTitleColor(UIColor.white, for: .normal)
        privatizeNo.backgroundColor =  UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
        privatizeYes.backgroundColor = UIColor.white
        privatizeYes.setTitleColor( UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1), for: .normal)
    }
    
    @IBAction func dataPrivacyButtonPressed(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "PrivacyPolicy") as? PrivacyPolicyViewController  {
            self.present(vc, animated: true, completion: nil)
        }
    }
    @IBAction func termsOfServiceButtonPressed(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "TermsOfService") as? TermsOfServiceViewController  {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func reportAnIssueButtonPressed(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReportAnIssue") as? ReportAnIssueViewController  {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func logoutButtonPressed(_ sender: MDCButton) {
        
        try? Auth.auth().signOut()
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "Start") as? StartViewController  {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func deleteAccountButtonPressed(_ sender: MDCButton) {
        let alert = UIAlertController(title: "Are you sure you want to delete your account?", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (handler) in
            if Auth.auth().currentUser != nil {
                Auth.auth().currentUser!.delete { error in
                    if error == nil {
                        self.db.collection("Usernames").document(Auth.auth().currentUser!.uid).delete()
                        self.db.collection("User").document(Auth.auth().currentUser!.uid).delete()
                        let storageRef = self.storage.reference()
                        Task {
                            try? await storageRef.child("users/\(Auth.auth().currentUser!.email!)").delete()
                        }
                        
                        self.showToastCompletion(message: "Your account has been deleted.", font: .systemFont(ofSize: 12))
                        
                    } else {
                        self.showToast(message: "Something went wrong. Please try again.", font: .systemFont(ofSize: 12))
                    }
                }
            } else {
                self.showToast(message: "Something went wrong. Please check your connection.", font: .systemFont(ofSize: 12))
            }
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (handler) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
       
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
            self.performSegue(withIdentifier: "MenuItemToHomeSegue", sender: self)
            toastLabel.removeFromSuperview()
        })
    }
}

