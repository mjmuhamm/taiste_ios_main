//
//  MeViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 2/23/22.
//

import UIKit
import Firebase
import FirebaseFirestore
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_Theming
import MaterialComponents.MaterialTextControls_FilledTextAreasTheming
import MaterialComponents.MaterialTextControls_FilledTextFieldsTheming
import MaterialComponents.MaterialTextControls_OutlinedTextAreasTheming
import MaterialComponents.MaterialTextControls_OutlinedTextFieldsTheming

class MeViewController: UIViewController {
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var preferences: UILabel!
    @IBOutlet weak var location: UILabel!
    
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var orderButton: MDCButton!
    @IBOutlet weak var chefsButton: MDCButton!
    @IBOutlet weak var likesButton: MDCButton!
    @IBOutlet weak var reviewsButton: MDCButton!
    
    @IBOutlet weak var meTableView: UITableView!
    
    private var userOrders: [UserOrders] = []
    private var userChefs: [UserChefs] = []
    private var userLikes: [UserLikes] = []
    private var userReviews: [UserReviews] = []
    
    
    private var orders: [UserOrders] = []
    private var chefs: [UserChefs] = []
    private var likes: [UserLikes] = []
    private var reviews: [UserReviews] = []

    
    private var toggle = "Orders"
    private var ordersOrLikes = "orders"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userImage.layer.borderWidth = 1
        userImage.layer.masksToBounds = false
        userImage.layer.borderColor = UIColor.white.cgColor
        userImage.layer.cornerRadius = userImage.frame.height/2
        userImage.clipsToBounds = true
        
       
        meTableView.delegate = self
        meTableView.dataSource = self
        
        
        meTableView.register(UINib(nibName: "PersonalChefTableViewCell", bundle: nil), forCellReuseIdentifier: "PersonalChefReusableCell")
        meTableView.register(UINib(nibName: "UserOrdersAndLikesTableViewCell", bundle: nil), forCellReuseIdentifier: "UserOrdersAndLikesReusableCell")
        meTableView.register(UINib(nibName: "UserReviewsTableViewCell", bundle: nil), forCellReuseIdentifier: "UserReviewsReusableCell")
        meTableView.register(UINib(nibName: "UserOrdersAndLikesTableViewCell", bundle: nil), forCellReuseIdentifier: "UserOrdersAndLikesReusableCell")
        meTableView.register(UINib(nibName: "UserChefsTableViewCell", bundle: nil), forCellReuseIdentifier: "UserChefsReusableCell")
        
        loadPersonalInfo()
        loadOrders()
       
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.tintColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
        self.tabBarController?.tabBar.barTintColor = UIColor.white
    }
    
    
    private func loadPersonalInfo() {
        let storageRef = storage.reference()
        let image : UIImage?
        db.collection("User").document(Auth.auth().currentUser!.uid).collection("PersonalInfo").addSnapshotListener { documents, error in
            if error == nil {
                if documents != nil {
                        for doc in documents!.documents {
                            let data = doc.data()
                            
                        if let fullName = data["fullName"] as? String, let email = data["email"] as? String, let city = data["city"] as? String, let state = data["state"] as? String, let userName = data["userName"] as? String, let burger = data["burger"] as? Int, let creative = data["creative"] as? Int, let healthy = data["healthy"] as? Int, let lowCal = data["lowCal"] as? Int, let lowCarb = data["lowCarb"] as? Int, let pasta = data["pasta"] as? Int, let seafood = data["seafood"] as? Int, let workout = data["workout"] as? Int, let local = data["local"] as? Int, let region = data["region"] as? Int, let nation = data["nation"] as? Int, let vegan = data["vegan"] as? Int {
                            
                            storageRef.child("users/\(Auth.auth().currentUser!.email!)/profileImage/\(Auth.auth().currentUser!.uid).png").downloadURL { itemUrl, error in
                                
                                URLSession.shared.dataTask(with: itemUrl!) { (data, response, error) in
                                    // Error handling...
                                    guard let imageData = data else { return }
                                    
                                    print("happening itemdata")
                                    DispatchQueue.main.async {
                                        self.userImage.image = UIImage(data: imageData)!
                                    }
                                }.resume()
                            }
                            
                            self.preferences.text = "Preferences:"
                            
                            if (burger == 1) {
                                self.preferences.text = "\(self.preferences.text!)  Burger"
                            }
                            if (creative == 1) {
                                self.preferences.text = "\(self.preferences.text!)  Creative"
                            }
                            if (healthy == 1) {
                                self.preferences.text = "\(self.preferences.text!)  Healthy"
                            }
                            if (lowCal == 1) {
                                self.preferences.text = "\(self.preferences.text!)  Low Calorie"
                            }
                            if (lowCarb == 1) {
                                self.preferences.text = "\(self.preferences.text!)  Low Carb"
                            }
                            if (pasta == 1) {
                                self.preferences.text = "\(self.preferences.text!)  Pasta"
                            }
                            if (seafood == 1) {
                                self.preferences.text = "\(self.preferences.text!)  Seafood"
                            }
                            if (vegan == 1) {
                                self.preferences.text = "\(self.preferences.text!)  Vegan"
                            }
                            if (workout == 1) {
                                self.preferences.text = "\(self.preferences.text!)  Workout"
                            }
                        
                        self.userName.text = "@\(userName)"
                            if local == 1 {
                                self.location.text = "Location: \(city), \(state)"
                            } else if region == 1 {
                                self.location.text = "Location: \(state)"
                            } else {
                                self.location.text = "Location: Nationwide"
                            }
                        }
                        }
                    
                }
            }
        }
    }
    private func loadOrders() {
        let storageRef = storage.reference()
        var chefImage = UIImage()
        var itemImage = UIImage()
        
        userOrders.removeAll()
        userChefs.removeAll()
        userLikes.removeAll()
        userReviews.removeAll()
        meTableView.reloadData()
       
        
        if self.orders.isEmpty {
            db.collection("User").document(Auth.auth().currentUser!.uid).collection("Orders").getDocuments { documents, error in
            if documents != nil {
                for doc in documents!.documents {
                    let data = doc.data()
                    let typeOfService = data["typeOfService"] as! String
                    var a = ""
                    if typeOfService == "Executive Item" {
                        a = "Executive Items"
                     } else {   
                        a = typeOfService
                    }
                    
                    if let chefEmail = data["chefEmail"] as? String, let chefImageId = data["chefImageId"] as? String, let city = data["city"] as? String, let eventDates = data["eventDates"] as? [String], let itemTitle = data["itemTitle"] as? String, let itemDescription = data["itemDescription"] as? String, let menuItemId = data["menuItemId"] as? String, let orderDate = data["orderDate"] as? String, let orderUpdate = data["orderUpdate"] as? String, let totalCostOfEvent = data["totalCostOfEvent"] as? Double, let travelFee = data["travelFee"] as? String, let typeOfService = data["typeOfService"] as? String, let unitPrice = data["unitPrice"] as? String, let imageCount = data["imageCount"] as? Int, let itemCalories = data["itemCalories"] as? String, let state = data["state"] as? String, let signatureDishId = data["signatureDishId"] as? String {
                        
                       
                        let index = self.userOrders.firstIndex(where: { $0.menuItemId == menuItemId })
                        if index == nil {
                            
                            
                            self.db.collection(a).document(menuItemId).getDocument { document, error in
                                if error == nil {
                                    if document != nil {
                                        let data1 = document!.data()
                                        
                                        if let liked = data1!["liked"] as? [String], let itemOrders = data1!["itemOrders"] as? Int, let itemRating = data1!["itemRating"] as? [Double], let chefUsername = data["chefUsername"] as? String {
                                            
                                            
                                            
                                            let newItem = UserOrders(chefName: chefUsername, chefEmail: chefEmail, chefImageId: chefImageId, chefImage: UIImage(), city: city, state: state, zipCode: "", eventDates: eventDates, itemTitle: itemTitle, itemDescription: itemDescription, itemPrice: unitPrice, menuItemId: menuItemId, itemImage: UIImage(), orderDate: orderDate, orderUpdate: orderUpdate, totalCostOfEvent: totalCostOfEvent, travelFee: travelFee, typeOfService: typeOfService, imageCount: imageCount, liked: liked, itemOrders: itemOrders, itemRating: itemRating, itemCalories: Int(itemCalories)!, documentId: doc.documentID, expectations: 0, chefRating: 0, quality: 0, signatureDishId: signatureDishId)
                                            
                                            if self.userOrders.isEmpty {
                                                self.userOrders.append(newItem)
                                                self.orders = self.userOrders
                                                self.meTableView.insertRows(at: [IndexPath(item: 0, section: 0)], with: .fade)
                                            } else {
                                                let index = self.userOrders.firstIndex { $0.documentId == doc.documentID
                                                }
                                                if index == nil {
                                                    self.userOrders.append(newItem)
                                                    self.orders = self.userOrders
                                                    self.meTableView.insertRows(at: [IndexPath(item: self.orders.count - 1, section: 0)], with: .fade)
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
        }
        } else {
            self.userOrders = self.orders
            self.meTableView.reloadData()
            meTableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        }
    }
    
    private func loadChefs() {
        let storageRef = storage.reference()
        userOrders.removeAll()
        userChefs.removeAll()
        userLikes.removeAll()
        userReviews.removeAll()
        meTableView.reloadData()
        
        
        if self.chefs.isEmpty {
            db.collection("User").document(Auth.auth().currentUser!.uid).collection("UserLikes").getDocuments { documents, error in
            
            if error == nil {
                for doc in documents!.documents {
                    let data = doc.data()
                    
                    if let chefEmail = data["chefEmail"] as? String, let chefImageId = data["profileImageId"] as? String, let chefName = data["chefUsername"] as? String, let chefPassion = data["chefPassion"] as? String, let liked = data["liked"] as? [String], let itemOrders = data["itemOrders"] as? Int, let itemRating = data["itemRating"] as? [Double] {
                        
                        
                        if let index = self.chefs.firstIndex(where: { $0.chefEmail == chefEmail }) {
                            for i in 0..<liked.count {
                                self.chefs[index].chefLiked.append(liked[i])
                            }
                            self.chefs[index].chefOrders += itemOrders
                            for i in 0..<itemRating.count {
                                self.chefs[index].chefRating.append(itemRating[i])
                            }
                            self.chefs[index].timesLiked += 1
                            self.meTableView.reloadData()
                        } else {
                            let newItem = UserChefs(chefEmail: chefEmail, chefImageId: chefImageId, chefImage: UIImage(), chefName: chefName, chefPassion: chefPassion, timesLiked: 0, chefLiked: liked, chefOrders: itemOrders, chefRating: itemRating)
                        
                        if self.userChefs.isEmpty {
                            self.userChefs.append(newItem)
                            self.chefs = self.userChefs
                            self.meTableView.insertRows(at: [IndexPath(item: 0, section: 0)], with: .fade)
                        } else {
                            let index = self.userChefs.firstIndex { $0.chefEmail == chefEmail }
                            if index == nil {
                                self.userChefs.append(newItem)
                                self.chefs = self.userChefs
                                self.meTableView.insertRows(at: [IndexPath(item: self.chefs.count - 1, section: 0)], with: .fade)
                            } else {
                                self.userChefs[index!].timesLiked = self.userChefs[index!].timesLiked + 1
                            }
                        }
                        }
                    }
                }
            }
        }
        } else {
            self.userChefs = self.chefs
            self.meTableView.reloadData()
            meTableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        }
    }
    
    private func loadLikes() {
        let storageRef = storage.reference()
//        var chefImage = UIImage()
//        var itemImage = UIImage()
        
        userOrders.removeAll()
        userChefs.removeAll()
        userLikes.removeAll()
        userReviews.removeAll()
        meTableView.reloadData()
        if self.likes.isEmpty {
            db.collection("User").document(Auth.auth().currentUser!.uid).collection("UserLikes").getDocuments { documents, error in
            if error == nil {
                if documents != nil {
                for doc in documents!.documents {
                    let data = doc.data()
                    
                    if let chefEmail = data["chefEmail"] as? String, let chefUsername = data["chefUsername"] as? String, let chefImageId = data["profileImageId"] as? String, let imageCount = data["imageCount"] as? Int, let itemDescription = data["itemDescription"] as? String, let itemPrice = data["itemPrice"] as? String, let itemTitle = data["itemTitle"] as? String, let itemType = data["itemType"] as? String, let city = data["city"] as? String, let state = data["state"] as? String, let expectations = data["expectations"] as? Int, let chefRating = data["chefRating"] as? Int, let quality = data["quality"] as? Int, let signatureDishId = data["signatureDishId"] as? String  {
                        print("likes happening")
                        
                            
                        
                        self.db.collection(itemType).document(doc.documentID).getDocument { document, error in
                            if error == nil {
                                if document!.exists {
                                    let data1 = document?.data()
                                    
                                    if let liked = data1!["liked"] as? [String], let itemOrders = data1!["itemOrders"] as? Int, let itemRating = data1!["itemRating"] as? [Double] {
                                    
                                        let newItem = UserLikes(chefName: chefUsername, chefEmail: chefEmail, chefImageId: chefImageId, chefImage: UIImage(), itemType: itemType, city: city, state: state, zipCode: "", itemTitle: itemTitle, itemDescription: itemDescription, itemPrice: itemPrice, itemImage: UIImage(), imageCount: imageCount, liked: liked, itemOrders: itemOrders, itemRating: itemRating, itemCalories: 0, documentId: doc.documentID, expectations: expectations, chefRating: chefRating, quality: quality, signatureDishId: signatureDishId)
                                    
                                    if self.userLikes.isEmpty {
                                        self.userLikes.append(newItem)
                                        self.likes = self.userLikes
                                        self.meTableView.insertRows(at: [IndexPath(item: 0, section: 0)], with: .fade)
                                    } else {
                                        let index = self.userLikes.firstIndex { $0.documentId == doc.documentID }
                                        if index == nil {
                                            self.userLikes.append(newItem)
                                            self.likes = self.userLikes
                                            self.meTableView.insertRows(at: [IndexPath(item: self.likes.count - 1, section: 0)], with: .fade)
                                        }
                                    }
                                    
                                
                                }
                        }
                            }}
                    }
                 }
                }
            }
        }
        } else {
            self.userLikes = self.likes
            self.meTableView.reloadData()
            meTableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        }
    }
    
    private func loadReviews() {
        let storageRef = storage.reference()
        
        userOrders.removeAll()
        userChefs.removeAll()
        userLikes.removeAll()
        userReviews.removeAll()
        meTableView.reloadData()
        
        if self.reviews.isEmpty {
            db.collection("User").document(Auth.auth().currentUser!.uid).collection("UserReviews").getDocuments { documents, error in
            if error == nil {
                if documents != nil {
                    for doc in documents!.documents {
                        let data = doc.data()
                        
                        
                        if let chefEmail = data["chefEmail"] as? String, let chefImageId = data["chefImageId"] as? String, let chefUsername = data["chefUsername"] as? String, let date = data["date"] as? String, let itemTitle = data["itemTitle"] as? String, let itemType = data["itemType"] as? String, let userChefRating = data["chefRating"] as? Int, let userExpectationsRating = data["expectations"] as? Int, let qualityRating = data["quality"] as? Int, let userRecommendation = data["recommend"] as? Int, let userReviewTextField = data["thoughts"] as? String, let liked = data["liked"] as? [String] {
                            
                               
                            print("reviews happening")
                            let newItem = UserReviews(chefEmail: chefEmail, chefImageId: chefImageId, chefImage: UIImage(), chefName: chefUsername, date: date, documentID: doc.documentID, itemTitle: itemTitle, itemType: itemType, liked: liked, user: Auth.auth().currentUser!.uid, userChefRating: userChefRating, userExpectationsRating: userExpectationsRating, userImageId: userImageId, userQualityRating: qualityRating, userRecommendation: userRecommendation, userReviewTextField: userReviewTextField)
                            
                            if self.userReviews.isEmpty {
                                self.userReviews.append(newItem)
                                self.reviews = self.userReviews
                                self.meTableView.insertRows(at: [IndexPath(item: 0, section: 0)], with: .fade)
                            } else {
                                let index = self.userReviews.firstIndex(where: { $0.documentID == doc.documentID })
                                if index == nil {
                                    self.userReviews.append(newItem)
                                    self.reviews = self.userReviews
                                    self.meTableView.insertRows(at: [IndexPath(item: self.reviews.count - 1, section: 0)], with: .fade)
                                }
                            
                        }
                        }
                    }
                }
            }
        }
        } else {
            self.userReviews = self.reviews
            self.meTableView.reloadData()
            meTableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        }
    }
    
    
    @IBAction func orderButtonPressed(_ sender: Any) {
        toggle = "Orders"
        ordersOrLikes = "orders"
        loadOrders()
        orderButton.setTitleColor(UIColor.white, for: .normal)
        orderButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
        chefsButton.backgroundColor = UIColor.white
        chefsButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        likesButton.backgroundColor = UIColor.white
        likesButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        reviewsButton.backgroundColor = UIColor.white
        reviewsButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
    }
    
    @IBAction func chefsButtonPressed(_ sender: Any) {
        toggle = "Chefs"
        loadChefs()
        orderButton.backgroundColor = UIColor.white
        orderButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        chefsButton.setTitleColor(UIColor.white, for: .normal)
        chefsButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
        likesButton.backgroundColor = UIColor.white
        likesButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        reviewsButton.backgroundColor = UIColor.white
        reviewsButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
    }
    
    @IBAction func likesButtonPressed(_ sender: Any) {
        toggle = "Likes"
        ordersOrLikes = "likes"
        loadLikes()
        orderButton.backgroundColor = UIColor.white
        orderButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        chefsButton.backgroundColor = UIColor.white
        chefsButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        likesButton.setTitleColor(UIColor.white, for: .normal)
        likesButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
        reviewsButton.backgroundColor = UIColor.white
        reviewsButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
    }
    
    @IBAction func reviewsButtonPressed(_ sender: Any) {
        toggle = "Reviews"
        loadReviews()
        orderButton.backgroundColor = UIColor.white
        orderButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        chefsButton.backgroundColor = UIColor.white
        chefsButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        likesButton.backgroundColor = UIColor.white
        likesButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        reviewsButton.setTitleColor(UIColor.white, for: .normal)
        reviewsButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
    }
    
    
    @IBAction func notificationButtonPressed(_ sender: Any) {
    }
    
    
    @IBAction func settingsButtonPressed(_ sender: Any) {
    }
    
}

extension MeViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if toggle == "Orders" {
            return userOrders.count
        } else if toggle == "Chefs" {
            return userChefs.count
        } else if toggle == "Likes" {
            return userLikes.count
        } else {
            return userReviews.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        
        if toggle == "Orders" {
            print("orders type of service \(userOrders[indexPath.row].typeOfService)")
            if userOrders[indexPath.row].typeOfService == "Cater Items" {
                var cell = meTableView.dequeueReusableCell(withIdentifier: "UserOrdersAndLikesReusableCell", for: indexPath) as! UserOrdersAndLikesTableViewCell
                
                var order = userOrders[indexPath.row]
                
                cell.itemTitle.text = order.itemTitle
                cell.itemDescription.text = order.itemDescription
                cell.likeText.text = "\(order.liked.count)"
                cell.orderText.text = "\(order.itemOrders)"
                cell.itemPrice.text = "$\(order.itemPrice)"
                var num = 0.0
                for i in 0..<order.itemRating.count {
                    num += order.itemRating[i]
                    if i == order.itemRating.count - 1 {
                        num = num / Double(order.itemRating.count)
                    }
                }
                cell.ratingText.text = "\(num)"
                cell.userImage.image = order.chefImage
                cell.itemImage.image = order.itemImage
                let storageRef = storage.reference()
                let itemRef = storage.reference()
                
                storageRef.child("chefs/\(order.chefEmail)/profileImage/\(order.chefImageId).png").downloadURL { itemUrl, error in
                    
                    URLSession.shared.dataTask(with: itemUrl!) { (data, response, error) in
                        // Error handling...
                        guard let imageData = data else { return }
                        
                        print("happening itemdata")
                        DispatchQueue.main.async {
                            cell.userImage.image = UIImage(data: imageData)!
                        }
                    }.resume()
                }
                
                itemRef.child("chefs/\(order.chefEmail)/\(order.typeOfService)/\(order.menuItemId)0.png").downloadURL { itemUrl, error in
                    
                    URLSession.shared.dataTask(with: itemUrl!) { (data, response, error) in
                        // Error handling...
                        guard let imageData = data else { return }
                        
                        print("happening itemdata")
                        DispatchQueue.main.async {
                            cell.itemImage.image = UIImage(data: imageData)!
                            order.itemImage = UIImage(data: imageData)!
                        }
                    }.resume()
                }
                
                cell.chefImageButtonTapped = {
                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileAsUser") as? ProfileAsUserViewController  {
                        vc.user = order.chefImageId
                        vc.chefOrUser = "chef"
                        self.present(vc, animated: true, completion: nil)
                    }
                }
                
                cell.itemImageButtonTapped = {
                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ItemDetail") as? ItemDetailViewController  {
                        vc.chefEmail = order.chefEmail
                        vc.imageCount = order.imageCount
                        vc.menuItemId = order.documentId
                        vc.itemType = order.typeOfService
                        vc.itemTitleI = order.itemTitle
                        vc.itemDescriptionI = order.itemDescription
                        vc.itemImage = order.itemImage
                        vc.caterOrPersonal = "cater"
                        self.present(vc, animated: true, completion: nil)
                        
                    }}
                
                
                
                
                return cell
            } else {
                var cell = meTableView.dequeueReusableCell(withIdentifier: "PersonalChefReusableCell", for: indexPath) as! PersonalChefTableViewCell
                
                var order = userOrders[indexPath.row]
                
                cell.chefName.text = order.chefName
                cell.briefIntro.text = order.itemDescription
                if order.expectations > 4 {
                    cell.expectations1.image = UIImage(systemName: "star.fill")
                    cell.expectations2.image = UIImage(systemName: "star.fill")
                    cell.expectations3.image = UIImage(systemName: "star.fill")
                    cell.expectations4.image = UIImage(systemName: "star.fill")
                    cell.expectations5.image = UIImage(systemName: "star.fill")
                } else if order.expectations > 3 {
                    cell.expectations1.image = UIImage(systemName: "star.fill")
                    cell.expectations2.image = UIImage(systemName: "star.fill")
                    cell.expectations3.image = UIImage(systemName: "star.fill")
                    cell.expectations4.image = UIImage(systemName: "star.fill")
                    cell.expectations5.image = UIImage(systemName: "star")
                } else if order.expectations > 2 && order.expectations < 4 {
                    cell.expectations1.image = UIImage(systemName: "star.fill")
                    cell.expectations2.image = UIImage(systemName: "star.fill")
                    cell.expectations3.image = UIImage(systemName: "star.fill")
                    cell.expectations4.image = UIImage(systemName: "star")
                    cell.expectations5.image = UIImage(systemName: "star")
                } else if order.expectations > 1 && order.expectations < 3 {
                    cell.expectations1.image = UIImage(systemName: "star.fill")
                    cell.expectations2.image = UIImage(systemName: "star.fill")
                    cell.expectations3.image = UIImage(systemName: "star")
                    cell.expectations4.image = UIImage(systemName: "star")
                    cell.expectations5.image = UIImage(systemName: "star")
                } else if order.expectations > 0 {
                    cell.expectations1.image = UIImage(systemName: "star.fill")
                    cell.expectations2.image = UIImage(systemName: "star")
                    cell.expectations3.image = UIImage(systemName: "star")
                    cell.expectations4.image = UIImage(systemName: "star")
                    cell.expectations5.image = UIImage(systemName: "star")
                } else {
                    cell.expectations1.image = UIImage(systemName: "star")
                    cell.expectations2.image = UIImage(systemName: "star")
                    cell.expectations3.image = UIImage(systemName: "star")
                    cell.expectations4.image = UIImage(systemName: "star")
                    cell.expectations5.image = UIImage(systemName: "star")
                }
                
                if order.chefRating > 4 {
                    cell.chefRating1.image = UIImage(systemName: "star.fill")
                    cell.chefRating2.image = UIImage(systemName: "star.fill")
                    cell.chefRating3.image = UIImage(systemName: "star.fill")
                    cell.chefRating4.image = UIImage(systemName: "star.fill")
                    cell.chefRating5.image = UIImage(systemName: "star.fill")
                } else if order.chefRating > 3 {
                    cell.chefRating1.image = UIImage(systemName: "star.fill")
                    cell.chefRating2.image = UIImage(systemName: "star.fill")
                    cell.chefRating3.image = UIImage(systemName: "star.fill")
                    cell.chefRating4.image = UIImage(systemName: "star.fill")
                    cell.chefRating5.image = UIImage(systemName: "star")
                } else if order.chefRating > 2 && order.chefRating < 4 {
                    cell.chefRating1.image = UIImage(systemName: "star.fill")
                    cell.chefRating2.image = UIImage(systemName: "star.fill")
                    cell.chefRating3.image = UIImage(systemName: "star.fill")
                    cell.chefRating4.image = UIImage(systemName: "star")
                    cell.chefRating5.image = UIImage(systemName: "star")
                } else if order.chefRating > 1 && order.chefRating < 3 {
                    cell.chefRating1.image = UIImage(systemName: "star.fill")
                    cell.chefRating2.image = UIImage(systemName: "star.fill")
                    cell.chefRating3.image = UIImage(systemName: "star")
                    cell.chefRating4.image = UIImage(systemName: "star")
                    cell.chefRating5.image = UIImage(systemName: "star")
                } else if order.chefRating > 0 {
                    cell.chefRating1.image = UIImage(systemName: "star.fill")
                    cell.chefRating2.image = UIImage(systemName: "star")
                    cell.chefRating3.image = UIImage(systemName: "star")
                    cell.chefRating4.image = UIImage(systemName: "star")
                    cell.chefRating5.image = UIImage(systemName: "star")
                } else {
                    cell.chefRating1.image = UIImage(systemName: "star")
                    cell.chefRating2.image = UIImage(systemName: "star")
                    cell.chefRating3.image = UIImage(systemName: "star")
                    cell.chefRating4.image = UIImage(systemName: "star")
                    cell.chefRating5.image = UIImage(systemName: "star")
                }
                
                if order.quality > 4 {
                    cell.quality1.image = UIImage(systemName: "star.fill")
                    cell.quality2.image = UIImage(systemName: "star.fill")
                    cell.quality3.image = UIImage(systemName: "star.fill")
                    cell.quality4.image = UIImage(systemName: "star.fill")
                    cell.quality5.image = UIImage(systemName: "star.fill")
                } else if order.quality > 3 {
                    cell.quality1.image = UIImage(systemName: "star.fill")
                    cell.quality2.image = UIImage(systemName: "star.fill")
                    cell.quality3.image = UIImage(systemName: "star.fill")
                    cell.quality4.image = UIImage(systemName: "star.fill")
                    cell.quality5.image = UIImage(systemName: "star")
                } else if order.quality > 2 && order.quality < 4 {
                    cell.quality1.image = UIImage(systemName: "star.fill")
                    cell.quality2.image = UIImage(systemName: "star.fill")
                    cell.quality3.image = UIImage(systemName: "star.fill")
                    cell.quality4.image = UIImage(systemName: "star")
                    cell.quality5.image = UIImage(systemName: "star")
                } else if order.quality > 1 && order.quality < 3 {
                    cell.quality1.image = UIImage(systemName: "star.fill")
                    cell.quality2.image = UIImage(systemName: "star.fill")
                    cell.quality3.image = UIImage(systemName: "star")
                    cell.quality4.image = UIImage(systemName: "star")
                    cell.quality5.image = UIImage(systemName: "star")
                } else if order.quality > 0 {
                    cell.quality1.image = UIImage(systemName: "star.fill")
                    cell.quality2.image = UIImage(systemName: "star")
                    cell.quality3.image = UIImage(systemName: "star")
                    cell.quality4.image = UIImage(systemName: "star")
                    cell.quality5.image = UIImage(systemName: "star")
                } else {
                    cell.quality1.image = UIImage(systemName: "star")
                    cell.quality2.image = UIImage(systemName: "star")
                    cell.quality3.image = UIImage(systemName: "star")
                    cell.quality4.image = UIImage(systemName: "star")
                    cell.quality5.image = UIImage(systemName: "star")
                }
                
                cell.chefLikes.text = "\(order.liked.count)"
                cell.chefOrders.text = "\(order.itemOrders)"
                cell.servicePrice.text = "$\(order.itemPrice)"
                var num = 0.0
                for i in 0..<order.itemRating.count {
                    num += order.itemRating[i]
                    if i == order.itemRating.count - 1 {
                        num = num / Double(order.itemRating.count)
                    }
                }
                cell.chefRating.text = "\(num)"
                let storageRef = storage.reference()
                let itemRef = storage.reference()
                
                storageRef.child("chefs/\(order.chefEmail)/profileImage/\(order.signatureDishId).png").downloadURL { itemUrl, error in
                    
                    URLSession.shared.dataTask(with: itemUrl!) { (data, response, error) in
                        // Error handling...
                        guard let imageData = data else { return }
                        
                        print("happening itemdata")
                        DispatchQueue.main.async {
                            cell.chefImage.image = UIImage(data: imageData)!
                        }
                    }.resume()
                }
                
              
                itemRef.child("chefs/\(order.chefEmail)/Executive Items/\(order)0.png").downloadURL { itemUrl, error in
                    
                    URLSession.shared.dataTask(with: itemUrl!) { (data, response, error) in
                        // Error handling...
                        guard let imageData = data else { return }
                        
                        print("happening itemdata")
                        DispatchQueue.main.async {
                            cell.signatureImage.image = UIImage(data: imageData)!
                            order.itemImage = UIImage(data: imageData)!
                        }
                    }.resume()
                }
                
                cell.chefImageButtonTapped = {
                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileAsUser") as? ProfileAsUserViewController  {
                        vc.user = order.chefImageId
                        vc.chefOrUser = "chef"
                        self.present(vc, animated: true, completion: nil)
                    }
                }
                
                cell.detailButtonTapped = {
                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ItemDetail") as? ItemDetailViewController  {
                        vc.caterOrPersonal = "personal"
                        vc.personalChefInfo = PersonalChefInfo(chefName: order.chefName, chefEmail: order.chefEmail, chefImageId: order.chefImageId, chefImage: order.chefImage!, city: order.city, state: order.state, zipCode: order.zipCode, signatureDishImage: order.itemImage!, signatureDishId: "", option1Title: "", option2Title: "", option3Title: "", option4Title: "", briefIntroduction: "", howLongBeenAChef: "", specialty: "", whatHelpesYouExcel: "", mostPrizedAccomplishment: "", availabilty: "", hourlyOrPerSession: "", servicePrice: "", trialRun: 0, weeks: 0, months: 0, liked: [], itemOrders: 0, itemRating: [0.0], expectations: 0, chefRating: 0, quality: 0, documentId: "", openToMenuRequests: "")
                        self.present(vc, animated: true, completion: nil)
                        
                    }}
                
                
                
                
                return cell
            }
            
        } else if toggle == "Chefs" {
            
        var cell = meTableView.dequeueReusableCell(withIdentifier: "UserChefsReusableCell", for: indexPath) as! UserChefsTableViewCell
            
            let item = userChefs[indexPath.row]
            
            cell.chefPassion.text = item.chefPassion
            cell.likeText.text = "\(item.chefLiked.count)"
            cell.orderText.text = "\(item.chefOrders)"
            var num = 0.0
            for i in 0..<item.chefRating.count {
                num += item.chefRating[i]
                if i == item.chefRating.count - 1 {
                    num = num / Double(item.chefRating.count)
                }
            }
            cell.ratingText.text = "\(num)"
            cell.chefImage.image = item.chefImage
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
            
            cell.chefImage.layer.borderWidth = 1
            cell.chefImage.layer.masksToBounds = false
            cell.chefImage.layer.borderColor = UIColor.white.cgColor
            cell.chefImage.layer.cornerRadius = cell.chefImage.frame.height/2
            cell.chefImage.clipsToBounds = true
            
            
            cell.chefImageButtonTapped = {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileAsUser") as? ProfileAsUserViewController  {
                    vc.user = item.chefImageId
                    vc.chefOrUser = "chef"
                    self.present(vc, animated: true, completion: nil)
                }
            }
            
            
        return cell
            
        } else if toggle == "Likes" {
            if userLikes[indexPath.row].itemType == "Cater Items" {
                var cell = meTableView.dequeueReusableCell(withIdentifier: "UserOrdersAndLikesReusableCell", for: indexPath) as! UserOrdersAndLikesTableViewCell
                
                
                var item = userLikes[indexPath.row]
                
                cell.itemTitle.text = item.itemTitle
                cell.itemDescription.text = item.itemDescription
                cell.itemPrice.text = "$\(item.itemPrice)"
                cell.likeText.text = "\(item.liked.count)"
                cell.orderText.text = "\(item.itemOrders)"
                var num = 0.0
                for i in 0..<item.itemRating.count {
                    num += item.itemRating[i]
                    if i == item.itemRating.count - 1 {
                        num = num / Double(item.itemRating.count)
                    }
                }
                cell.ratingText.text = "\(num)"
                cell.likeImage.image = UIImage(systemName: "heart.fill")
                let storageRef = storage.reference()
                let itemRef = storage.reference()
                
                storageRef.child("chefs/\(item.chefEmail)/profileImage/\(item.chefImageId).png").downloadURL { itemUrl, error in
                    
                    URLSession.shared.dataTask(with: itemUrl!) { (data, response, error) in
                        // Error handling...
                        guard let imageData = data else { return }
                        
                        print("happening itemdata")
                        DispatchQueue.main.async {
                            cell.userImage.image = UIImage(data: imageData)!
                        }
                    }.resume()
                }
                itemRef.child("chefs/\(item.chefEmail)/Executive Items/\(item.signatureDishId)0.png").downloadURL { itemUrl, error in
                    
                    URLSession.shared.dataTask(with: itemUrl!) { (data, response, error) in
                        // Error handling...
                        guard let imageData = data else { return }
                        
                        print("happening itemdata")
                        DispatchQueue.main.async {
                            cell.itemImage.image = UIImage(data: imageData)!
                            item.itemImage = UIImage(data: imageData)!
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
                
                cell.itemImageButtonTapped = {
                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ItemDetail") as? ItemDetailViewController  {
                        vc.chefEmail = item.chefEmail
                        vc.imageCount = item.imageCount
                        vc.menuItemId = item.documentId
                        vc.itemType = item.itemType
                        vc.itemTitleI = item.itemTitle
                        vc.itemDescriptionI = item.itemDescription
                        vc.itemImage = item.itemImage
                        vc.caterOrPersonal = "cater"
                        self.present(vc, animated: true, completion: nil)
                    }
                }
                
                cell.likeImageButtonTapped = {
                    if let index = self.userLikes.firstIndex(where: { $0.documentId == item.documentId }) {
                        self.userLikes.remove(at: index)
                        self.meTableView.deleteRows(at: [IndexPath(item:index, section: 0)], with: .fade)
                        self.db.collection("User").document(Auth.auth().currentUser!.uid).collection("UserLikes").document(item.documentId).delete()
                    }
                }
                
                
                return cell
            } else {
                var cell = meTableView.dequeueReusableCell(withIdentifier: "PersonalChefReusableCell", for: indexPath) as! PersonalChefTableViewCell
                
                var item = userLikes[indexPath.row]
                
                cell.chefName.text = item.chefName
                cell.briefIntro.text = item.itemDescription
                if item.expectations > 4 {
                    cell.expectations1.image = UIImage(systemName: "star.fill")
                    cell.expectations2.image = UIImage(systemName: "star.fill")
                    cell.expectations3.image = UIImage(systemName: "star.fill")
                    cell.expectations4.image = UIImage(systemName: "star.fill")
                    cell.expectations5.image = UIImage(systemName: "star.fill")
                } else if item.expectations > 3 {
                    cell.expectations1.image = UIImage(systemName: "star.fill")
                    cell.expectations2.image = UIImage(systemName: "star.fill")
                    cell.expectations3.image = UIImage(systemName: "star.fill")
                    cell.expectations4.image = UIImage(systemName: "star.fill")
                    cell.expectations5.image = UIImage(systemName: "star")
                } else if item.expectations > 2 && item.expectations < 4 {
                    cell.expectations1.image = UIImage(systemName: "star.fill")
                    cell.expectations2.image = UIImage(systemName: "star.fill")
                    cell.expectations3.image = UIImage(systemName: "star.fill")
                    cell.expectations4.image = UIImage(systemName: "star")
                    cell.expectations5.image = UIImage(systemName: "star")
                } else if item.expectations > 1 && item.expectations < 3 {
                    cell.expectations1.image = UIImage(systemName: "star.fill")
                    cell.expectations2.image = UIImage(systemName: "star.fill")
                    cell.expectations3.image = UIImage(systemName: "star")
                    cell.expectations4.image = UIImage(systemName: "star")
                    cell.expectations5.image = UIImage(systemName: "star")
                } else if item.expectations > 0 {
                    cell.expectations1.image = UIImage(systemName: "star.fill")
                    cell.expectations2.image = UIImage(systemName: "star")
                    cell.expectations3.image = UIImage(systemName: "star")
                    cell.expectations4.image = UIImage(systemName: "star")
                    cell.expectations5.image = UIImage(systemName: "star")
                } else {
                    cell.expectations1.image = UIImage(systemName: "star")
                    cell.expectations2.image = UIImage(systemName: "star")
                    cell.expectations3.image = UIImage(systemName: "star")
                    cell.expectations4.image = UIImage(systemName: "star")
                    cell.expectations5.image = UIImage(systemName: "star")
                }
                
                if item.chefRating > 4 {
                    cell.chefRating1.image = UIImage(systemName: "star.fill")
                    cell.chefRating2.image = UIImage(systemName: "star.fill")
                    cell.chefRating3.image = UIImage(systemName: "star.fill")
                    cell.chefRating4.image = UIImage(systemName: "star.fill")
                    cell.chefRating5.image = UIImage(systemName: "star.fill")
                } else if item.chefRating > 3 {
                    cell.chefRating1.image = UIImage(systemName: "star.fill")
                    cell.chefRating2.image = UIImage(systemName: "star.fill")
                    cell.chefRating3.image = UIImage(systemName: "star.fill")
                    cell.chefRating4.image = UIImage(systemName: "star.fill")
                    cell.chefRating5.image = UIImage(systemName: "star")
                } else if item.chefRating > 2 && item.chefRating < 4 {
                    cell.chefRating1.image = UIImage(systemName: "star.fill")
                    cell.chefRating2.image = UIImage(systemName: "star.fill")
                    cell.chefRating3.image = UIImage(systemName: "star.fill")
                    cell.chefRating4.image = UIImage(systemName: "star")
                    cell.chefRating5.image = UIImage(systemName: "star")
                } else if item.chefRating > 1 && item.chefRating < 3 {
                    cell.chefRating1.image = UIImage(systemName: "star.fill")
                    cell.chefRating2.image = UIImage(systemName: "star.fill")
                    cell.chefRating3.image = UIImage(systemName: "star")
                    cell.chefRating4.image = UIImage(systemName: "star")
                    cell.chefRating5.image = UIImage(systemName: "star")
                } else if item.chefRating > 0 {
                    cell.chefRating1.image = UIImage(systemName: "star.fill")
                    cell.chefRating2.image = UIImage(systemName: "star")
                    cell.chefRating3.image = UIImage(systemName: "star")
                    cell.chefRating4.image = UIImage(systemName: "star")
                    cell.chefRating5.image = UIImage(systemName: "star")
                } else {
                    cell.chefRating1.image = UIImage(systemName: "star")
                    cell.chefRating2.image = UIImage(systemName: "star")
                    cell.chefRating3.image = UIImage(systemName: "star")
                    cell.chefRating4.image = UIImage(systemName: "star")
                    cell.chefRating5.image = UIImage(systemName: "star")
                }
                
                if item.quality > 4 {
                    cell.quality1.image = UIImage(systemName: "star.fill")
                    cell.quality2.image = UIImage(systemName: "star.fill")
                    cell.quality3.image = UIImage(systemName: "star.fill")
                    cell.quality4.image = UIImage(systemName: "star.fill")
                    cell.quality5.image = UIImage(systemName: "star.fill")
                } else if item.quality > 3 {
                    cell.quality1.image = UIImage(systemName: "star.fill")
                    cell.quality2.image = UIImage(systemName: "star.fill")
                    cell.quality3.image = UIImage(systemName: "star.fill")
                    cell.quality4.image = UIImage(systemName: "star.fill")
                    cell.quality5.image = UIImage(systemName: "star")
                } else if item.quality > 2 && item.quality < 4 {
                    cell.quality1.image = UIImage(systemName: "star.fill")
                    cell.quality2.image = UIImage(systemName: "star.fill")
                    cell.quality3.image = UIImage(systemName: "star.fill")
                    cell.quality4.image = UIImage(systemName: "star")
                    cell.quality5.image = UIImage(systemName: "star")
                } else if item.quality > 1 && item.quality < 3 {
                    cell.quality1.image = UIImage(systemName: "star.fill")
                    cell.quality2.image = UIImage(systemName: "star.fill")
                    cell.quality3.image = UIImage(systemName: "star")
                    cell.quality4.image = UIImage(systemName: "star")
                    cell.quality5.image = UIImage(systemName: "star")
                } else if item.quality > 0 {
                    cell.quality1.image = UIImage(systemName: "star.fill")
                    cell.quality2.image = UIImage(systemName: "star")
                    cell.quality3.image = UIImage(systemName: "star")
                    cell.quality4.image = UIImage(systemName: "star")
                    cell.quality5.image = UIImage(systemName: "star")
                } else {
                    cell.quality1.image = UIImage(systemName: "star")
                    cell.quality2.image = UIImage(systemName: "star")
                    cell.quality3.image = UIImage(systemName: "star")
                    cell.quality4.image = UIImage(systemName: "star")
                    cell.quality5.image = UIImage(systemName: "star")
                }
                var num = 0.0
                for i in 0..<item.itemRating.count {
                    num += item.itemRating[i]
                    if i == item.itemRating.count - 1 {
                        num = num / Double(item.itemRating.count)
                    }
                }
                cell.chefLikes.text = "\(item.liked.count)"
                cell.chefOrders.text = "\(item.itemOrders)"
                cell.servicePrice.text = "$\(item.itemPrice)"
                cell.chefRating.text = "\(num)"
                cell.likeImage.image = UIImage(systemName: "heart.fill")
                let storageRef = storage.reference()
                let itemRef = storage.reference()
                
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
                itemRef.child("chefs/\(item.chefEmail)/Executive Items/\(item.documentId)0.png").downloadURL { itemUrl, error in
                    
                    URLSession.shared.dataTask(with: itemUrl!) { (data, response, error) in
                        // Error handling...
                        guard let imageData = data else { return }
                        
                        print("happening itemdata")
                        DispatchQueue.main.async {
                            cell.signatureImage.image = UIImage(data: imageData)!
                            item.itemImage = UIImage(data: imageData)!
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
                
                cell.detailButtonTapped = {
                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ItemDetail") as? ItemDetailViewController {
                        vc.caterOrPersonal = "personal"
                        vc.personalChefInfo = PersonalChefInfo(chefName: item.chefName, chefEmail: item.chefEmail, chefImageId: item.chefImageId, chefImage: item.chefImage!, city: item.city, state: item.state, zipCode: item.zipCode, signatureDishImage: item.itemImage!, signatureDishId: "", option1Title: "", option2Title: "", option3Title: "", option4Title: "", briefIntroduction: "", howLongBeenAChef: "", specialty: "", whatHelpesYouExcel: "", mostPrizedAccomplishment: "", availabilty: "", hourlyOrPerSession: "", servicePrice: "", trialRun: 0, weeks: 0, months: 0, liked: [], itemOrders: 0, itemRating: [0.0], expectations: 0, chefRating: 0, quality: 0, documentId: "", openToMenuRequests: "")
                        self.present(vc, animated: true, completion: nil)
                    }
                }
                
                cell.likeButtonTapped = {
                    if let index = self.userLikes.firstIndex(where: { $0.documentId == item.documentId }) {
                        self.userLikes.remove(at: index)
                        self.meTableView.deleteRows(at: [IndexPath(item:index, section: 0)], with: .fade)
                        self.db.collection("User").document(Auth.auth().currentUser!.uid).collection("UserLikes").document(item.documentId).delete()
                    }
                }
                
                
                return cell
            }
            
        } else {
            
        var cell = meTableView.dequeueReusableCell(withIdentifier: "UserReviewsReusableCell", for: indexPath) as! UserReviewsTableViewCell
            
            let item = userReviews[indexPath.row]

            cell.itemTitle.text = item.itemTitle
            cell.review.text = item.userReviewTextField
            if item.userRecommendation == 1 {
                cell.recommend.text = "Recommend: Yes"
            } else {
                cell.recommend.text = "Recommend: No"
            }
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
            
            cell.expectationsMetRating.text = "\(item.userExpectationsRating)"
            cell.qualityRating.text = "\(item.userQualityRating)"
            cell.chefRating.text = "\(item.userChefRating)"
            cell.likeText.text = "\(item.liked.count)"
            cell.chefImage.image = item.chefImage
            
        return cell
        }
    }
    
}
