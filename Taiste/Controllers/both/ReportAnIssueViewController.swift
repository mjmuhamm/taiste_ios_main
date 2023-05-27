//
//  ReportAnIssueViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 5/26/23.
//

import UIKit
import Firebase
import FirebaseFirestore
import MaterialComponents.MaterialButtons
import MaterialComponents

class ReportAnIssueViewController: UIViewController, UITextViewDelegate {

    let db = Firestore.firestore()
    
    @IBOutlet weak var issueWithEventYesButton: MDCButton!
    @IBOutlet weak var issueWithEventNoButton: MDCButton!
    
    
    @IBOutlet weak var briefDescriptionConstraint: NSLayoutConstraint!
    //19
    //105
    
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var itemTitle: UITextField!
    @IBOutlet weak var descriptionOfIssue: UITextField!
    @IBOutlet weak var issueInDetail: UITextView!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var email: UITextField!
    
    private var issueWithEventYes = 1
    private var issueWithEventNo = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        issueInDetail.text = ""
        issueInDetail.textColor = UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1)
    }
    
    @IBAction func issueWithEventYesButtonPressed(_ sender: Any) {
        briefDescriptionConstraint.constant = 105
        itemTitleLabel.isHidden = false
        itemTitle.isHidden = false
        issueWithEventYesButton.setTitleColor(UIColor.white, for: .normal)
        issueWithEventYesButton.backgroundColor = UIColor.red
        issueWithEventNoButton.backgroundColor = UIColor.white
        issueWithEventNoButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
    }
    
    @IBAction func issueWithEventNoButtonPressed(_ sender: Any) {
        briefDescriptionConstraint.constant = 19
        itemTitleLabel.isHidden = true
        itemTitle.isHidden = true
        issueWithEventNoButton.setTitleColor(UIColor.white, for: .normal)
        issueWithEventNoButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
        issueWithEventYesButton.backgroundColor = UIColor.white
        issueWithEventYesButton.setTitleColor(UIColor.red, for: .normal)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if descriptionOfIssue.text == "" {
            showToast(message: "Please provide a brief description of your issue..", font: .systemFont(ofSize: 12))
        } else if issueInDetail.text == "" {
            showToast(message: "Please enter your issue in detail.", font: .systemFont(ofSize: 12))
        } else if issueWithEventYes == 1 && itemTitle.text == "" {
            showToast(message: "Please provide an item title for the event.", font: .systemFont(ofSize: 12))
        } else if phoneNumber.text == "" && email.text == "" {
            showToast(message: "Please provide at least one way to contact you.", font: .systemFont(ofSize: 12))
        } else {
            var itemTitle = ""
            var phoneNumber = ""
            var email = ""
            if self.itemTitle.text != "" {
                itemTitle = self.itemTitle.text!
            }
            if self.phoneNumber.text != "" {
                phoneNumber = self.phoneNumber.text!
            }
            if self.email.text != "" {
                email = self.email.text!
            }
            var issueWithEvent = 0
            if issueWithEventYes == 1 {
                issueWithEvent = 1
            } else {
                issueWithEvent = 0
            }
            
            let date = Date()
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            
            let data : [String: Any] = ["briefDescription" : descriptionOfIssue.text!, "detailedDescription" : issueInDetail.text!, "phone" : phoneNumber, "email" : email, "issueWithEvent" : issueWithEvent, "itemTitle" : itemTitle, "user" : Auth.auth().currentUser!.uid, "date" : "\(df.string(from: Date()))"]
            
            db.collection("Issues").document().setData(data)
            showToastCompletion(message: "Thank you. Someone will get back to you really soon.", font: .systemFont(ofSize: 12))
            
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
                self.dismiss(animated: true)
                toastLabel.removeFromSuperview()
            })
        }
    
    
}
