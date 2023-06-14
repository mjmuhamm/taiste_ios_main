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
    
    var paymentId = ""
    
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
    
    //messageRequest
        var messageRequestRecipient = ""
        var messageRequestReceiverUsername = ""
        var messageRequestSenderUsername = ""
        var messageRequestSenderImageId = ""
        var messageRequestReceiverImageId = ""
        var messageRequestChefOrUser = ""
        var messageRequestDocumentId = ""
        var messageRequestSenderEmail = ""
        var messageRequestReceiverEmail = ""
        var messageRequestReceiverChefOrUser = ""

        //Orders
        var travelFeeOrMessages = ""
        var travelFee = ""
        var menuItemId = ""
        var totalCostOfEvent = ""
        var itemTitle = ""
        var eventType = ""
        var eventQuantity = ""
        var locationText = ""
        
        var orderMessageSenderImageId = ""
        var orderMessageReceiverImageId = ""
        var orderMessageChefOrUser = ""
        var orderMessageDocumentId = ""
        var orderMessageReceiverName = ""
        var orderMessageSenderName = ""
        var orderMessageReceiverEmail = ""
        var orderMessageSenderEmail = ""
        var orderMessageReceiverChefOrUser = ""
    
    @IBOutlet weak var tableViewConstant: NSLayoutConstraint!
    
    //31.5
    
    //this user
    var userName = ""
    var fullName = ""
    
    @IBOutlet weak var messageText: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if travelFeeOrMessages == "MessageRequests" {
            self.eventTypeAndQuantity.isHidden = true
            self.location.isHidden = true
            
        } else {
            self.eventTypeAndQuantity.text = "Event Type: \(eventType)   Event Quantity: \(eventQuantity)"
            self.location.text = locationText
            self.eventTypeAndQuantity.isHidden = false
            self.location.isHidden = false
        }
            
        df.dateFormat = "MM-dd-yyyy hh:mm a"
        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        messageTableView.register(UINib(nibName: "MessagesTableViewCell", bundle: nil), forCellReuseIdentifier: "MessagesReusableCell")
        
        if travelFeeOrMessages == "MessageRequests" {
            username.text = messageRequestSenderUsername
        } else {
            username.text = orderMessageSenderName
        }
        
        if orderMessageChefOrUser == "Chef" {
            requestTravelFeeButton.isHidden = false
        } else {
            requestTravelFeeButton.addTarget(self, action: #selector(didTapCheckoutButton), for: .touchUpInside)
            requestTravelFeeButton.isHidden = true
        }
//        
        if travelFeeOrMessages == "travelFee" {
            if Auth.auth().currentUser != nil {
                loadTravelFeeMessages()
            } else {
                self.showToast(message: "Something went wrong. Please check your connection.", font: .systemFont(ofSize: 12))
            }
        } else if travelFeeOrMessages == "MessageRequests" {
            requestTravelFeeButton.isHidden = true
            travelFeeLabel.isHidden = true
            tableViewConstant.constant = 31.5
            if Auth.auth().currentUser != nil {
                loadMessageRequests()
            } else {
                self.showToast(message: "Something went wrong. Please check your connection.", font: .systemFont(ofSize: 12))
            }
        } else {
            travelFeeLabel.isHidden = false
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
        if Auth.auth().currentUser == nil {
            print("gusername \(guserName)")
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
        } else {
            self.showToast(message: "Something went wrong. Please check your connection.", font: .systemFont(ofSize: 12))
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
            
            db.collection("TravelFeePayments").document(menuItemId).setData(data)
            db.collection(Auth.auth().currentUser!.displayName!).document(Auth.auth().currentUser!.uid).collection("TravelFeePayments").document(orderMessageDocumentId).collection(orderMessageDocumentId).document("payment").setData(data)
            db.collection(orderMessageReceiverChefOrUser).document(orderMessageReceiverImageId).collection("TravelFeePayments").document(orderMessageDocumentId).collection(orderMessageDocumentId).document("payment").setData(data)
            
            db.collection(orderMessageReceiverChefOrUser).document(orderMessageReceiverImageId).collection("Orders").document(orderMessageDocumentId).updateData(data2)
            db.collection(Auth.auth().currentUser!.displayName!).document(Auth.auth().currentUser!.uid).collection("Orders").document(orderMessageDocumentId).updateData(data2)
            db.collection("Orders").document(menuItemId).updateData(data2)
            
            
            let docRef = db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("Dashboard").document(eventType)
            let docRef1 = db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("Dashboard").document(eventType).collection(menuItemId).document("Total")
            let docRef2 = db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("Dashboard").document(eventType).collection(menuItemId).document("Month").collection(yearMonth).document("Total")
            let docRef3 = db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("Dashboard").document(eventType).collection(menuItemId).document("Month").collection(yearMonth).document("Week").collection(weekOfMonth).document("Total")
            let docRef4 = db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("Dashboard").document(eventType).collection(menuItemId).document("Month").collection(yearMonth).document("Week").collection(weekOfMonth).document(orderMessageDocumentId)
            
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
           
            
            self.dismiss(animated: true, completion: nil)
        } else {
            self.showToast(message: "Somthing went wrong. Please check your connection.", font: .systemFont(ofSize: 12))
        }
    }
    private func loadMessageRequests() {
        self.messageText.isEnabled = false
        let storageRef = storage.reference()
        db.collection(Auth.auth().currentUser!.displayName!).document(Auth.auth().currentUser!.uid).collection("MessageRequests").document(messageRequestDocumentId).collection(messageRequestDocumentId).addSnapshotListener { documents, error in
            if error == nil {
                if documents != nil {
                    if documents!.count == 0 {
                        self.messageText.isEnabled = true
                    }
                   
                    for doc in documents!.documents {
                        
                        let data = doc.data()
                        if let chefOrUserI = data["chefOrUser"] as? String, let user = data["user"] as? String, let message = data["message"] as? String, let date = data["date"] as? String, let userEmail = data["userEmail"] as? String {
                         
                            if documents!.count == 1 && userEmail == Auth.auth().currentUser!.email! {
                                self.messageText.isEnabled = false
                            }
                            if documents!.count > 1 {
                                self.messageText.isEnabled = true
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
                            
                           
                            print("vari \(vari)")
                            print("vari \(userEmail)")
                            print("vari \(user)")
                            
                            
                            let date1 = self.df.date(from: date)
                            storageRef.child("\(vari)/\(userEmail)/profileImage/\(user).png").getData(maxSize: 15 * 1024 * 1024) { data, error in
                                
                                let image = UIImage(data: data!)
                                
                                DispatchQueue.main.async {
                                    print("message \(message)")
                                    let index = self.messages.firstIndex { $0.documentId == doc.documentID }
                                    if index == nil {
                                    self.messages.append(Messages(homeOrAway: homeOrAway, pictureId: user, image: image!, message: message, date: date1!, dateString: date, documentId: doc.documentID, chefOrUser: "\(vari.prefix(4))", travelFee: ""))
                                        if self.messages.count == 1 {
                                            if userEmail != Auth.auth().currentUser!.email! {
                                                self.messageText.isEnabled = true
                                            }
                                        } else {
                                            self.messageText.isEnabled = true
                                        }
                                    
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
        db.collection(Auth.auth().currentUser!.displayName!).document(Auth.auth().currentUser!.uid).collection("TravelFeeMessages").document(orderMessageDocumentId).collection(orderMessageDocumentId).addSnapshotListener { documents, error in
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
                                if Auth.auth().currentUser!.displayName! == "User" {
                                self.travelFeeLabel.text = "$\(travelFee)"
                                    if Double(travelFee) != nil {
                                        self.fetchPaymentIntent(costOfEvent: Double(travelFee)!)
                                    }
                                }
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
        db.collection(Auth.auth().currentUser!.displayName!).document(Auth.auth().currentUser!.uid).collection("Messages").document(orderMessageDocumentId).collection(orderMessageDocumentId).addSnapshotListener { documents, error in
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
                if Auth.auth().currentUser!.displayName! == "Chef" {
                    vari = "chefs"
                } else {
                    vari = "users"
                }
                let documentId = UUID().uuidString
                storageRef.child("\(vari)/\(Auth.auth().currentUser!.email!)/profileImage/\(Auth.auth().currentUser!.uid).png").downloadURL { url, error in
                    
                    
                    URLSession.shared.dataTask(with: url!) { (data, response, error) in
                        // Error handling...
                        guard let imageData = data else { return }
                        
                        print("happening itemdata")
                        DispatchQueue.main.async {
                            self.messages.append(Messages(homeOrAway: "home", pictureId: Auth.auth().currentUser!.uid, image: UIImage(data: imageData)!, message: self.messageText.text!, date: self.df.date(from: self.df.string(from: self.date))!, dateString: self.df.string(from: self.date), documentId: documentId, chefOrUser: Auth.auth().currentUser!.displayName!, travelFee: ""))
                            self.messages.sort(by: { $0.date.compare($1.date) == .orderedAscending })
                            self.messageTableView.reloadData()
                        }
                    }.resume()
                }
                   
                    
                    self.messageText.text = ""
                    if self.travelFeeOrMessages == "MessageRequests" && self.messages.count == 1 {
                        self.messageText.isEnabled = false
                    }
                    
                }
                
                let data : [String : Any] = ["chefOrUser" : Auth.auth().currentUser!.displayName!, "user" : Auth.auth().currentUser!.uid, "message" : messageText.text!, "date" : df.string(from: date), "userEmail": Auth.auth().currentUser!.email!, "travelFee" : "", "userName" : guserName, "fullName" : self.fullName]
                
            
                var travelFeeVari = ""
                
                if travelFeeOrMessages == "travelFee" {
                    travelFeeVari = "TravelFeeMessages"
                } else if travelFeeOrMessages == "Messages" {
                    travelFeeVari = "Messages"
                } else if travelFeeOrMessages == "MessageRequests" {
                    travelFeeVari = "MessageRequests"
                    
                    let documentId = UUID().uuidString
                    let data5 : [String: Any] = ["chefOrUser" :  Auth.auth().currentUser!.displayName!, "userImageId" : Auth.auth().currentUser!.uid, "userEmail" : Auth.auth().currentUser!.email!, "date": self.df.string(from: self.date), "userName" : guserName]
                    self.db.collection(Auth.auth().currentUser!.displayName!).document(Auth.auth().currentUser!.uid).collection(travelFeeVari).document(messageRequestDocumentId).setData(data5)
                    self.db.collection(messageRequestReceiverChefOrUser).document(messageRequestReceiverImageId).collection(travelFeeVari).document(messageRequestDocumentId).setData(data5)
                    self.db.collection(Auth.auth().currentUser!.displayName!).document(Auth.auth().currentUser!.uid).collection(travelFeeVari).document(messageRequestDocumentId).collection(messageRequestDocumentId).document(documentId).setData(data)
                    self.db.collection(messageRequestReceiverChefOrUser).document(messageRequestReceiverImageId).collection(travelFeeVari).document(messageRequestDocumentId).collection(messageRequestDocumentId).document(documentId).setData(data)
                  
                    print("other username")
                    db.collection(Auth.auth().currentUser!.displayName!).document(Auth.auth().currentUser!.uid).getDocument { document, error in
                        if error == nil {
                            if document != nil {
                                let data = document!.data()
                                
                                let notificationToken1 = data!["notificationToken"] as! String
                                
                                self.db.collection(self.messageRequestReceiverChefOrUser).document(self.messageRequestReceiverImageId).getDocument { document, error in
                                    if error == nil {
                                        if document != nil {
                                            let data = document!.data()
                                            let notificationToken2 = data!["notificationToken"] as! String
                                            
                                            self.subscribeToTopic(userNotification: notificationToken1, chefNotification: notificationToken2, chefOrUser: Auth.auth().currentUser!.displayName!, topic: self.messageRequestDocumentId)
                                        }
                                    }
                                }
                            }
                        }
                        
                    }
                    
                    let date =  self.df.string(from: Date())
                    let data3: [String: Any] = ["notification" : "@\(self.userName) has just sent you a message request.", "date" : date]
                    let data4: [String: Any] = ["notifications" : "yes"]
                    self.db.collection(messageRequestReceiverChefOrUser).document(messageRequestReceiverImageId).collection("Notifications").document().setData(data3)
                    self.db.collection(messageRequestReceiverChefOrUser).document(messageRequestReceiverImageId).updateData(data4)
                    
                } else {
                    travelFeeVari = "Messages"
                }
                if travelFeeVari != "MessageRequests" {
                    let documentId = UUID().uuidString
                    self.db.collection(Auth.auth().currentUser!.displayName!).document(Auth.auth().currentUser!.uid).collection(travelFeeVari).document(orderMessageDocumentId).collection(orderMessageDocumentId).document(documentId).setData(data)
                    self.db.collection(orderMessageReceiverChefOrUser).document(orderMessageReceiverImageId).collection(travelFeeVari).document(orderMessageDocumentId).collection(orderMessageDocumentId).document(documentId).setData(data)
                    
                    if Auth.auth().currentUser!.displayName! == "Chef" {
                        db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("PersonalInfo").getDocuments { documents, error in
                            if error == nil {
                                for doc in documents!.documents {
                                    let data = doc.data()
                                    let userName = data["chefName"] as! String
                                    self.sendMessage(title: travelFeeVari, notification: "New message from @\(userName)", topic: self.orderMessageDocumentId)
                                }
                            }
                        }
                    } else {
                        db.collection("User").document(Auth.auth().currentUser!.uid).collection("PersonalInfo").getDocuments { documents, error in
                            if error == nil {
                                for doc in documents!.documents {
                                    let data = doc.data()
                                    let userName = data["userName"] as! String
                                    self.sendMessage(title: travelFeeVari, notification: "New message from @\(userName)", topic: self.orderMessageDocumentId)
                                }
                            }
                        }
                    }
                    let date = Date()
                    let df = DateFormatter()
                    df.dateFormat = "MM-dd-yyyy hh:mm a"
                    let date1 =  df.string(from: Date())
                    let data3: [String: Any] = ["notification" : "\(guserName) has just messaged you (\(eventType)) about \(itemTitle).", "date" : date1]
                    let data4: [String: Any] = ["notifications" : "yes"]
                    self.db.collection(orderMessageReceiverChefOrUser).document(orderMessageReceiverImageId).collection("Notifications").document().setData(data3)
                    self.db.collection(orderMessageReceiverChefOrUser).document(orderMessageReceiverImageId).updateData(data4)
                
                
                
                self.showToast(message: "Message Sent", font: .systemFont(ofSize: 12))
            }
        }
    }
    
    private var user = ""
    private var chefOrUser = ""
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MessagesToProfileAsUserSegue" {
            let info = segue.destination as! ProfileAsUserViewController
            info.chefOrUser = Auth.auth().currentUser!.displayName!
            info.user = user
        } else if segue.identifier == "MessagesToTravelFeeSegue" {
            let info = segue.destination as! TravelFeeViewController
            info.travelFeePriceText = self.travelFee
            info.userImageId = userImageId
            info.chefOrUser = Auth.auth().currentUser!.displayName!
            info.travelFeePriceText = self.travelFee
//            info.order = self.order
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
