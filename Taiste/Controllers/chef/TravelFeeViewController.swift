//
//  TravelFeeViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 5/5/23.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import StripePaymentSheet
import Stripe


class TravelFeeViewController: UIViewController {
    
    let date = Date()
    let df = DateFormatter()
    let db = Firestore.firestore()
    @IBOutlet weak var travelFeeLabel: UILabel!
    
    var paymentId = ""
    var paymentSheet: PaymentSheet?
    let backendCheckoutUrl = URL(string: "https://ruh.herokuapp.com/create-payment-intent")!
    
    @IBOutlet weak var travelFeeTitle: UILabel!
    @IBOutlet weak var travelFeePrice: UITextField!
    @IBOutlet weak var engageLabel: UILabel!
    @IBOutlet weak var requestButton: UIButton!
    
    var travelFeePriceText = ""
    var userImageId = ""
    var chefOrUser = ""
    var itemTitle = ""
    
    var orderMessageDocumentId = ""
    var orderMessageReceiverEmail = ""
    var orderMessageReceiverImageId = ""
    var totalCostOfEvent = ""
    var eventType = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if Auth.auth().currentUser!.displayName! == "User" {
            requestButton.addTarget(self, action: #selector(didTapPayButton), for: .touchUpInside)
            engageLabel.text = "This is the amount requested for travel by the chef."
            requestButton.setTitle("Pay", for: .normal)
            if travelFeePriceText != "" {
                fetchPaymentIntent(costOfEvent: Double(travelFeePriceText)!)
            }
            travelFeeLabel.text = "$\(travelFeePriceText)"
            travelFeePrice.isHidden = true
        } else {
            travelFeeLabel.isHidden = true
            travelFeePrice.isHidden = false
        }
        
        
        df.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func requestButtonPressed(_ sender: Any) {
        if Auth.auth().currentUser!.displayName! == "User" && travelFeePriceText != "" && Double(travelFeePriceText) != nil {
            
        } else {
            if travelFeePrice.text != nil {
                db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("PersonalInfo").getDocuments { documents, error in
                    if error == nil {
                        for doc in documents!.documents {
                            let info = doc.data()
                            let chefName = info["chefName"] as! String
                            let data : [String : Any] = ["chefOrUser" : self.chefOrUser, "userImageId" : Auth.auth().currentUser!.uid, "message" : "@\(guserName) has requested $\(self.travelFeePrice.text!) for travel.", "date" : self.df.string(from: self.date), "userEmail": Auth.auth().currentUser!.email!, "travelFee" : self.travelFeePrice.text!]
                            
                            let documentId = UUID().uuidString
                            self.db.collection(Auth.auth().currentUser!.displayName!).document(Auth.auth().currentUser!.uid).collection("TravelFeeMessages").document(self.orderMessageDocumentId).collection(self.orderMessageDocumentId).document(documentId).setData(data)
                            self.db.collection("User").document(self.orderMessageReceiverImageId).collection("TravelFeeMessages").document(self.orderMessageDocumentId).collection(self.orderMessageDocumentId).document(documentId).setData(data)
                            self.sendMessage(title: "TravelFeeMessage", notification: "@\(guserName) has requested $\(self.travelFeePrice.text!) for travel.", topic: self.orderMessageDocumentId)
                            self.dismiss(animated: true, completion: nil)
                        }
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
    
    private func fetchPaymentIntent(costOfEvent: Double) {
        
        let cost = costOfEvent * 100
        let a = String(format: "%.0f", cost)
        
        let json: [String: Any] = ["amount": a]
        
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        // MARK: Fetch the Intent client secret, Ephemeral Key secret, Customer ID, and publishable key
        var request = URLRequest(url: URL(string: "https://taiste-payments.onrender.com/create-payment-intent")!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
          guard let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                let customerId = json["customer"] as? String,
                let customerEphemeralKeySecret = json["ephemeralKey"] as? String,
                let IntentClientSecret = json["paymentIntent"] as? String,
                let publishableKey = json["publishableKey"] as? String,
                let paymentId = json["paymentId"] as? String,
                let self = self else {
            // Handle error
            return
          }

            STPAPIClient.shared.publishableKey = publishableKey
          // MARK: Create a PaymentSheet instance
          var configuration = PaymentSheet.Configuration()
          configuration.merchantDisplayName = "Taïste, Inc."
          configuration.customer = .init(id: customerId, ephemeralKeySecret: customerEphemeralKeySecret)
          // Set `allowsDelayedPaymentMethods` to true if your business can handle payment
          // methods that complete payment after a delay, like SEPA Debit and Sofort.
          configuration.allowsDelayedPaymentMethods = true
          self.paymentSheet = PaymentSheet(paymentIntentClientSecret: IntentClientSecret, configuration: configuration)
           

          DispatchQueue.main.async {
            
              self.paymentId = paymentId
          }
        })
        task.resume()
    }
    
    private func saveInfo() {
        if Auth.auth().currentUser != nil {
            let month = "\(df.string(from: date))".prefix(7).suffix(2)
            let year = "\(df.string(from: date))".prefix(4)
            let yearMonth = "\(year), \(month)"
            
            let calendar = Calendar(identifier: .gregorian)
            var currentWeek = calendar.component(.weekOfMonth, from: Date())
            var weekOfMonth = ""
            if currentWeek > 4 { weekOfMonth = "Week 4" } else { weekOfMonth = "Week \(currentWeek)" }
            
            
            let data: [String: Any] = ["paymentId" : paymentId, "userImageId" : Auth.auth().currentUser!.uid, "chefEmail" : orderMessageReceiverEmail, "menuItemId" : orderMessageDocumentId, "date" : df.string(from: date), "chefImageId" : orderMessageReceiverImageId]
            let data2: [String: Any] = ["orderUpdate" : "scheduled", "travelFee" : self.travelFeeLabel.text!]
            
//            let data3: [String: Any] = ["totalPay" : (totalCostOfEvent - (totalCostOfEvent * 0.05))]
            //        let data4: [String: Any] = ["Total" : ]
            
            let data5 : [String : Any] = ["chefOrUser" : Auth.auth().currentUser!.displayName!, "userImageId" : Auth.auth().currentUser!.uid, "message" : "Payment Received.", "date" : df.string(from: date), "userEmail": Auth.auth().currentUser!.email!, "travelFee" : "", "userName" : guserName, "fullName" : ""]
            db.collection(Auth.auth().currentUser!.displayName!).document(Auth.auth().currentUser!.uid).collection("TravelFeeMessages").document(orderMessageDocumentId).collection(orderMessageDocumentId).document("payment").setData(data5)
            db.collection("Chef").document(orderMessageReceiverImageId).collection("TravelFeeMessages").document(orderMessageDocumentId).collection(orderMessageDocumentId).document("payment").setData(data5)
            
            db.collection("TravelFeePayments").document(orderMessageDocumentId).setData(data)
            db.collection(Auth.auth().currentUser!.displayName!).document(Auth.auth().currentUser!.uid).collection("TravelFeePayments").document(orderMessageDocumentId).collection(orderMessageDocumentId).document("payment").setData(data)
            db.collection("Chef").document(orderMessageReceiverImageId).collection("TravelFeePayments").document(orderMessageDocumentId).collection(orderMessageDocumentId).document("payment").setData(data)
            
            db.collection("Chef").document(orderMessageReceiverImageId).collection("Orders").document(orderMessageDocumentId).updateData(data2)
            db.collection(Auth.auth().currentUser!.displayName!).document(Auth.auth().currentUser!.uid).collection("Orders").document(orderMessageDocumentId).updateData(data2)
            db.collection("Orders").document(orderMessageDocumentId).updateData(data2)
            sendMessage(title: "Travel Fee Received.", notification: "The travel fee has been paid.", topic: orderMessageDocumentId)
            let data6: [String:Any] = ["notification" : "Travel Fee has been paid for \(itemTitle).", "date" : df.string(from: Date())]
            let data7: [String:Any] = ["notifications" : "yes"]
                db.collection("Chef").document(orderMessageReceiverImageId).collection("Notifications").document().setData(data6)
            db.collection("Chef").document(orderMessageReceiverImageId).updateData(data7)
            
            let docRef = db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("Dashboard").document(eventType)
            let docRef1 = db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("Dashboard").document(eventType).collection(orderMessageDocumentId).document("Total")
            let docRef2 = db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("Dashboard").document(eventType).collection(orderMessageDocumentId).document("Month").collection(yearMonth).document("Total")
            let docRef3 = db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("Dashboard").document(eventType).collection(orderMessageDocumentId).document("Month").collection(yearMonth).document("Week").collection(weekOfMonth).document("Total")
            let docRef4 = db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("Dashboard").document(eventType).collection(orderMessageDocumentId).document("Month").collection(yearMonth).document("Week").collection(weekOfMonth).document(orderMessageDocumentId)
            
            docRef.getDocument { document, error in
                if error == nil {
                    if document != nil {
                        let data = document!.data()
                        let totalPay = data!["totalPay"] as! Double
                        let data4: [String: Any] = ["totalPay" : totalPay + Double(self.totalCostOfEvent)!]
                        docRef.updateData(data4)
                    }
                }
            }
            docRef1.getDocument { document, error in
                if error == nil {
                    if document != nil {
                        let data = document!.data()
                        let totalPay = data!["totalPay"] as! Double
                        let data4: [String: Any] = ["totalPay" : totalPay + Double(self.totalCostOfEvent)!]
                        docRef1.updateData(data4)
                    }
                }
            }
            docRef2.getDocument { document, error in
                if error == nil {
                    if document != nil {
                        let data = document!.data()
                        let totalPay = data!["totalPay"] as! Double
                        let data4: [String: Any] = ["totalPay" : totalPay + Double(self.totalCostOfEvent)!]
                        docRef2.updateData(data4)
                    }
                }
            }
            docRef3.getDocument { document, error in
                if error == nil {
                    if document != nil {
                        let data = document!.data()
                        let totalPay = data!["totalPay"] as! Double
                        let data4: [String: Any] = ["totalPay" : totalPay + Double(self.totalCostOfEvent)!]
                        docRef3.updateData(data4)
                    }
                }
            }
            let data4: [String: Any] = ["totalPay" : Double(totalCostOfEvent)!]
            docRef.setData(data4)
           
            self.performSegue(withIdentifier: "TravelFeeToUserTabSegue", sender: self)
            self.dismiss(animated: true, completion: nil)
        } else {
            
            self.showToast(message: "Somthing went wrong. Please check your connection.", font: .systemFont(ofSize: 12))
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

    @objc
    func didTapPayButton() {
      // MARK: Start the checkout process
        paymentSheet?.present(from: self) { paymentResult in
          // MARK: Handle the payment result
          switch paymentResult {
          case .completed:
              self.saveInfo()
          case .canceled:
            print("Canceled!")
          case .failed(let error):
              self.showToast(message: "Order Failed. Please check your information and try again.", font: .systemFont(ofSize: 12))
          }
        }
    }
}
