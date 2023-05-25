//
//  ReviewsViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 5/22/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class ReviewsViewController: UIViewController {

    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var reviewTableView: UITableView!
    
    var reviews: [Reviews] = []
    
    var item : FeedMenuItems?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reviewTableView.delegate = self
        reviewTableView.dataSource = self
        
        reviewTableView.register(UINib(nibName: "ReviewsTableViewCell", bundle: nil), forCellReuseIdentifier: "ReviewsReusableCell")
        
        reviewTableView.reloadData()
    }
    
    private func loadReviews() {
        let storageRef = storage.reference()
        
        db.collection(item!.itemType).document(item!.menuItemId).collection("UserReviews").addSnapshotListener { documents, error in
            if error == nil {
                if documents != nil {
                    for doc in documents!.documents {
                        let data = doc.data()
                        
                        if let date = data["date"] as? String, let expectations = data["expectations"] as? Int, let likes = data["liked"] as? [String], let quality = data["quality"] as? Int, let recommend = data["recommend"] as? Int, let chefRating = data["chefRating"] as? Int, let thoughts = data["thoughts"] as? String, let userImageId = data["userImageId"] as? String, let userEmail = data["userEmail"] as? String {
                            
                            if let index = self.reviews.firstIndex(where: { $0.documentId == doc.documentID }) {} else {
                            
                                        
                                    self.reviews.append(Reviews(date: date, expectations: expectations, quality: quality, chefRating: chefRating, likes: likes, recommend: recommend, thoughts: thoughts, image: UIImage(), userImageId: userImageId, userEmail: userEmail, documentId: doc.documentID))
                                        }
                                DispatchQueue.main.async {
                                    
//                                    if self.reviews.count == 1 {
//                                        self.reviewTableView.insertRows(at: [IndexPath(item: 0, section: 0)], with: .fade)
//                                    } else {
//                                        self.reviewTableView.insertRows(at: [IndexPath(item: self.reviews.count - 1, section: 0)], with: .fade)
//                                    }
                                    self.reviewTableView.reloadData()
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
    
    

}
extension ReviewsViewController :  UITableViewDelegate, UITableViewDataSource  {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = reviewTableView.dequeueReusableCell(withIdentifier: "ReviewsReusableCell", for: indexPath) as! ReviewsTableViewCell
        var review = reviews[indexPath.row]
      
        cell.thoughtsText.text = review.thoughts
        cell.reviewDate.text = review.date
        cell.expectectationsText.text = "\(review.expectations)"
        cell.qualityText.text = "\(review.quality)"
        cell.chefRatingText.text = "\(review.chefRating)"
        
        
        let chefRef = storage.reference()
        
        DispatchQueue.main.async {

        chefRef.child("users/\(review.userEmail)/profileImage/\(review.userImageId).png").getData(maxSize: 15 * 1024 * 1024) { data, error in
            if error == nil {
                cell.userImage.image = UIImage(data: data!)!
            }}
            
        }
        
        if review.recommend == 1 {
            cell.recommendText.text = "Yes"
        } else {
            cell.recommendText.text = "No"
        }
        cell.likesText.text = "\(review.likes.count)"
        
        cell.userlikedTapped = {
            self.db.collection(self.item!.itemType).document(self.item!.menuItemId).collection("UserReviews").document(review.documentId).getDocument { document, error in
                if error == nil {
                    if document != nil {
                        let data = document!.data()
                        
                        let likes = data!["likes"] as? [String]
                        if !likes!.contains(Auth.auth().currentUser!.email!) {
                            cell.likeImage.image = UIImage(systemName: "heart.fill")
                            cell.likesText.text = "\(Int(cell.likesText.text!)! + 1)"
                            self.db.collection(self.item!.itemType).document(self.item!.menuItemId).collection("UserReviews").document(review.documentId).updateData(["likes" : FieldValue.arrayUnion(["\(Auth.auth().currentUser!.email!)"])])
                        } else {
                            cell.likeImage.image = UIImage(systemName: "heart")
                            cell.likesText.text = "\(Int(cell.likesText.text!)! - 1)"
                            self.db.collection(self.item!.itemType).document(self.item!.menuItemId).collection("UserReviews").document(review.documentId).updateData(["likes" : FieldValue.arrayRemove(["\(Auth.auth().currentUser!.email!)"])])
                        }
                    }
                }
            }
        }
        
        cell.userProfileTapped = {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileAsUser") as? ProfileAsUserViewController {
                vc.chefOrUser = "user"
                vc.user = review.userImageId
                vc.toggle = "Orders"
                self.present(vc, animated: true, completion: nil)
            }
        }
        
        
    
        
        return cell
    }
    
}
