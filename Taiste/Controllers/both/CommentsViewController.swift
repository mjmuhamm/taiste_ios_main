//
//  CommentsViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 5/22/23.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class CommentsViewController: UIViewController {
    
    let date = Date()
    let df = DateFormatter()
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    @IBOutlet weak var sendComment: UIButton!
    @IBOutlet weak var messageText: UITextField!
    
    @IBOutlet weak var commentsTableView: UITableView!
    
    private var comments : [Comments] = []
    
    var videoId = ""
    var chefOrUser = ""
    var username = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        df.dateFormat = "dd-MM-yyyy HH:mm:ss"
        commentsTableView.delegate = self
        commentsTableView.dataSource = self
        
        commentsTableView.register(UINib(nibName: "CommentsTableViewCell", bundle: nil), forCellReuseIdentifier: "CommentsReusableCell")
        loadUsername()
    }
    
    private func loadUsername() {
        db.collection("Usernames").getDocuments { documents, error in
            if error == nil {
                for doc in documents!.documents {
                    let data = doc.data()
                    
                    if let email = data["email"] as? String, let username = data["username"] as? String {
                        if email == Auth.auth().currentUser!.email! {
                            self.username = username
                        }
                    }
                }
            }
        }
    }
    
    private func loadComments() {
        self.db.collection("Videos").document(videoId).collection("UserComments").addSnapshotListener { documents, error in
            if error == nil {
                if documents != nil {
                    for doc in documents!.documents {
                        let data = doc.data()
                        
                        if let comment = data["comment"] as? String, let date = data["date"] as? String, let likes = data["likes"] as? [String], let userImageId = data["userImageId"] as? String, let userEmail = data["userEmail"] as? String, let chefOrUser = data["chefOrUser"] as? String, let username = data["username"] as? String {
                            
                            
                            let index = self.comments.firstIndex(where: { $0.documentId == doc.documentID })
                            if index == nil {
                                self.comments.append(Comments(userImage: UIImage(), username: username, userImageId: userImageId, userEmail: userEmail, comment: comment, date: date, likes: likes, documentId: doc.documentID, chefOrUser: chefOrUser))
                                if self.comments.count == 1 {}
                            }
                            
                        }
                    }
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
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    @IBAction func sendCommentButtonPressed(_ sender: Any) {
        if messageText.text != nil && messageText.text! != "" {
            if Reachability.isConnectedToNetwork(){
                print("Internet Connection Available!")
                
                
                let data : [String : Any] = ["comment" : messageText.text!, "date" : df.string(from: Date()), "likes" : [], "userImageId" : Auth.auth().currentUser!.uid, "username" : self.username, "userEmail" : Auth.auth().currentUser!.email!, "chefOrUser" : chefOrUser]
                
                let documentId = UUID().uuidString
                self.db.collection("Videos").document(self.videoId).collection("UserComments").document(documentId).setData(data)
                self.messageText.text = ""
                self.showToast(message: "Comment Sent.", font: .systemFont(ofSize: 12))
                self.comments.append(Comments(userImage: UIImage(), username: username, userImageId: Auth.auth().currentUser!.uid, userEmail: Auth.auth().currentUser!.email!, comment: self.messageText.text!, date: self.df.string(from: Date()), likes: [], documentId: documentId, chefOrUser: chefOrUser))
                self.commentsTableView.reloadData()
                
            }  else {
                self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
            }
        } else {
            self.showToast(message: "Please enter a message first.", font: .systemFont(ofSize: 12))
        }
    }
}

extension CommentsViewController :  UITableViewDelegate, UITableViewDataSource  {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = commentsTableView.dequeueReusableCell(withIdentifier: "CommentsReusableCell", for: indexPath) as! CommentsTableViewCell
        let comment = comments[indexPath.row]
      
        

        cell.thoughtsText.text = comment.comment
        cell.date.text = comment.date
        
        let storageRef = storage.reference()
        
        var chefOrUser = ""
        if comment.chefOrUser == "Chef" { chefOrUser = "chefs" } else { chefOrUser = "users" }
        
        storageRef.child("\(chefOrUser)/\(comment.userEmail)/profileImage/\(comment.userImageId).png").getData(maxSize: 15 * 1024 * 1024) { data, error in
            if error == nil {
                let image = UIImage(data: data!)
                cell.userImage.image = image
            }
        }
        
        cell.likeText.text = "\(comment.likes.count)"
        
        cell.userlikedTapped = {
            self.db.collection("Videos").document(self.videoId).collection("UserComments").document(comment.documentId).getDocument { document, error in
                if error == nil {
                    if document != nil {
                        let data = document!.data()
                        
                        let likes = data!["likes"] as? [String]
                        if !likes!.contains(Auth.auth().currentUser!.email!) {
                            cell.likeImage.image = UIImage(systemName: "heart.fill")
                            cell.likeText.text = "\(Int(cell.likeText.text!)! + 1)"
                            self.db.collection("Videos").document(self.videoId).collection("UserComments").document(comment.documentId).updateData(["likes" : FieldValue.arrayUnion(["\(Auth.auth().currentUser!.email!)"])])
                        } else {
                            cell.likeImage.image = UIImage(systemName: "heart")
                            cell.likeText.text = "\(Int(cell.likeText.text!)! - 1)"
                            self.db.collection("Videos").document(self.videoId).collection("UserComments").document(comment.documentId).updateData(["likes" : FieldValue.arrayRemove(["\(Auth.auth().currentUser!.email!)"])])
                        }
                    }
                }
            }
        }
        
        cell.userProfileTapped = {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileAsUser") as? ProfileAsUserViewController {
                vc.chefOrUser = "user"
                vc.user = comment.userImageId
                vc.toggle = "Orders"
                self.present(vc, animated: true, completion: nil)
            }
        }
        
        
    
        
        return cell
    }
    
}
