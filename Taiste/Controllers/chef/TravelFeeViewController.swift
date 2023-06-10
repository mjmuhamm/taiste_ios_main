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
        if travelFeePrice.text != nil {
        db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("PersonalInfo").getDocuments { documents, error in
            if error == nil {
                for doc in documents!.documents {
                    let info = doc.data()
                    let chefName = info["chefName"] as! String
                    let data : [String : Any] = ["chefOrUser" : self.chefOrUser, "user" : Auth.auth().currentUser!.uid, "message" : "@\(chefName) has requested $\(self.travelFeePrice.text!) for travel.", "date" : self.df.string(from: self.date), "userEmail": "", "travelFee" : self.travelFeePrice.text!]
                    
                    let documentId = UUID().uuidString
                    self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("TravelFeeMessages").document(self.order!.documentId).collection(self.order!.orderDate).document(documentId).setData(data)
                    self.db.collection("User").document(self.userImageId).collection("TravelFeeMessages").document(self.order!.documentId).collection(self.order!.orderDate).document(documentId).setData(data)
                    self.sendMessage(title: "TravelFeeMessage", notification: "@\(chefName) has requested $\(self.travelFeePrice.text!) for travel.", topic: self.order!.documentId)
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
        
        
    }
    
    private func sendMessage(title: String, notification: String, topic: String) {
        let json: [String: Any] = ["title": title, "notification" : notification, "topic" : topic]
        
    
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        // MARK: Fetch the Intent client secret, Ephemeral Key secret, Customer ID, and publishable key
        var request = URLRequest(url: URL(string: "https://taiste-payments.onrender.com/send-message")!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
          guard let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                
                let self = self else {
            // Handle error
            return
          }
            
          DispatchQueue.main.async {
              
          }
        })
        task.resume()
    }

}
