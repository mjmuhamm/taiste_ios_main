//
//  TravelFeeViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 5/5/23.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth


class TravelFeeViewController: UIViewController {
    
    let date = Date()
    let df = DateFormatter()
    let db = Firestore.firestore()
    
    @IBOutlet weak var travelFeeTitle: UILabel!
    @IBOutlet weak var travelFeePrice: UITextField!
    @IBOutlet weak var engageLabel: UILabel!
    @IBOutlet weak var requestButton: UIButton!
    
    var travelFeePriceText = ""
    var userImageId = ""
    var chefOrUser = ""
    var order : Orders?
    override func viewDidLoad() {
        super.viewDidLoad()

        engageLabel.text = "This is the amount requested for travel by the chef."
        requestButton.setTitle("Pay", for: .normal)
        travelFeePrice.text = travelFeePriceText
        
        
        df.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func requestButtonPressed(_ sender: Any) {
        let data : [String : Any] = ["chefOrUser" : chefOrUser, "user" : Auth.auth().currentUser!.uid, "message" : "@\(Auth.auth().currentUser!.displayName!) has requested $\(self.travelFeePrice.text!) for travel.", "date" : df.string(from: date), "userEmail": "", "travelFee" : self.travelFeePrice.text!]
        
        if travelFeePrice.text != nil {
            db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("TravelFeeMessages").document(order!.documentId).collection(order!.itemTitle).document().setData(data)
            db.collection("User").document(userImageId).collection("TravelFeeMessages").document(order!.documentId).collection(order!.itemTitle).document().setData(data)
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    

}
