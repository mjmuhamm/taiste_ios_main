//
//  NotificationsViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 6/11/23.
//

import UIKit
import MaterialComponents.MaterialButtons
import MaterialComponents
import Firebase
import FirebaseStorage

class NotificationsViewController: UIViewController {
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    var chefOrUser = ""
    private var toggle = "Messages"
    private var notifications : [Notifications] = []
    private var messages : [MessageNotification] = []

    @IBOutlet weak var messagesButton: MDCButton!
    @IBOutlet weak var notificationsButton: MDCButton!
    
    @IBOutlet weak var notificationsTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        notificationsTableView.delegate = self
        notificationsTableView.dataSource = self
        notificationsTableView.register(UINib(nibName: "NotificationsTableViewCell", bundle: nil), forCellReuseIdentifier: "NotificationsReusableCell")
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            loadNotifications()
        } else {
        self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
       }
        
        
        // Do any additional setup after loading the view.
    }
    
    private func loadNotifications() {
        notificationsTableView.reloadData()
        let data2 : [String: Any] = ["notifications" : ""]
        db.collection(Auth.auth().currentUser!.displayName!).document(Auth.auth().currentUser!.uid).updateData(data2)
        if toggle == "Messages" {
            db.collection(Auth.auth().currentUser!.displayName!).document(Auth.auth().currentUser!.uid).collection("MessageRequests").addSnapshotListener { documents, error in
                if error == nil {
                    if documents != nil {
                        for doc in documents!.documents {
                            let data = doc.data()
                            
                            if let userImageId = data["user"] as? String, let userName = data["userName"] as? String, let chefOrUser = data["chefOrUser"] as? String, let userEmail = data["userEmail"] as? String, let date = data["date"] as? String {
                                
                                let message = MessageNotification(chefOrUser: chefOrUser, notification: "", userName: userName, userEmail: userEmail, userImageId: userImageId, date: date, documentId: doc.documentID)
                                
                                DispatchQueue.main.async {
                                    if self.messages.count == 0 {
                                        self.messages.append(message)
                                        self.messages.sort(by: { $0.date.compare($1.date) == .orderedAscending })
                                        self.notificationsTableView.reloadData()
                                    } else {
                                        if let index = self.messages.firstIndex(where: { $0.userImageId == userImageId }) {} else {
                                            self.messages.append(message)
                                            self.messages.sort(by: { $0.date.compare($1.date) == .orderedAscending })
                                            self.notificationsTableView.reloadData()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else {
            
            db.collection(Auth.auth().currentUser!.displayName!).document(Auth.auth().currentUser!.uid).collection("Notifications").addSnapshotListener { documents, error in
                if error == nil {
                    if documents != nil {
                        for doc in documents!.documents {
                            let data = doc.data()
                            
                            if let notification = data["notification"] as? String, let date = data["date"] as? String {
                                let notification = Notifications(chefOrUser: "", messageOrEvent: "", notification: notification, date: date, documentId: doc.documentID)
                                
                                DispatchQueue.main.async {
                                    if self.notifications.count == 0 {
                                        self.notifications.append(notification)
                                        self.notifications.sort(by: { $0.date.compare($1.date) == .orderedAscending })
                                        self.notificationsTableView.insertRows(at: [IndexPath(item: 0, section: 0)], with: .fade)
                                    } else {
                                        if let index = self.notifications.firstIndex(where: { $0.documentId == doc.documentID }) {} else {
                                            self.notifications.append(notification)
                                            self.notifications.sort(by: { $0.date.compare($1.date) == .orderedAscending })
                                            self.notificationsTableView.insertRows(at: [IndexPath(item: self.notifications.count - 1, section: 0)], with: .fade)
                                        }
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
        self.dismiss(animated: true)
        
    }
    @IBAction func messagesButtonPressed(_ sender: Any) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
      
      
        toggle = "Messages"
        loadNotifications()
        messagesButton.setTitleColor(UIColor.white, for: .normal)
        messagesButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
        notificationsButton.backgroundColor = UIColor.white
        notificationsButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        } else {
        self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
       }
    }
    
    @IBAction func notificationsButtonPressed(_ sender: Any) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
      
        toggle = "Notifications"
        loadNotifications()
        notificationsButton.setTitleColor(UIColor.white, for: .normal)
        notificationsButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
        messagesButton.backgroundColor = UIColor.white
        messagesButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
            
              } else {
              self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
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

extension NotificationsViewController :  UITableViewDelegate, UITableViewDataSource  {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if toggle == "Messages" {
            return messages.count
        } else {
            return notifications.count
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = notificationsTableView.dequeueReusableCell(withIdentifier: "NotificationsReusableCell", for: indexPath) as! NotificationsTableViewCell
        
        
        
        
        
        if toggle == "Messages" {
            let message = messages[indexPath.row]
            cell.userImage.isHidden = false
            cell.userImageButton.isHidden = false
            
            cell.message.text = "@\(message.userName)"
            cell.message2.text = "Click here to view your message from @\(message.userName)"
            
            var a = ""
            if message.chefOrUser == "Chef" { a = "chef" } else { a = "user" }
            
            let storageRef = storage.reference()
            storageRef.child("\(a)s/\(message.userEmail)/profileImage/\(message.userImageId).png").downloadURL { imageUrl, error in
                
                
                URLSession.shared.dataTask(with: imageUrl!) { (data, response, error) in
                    // Error handling...
                    guard let imageData = data else { return }
                    
                    print("happening itemdata")
                    DispatchQueue.main.async {
                        cell.userImage.image = UIImage(data: imageData)!
                        
                    }
                }.resume()
            }
            
            cell.userImageTapped = {
              
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileAsUser") as? ProfileAsUserViewController {
                    vc.user = message.userImageId
                    vc.chefOrUser = a
                    self.present(vc, animated: true, completion: nil)
                }
            }
            
            cell.notificationTapped = {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "Messages") as? MessagesViewController {
                    vc.messageRequestReceiverUsername = message.userName
                    vc.messageRequestSenderUsername = guserName
                    vc.messageRequestSenderImageId = Auth.auth().currentUser!.uid
                    vc.messageRequestReceiverImageId = message.userImageId
                    vc.messageRequestChefOrUser = Auth.auth().currentUser!.displayName!
                    vc.messageRequestDocumentId = message.documentId
                    vc.messageRequestSenderEmail = Auth.auth().currentUser!.email!
                    vc.messageRequestReceiverEmail = message.userEmail
                    vc.messageRequestReceiverChefOrUser = message.chefOrUser
                    vc.travelFeeOrMessages = "MessageRequests"
                    self.present(vc, animated: true, completion: nil)
                }
            }
            
        } else {
            let notification = notifications[indexPath.row]
            cell.userImage.isHidden = true
            cell.userImageButton.isHidden = true
            cell.message.text = "@\(notification.notification)"
            cell.message2.text = notification.date
            
            
        }
        
        
        
        return cell
    }
}
