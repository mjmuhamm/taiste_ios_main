//
//  UserReviewViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 5/5/23.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import MaterialComponents.MaterialButtons
import MaterialComponents

class UserReviewViewController: UIViewController {
    
    let date = Date()
    let df = DateFormatter()
    
    private let db = Firestore.firestore()

    @IBOutlet weak var expectations1: UIImageView!
    @IBOutlet weak var expectations2: UIImageView!
    @IBOutlet weak var expectations3: UIImageView!
    @IBOutlet weak var expectations4: UIImageView!
    @IBOutlet weak var expectations5: UIImageView!
    
    @IBOutlet weak var quality1: UIImageView!
    @IBOutlet weak var quality2: UIImageView!
    @IBOutlet weak var quality3: UIImageView!
    @IBOutlet weak var quality4: UIImageView!
    @IBOutlet weak var quality5: UIImageView!
    
    @IBOutlet weak var chefRating1: UIImageView!
    @IBOutlet weak var chefRating2: UIImageView!
    @IBOutlet weak var chefRating3: UIImageView!
    @IBOutlet weak var chefRating4: UIImageView!
    @IBOutlet weak var chefRating5: UIImageView!
    
    @IBOutlet weak var recommendYesButton: MDCButton!
    @IBOutlet weak var recommendNoButton: MDCButton!
    
    @IBOutlet weak var thoughtsText: UITextField!
    
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var itemDescription: UILabel!
    
    private var expectationsNum = 0
    private var qualityNum = 0
    private var chefRatingNum = 0
    private var recommend = 1
    
    var item : Orders?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemTitle.text = item!.itemTitle
        itemDescription.text = item!.itemDescription
        loadUsername()
        df.dateFormat = "yyyy-MM-dd HH:mm"
    //        print("date \(year), \(month)")

        // Do any additional setup after loading the view.
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
    
    
    
    @IBAction func expectations1ButtonPressed(_ sender: Any) {
        expectationsNum = 1
        self.expectations1.image = UIImage(systemName: "star.fill")
        self.expectations2.image = UIImage(systemName: "star")
        self.expectations3.image = UIImage(systemName: "star")
        self.expectations4.image = UIImage(systemName: "star")
        self.expectations5.image = UIImage(systemName: "star")
    }
    
    @IBAction func expectations2ButtonPressed(_ sender: Any) {
        expectationsNum = 2
        self.expectations1.image = UIImage(systemName: "star.fill")
        self.expectations2.image = UIImage(systemName: "star.fill")
        self.expectations3.image = UIImage(systemName: "star")
        self.expectations4.image = UIImage(systemName: "star")
        self.expectations5.image = UIImage(systemName: "star")
    }
    
    @IBAction func expectations3ButtonPressed(_ sender: Any) {
        expectationsNum = 3
        self.expectations1.image = UIImage(systemName: "star.fill")
        self.expectations2.image = UIImage(systemName: "star.fill")
        self.expectations3.image = UIImage(systemName: "star.fill")
        self.expectations4.image = UIImage(systemName: "star")
        self.expectations5.image = UIImage(systemName: "star")
    }
    
    @IBAction func expectations4ButtonPressed(_ sender: Any) {
        expectationsNum = 4
        self.expectations1.image = UIImage(systemName: "star.fill")
        self.expectations2.image = UIImage(systemName: "star.fill")
        self.expectations3.image = UIImage(systemName: "star.fill")
        self.expectations4.image = UIImage(systemName: "star.fill")
        self.expectations5.image = UIImage(systemName: "star")
    }
    
    @IBAction func expectations5ButtonPressed(_ sender: Any) {
        expectationsNum = 5
        self.expectations1.image = UIImage(systemName: "star.fill")
        self.expectations2.image = UIImage(systemName: "star.fill")
        self.expectations3.image = UIImage(systemName: "star.fill")
        self.expectations4.image = UIImage(systemName: "star.fill")
        self.expectations5.image = UIImage(systemName: "star.fill")
    }
    
    
    @IBAction func quality1ButtonPressed(_ sender: Any) {
        qualityNum = 1
        self.quality1.image = UIImage(systemName: "star.fill")
        self.quality2.image = UIImage(systemName: "star")
        self.quality3.image = UIImage(systemName: "star")
        self.quality4.image = UIImage(systemName: "star")
        self.quality5.image = UIImage(systemName: "star")
    }
    
    @IBAction func quality2ButtonPressed(_ sender: Any) {
        qualityNum = 2
        self.quality1.image = UIImage(systemName: "star.fill")
        self.quality2.image = UIImage(systemName: "star.fill")
        self.quality3.image = UIImage(systemName: "star")
        self.quality4.image = UIImage(systemName: "star")
        self.quality5.image = UIImage(systemName: "star")
    }
    
    @IBAction func quality3ButtonPressed(_ sender: Any) {
        qualityNum = 3
        self.quality1.image = UIImage(systemName: "star.fill")
        self.quality2.image = UIImage(systemName: "star.fill")
        self.quality3.image = UIImage(systemName: "star.fill")
        self.quality4.image = UIImage(systemName: "star")
        self.quality5.image = UIImage(systemName: "star")
    }
    
    @IBAction func quality4ButtonPressed(_ sender: Any) {
        qualityNum = 4
        self.quality1.image = UIImage(systemName: "star.fill")
        self.quality2.image = UIImage(systemName: "star.fill")
        self.quality3.image = UIImage(systemName: "star.fill")
        self.quality4.image = UIImage(systemName: "star.fill")
        self.quality5.image = UIImage(systemName: "star")
    }
    
    @IBAction func quality5ButtonPressed(_ sender: Any) {
        qualityNum = 5
        self.quality1.image = UIImage(systemName: "star.fill")
        self.quality2.image = UIImage(systemName: "star.fill")
        self.quality3.image = UIImage(systemName: "star.fill")
        self.quality4.image = UIImage(systemName: "star.fill")
        self.quality5.image = UIImage(systemName: "star.fill")
    }
    
    
    @IBAction func chefRating1ButtonPressed(_ sender: Any) {
        chefRatingNum = 1
        self.chefRating1.image = UIImage(systemName: "star.fill")
        self.chefRating2.image = UIImage(systemName: "star")
        self.chefRating3.image = UIImage(systemName: "star")
        self.chefRating4.image = UIImage(systemName: "star")
        self.chefRating5.image = UIImage(systemName: "star")
    }
    
    @IBAction func chefRating2ButtonPressed(_ sender: Any) {
        chefRatingNum = 2
        self.chefRating1.image = UIImage(systemName: "star.fill")
        self.chefRating2.image = UIImage(systemName: "star.fill")
        self.chefRating3.image = UIImage(systemName: "star")
        self.chefRating4.image = UIImage(systemName: "star")
        self.chefRating5.image = UIImage(systemName: "star")
    }
    
    @IBAction func chefRating3ButtonPressed(_ sender: Any) {
        chefRatingNum = 3
        self.chefRating1.image = UIImage(systemName: "star.fill")
        self.chefRating2.image = UIImage(systemName: "star.fill")
        self.chefRating3.image = UIImage(systemName: "star.fill")
        self.chefRating4.image = UIImage(systemName: "star")
        self.chefRating5.image = UIImage(systemName: "star")
    }
    
    @IBAction func chefRating4ButtonPressed(_ sender: Any) {
        chefRatingNum = 4
        self.chefRating1.image = UIImage(systemName: "star.fill")
        self.chefRating2.image = UIImage(systemName: "star.fill")
        self.chefRating3.image = UIImage(systemName: "star.fill")
        self.chefRating4.image = UIImage(systemName: "star.fill")
        self.chefRating5.image = UIImage(systemName: "star")
    }
    
    @IBAction func chefRating5ButtonPressed(_ sender: Any) {
        chefRatingNum = 5
        self.chefRating1.image = UIImage(systemName: "star.fill")
        self.chefRating2.image = UIImage(systemName: "star.fill")
        self.chefRating3.image = UIImage(systemName: "star.fill")
        self.chefRating4.image = UIImage(systemName: "star.fill")
        self.chefRating5.image = UIImage(systemName: "star.fill")
    }
    
    @IBAction func recommendYesButtonPressed(_ sender: Any) {
        recommend = 1
        recommendYesButton.setTitleColor(UIColor.white, for:.normal)
        recommendYesButton.backgroundColor = UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1)
        recommendNoButton.backgroundColor = UIColor.white
        recommendNoButton.setTitleColor(UIColor(red:98/255, green: 99/255, blue: 72/255, alpha:1), for: .normal)
        
    }
    
    @IBAction func recommendNoButtonPressed(_ sender: Any) {
        recommend = 2
        recommendNoButton.setTitleColor(UIColor.white, for:.normal)
        recommendNoButton.backgroundColor = UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1)
        recommendYesButton.backgroundColor = UIColor.white
        recommendYesButton.setTitleColor(UIColor(red:98/255, green: 99/255, blue: 72/255, alpha:1), for: .normal)
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            
            let data: [String: Any] = ["itemTitle" : item!.itemTitle, "itemDescription" : item!.itemDescription, "expectations" : expectationsNum, "quality" : qualityNum, "chefRating" : chefRatingNum, "recommend" : recommend, "thoughts" : thoughtsText.text ?? "", "date" :  df.string(from: date), "liked" : [], "chefEmail" : item!.chefEmail, "chefImageId" : item!.chefImageId, "itemType" : item!.typeOfService]
            let data1: [String: Any] = ["itemRating" : (expectationsNum + qualityNum + chefRatingNum) / 3]
            db.collection(item!.typeOfService).document(item!.menuItemId).collection("UserReviews").document().setData(data)
            db.collection("User").document(Auth.auth().currentUser!.uid).collection("UserReviews").document().setData(data)
            
            
            let date = Date()
            let df = DateFormatter()
            df.dateFormat = "MM-dd-yyyy hh:mm a"
            let date1 =  df.string(from: Date())
            let data3: [String: Any] = ["notification" : "\(guserName) has just reviewed your item (\(item!.typeOfService)) \(item!.itemTitle).", "date" : date1]
            let data4: [String: Any] = ["notifications" : "yes"]
            self.db.collection("Chef").document(item!.chefImageId).collection("Notifications").document().setData(data3)
            self.db.collection("Chef").document(item!.chefImageId).updateData(data4)
            //        db.collection(item!.typeOfService).document(item!.menuItemId)
            
            self.performSegue(withIdentifier: "UserReviewToHomeSegue", sender: self)
            
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
