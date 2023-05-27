//
//  ReportAnIssueViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 5/26/23.
//

import UIKit
import Firebase
import FirebaseFirestore

class ReportAnIssueViewController: UIViewController, UITextViewDelegate {

    let db = Firestore.firestore()
    
    @IBOutlet weak var subjectToIssue: UITextField!
    @IBOutlet weak var issueInDetail: UITextView!
    @IBOutlet weak var chefOrEvent: UITextField!
    @IBOutlet weak var anythingElse: UITextField!
    
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
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if subjectToIssue.text == "" {
            showToast(message: "Please enter a subject to your issue.", font: .systemFont(ofSize: 12))
        } else if issueInDetail.text == "" {
            showToast(message: "Please enter your issue in detail.", font: .systemFont(ofSize: 12))
        } else if chefOrEvent.text == "" {
            showToast(message: "Please describe whether the issue was with a chef, event, transaction, or with the app.", font: .systemFont(ofSize: 12))
        } else {
            
            let data : [String: Any] = ["subjectToIssue" : subjectToIssue.text!, "issueInDetail" : issueInDetail.text!, "issueAbout" : chefOrEvent.text!, "anythingElse" : anythingElse.text!]
            
            db.collection("Issues").document().setData(data)
            showToastCompletion(message: "Thank you. Someone will get back to you shortly.", font: .systemFont(ofSize: 12))
            
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
