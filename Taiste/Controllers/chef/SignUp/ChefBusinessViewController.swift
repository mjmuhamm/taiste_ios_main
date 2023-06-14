//
//  ChefBusinessViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 4/29/23.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ChefBusinessViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var streetAddress: UITextField!
    
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var state: UITextField!
    @IBOutlet weak var zipCode: UITextField!
    @IBOutlet weak var chefPassion: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    
    private var documentId = ""
    
    var newOrEdit = "new"
    override func viewDidLoad() {
        super.viewDidLoad()

        if newOrEdit == "new" {
            saveButton.setTitle("Continue", for: .normal)
        } else {
            loadBusinessInfo()
            saveButton.setTitle("Save", for: .normal)
        }
    }
    
    private func loadBusinessInfo() {
        self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("BusinessInfo").getDocuments { documents, error in
            if error == nil {
                if documents != nil {
                    for doc in documents!.documents {
                        let data = doc.data()
                        
                        if let city = data["city"] as? String , let state = data["state"] as? String, let zipCode = data["zipCode"] as? String, let streetAddress = data["streetAddress"] as? String, let chefPassion = data["chefPassion"] as? String {
                            
                            self.chefPassion.text = chefPassion
                            self.streetAddress.text = streetAddress
                            self.city.text = city
                            self.state.text = state
                            self.zipCode.text = zipCode
                            self.documentId = doc.documentID
                        }
                    }
                }
            }
        }
    }
    

    @IBAction func backButtonPressed(_ sender: Any) {
        self.showToast(message: "To return, please exit app, login and return to this screen in settings.", font: .systemFont(ofSize: 12))
    }
    
    private func stateFilter(state: String) -> String {
        var stateAbbr : [String] = ["AL", "AK", "AZ", "AR", "AS", "CA", "CO", "CT", "DE", "DC", "FL", "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", "MA", "MI", "MN", "MS", "MO", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "PR", "RI", "SC", "SD", "TN", "TX", "TT", "UT", "VT", "VA", "VI", "WA", "WY", "WV", "WI", "WY" ]
        
        
        for i in 0..<stateAbbr.count {
            let a = stateAbbr[i].lowercased()
            if a == state.lowercased() {
                return "good"
            }
        }
        
        return "not good"
      
        
    }
    @IBAction func saveButtonPressed(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            if streetAddress.text == "" || city.text == "" || state.text == "" || zipCode.text == "" {
                self.showToast(message: "Please enter your business street address.", font: .systemFont(ofSize: 12))
            } else if stateFilter(state: state.text!) != "good" {
                self.showToast(message: "Please enter the abbreviation of your state.", font: .systemFont(ofSize: 12))
            } else if chefPassion.text == "" {
                self.showToast(message: "Please enter a passion for cooking.", font: .systemFont(ofSize: 12))
            } else {
                
                if newOrEdit == "new" {
                    let data : [String : Any] = ["chefPassion" : chefPassion.text!, "streetAddress" : streetAddress.text!, "city" : city.text!, "state" : state.text!, "zipCode" : zipCode.text!]
                    db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("BusinessInfo").document().setData(data)
                    db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("PersonalInfo").getDocuments { documents, error in
                        if error == nil {
                            for doc in documents!.documents {
                                self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("PersonalInfo").document(doc.documentID).updateData(data)
                            }
                        }
                    }
                    
                    performSegue(withIdentifier: "ChefBusinessToChefBankingSegue", sender: self)
                } else {
                    let data : [String : Any] = ["chefPassion" : chefPassion.text!, "streetAddress" : streetAddress.text, "city" : city.text, "state" : state.text, "zipCode" : zipCode.text]
                    db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("PersonalInfo").getDocuments { documents, error in
                        if error == nil {
                            for doc in documents!.documents {
                                self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("PersonalInfo").document(doc.documentID).updateData(data)
                            }
                        }
                    }
                    
                    let array = ["Cater Items", "Executive Items", "MealKit Items"]
                    
                    for i in 0..<array.count {
                        
                        db.collection("Chef").document(Auth.auth().currentUser!.uid).collection(array[i]).getDocuments { documents, error in
                            if error == nil {
                                if documents != nil {
                                    for doc in documents!.documents {
                                        let data = doc.data()
                                        
                                        let data1 : [String : Any] = ["chefPassion" : self.chefPassion.text!, "city" : self.city.text! , "state" : self.state.text! , "zipCode" : self.zipCode.text!]
                                        self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection(array[i]).document(doc.documentID).updateData(data1)
                                        
                                        self.db.collection(array[i]).document(doc.documentID).updateData(data1)
                                        
                                        
                                    }
                                }
                            }
                        }
                    }
                    db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("BusinessInfo").document(self.documentId).updateData(data)
                    showToast(message: "Business info saved.", font: .systemFont(ofSize: 12))
                    self.dismiss(animated: true, completion: nil)
                }
                
            }
        } else {
            self.showToast(message: "Something went wrong. Please check your connection.", font: .systemFont(ofSize: 12))
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
        UIView.animate(withDuration: 5.0, delay: 0.1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            self.dismiss(animated: true, completion: nil)
            toastLabel.removeFromSuperview()
        })
    }
    
}


