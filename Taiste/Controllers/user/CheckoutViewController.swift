//
//  CheckoutViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 2/26/22.
//

import UIKit
import Firebase
import Stripe
import StripePaymentsUI
import StripePaymentSheet
import FirebaseFirestore
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_Theming
import MaterialComponents.MaterialTextControls_FilledTextAreasTheming
import MaterialComponents.MaterialTextControls_FilledTextFieldsTheming
import MaterialComponents.MaterialTextControls_OutlinedTextAreasTheming
import MaterialComponents.MaterialTextControls_OutlinedTextFieldsTheming


class CheckoutViewController: UIViewController {

    var paymentSheet: PaymentSheet?
    let backendCheckoutUrl = URL(string: "https://taiste-payments.onrender.com/create-payment-intent")! // Your backend endpoint

    let date = Date()
    let df = DateFormatter()
    
    
    private let storage = Storage.storage()
    @IBOutlet weak var foodTotalText: UILabel!
    @IBOutlet weak var taxesAndFeesText: UILabel!
    @IBOutlet weak var finalTotalText: UILabel!
    
    private let db = Firestore.firestore()
    private let user = "malik@testing.com"
    
    private var checkoutItems : [CheckoutItems] = []

    private var creditsIds : [String] = []
    private var creditsApplied = ""
    private var paymentId = ""
    @IBOutlet weak var payButton: MDCButton!
    
    private var totalPrice = 0.0
    
    let sdf = DateFormatter()
    var userName = ""
    
    @IBOutlet weak var checkoutTableView: UITableView!
    
    @IBOutlet weak var progressBar: UIActivityIndicatorView!
    private var cant = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        df.dateFormat = "MM-dd-yyyy hh:mm a"
        sdf.dateFormat = "MM-dd-yyyy"
        payButton.addTarget(self, action: #selector(didTapCheckoutButton), for: .touchUpInside)
        payButton.isEnabled = false

        checkoutTableView.delegate = self
        checkoutTableView.dataSource = self
        checkoutTableView.register(UINib(nibName: "CheckoutTableViewCell", bundle: nil), forCellReuseIdentifier: "CheckoutReusableCell")
        
        payButton.applyOutlinedTheme(withScheme: globalContainerScheme())
        payButton.layer.cornerRadius = 2
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            
            profilePicGuard()
        } else {
            self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
        }
        // Do any additional setup after loading the view.
    }
    
    
    private func fetchPaymentIntent(costOfEvent: Double) {
        
        let cost = costOfEvent * 100
        let a = String(format: "%.0f", cost)
        
        let json: [String: Any] = ["amount": a]
        print("fetch payment happening")
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        // MARK: Fetch the Intent client secret, Ephemeral Key secret, Customer ID, and publishable key
        var request = URLRequest(url: backendCheckoutUrl)
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

            print("fetch payment succeeded")
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
              self.progressBar.stopAnimating()
              self.progressBar.isHidden = true
              
            self.payButton.isEnabled = true
              self.paymentId = paymentId
          }
        })
        task.resume()
    }
    
    private func profilePicGuard() {
        db.collection("User").document(Auth.auth().currentUser!.uid).getDocument { document, error in
            if error == nil {
                if document != nil {
                    let data = document!.data()
                    if let profilePic = data!["profilePic"] as? String {
                        if profilePic == "yes" {
                            self.loadCart()
                        } else {
                            self.showToast(message: "Please upload a profile pic before continuing.", font: .systemFont(ofSize: 12))
                        }
                    }
                }
            }
        }
    }
    private func loadCart() {
        
        if Auth.auth().currentUser != nil {
            let storageRef = storage.reference()
            var chefImage = UIImage()
            
            db.collection("User").document(Auth.auth().currentUser!.uid).collection("PersonalInfo").getDocuments { documents, error in
                if error == nil {
                    if documents != nil {
                        for doc in documents!.documents {
                            let data = doc.data()
                            
                            let userName = data["userName"] as! String
                            self.userName = userName
                        }
                    }
                }
            }
            
            db.collection("User").document(Auth.auth().currentUser!.uid).collection("Cart").getDocuments { documents, error in
                if error == nil {
                    for doc in documents!.documents {
                        let data = doc.data()
                        
                        if let chefEmail = data["chefEmail"] as? String, let chefImageId = data["chefImageId"] as? String, let chefUsername = data["chefUsername"] as? String, let menuItemId = data["menuItemId"] as? String, let itemDescription = data["itemDescription"] as? String, let itemTitle = data["itemTitle"] as? String, let datesOfEvent = data["datesOfEvent"] as? [String], let timesForDatesOfEvent = data["timesForDatesOfEvent"] as? [String], let travelExpenseOption = data["travelExpenseOption"] as? String, let totalCostOfEvent = data["totalCostOfEvent"] as? Double, let priceToChef = data["priceToChef"] as? Double, let quantityOfEvent = data["quantityOfEvent"] as? String, let unitPrice = data["unitPrice"] as? String, let distance = data["distance"] as? String, let location = data["location"] as? String, let latitudeOfEvent = data["latitudeOfEvent"] as? String, let longitudeOfEvent = data["longitudeOfEvent"] as? String, let notesToChef = data["notesToChef"] as? String, let typeOfService = data["typeOfService"] as? String, let typeOfEvent = data["typeOfEvent"] as? String, let city = data["city"] as? String, let state = data["state"] as? String, let user = data["user"] as? String, let imageCount = data["imageCount"] as? Int, let liked = data["liked"] as? [String], let itemOrders = data["itemOrders"] as? Int, let itemRating = data["itemRating"] as? [Double], let itemCalories = data["itemCalories"] as? String, let allergies = data["allergies"] as? String, let additionalMenuItems = data["additionalMenuItems"] as? String, let signatureDishId = data["signatureDishId"] as? String, let userNotificationToken = data["userNotificationToken"] as? String, let chefNotificationToken = data["chefNotificationToken"] as? String  {
                            
                            if chefUsername == "chefTest" {
                                self.cant = "cant"
                            }
                            
                            let newItem = CheckoutItems(chefEmail: chefEmail, chefImageId: chefImageId, chefUsername: chefUsername, chefImage: chefImage, menuItemId: menuItemId, itemTitle: itemTitle, itemDescription: itemDescription, datesOfEvent: datesOfEvent, timesForDatesOfEvent: timesForDatesOfEvent, travelExpenseOption: travelExpenseOption, totalCostOfEvent: totalCostOfEvent, priceToChef: priceToChef, quantityOfEvent: quantityOfEvent, unitPrice: unitPrice, distance: distance, location: location, latitudeOfEvent: latitudeOfEvent, longitudeOfEvent: longitudeOfEvent, notesToChef: notesToChef, typeOfService: typeOfService, typeOfEvent: typeOfEvent, city: city, state: state, user: user, documentId: doc.documentID, imageCount: imageCount, liked: liked, itemOrders: itemOrders, itemRating: itemRating, itemCalories: Int(itemCalories)!, allergies: allergies, additionalMenuItems: additionalMenuItems, signatureDishId: signatureDishId, userNotification: userNotificationToken, chefNotification: chefNotificationToken)
                            
                            if self.checkoutItems.count == 0 {
                                self.checkoutItems.append(newItem)
                                self.totalPrice += totalCostOfEvent
                                let a = String(format: "%.2f", self.totalPrice)
                                let taxesAndFees = self.totalPrice * 0.125
                                let b = String(format: "%.2f", taxesAndFees)
                                let finalTotal = self.totalPrice + taxesAndFees
                                let c = String(format: "%.2f", finalTotal)
                                self.foodTotalText.text = "$\(a)"
                                self.taxesAndFeesText.text = "$\(b)"
                                self.finalTotalText.text = "$\(c)"
                                self.fetchPaymentIntent(costOfEvent: finalTotal)
                                
                                self.checkoutTableView.insertRows(at: [IndexPath(item: 0, section: 0)], with: .fade)
                            } else {
                                let index = self.checkoutItems.firstIndex { $0.documentId == doc.documentID
                                }
                                if index == nil {
                                    self.checkoutItems.append(newItem)
                                    self.totalPrice += totalCostOfEvent
                                    let a = String(format: "%.2f", self.totalPrice)
                                    let taxesAndFees = self.totalPrice * 0.125
                                    let b = String(format: "%.2f", taxesAndFees)
                                    let finalTotal = self.totalPrice + taxesAndFees
                                    let c = String(format: "%.2f", finalTotal)
                                    self.foodTotalText.text = "$\(a)"
                                    self.taxesAndFeesText.text = "$\(b)"
                                    self.finalTotalText.text = "$\(c)"
                                    self.fetchPaymentIntent(costOfEvent: finalTotal)
                                    self.checkoutTableView.insertRows(at: [IndexPath(item:self.checkoutItems.count - 1, section: 0)], with: .fade)
                                    
                                    
                                }
                            }}
                        
                    }
                }
            }
        } else {
            self.showToast(message: "Something went wrong. Please check your connection.", font: .systemFont(ofSize: 12))
        }
    }
    
    private func subscribeToTopic(userNotification: String, chefNotification: String, orderId: String, itemTitle: String) {
        let json: [String: Any] = ["notificationToken1": userNotification, "notificationToken2" : chefNotification, "topic" : orderId]
        
    
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        // MARK: Fetch the Intent client secret, Ephemeral Key secret, Customer ID, and publishable key
        var request = URLRequest(url: URL(string: "https://taiste-payments.onrender.com/subscribe-to-topic")!)
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
              self.db.collection("User").document(Auth.auth().currentUser!.uid).collection("PersonalInfo").getDocuments { documents, error in
                  if error == nil {
                      for doc in documents!.documents {
                          let data = doc.data()
                          let userName = data["userName"] as! String
                          self.sendMessage(title: "New Order", notification: "@\(userName) has just ordered \(itemTitle); now awaiting response.", topic: orderId)
                      }
                  }
              }
              
          }
        })
        task.resume()
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
    
    
    private func saveInfo() {
        
        if Auth.auth().currentUser != nil {
            var date = sdf.string(from: Date())
            for i in 0..<checkoutItems.count {
                let item = checkoutItems[i]
                let orderId = UUID().uuidString
                let data: [String: Any] = ["cancelled" : "", "chefEmail" : item.chefEmail, "chefImageId" : item.chefImageId, "chefUsername" : item.chefUsername, "city" : item.city, "state" : item.state, "distance" : item.distance, "eventDates" : item.datesOfEvent, "eventNotes" : item.notesToChef, "eventTimes" : item.timesForDatesOfEvent, "eventType" : item.typeOfEvent, "itemDescription" : item.itemDescription, "itemTitle" : item.itemTitle, "menuItemId" : item.menuItemId, "numberOfEvents" : checkoutItems.count, "orderDate" : date, "orderId" : orderId, "orderUpdate" : "pending", "priceToChef" : item.totalCostOfEvent * 0.95, "taxesAndFees" : item.totalCostOfEvent * 0.125, "totalCostOfEvent" : item.totalCostOfEvent, "travelFee" : "", "travelFeeAccepted" : "", "travelFeeRequested" : "", "travelFeeApproved" : "", "typeOfService" : "Executive Items", "userImageId" : Auth.auth().currentUser!.uid, "user" : self.userName, "unitPrice" : item.unitPrice, "imageCount" : item.imageCount, "liked" : item.liked, "itemOrders" : item.itemOrders, "itemRating" : item.itemRating, "itemCalories" : "\(item.itemCalories)", "location" : item.location, "eventQuantity" : item.quantityOfEvent, "travelExpenseOption" : item.travelExpenseOption, "creditsApplied" : creditsApplied, "creditIds" : creditsIds, "allergies": item.allergies, "additionalMenuItems" : item.additionalMenuItems, "signatureDishId" : item.signatureDishId, "userNotificationToken" : item.userNotification, "chefNotificationToken" : item.chefNotification, "userName" : guserName, "userEmail" : Auth.auth().currentUser!.email!, "payoutDates" : []]
                
                
                let data1: [String: Any] = ["cancelled" : "", "chefEmail" : item.chefEmail, "chefImageId" : item.chefImageId,  "chefUsername" : item.chefUsername, "city" : item.city, "state" : item.state, "distance" : item.distance, "eventDates" : item.datesOfEvent, "eventNotes" : item.notesToChef, "eventTimes" : item.timesForDatesOfEvent, "eventType" : item.typeOfEvent, "itemDescription" : item.itemDescription, "itemTitle" : item.itemTitle,"menuItemId" : item.menuItemId, "numberOfEvents" : checkoutItems.count, "orderDate" : date, "orderId" : orderId, "orderUpdate" : "pending", "priceToChef" : (item.totalCostOfEvent * 0.95), "taxesAndFees" : item.totalCostOfEvent * 0.125, "totalCostOfEvent" : item.totalCostOfEvent, "travelFee" : "", "travelFeeAccepted" : "", "travelFeeRequested" : "", "travelFeeApproved" : "", "typeOfService" : "Executive Items", "userImageId" : Auth.auth().currentUser!.uid, "user" : self.userName, "unitPrice" : item.unitPrice, "imageCount" : item.imageCount, "liked" : item.liked, "itemOrders" : item.itemOrders, "itemRating" : item.itemRating, "itemCalories" : "\(item.itemCalories)", "location" : item.location, "eventQuantity" : item.quantityOfEvent, "travelExpenseOption" : item.travelExpenseOption, "creditsApplied" : creditsApplied, "creditIds" : creditsIds, "paymentIntent" : paymentId, "allergies": item.allergies, "additionalMenuItems" : item.additionalMenuItems, "signatureDishId" : item.signatureDishId, "userNotificationToken" : item.userNotification, "chefNotificationToken" : item.chefNotification, "userName" : guserName, "userEmail" : Auth.auth().currentUser!.email!, "payoutDates" : []]
                
                var numOfOrders = 0
                if item.quantityOfEvent == "1-10" {
                    numOfOrders = 10
                } else if item.quantityOfEvent == "11-25" {
                    numOfOrders = 25
                } else if item.quantityOfEvent == "26-40" {
                    numOfOrders = 40
                } else if item.quantityOfEvent == "41-55" {
                    numOfOrders = 55
                } else if item.quantityOfEvent == "56-70" {
                    numOfOrders = 70
                } else if item.quantityOfEvent == "71-90" {
                    numOfOrders = 90
                } else {
                    if Int(item.quantityOfEvent) != nil {
                        numOfOrders = Int(item.quantityOfEvent)!
                    }
                }
                let date = df.string(from: Date())
                let data2: [String: Any] = ["itemOrders" : numOfOrders]
                let data3: [String: Any] = ["notification" : "@\(self.userName) has just placed an order (\(item.typeOfService)) for \(item.itemTitle)", "date" : date]
                let data4: [String: Any] = ["notifications" : "yes"]
                db.collection("Chef").document(item.chefImageId).collection("Orders").document(orderId).setData(data)
                db.collection("Chef").document(item.chefImageId).collection("Notifications").document(orderId).setData(data3)
                db.collection("Chef").document(item.chefImageId).updateData(data4)
                db.collection("User").document(Auth.auth().currentUser!.uid).collection("Orders").document(orderId).setData(data)
                db.collection("Orders").document(orderId).setData(data1)
                db.collection("User").document(Auth.auth().currentUser!.uid).collection("Cart").document(item.documentId).delete()
                db.collection(item.typeOfService).document(item.menuItemId).updateData(data2)
                subscribeToTopic(userNotification: item.userNotification, chefNotification: item.chefNotification, orderId: orderId, itemTitle: item.itemTitle)
                
                if (i == checkoutItems.count - 1) {
                    showToastCompletion(message: "Order Complete! Please check 'Orders' tab for an update on this order.", font: .systemFont(ofSize: 12))
                }
                
            }
        } else {
            self.showToast(message: "Something went wrong. Please check your connection.", font: .systemFont(ofSize: 12))
        }
    }
    
    var happened = ""
    @IBAction func backButtonPressed(_ sender: Any) {
        if happened != "" {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserTab") as? UserTabViewController  {
                vc.whereTo = "home"
                self.present(vc, animated: true, completion: nil)
            }
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func payButtonPressed(_ sender: Any) {
        
    }

@objc
func didTapCheckoutButton() {
    if self.cant == "cant" {
        self.showToast(message: "You have orders from test profiles in this order. Please cancel this order.", font: .systemFont(ofSize: 12))
    }  else {
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
            self.performSegue(withIdentifier: "CheckoutToUserTabSegue", sender: self)
            toastLabel.removeFromSuperview()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CheckoutToUserTabSugue" {
            let info = segue.destination as! UserTabViewController
            info.whereTo = "orders"
        }
    }
    
   
    
}

extension CheckoutViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checkoutItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
            let cell = checkoutTableView.dequeueReusableCell(withIdentifier: "CheckoutReusableCell", for: indexPath) as! CheckoutTableViewCell
            let item = checkoutItems[indexPath.row]
        
            cell.chefImage.image = item.chefImage
            cell.chefImage.layer.borderWidth = 1
            cell.chefImage.layer.masksToBounds = false
            cell.chefImage.layer.borderColor = UIColor.white.cgColor
            cell.chefImage.layer.cornerRadius = cell.chefImage.frame.height/2
            cell.chefImage.clipsToBounds = true
            cell.itemTitle.text = item.itemTitle
        if item.typeOfService == "Cater Items" {
            cell.allergies.isHidden = true
            cell.additionalRequests.isHidden = true
            cell.noteConstant.constant = 4.5
            cell.eventTypeAndQuantity.text = "Event Type: \(item.typeOfEvent)   Event Quantity: \(item.quantityOfEvent)"
        } else {
            cell.allergies.isHidden = false
            cell.additionalRequests.isHidden = false
            cell.allergies.text = "Allergies: \(item.allergies)"
            cell.additionalRequests.text = "Additional Requests: \(item.additionalMenuItems)"
            cell.noteConstant.constant = 43
            cell.eventTypeAndQuantity.text = "Service Length: \(item.typeOfEvent)   Event Quantity: \(item.quantityOfEvent)"
        }
            cell.location.text = "Location: \(item.location)"
            for i in 0..<item.datesOfEvent.count {
                if i == 0 {
                    cell.dates.text = "Dates: \(item.datesOfEvent[i])"
                } else {
                    if (i < 3) {
                        cell.dates.text = "\(cell.dates.text!), \(item.datesOfEvent[i])"
                        if i == 2 && item.datesOfEvent.count > 3 {
                            cell.dates.text = "\(cell.dates.text!)..."
                        }
                    }
                }
            }
            cell.noteToChef.text = item.notesToChef
            let a = String(format: "%.2f", item.totalCostOfEvent)
            cell.eventCost.text = "$\(a)"
            let storageRef = storage.reference()
            storageRef.child("chefs/\(item.chefEmail)/profileImage/\(item.chefImageId).png").downloadURL { itemUrl, error in
                
                URLSession.shared.dataTask(with: itemUrl!) { (data, response, error) in
                    // Error handling...
                    guard let imageData = data else { return }
                    
                    print("happening itemdata")
                    DispatchQueue.main.async {
                        cell.chefImage.image = UIImage(data: imageData)!
                    }
                }.resume()
            }
            
            cell.chefImageButtonTapped = {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileAsUser") as? ProfileAsUserViewController  {
                    vc.user = item.chefImageId
                    vc.chefOrUser = "chef"
                    self.present(vc, animated: true, completion: nil)
                }
            }
            cell.cancelButtonTapped = {
                self.happened = "yes"
                let foodTotal = self.foodTotalText.text!.suffix(self.foodTotalText.text!.count - 1)
                let newTotal = Double(foodTotal)! - item.totalCostOfEvent
                let taxes = Double(newTotal) * 0.125
                let newFinalTotal = Double(newTotal) + Double(
                    taxes)
                
                if let index = self.checkoutItems.firstIndex(where: { $0.documentId == item.documentId }) {
                    self.checkoutItems.remove(at: index)
                    self.checkoutTableView.deleteRows(at: [IndexPath(item:index, section: 0)], with: .fade)
                    self.foodTotalText.text = "$\(String(format: "%.2f", newTotal))"
                    self.taxesAndFeesText.text = "$\(String(format: "%.2f", taxes))"
                    self.finalTotalText.text = "$\(String(format: "%.2f", newFinalTotal))"
                    self.db.collection("User").document(Auth.auth().currentUser!.uid).collection("Cart").document(item.documentId).delete()
                    self.fetchPaymentIntent(costOfEvent: newFinalTotal)
                    if newFinalTotal == 0 {
                        self.payButton.isEnabled = false
                    }
                }
                
                
            }
        
        cell.orderDetailButtonTapped = {
            if item.typeOfService == "Cater Items" {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "OrderDetail") as? OrderDetailsViewController  {
                    vc.newOrEdit = "edit"
                    vc.documentId = item.documentId
                    self.present(vc, animated: true, completion: nil)
                }
            } else {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "PersonalChefOrderDetail") as? PersonalChefOrderDetailViewController  {
                    vc.newOrEdit = "edit"
                    vc.documentId = item.documentId
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
            
        
            
            return cell
        }
}
