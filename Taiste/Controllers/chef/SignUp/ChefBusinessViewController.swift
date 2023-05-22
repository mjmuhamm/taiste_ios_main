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
                        
                        if let city = data["city"] as? String , let state = data["state"] as? String, let zipCode = data["zipCode"] as? String, let streetAddress = data["streetAddress"] as? String {
                            
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
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if streetAddress.text == "" || city.text == "" || state.text == "" || zipCode.text == "" {
            self.showToast(message: "Please enter your business street address.", font: .systemFont(ofSize: 12))
        } else {
            
        if newOrEdit == "new" {
            let data : [String : Any] = ["streetAddress" : streetAddress.text, "city" : city.text, "state" : state.text, "zipCode" : zipCode.text]
            db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("BusinessInfo").document().setData(data)

            performSegue(withIdentifier: "ChefBusinessToChefBankingSegue", sender: self)
        } else {
            let data : [String : Any] = ["streetAddress" : streetAddress.text, "city" : city.text, "state" : state.text, "zipCode" : zipCode.text]
            
            let array = ["Cater Items", "Executive Items", "MealKit Items"]
            for i in 0..<array.count {
            
                db.collection("Chef").document(Auth.auth().currentUser!.uid).collection(array[i]).getDocuments { documents, error in
                    if error == nil {
                        if documents != nil {
                            for doc in documents!.documents {
                                let data = doc.data()
                                
                                let data1 : [String : Any] = ["city" : self.city.text , "state" : self.state.text , "zipCode" : self.zipCode.text]
                                if let city = data["city"] as? String, let state = data["state"] as? String, let zipCode = data["zipCode"] as? String {
                                    
                                    self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection(array[i]).document(doc.documentID).updateData(data1)
                                    self.db.collection(array[i]).document(doc.documentID).updateData(data1)
                                }
                                
                            }
                        }
                    }
                }
            }
            db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("BusinessInfo").document(self.documentId).updateData(data)
            
            showToast(message: "Business info saved.", font: .systemFont(ofSize: 12))
            }
            self.dismiss(animated: true, completion: nil)
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

