//
//  MessagesViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 5/2/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
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
    
    @IBOutlet weak var travelFeeStack: UIStackView!
    @IBOutlet weak var travelFeeLabel: UILabel!
    @IBOutlet weak var payButton: UIButton!
    
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var requestTravelFeeButton: UIButton!
    
    private var messages : [Messages] = []
    private var sortedMessages : [Messages] = []
    
    var travelFeeOrMessage = ""
    var otherUser = ""
    private var travelFeePriceText = ""
    private var userImageId = ""
    var order : Orders?
    var chefOrUser = ""
    var documentId = ""
    private var paymentId = ""
    
    @IBOutlet weak var messageText: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        payButton.addTarget(self, action: #selector(didTapCheckoutButton), for: .touchUpInside)
        df.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        messageTableView.register(UINib(nibName: "MessagesTableViewCell", bundle: nil), forCellReuseIdentifier: "MessagesReusableCell")
        
        username.text = otherUser
        
        if chefOrUser == "Chef" {
            requestTravelFeeButton.isHidden = false
        } else {
            requestTravelFeeButton.isHidden = true
        }
//        
        if travelFeeOrMessage == "travelFee" {
            loadTravelFeeMessages()
        } else {
            requestTravelFeeButton.isHidden = true
            loadMessages()
        }
        
        
    }
    
    
    private func fetchPaymentIntent(costOfEvent: Double) {
        
        let cost = costOfEvent * 100
        let a = String(format: "%.0f", cost)
        
        let json: [String: Any] = ["amount": a]
        
        
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
            self.payButton.isEnabled = true
              self.paymentId = paymentId
          }
        })
        task.resume()
    }
    
    private func saveInfo() {
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
        self.db.collection("User").document(Auth.auth().currentUser!.uid).collection("TravelFeeMessages").document(order!.menuItemId).collection(order!.itemTitle).document("payment").setData(data)
        self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("TravelFeeMessages").document(order!.menuItemId).collection(order!.itemTitle).document("payment").setData(data)
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
    }
    
    private func loadTravelFeeMessages() {
        let storageRef = storage.reference()
        db.collection(chefOrUser).document(Auth.auth().currentUser!.uid).collection("TravelFeeMessages").document(order!.documentId).collection(order!.itemTitle).addSnapshotListener { documents, error in
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
                            if userEmail == Auth.auth().currentUser!.email {
                                homeOrAway = "home"
                            } else if travelFee == "" {
                                homeOrAway = "away"
                            } else {
                                homeOrAway = "travel"
                                if self.chefOrUser == "User" {
                                self.travelFeeStack.isHidden = false
                                self.travelFeeLabel.text = "$\(travelFee)"
                                self.fetchPaymentIntent(costOfEvent: Double(travelFee)!)
                                }
                            }
                            self.travelFeePriceText = travelFee
                            if user != Auth.auth().currentUser!.uid {
                                self.userImageId = user
                            }
                            
                            print("vari \(vari)")
                            print("homeoraway \(homeOrAway)")
                            print("useremail \(userEmail)")
                            print("user \(user)")
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
                            if userEmail == Auth.auth().currentUser!.email {
                                homeOrAway = "home"
                            } else if travelFee == "" {
                                homeOrAway = "away"
                            } else {
                                homeOrAway = "travel"
                                self.travelFeeStack.isHidden = false
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
        
        let data : [String : Any] = ["chefOrUser" : chefOrUser, "user" : Auth.auth().currentUser!.uid, "message" : messageText.text, "date" : df.string(from: date), "userEmail": Auth.auth().currentUser!.email, "travelFee" : ""]
        
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
        } else {
            travelFeeVari = "Messages"
        }
        self.db.collection(chefOrUser).document(Auth.auth().currentUser!.uid).collection(travelFeeVari).document(order!.documentId).collection(order!.itemTitle).document(documentId).setData(data)
        self.db.collection(otherUser).document(otherImageId).collection(travelFeeVari).document(order!.documentId).collection(order!.itemTitle).document(documentId).setData(data)
        
       
        self.showToast(message: "Message Sent", font: .systemFont(ofSize: 12))
        
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
