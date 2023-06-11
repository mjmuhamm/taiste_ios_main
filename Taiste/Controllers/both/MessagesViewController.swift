//
//  MessagesViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 5/2/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import StripePaymentSheet
import FirebaseStorage
import Stripe

class MessagesViewController: UIViewController {
    
    let date = Date()
    let df = DateFormatter()
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    var paymentSheet: PaymentSheet?
    let backendCheckoutUrl = URL(string: "https://ruh.herokuapp.com/create-payment-intent")! // Your backend endpoint
    
    @IBOutlet weak var username: UILabel!
    
    @IBOutlet weak var eventTypeAndQuantity: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var travelFeeLabel: UILabel!
    
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var requestTravelFeeButton: UIButton!
    
    private var messages : [Messages] = []
    private var sortedMessages : [Messages] = []
    
    var travelFeeOrMessage = ""
    var otherUser = ""
    var otherUserName = ""
    private var travelFeePriceText = ""
    private var userImageId = ""
    var order : Orders?
    var chefOrUser = ""
    var documentId = ""
    private var paymentId = ""
    
    var eventTypeAndQuantityText = ""
    var locationText = ""
    var itemTitle = ""
    
    var messageRequestMessages = 0
    var messageRequestRecipient = ""
    
    //this user
    var userName = ""
    var fullName = ""
    
    @IBOutlet weak var messageText: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if eventTypeAndQuantityText == "na" {
            self.eventTypeAndQuantity.isHidden = true
            self.location.isHidden = true
            
        } else {
            self.eventTypeAndQuantity.text = eventTypeAndQuantityText
            self.location.text = locationText
            self.eventTypeAndQuantity.isHidden = false
            self.location.isHidden = false
        }
            
        df.dateFormat = "MM-dd-yyyy hh:mm a"
        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        messageTableView.register(UINib(nibName: "MessagesTableViewCell", bundle: nil), forCellReuseIdentifier: "MessagesReusableCell")
        
        username.text = otherUserName
        
        if chefOrUser == "Chef" {
            requestTravelFeeButton.isHidden = false
        } else {
            requestTravelFeeButton.addTarget(self, action: #selector(didTapCheckoutButton), for: .touchUpInside)
            requestTravelFeeButton.isHidden = true
        }
//        
        if travelFeeOrMessage == "travelFee" {
            if Auth.auth().currentUser != nil {
                loadTravelFeeMessages()
            } else {
                self.showToast(message: "Something went wrong. Please check your connection.", font: .systemFont(ofSize: 12))
            }
        } else if travelFeeOrMessage == "MessageRequests" {
            requestTravelFeeButton.isHidden = true
            if Auth.auth().currentUser != nil {
                loadMessageRequests()
            } else {
                self.showToast(message: "Something went wrong. Please check your connection.", font: .systemFont(ofSize: 12))
            }
        } else {
            requestTravelFeeButton.isHidden = true
            if Auth.auth().currentUser != nil {
                loadMessages()
            } else {
                self.showToast(message: "Something went wrong. Please check your connection.", font: .systemFont(ofSize: 12))
            }
        }
        
        loadUsername()
        
    }
    
    private func loadUsername() {
        if guserName == "" {
            db.collection("Usernames").getDocuments { documents, error in
                if error == nil {
                    if documents != nil {
                        for doc in documents!.documents {
                            let data = doc.data()
                            
                            if let username = data["username"] as? String, let email = data["email"] as? String {
                                if email == Auth.auth().currentUser!.email! {
                                    guserName = username
                                }
                            }
                        }
                    }
                }
            }
        }
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
            self.requestTravelFeeButton.isEnabled = true
              self.paymentId = paymentId
          }
        })
        task.resume()
    }
    
    private func subscribeToTopic(userNotification: String, chefNotification: String, chefOrUser: String, topic: String) {
        let json: [String: Any] = ["notificationToken1": userNotification, "notificationToken2" : chefNotification, "topic" : topic]
        
    
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
              self.db.collection(chefOrUser).document(Auth.auth().currentUser!.uid).collection("PersonalInfo").getDocuments { documents, error in
                  if error == nil {
                      for doc in documents!.documents {
                          let data = doc.data()
                          var a = ""
                          if data["userName"] as? String == nil {
                              a = data["chefName"] as! String
                          } else {
                              a = data["userName"] as! String
                          }
                          self.sendMessage(title: "New Message", notification: "@\(a) has just sent a message.", topic: topic)
                          
                          
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
    
    private func getUsername() {
        db.collection("Usernames").getDocuments { documents, error in
            if error == nil {
                if documents != nil {
                    for doc in documents!.documents {
                        let data = doc.data()
                        
                        if let username = data["username"] as? String, let fullName = data["fullName"] as? String {
                            self.userName = username
                            self.fullName = fullName
                        }
                    }
                }
                
            }
        }
    }
    private func saveInfo() {
        if Auth.auth().currentUser != nil {
            let month = "\(df.string(from: date))".prefix(7).suffix(2)
            let year = "\(df.string(from: date))".prefix(4)
            let yearMonth = "\(year), \(month)"
            
            let calendar = Calendar(identifier: .gregorian)
            let currentWeek = calendar.component(.weekOfMonth, from: Date())
            
            let data: [String: Any] = ["paymentId" : paymentId, "userId" : Auth.auth().currentUser!.uid, "chefEmail" : order!.chefEmail, "menuItemId" : order!.documentId, "date" : df.string(from: date), "chefImageId" : order!.chefImageId]
            let data2: [String: Any] = ["orderUpdate" : "scheduled", "travelFee" : self.travelFeeLabel.text!]
            let data3: [String: Any] = ["totalPay" : (order!.totalCostOfEvent - (order!.totalCostOfEvent * 0.05))]
            //        let data4: [String: Any] = ["Total" : ]
            
            self.db.collection("TravelFeePayments").document().setData(data)
            
            self.db.collection("User").document(Auth.auth().currentUser!.uid).collection(travelFeeOrMessage).document(order!.documentId).collection(order!.itemTitle).document("payment").setData(data)
            self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection(travelFeeOrMessage).document(order!.documentId).collection(order!.itemTitle).document("payment").setData(data)
            self.db.collection("User").document(order!.userImageId).collection("Orders").document(order!.documentId).updateData(data2)
            self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("Orders").document(order!.documentId).updateData(data2)
            self.db.collection("Orders").document(order!.menuItemId).updateData(data2)
            
            self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("Dashboard").document(order!.typeOfService).collection(order!.menuItemId).document("Month").collection(yearMonth).document("Week").collection("Week \(currentWeek)").document().setData(data3)
            
            self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("Dashboard").document(order!.typeOfService).collection(order!.menuItemId).document("Month").collection(yearMonth).document("Total").getDocument(completion: { document, error in
                if error == nil {
                    if document != nil {
                        let data = document!.data()
                        if let total = data!["totalPay"] as? Double {
                            let data5 : [String : Any] = ["totalPay" : total + Double(self.order!.totalCostOfEvent)]
                            self.db.collection("Chef").document(self.order!.chefImageId).collection("Dashboard").document(self.order!.typeOfService).collection(self.order!.menuItemId).document("Month").collection(yearMonth).document("Total").updateData(data5)
                        }
                    } else {
                        let data5 : [String : Any] = ["totalPay" : Double(self.order!.totalCostOfEvent)]
                        self.db.collection("Chef").document(self.order!.chefImageId).collection("Dashboard").document(self.order!.typeOfService).collection(self.order!.documentId).document("Month").collection(yearMonth).document("Total").setData(data5)
                    }
                    
                }
            })
            self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("Dashboard").document(order!.typeOfService).getDocument { document, error in
                if error == nil {
                    if document != nil {
                        let data = document!.data()
                        if let total = data!["totalPay"] as? Double {
                            let data5 : [String : Any] = ["totalPay" : total + Double(self.order!.totalCostOfEvent)]
                            self.db.collection("Chef").document(self.order!.chefImageId).collection("Dashboard").document(self.order!.typeOfService).updateData(data5)
                        }
                    } else {
                        let data5 : [String : Any] = ["totalPay" : Double(self.order!.totalCostOfEvent)]
                        self.db.collection("Chef").document(self.order!.chefImageId).collection("Dashboard").document(self.order!.typeOfService).setData(data5)
                    }
                    
                }
            }
            
            self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("Dashboard").document(order!.typeOfService).collection(order!.menuItemId).document("Total").getDocument { document, error in
                if error == nil {
                    if document != nil {
                        let data = document!.data()
                        
                        if let total = data!["totalPay"] as? Double {
                            let data5 : [String : Any] = ["totalPay" : total + Double(self.order!.totalCostOfEvent)]
                            self.db.collection("Chef").document(self.order!.chefImageId).collection("Dashboard").document(self.order!.typeOfService).collection(self.order!.menuItemId).document("Total").updateData(data5)
                        }
                    } else {
                        let data5 : [String : Any] = ["totalPay" : Double(self.order!.totalCostOfEvent)]
                        self.db.collection("Chef").document(self.order!.chefImageId).collection("Dashboard").document(self.order!.typeOfService).collection(self.order!.menuItemId).document("Total").setData(data5)
                    }
                }
            }
            self.dismiss(animated: true, completion: nil)
        } else {
            self.showToast(message: "Somthing went wrong. Please check your connection.", font: .systemFont(ofSize: 12))
        }
    }
    private func loadMessageRequests() {
        self.messageText.isEnabled = false
        let storageRef = storage.reference()
        db.collection(chefOrUser).document(Auth.auth().currentUser!.uid).collection("MessageRequests").document(otherUser).collection(otherUserName).addSnapshotListener { documents, error in
            if error == nil {
                if documents != nil {
                    if documents!.count == 0 {
                        self.messageText.isEnabled = true
                    }
                    self.messageRequestMessages = documents!.count
                    for doc in documents!.documents {
                        
                        let data = doc.data()
                        if let chefOrUserI = data["chefOrUser"] as? String, let user = data["user"] as? String, let message = data["message"] as? String, let date = data["date"] as? String, let userEmail = data["userEmail"] as? String {
                         
                            if self.messageRequestRecipient == "" {
                                self.messageRequestRecipient = user
                            } else if self.messageRequestRecipient != "good" {
                                if self.messageRequestRecipient != user {
                                    self.messageRequestRecipient = "good"
                                    self.messageText.isEnabled = true
                                }
                             }
                            var vari = ""
                            if chefOrUserI == "Chef" {
                                vari = "chefs"
                            } else {
                                vari = "users"
                            }
                            var homeOrAway = ""
                            if userEmail == Auth.auth().currentUser!.email! {
                                homeOrAway = "home"
                            } else  {
                                homeOrAway = "away"
                            }
                            
                            if user != Auth.auth().currentUser!.uid {
                                self.userImageId = user
                            }
                            
                            
                            let date1 = self.df.date(from: date)
                            storageRef.child("\(vari)/\(self.otherUserName)/profileImage/\(self.otherUser).png").getData(maxSize: 15 * 1024 * 1024) { data, error in
                                
                                let image = UIImage(data: data!)
                                
                                DispatchQueue.main.async {
                                    print("message \(message)")
                                    let index = self.messages.firstIndex { $0.documentId == doc.documentID }
                                    if index == nil {
                                    self.messages.append(Messages(homeOrAway: homeOrAway, pictureId: user, image: image!, message: message, date: date1!, dateString: date, documentId: doc.documentID, chefOrUser: "\(vari.prefix(4))", travelFee: ""))
                                    
                                    self.messages = self.messages.sorted(by: { $0.date.compare($1.date) == .orderedAscending })
                                    self.messageTableView.reloadData()
                                    }
                                }
                                }
                        }
                    }
                }
            }
        }
    }
    
    private func loadTravelFeeMessages() {
        
        let storageRef = storage.reference()
        db.collection(chefOrUser).document(Auth.auth().currentUser!.uid).collection("TravelFeeMessages").document(order!.documentId).collection(order!.orderDate).addSnapshotListener { documents, error in
            if error == nil {
                if documents != nil {
                    for doc in documents!.documents {
                        if doc.documentID != "payment" {
                        let data = doc.data()
                        if let chefOrUserI = data["chefOrUser"] as? String, let user = data["user"] as? String, let message = data["message"] as? String, let date = data["date"] as? String, let userEmail = data["userEmail"] as? String, let travelFee = data["travelFee"] as? String {
                         
                            var vari = ""
                            if chefOrUserI == "Chef" {
                                vari = "chefs"
                            } else {
                                vari = "users"
                            }
                            var homeOrAway = ""
                            if userEmail == Auth.auth().currentUser!.email! {
                                homeOrAway = "home"
                            } else if travelFee == "" {
                                homeOrAway = "away"
                            } else {
                                homeOrAway = "travel"
                                if self.chefOrUser == "User" {
                                self.travelFeeLabel.text = "$\(travelFee)"
                                    if Double(travelFee) != nil {
                                        self.fetchPaymentIntent(costOfEvent: Double(travelFee)!)
                                    }
                                }
                            }
                            self.travelFeePriceText = travelFee
                            if user != Auth.auth().currentUser!.uid {
                                self.userImageId = user
                            }
                            
                            print("date \(date)")
                            print("date1 \(self.df.date(from: date))")
                            let date1 = self.df.date(from: date)
                            if homeOrAway != "travel" {
                            storageRef.child("\(vari)/\(userEmail)/profileImage/\(user).png").getData(maxSize: 15 * 1024 * 1024) { data, error in
                                
                                let image = UIImage(data: data!)
                                
                                DispatchQueue.main.async {
                                    print("message \(message)")
                                    let index = self.messages.firstIndex { $0.documentId == doc.documentID }
                                    if index == nil {
                                    self.messages.append(Messages(homeOrAway: homeOrAway, pictureId: user, image: image!, message: message, date: date1!, dateString: date, documentId: doc.documentID, chefOrUser: "\(vari.prefix(4))", travelFee: travelFee))
                                    
                                    self.messages = self.messages.sorted(by: { $0.date.compare($1.date) == .orderedAscending })
                                    self.messageTableView.reloadData()
                                    }
                                }
                                }
                                
                            } else {
                                self.messages.append(Messages(homeOrAway: homeOrAway, pictureId: user, image: UIImage(), message: message, date: date1!, dateString: date, documentId: doc.documentID, chefOrUser: "\(vari.prefix(4))", travelFee: travelFee))
                                
                                self.messages = self.messages.sorted(by: { $0.date.compare($1.date) == .orderedAscending })
                                self.messageTableView.reloadData()
                            }
                        }
                        
                        }
                    }
                }
            }
        }
    }

    private func loadMessages() {
        let storageRef = storage.reference()
        db.collection(chefOrUser).document(Auth.auth().currentUser!.uid).collection("Messages").document(order!.documentId).collection(order!.itemTitle).addSnapshotListener { documents, error in
            if error == nil {
                if documents != nil {
                    for doc in documents!.documents {
                        if doc.documentID != "payment" {
                        let data = doc.data()
                        if let chefOrUserI = data["chefOrUser"] as? String, let user = data["user"] as? String, let message = data["message"] as? String, let date = data["date"] as? String, let userEmail = data["userEmail"] as? String, let travelFee = data["travelFee"] as? String {
                         
                            var vari = ""
                            if chefOrUserI == "Chef" {
                                vari = "chefs"
                            } else {
                                vari = "users"
                            }
                            var homeOrAway = ""
                            if userEmail == Auth.auth().currentUser!.email! {
                                homeOrAway = "home"
                            } else if travelFee == "" {
                                homeOrAway = "away"
                            } else {
                                homeOrAway = "travel"
                                self.travelFeeLabel.text = "$\(travelFee)"
                                self.fetchPaymentIntent(costOfEvent: Double(travelFee)!)
                            }
                            self.travelFeePriceText = travelFee
                            self.userImageId = user
                            if user != Auth.auth().currentUser!.uid {
                                self.userImageId = user
                            }
                            
                            let date1 = self.df.date(from: date)
                            if homeOrAway != "travel" {
                            storageRef.child("\(vari)/\(userEmail)/profileImage/\(user).png").getData(maxSize: 15 * 1024 * 1024) { data, error in
                                
                                let image = UIImage(data: data!)
                                
                                 
                                DispatchQueue.main.async {
                                    let index = self.messages.firstIndex { $0.documentId == doc.documentID }
                                    if index == nil {
                                    self.messages.append(Messages(homeOrAway: homeOrAway, pictureId: user, image: image!, message: message, date: date1!, dateString: date, documentId: doc.documentID, chefOrUser: "\(vari.prefix(4))", travelFee: ""))
                                   
                                    self.messages = self.messages.sorted(by: { $0.date.compare($1.date) == .orderedAscending })
                                    
                                    self.messageTableView.reloadData()
                                    }
                                }
                                
                            }
                            } else {
                                self.messages.append(Messages(homeOrAway: homeOrAway, pictureId: user, image: UIImage(), message: message, date: date1!, dateString: date, documentId: doc.documentID, chefOrUser: "\(vari.prefix(4))", travelFee: ""))
                               
                                self.messages = self.messages.sorted(by: { $0.date.compare($1.date) == .orderedAscending })
                                
                                self.messageTableView.reloadData()
                            }
                        }
                        }
                    }
                }
            }
        }
    }
    
    @objc
    func didTapCheckoutButton() {
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
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func payButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func requestTravelFeeButtonPressed(_ sender: Any) {
        
        self.performSegue(withIdentifier: "MessagesToTravelFeeSegue", sender: self)
    }
    
    @IBAction func sendMessageButtonPressed(_ sender: Any) {
        
        if messageText.text != nil {
            if messageText.text!.isEmpty || messageText.text == "" {
                self.showToast(message: "Please enter a message.", font: .systemFont(ofSize: 12))
            } else {
                
                let storageRef = storage.reference()
                var vari = ""
                if chefOrUser == "Chef" {
                    vari = "chefs"
                } else {
                    vari = "users"
                }
                let documentId = UUID().uuidString
                storageRef.child("\(vari)/\(Auth.auth().currentUser!.email!)/profileImage/\(Auth.auth().currentUser!.uid).png").getData(maxSize: 15 * 1024 * 1024) { data, error in
                    
                    self.messages.append(Messages(homeOrAway: "home", pictureId: Auth.auth().currentUser!.uid, image: UIImage(data: data!)!, message: self.messageText.text!, date: self.df.date(from: self.df.string(from: self.date))!, dateString: self.df.string(from: self.date), documentId: documentId, chefOrUser: self.chefOrUser, travelFee: ""))
                    self.messages.sort(by: { $0.date.compare($1.date) == .orderedAscending })
                    self.messageTableView.reloadData()
                    
                    self.messageText.text = ""
                    
                }
                
                let data : [String : Any] = ["chefOrUser" : chefOrUser, "user" : Auth.auth().currentUser!.uid, "message" : messageText.text!, "date" : df.string(from: date), "userEmail": Auth.auth().currentUser!.email!, "travelFee" : "", "userName" : self.username, "fullName" : self.fullName]
                
                var otherUser = ""
                var otherImageId = ""
                var travelFeeVari = ""
                
                if chefOrUser == "Chef" {
                    otherUser = "User"
                    otherImageId = order!.userImageId
                } else {
                    otherUser = "Chef"
                    otherImageId = order!.chefImageId
                }
                if travelFeeOrMessage == "travelFee" {
                    travelFeeVari = "TravelFeeMessages"
                } else if travelFeeOrMessage == "MessageRequests" {
                    travelFeeVari = "MessageRequests"
                    
                    self.db.collection(chefOrUser).document(Auth.auth().currentUser!.uid).collection(travelFeeVari).document(self.otherUser).collection(self.otherUserName).document(documentId).setData(data)
                    self.db.collection(otherUser).document(self.otherUser).collection(travelFeeVari).document(self.otherUser).collection(self.otherUserName).document(documentId).setData(data)
                    db.collection(chefOrUser).document(Auth.auth().currentUser!.uid).getDocument { document, error in
                        if error == nil {
                            if document != nil {
                                let data = document!.data()
                                
                                let notificationToken1 = data!["notificationToken"] as! String
                                
                                self.db.collection(otherUser).document(self.otherUser).getDocument { document, error in
                                    if error == nil {
                                        if document != nil {
                                            let data = document!.data()
                                            let notificationToken2 = data!["notificationToken"] as! String
                                            
                                            self.subscribeToTopic(userNotification: notificationToken1, chefNotification: notificationToken2, chefOrUser: self.chefOrUser, topic: self.otherUser)
                                        }
                                    }
                                }
                            }
                        }
                        
                    }
                    
                    let date =  self.df.string(from: Date())
                    let data3: [String: Any] = ["notification" : "\(otherUserName) has just messaged you in MessageRequests.", "date" : date]
                    let data4: [String: Any] = ["notifications" : "yes"]
                    self.db.collection(otherUser).document(self.otherUser).collection("Notifications").document().setData(data3)
                    self.db.collection(otherUser).document(self.otherUser).updateData(data4)
                } else {
                    travelFeeVari = "Messages"
                }
                if travelFeeVari != "MessageRequests" {
                    self.db.collection(chefOrUser).document(Auth.auth().currentUser!.uid).collection(travelFeeVari).document(order!.documentId).collection(order!.orderDate).document(documentId).setData(data)
                    self.db.collection(otherUser).document(otherImageId).collection(travelFeeVari).document(order!.documentId).collection(order!.orderDate).document(documentId).setData(data)
                    
                    if chefOrUser == "Chef" {
                        db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("PersonalInfo").getDocuments { documents, error in
                            if error == nil {
                                for doc in documents!.documents {
                                    let data = doc.data()
                                    let userName = data["chefName"] as! String
                                    self.sendMessage(title: travelFeeVari, notification: "New message from \(userName)", topic: self.order!.documentId)
                                }
                            }
                        }
                    } else {
                        db.collection("User").document(Auth.auth().currentUser!.uid).collection("PersonalInfo").getDocuments { documents, error in
                            if error == nil {
                                for doc in documents!.documents {
                                    let data = doc.data()
                                    let userName = data["userName"] as! String
                                    self.sendMessage(title: travelFeeVari, notification: "New message from \(userName)", topic: self.order!.documentId)
                                }
                            }
                        }
                    }
                }
                
               
                
                let date = Date()
                let df = DateFormatter()
                df.dateFormat = "MM-dd-yyyy hh:mm a"
                let date1 =  df.string(from: Date())
                let data3: [String: Any] = ["notification" : "\(guserName) has just messaged you (\(order!.typeOfService)) about \(order!.itemTitle).", "date" : date1]
                let data4: [String: Any] = ["notifications" : "yes"]
                self.db.collection(otherUser).document(otherImageId).collection("Notifications").document().setData(data3)
                self.db.collection(otherUser).document(otherImageId).updateData(data4)
                
                self.showToast(message: "Message Sent", font: .systemFont(ofSize: 12))
            }
        }
    }
    
    private var user = ""
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MessagesToProfileAsUserSegue" {
            let info = segue.destination as! ProfileAsUserViewController
            info.chefOrUser = chefOrUser
            info.user = user
        } else if segue.identifier == "MessagesToTravelFeeSegue" {
            let info = segue.destination as! TravelFeeViewController
            info.travelFeePriceText = travelFeePriceText
            info.userImageId = userImageId
            info.chefOrUser = chefOrUser
            info.travelFeePriceText = travelFeePriceText
            info.order = self.order
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
}

extension MessagesViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = messageTableView.dequeueReusableCell(withIdentifier: "MessagesReusableCell", for: indexPath) as! MessagesTableViewCell
        var message = messages[indexPath.row]
        
        if message.homeOrAway == "home" {
            cell.awayImage.isHidden = true
            cell.awayMessage.isHidden = true
            cell.awayDate.isHidden = true
            cell.homeImage.isHidden = false
            cell.homeMessage.isHidden = false
            cell.homeDate.isHidden = false
            cell.travelFeeMessage.isHidden = true
            cell.homeImage.image = message.image
            cell.homeMessage.text = message.message
            cell.homeDate.text = "\(message.dateString)"
        } else if message.homeOrAway == "away" {
            cell.awayImage.isHidden = false
            cell.awayMessage.isHidden = false
            cell.awayDate.isHidden = false
            cell.homeImage.isHidden = true
            cell.homeMessage.isHidden = true
            cell.homeDate.isHidden = true
            cell.travelFeeMessage.isHidden = true
            cell.awayImage.image = message.image
            cell.awayMessage.text = message.message
            cell.awayDate.text = "\(message.dateString)"
        } else {
            cell.awayImage.isHidden = true
            cell.awayMessage.isHidden = true
            cell.awayDate.isHidden = true
            cell.homeImage.isHidden = true
            cell.homeMessage.isHidden = true
            cell.homeDate.isHidden = true
            cell.travelFeeMessage.isHidden = false
            cell.travelFeeMessage.text = message.message
        }
        
        cell.profileButtonTapped = {
            self.user = message.pictureId
            self.chefOrUser = message.chefOrUser
            self.performSegue(withIdentifier: "MessagesToProfileAsUserSegue", sender: self)
        }
        
        
        
        
        
        
        
        return cell
    }
}
