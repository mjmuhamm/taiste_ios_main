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
    
    @IBOutlet weak var messageLabel: UILabel!
    
    
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
        
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
       
        if travelFeeOrMessages == "MessageRequests" {
            self.eventTypeAndQuantity.isHidden = true
            self.location.isHidden = true
            
        } else {
           
            self.eventTypeAndQuantity.text = "Event Type: \(eventType)   Event Quantity: \(eventQuantity)"
            self.location.text = locationText
            self.eventTypeAndQuantity.isHidden = false
            self.location.isHidden = false
        }
            
        df.dateFormat = "MM-dd-yyyy hh:mm:ss a"
        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        messageTableView.register(UINib(nibName: "MessagesTableViewCell", bundle: nil), forCellReuseIdentifier: "MessagesReusableCell")
        
        if travelFeeOrMessages == "MessageRequests" {
            username.text = messageRequestSenderUsername
        } else {
            username.text = orderMessageSenderName
        }
        
//        
        if travelFeeOrMessages == "travelFee" {
            if Auth.auth().currentUser != nil {
                    messageLabel.isHidden = true
                    requestTravelFeeButton.isHidden = false
                if orderMessageChefOrUser == "User" {
                    requestTravelFeeButton.setTitle("Pay Travel Fee", for: .normal)
                    if Double(travelFee) == nil {
                        requestTravelFeeButton.isEnabled = true
                    } else {
                        requestTravelFeeButton.isEnabled = false
                    }
                } else {
                    requestTravelFeeButton.setTitle("Request Travel Fee", for: .normal)
                }
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
        
        self.requestTravelFeeButton.isEnabled = true
        loadUsername()
        if travelFeeOrMessages == "messages" {
            self.travelFeeLabel.isHidden = true
        }
        } else {
              self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
        }
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
                        if let chefOrUserI = data["chefOrUser"] as? String, let user = data["userImageId"] as? String, let message = data["message"] as? String, let date = data["date"] as? String, let userEmail = data["userEmail"] as? String {
                         
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
                            
                                
                                DispatchQueue.main.async {
                                    print("message \(message)")
                                    let index = self.messages.firstIndex { $0.documentId == doc.documentID }
                                    if index == nil {
                                    self.messages.append(Messages(homeOrAway: homeOrAway, userImageId: user, userEmail: userEmail, image: UIImage(), message: message, date: date1!, dateString: date, documentId: doc.documentID, chefOrUser: "\(vari.prefix(4))", travelFee: ""))
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
    
    private func loadTravelFeeMessages() {
        
        let storageRef = storage.reference()
        db.collection(Auth.auth().currentUser!.displayName!).document(Auth.auth().currentUser!.uid).collection("TravelFeeMessages").document(orderMessageDocumentId).collection(orderMessageDocumentId).addSnapshotListener { documents, error in
            if error == nil {
                if documents != nil {
                    for doc in documents!.documents {
                        if doc.documentID != "payment" {
                        let data = doc.data()
                        if let chefOrUserI = data["chefOrUser"] as? String, let user = data["userImageId"] as? String, let message = data["message"] as? String, let date = data["date"] as? String, let userEmail = data["userEmail"] as? String, let travelFee = data["travelFee"] as? String {
                            
                          
                            var homeOrAway = ""
                            if userEmail == Auth.auth().currentUser!.email! {
                                homeOrAway = "home"
                            } else if travelFee == "" {
                                homeOrAway = "away"
                            } else {
                                homeOrAway = "travel"
                                if Auth.auth().currentUser!.displayName! == "User" {
                                self.travelFeeLabel.text = "$\(travelFee)"
                                   
                                }
                            }
                            let date1 = self.df.date(from: date)
                                let index = self.messages.firstIndex(where: { $0.documentId == doc.documentID })
                                if index == nil {
                                    self.messages.append(Messages(homeOrAway: homeOrAway, userImageId: user, userEmail: userEmail, image: UIImage(), message: message, date: date1!, dateString: date, documentId: doc.documentID, chefOrUser: chefOrUserI, travelFee: travelFee))
                                    
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
                        if let chefOrUserI = data["chefOrUser"] as? String, let user = data["userImageId"] as? String, let message = data["message"] as? String, let date = data["date"] as? String, let userEmail = data["userEmail"] as? String, let travelFee = data["travelFee"] as? String {
                         
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
                              
                            }
                            let date1 = self.df.date(from: date)
                                
                                 
                                DispatchQueue.main.async {
                                    let index = self.messages.firstIndex { $0.documentId == doc.documentID }
                                    if index == nil {
                                    self.messages.append(Messages(homeOrAway: homeOrAway, userImageId: user, userEmail: userEmail, image: UIImage(), message: message, date: date1!, dateString: date, documentId: doc.documentID, chefOrUser: "\(vari.prefix(4))", travelFee: ""))
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
    
  
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func payButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func requestTravelFeeButtonPressed(_ sender: Any) {
        if travelFeeLabel.text != "" {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "TravelFee") as? TravelFeeViewController  {
                vc.orderMessageDocumentId = self.orderMessageDocumentId
                vc.orderMessageReceiverEmail = self.orderMessageReceiverEmail
                vc.orderMessageReceiverImageId = self.orderMessageReceiverImageId
                vc.totalCostOfEvent = self.totalCostOfEvent
                vc.eventType = self.eventType
                vc.travelFeePriceText = self.travelFee
                vc.userImageId = userImageId
                vc.chefOrUser = Auth.auth().currentUser!.displayName!
                vc.travelFeePriceText = self.travelFee
                self.present(vc, animated: true, completion: nil)
            }
            
        }
    }
    
    @IBAction func sendMessageButtonPressed(_ sender: Any) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
       
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
                
                   
                
                    
                    if self.travelFeeOrMessages == "MessageRequests" && self.messages.count == 1 {
                        self.messageText.isEnabled = false
                    }
                    
                }
                
                let data : [String : Any] = ["chefOrUser" : Auth.auth().currentUser!.displayName!, "userImageId" : Auth.auth().currentUser!.uid, "message" : messageText.text!, "date" : df.string(from: date), "userEmail": Auth.auth().currentUser!.email!, "travelFee" : "", "userName" : guserName, "fullName" : self.fullName]
                
            
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
                    self.db.collection(Auth.auth().currentUser!.displayName!).document(Auth.auth().currentUser!.uid).collection(travelFeeVari).document(orderMessageDocumentId).setData(data)
                    self.db.collection(orderMessageReceiverChefOrUser).document(orderMessageReceiverImageId).collection(travelFeeVari).document(orderMessageDocumentId).setData(data)
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
                    df.dateFormat = "MM-dd-yyyy hh:mm:ss a"
                    let date1 =  df.string(from: Date())
                    let data3: [String: Any] = ["notification" : "\(guserName) has just messaged you (\(eventType)) about \(itemTitle).", "date" : date1]
                    let data4: [String: Any] = ["notifications" : "yes"]
                    self.db.collection(orderMessageReceiverChefOrUser).document(orderMessageReceiverImageId).collection("Notifications").document().setData(data3)
                    self.db.collection(orderMessageReceiverChefOrUser).document(orderMessageReceiverImageId).updateData(data4)
                
                
                
                self.showToast(message: "Message Sent", font: .systemFont(ofSize: 12))
            }
        }
        messageText.text = ""
        } else {
              self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
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
        
        if message.homeOrAway == "home" && message.chefOrUser != "system" {
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
        } else if message.homeOrAway == "away" &&  message.chefOrUser != "system" {
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
            print("travelfee \(message.travelFee)")
            self.travelFeeLabel.text = "$\(message.travelFee)"
            self.travelFeeLabel.isHidden = false
        }
        var a = ""
        if message.chefOrUser == "Chef" || message.chefOrUser == "chef" { a = "chefs" } else { a = "users" }
        if message.travelFee != "" {
            
        }
        
        if message.documentId == "payment" {
            self.showToast(message: "Payment Received.", font: .systemFont(ofSize: 12))
            if Auth.auth().currentUser!.displayName! == "Chef" {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChefTab") as? ChefTabViewController  {
                    self.present(vc, animated: true, completion: nil)
                }
            } else {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserTab") as? UserTabViewController  {
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
        
        print("cheforuser \(message.chefOrUser)")
        print("\(message.userEmail)")
        print("\(message.userImageId)")
        if (message.homeOrAway == "home" || message.homeOrAway == "away") && message.chefOrUser != "system" {
            let storageRef = storage.reference()
            storageRef.child("\(a)/\(message.userEmail)/profileImage/\(message.userImageId).png").downloadURL { imageUrl, error in
                
                
                URLSession.shared.dataTask(with: imageUrl!) { (data, response, error) in
                    // Error handling...
                    guard let imageData = data else { return }
                    
                    print("happening itemdata")
                    DispatchQueue.main.async {
                        let image = UIImage(data: data!)!
                        if message.homeOrAway == "home" {
                            cell.homeImage.image = image
                        } else {
                            cell.awayImage.image = image
                        }
                     }
                }.resume()
                
            }
        }
        
        cell.profileButtonTapped = {
            self.user = message.userImageId
            self.chefOrUser = message.chefOrUser
            self.performSegue(withIdentifier: "MessagesToProfileAsUserSegue", sender: self)
        }
        
        
        
        
        
        
        
        return cell
    }
}
