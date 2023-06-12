//
//  ProfileAsUserViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 2/25/22.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import MaterialComponents.MaterialButtons
import MaterialComponents


class ProfileAsUserViewController: UIViewController {
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var educationText: UILabel!
    @IBOutlet weak var chefPassion: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var chefImage: UIImageView!
    
    @IBOutlet weak var chefToggleStack: UIStackView!
    @IBOutlet weak var cateringButton: MDCButton!
    @IBOutlet weak var personalChefButton: MDCButton!
    @IBOutlet weak var mealKitButton: MDCButton!
    @IBOutlet weak var contentButton: MDCButton!
    
    @IBOutlet weak var userToggleStack: UIStackView!
    @IBOutlet weak var ordersButton: MDCButton!
    @IBOutlet weak var chefsButton: MDCButton!
    @IBOutlet weak var likesButton: MDCButton!
    @IBOutlet weak var reviewsButton: MDCButton!
    
    @IBOutlet weak var comingSoon: UILabel!
    
    var toggle = "Cater Items"
    
    private var cateringItems : [FeedMenuItems] = []
    private var personalChefItem : PersonalChefInfo?
    private var mealKitItems : [FeedMenuItems] = []
    private var content : [VideoModel] = []
    
    private var userOrders: [UserOrders] = []
    private var userChefs: [UserChefs] = []
    private var userLikes: [UserLikes] = []
    private var userReviews: [UserReviews] = []
    
    private var orders: [UserOrders] = []
    private var chefs: [UserChefs] = []
    private var likes: [UserLikes] = []
    private var reviews: [UserReviews] = []
    
    private var items : [FeedMenuItems] = []
    
    
    var user = ""
    var chefOrUser = ""
    var chefEmail = ""
    
    
    @IBOutlet weak var itemTableView: UITableView!
    @IBOutlet weak var contentCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        chefImage.layer.borderWidth = 1
        chefImage.layer.masksToBounds = false
        chefImage.layer.borderColor = UIColor.white.cgColor
        chefImage.layer.cornerRadius = chefImage.frame.height/2
        chefImage.clipsToBounds = true
        
        itemTableView.register(UINib(nibName: "ChefItemTableViewCell", bundle: nil), forCellReuseIdentifier: "ChefItemReusableCell")
        itemTableView.delegate = self
        itemTableView.dataSource = self
        contentCollectionView.register(UINib(nibName: "ChefContentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ChefContentCollectionViewReusableCell")
        itemTableView.register(UINib(nibName: "UserOrdersAndLikesTableViewCell", bundle: nil), forCellReuseIdentifier: "UserOrdersAndLikesReusableCell")
        itemTableView.register(UINib(nibName: "PersonalChefTableViewCell", bundle: nil), forCellReuseIdentifier: "PersonalChefReusableCell")
        itemTableView.register(UINib(nibName: "UserReviewsTableViewCell", bundle: nil), forCellReuseIdentifier: "UserReviewsReusableCell")
        itemTableView.register(UINib(nibName: "UserChefsTableViewCell", bundle: nil), forCellReuseIdentifier: "UserChefsReusableCell")
        contentCollectionView.delegate = self
        contentCollectionView.dataSource = self
        
        if chefOrUser == "chef" {
            toggle = "Cater Items"
        loadChefInfo()
        loadChefItems()
            self.chefToggleStack.isHidden = false
            self.userToggleStack.isHidden = true

        } else {
            toggle = "Orders"
            loadUserInfo()
            loadUserOrders()
            self.chefToggleStack.isHidden = true
            self.userToggleStack.isHidden = false
        }
        loadUsername()
        

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
    
    
  
    
    private func loadUserInfo() {
        let storageRef = storage.reference()
        let image : UIImage?
        db.collection("User").document(user).collection("PersonalInfo").getDocuments { documents, error in
            if error == nil {
                if documents != nil {
                        for doc in documents!.documents {
                            let data = doc.data()

                        if let fullName = data["fullName"] as? String, let email = data["email"] as? String, let city = data["city"] as? String, let state = data["state"] as? String, let userName = data["userName"] as? String, let burger = data["burger"] as? Int, let creative = data["creative"] as? Int, let healthy = data["healthy"] as? Int, let lowCal = data["lowCal"] as? Int, let lowCarb = data["lowCarb"] as? Int, let pasta = data["pasta"] as? Int, let seafood = data["seafood"] as? Int, let workout = data["workout"] as? Int, let vegan = data["vegan"] as? Int, let local = data["local"] as? Int, let region = data["region"] as? Int, let nation = data["nation"] as? Int, let surpriseMe = data["surpriseMe"] as? Int {

                            storageRef.child("users/\(email)/profileImage/\(self.user).png").downloadURL { itemUrl, error in
                                
                                URLSession.shared.dataTask(with: itemUrl!) { (data, response, error) in
                                    // Error handling...
                                    guard let imageData = data else { return }
                                    
                                    print("happening itemdata")
                                    DispatchQueue.main.async {
                                        self.chefImage.image = UIImage(data: imageData)!
                                    }
                                }.resume()
                            }
                            self.educationText.text = ""
                            self.chefPassion.text = "Preferences:"
                            
                            if (burger == 1) {
                                self.chefPassion.text = "\(self.chefPassion.text!)  Burger"
                            }
                            if (creative == 1) {
                                self.chefPassion.text = "\(self.chefPassion.text!)  Creative"
                            }
                            if (healthy == 1) {
                                self.chefPassion.text = "\(self.chefPassion.text!)  Healthy"
                            }
                            if (lowCal == 1) {
                                self.chefPassion.text = "\(self.chefPassion.text!)  Low Calorie"
                            }
                            if (lowCarb == 1) {
                                self.chefPassion.text = "\(self.chefPassion.text!)  Low Carb"
                            }
                            if (pasta == 1) {
                                self.chefPassion.text = "\(self.chefPassion.text!)  Pasta"
                            }
                            if (seafood == 1) {
                                self.chefPassion.text = "\(self.chefPassion.text!)  Seafood"
                            }
                            if (vegan == 1) {
                                self.chefPassion.text = "\(self.chefPassion.text!)  Vegan"
                            }
                            if (workout == 1) {
                                self.chefPassion.text = "\(self.chefPassion.text!)  Workout"
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


    private func loadUserOrders() {
        let storageRef = storage.reference()

        userOrders.removeAll()
        userChefs.removeAll()
        userLikes.removeAll()
        userReviews.removeAll()
        itemTableView.reloadData()
        
        if self.orders.isEmpty {
            db.collection("User").document(user).collection("Orders").getDocuments { documents, error in
            if documents != nil {
                for doc in documents!.documents {
                    let data = doc.data()

                    if let chefEmail = data["chefEmail"] as? String, let chefImageId = data["chefImageId"] as? String, let city = data["city"] as? String, let eventDates = data["eventDates"] as? [String], let itemTitle = data["itemTitle"] as? String, let itemDescription = data["itemDescription"] as? String, let menuItemId = data["menuItemId"] as? String, let orderDate = data["orderDate"] as? String, let orderUpdate = data["orderUpdate"] as? String, let totalCostOfEvent = data["totalCostOfEvent"] as? Double, let travelFee = data["travelFee"] as? String, let typeOfService = data["typeOfService"] as? String, let unitPrice = data["unitPrice"] as? String, let imageCount = data["imageCount"] as? Int, let itemCalories = data["itemCalories"] as? String, let state = data["state"] as? String, let chefUsername = data["chefUsername"] as? String, let expectations = data["expectations"] as? Int, let chefRating = data["chefRating"] as? Int, let quality = data["quality"] as? Int, let signatureDishId = data["signatureDishId"] as? String {
                        var a = ""
                        if typeOfService == "Executive Item" {
                            a = "Executive Items"
                           
                        } else {
                            
                            a = typeOfService
                        }
                        self.db.collection(a).document(menuItemId).getDocument { document, error in
                            if error == nil {
                                if document != nil {
                                    let data1 = document!.data()

                                    if let liked = data1!["liked"] as? [String], let itemOrders = data1!["itemOrders"] as? Int, let itemRating = data["itemRating"] as? [Double] {

                                        let newItem = UserOrders(chefName: chefUsername, chefEmail: chefEmail, chefImageId: chefImageId, chefImage: UIImage(), city: city, state: state, zipCode: "", eventDates: eventDates, itemTitle: itemTitle, itemDescription: itemDescription, itemPrice: unitPrice, menuItemId: menuItemId, itemImage: UIImage(), orderDate: orderDate, orderUpdate: orderUpdate, totalCostOfEvent: totalCostOfEvent, travelFee: travelFee, typeOfService: typeOfService, imageCount: imageCount, liked: liked, itemOrders: itemOrders, itemRating: itemRating, itemCalories: Int(itemCalories)!, documentId: doc.documentID, expectations: expectations, chefRating: chefRating, quality: quality, signatureDishId: signatureDishId)

                        if self.userOrders.isEmpty {
                            self.userOrders.append(newItem)
                            self.orders = self.userOrders
                            self.itemTableView.insertRows(at: [IndexPath(item: 0, section: 0)], with: .fade)
                        } else {
                            let index = self.userOrders.firstIndex { $0.documentId == doc.documentID
                            }
                            if index == nil {
                                self.userOrders.append(newItem)
                                self.orders = self.userOrders
                                self.itemTableView.insertRows(at: [IndexPath(item: self.orders.count - 1, section: 0)], with: .fade)
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
            self.itemTableView.reloadData()
            itemTableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        }
    }

    private func loadUserChefs() {
        userOrders.removeAll()
        userChefs.removeAll()
        userLikes.removeAll()
        userReviews.removeAll()
        itemTableView.reloadData()

        if self.chefs.isEmpty {
            db.collection("User").document(user).collection("UserLikes").getDocuments { documents, error in

            if error == nil {
                for doc in documents!.documents {
                    let data = doc.data()
                    
                    if let chefEmail = data["chefEmail"] as? String, let chefImageId = data["profileImageId"] as? String, let chefName = data["chefUsername"] as? String, let chefPassion = data["chefPassion"] as? String, let liked = data["liked"] as? [String], let itemOrders = data["itemOrders"] as? Int, let itemRating = data["itemRating"] as? [Double] {
                        
                        print("chefs happening")
                        if let index = self.chefs.firstIndex(where: { $0.chefEmail == chefEmail }) {
                            for i in 0..<liked.count {
                                self.chefs[index].chefLiked.append(liked[i])
                            }
                            self.chefs[index].chefOrders += itemOrders
                            for i in 0..<itemRating.count {
                                self.chefs[index].chefRating.append(itemRating[i])
                            }
                            self.chefs[index].timesLiked += 1
                            self.itemTableView.reloadData()
                        } else {
                            let newItem = UserChefs(chefEmail: chefEmail, chefImageId: chefImageId, chefImage: UIImage(), chefName: chefName, chefPassion: chefPassion, timesLiked: 0, chefLiked: liked, chefOrders: 0, chefRating: itemRating)
                            
                            if self.userChefs.isEmpty {
                                self.userChefs.append(newItem)
                                self.chefs = self.userChefs
                                self.itemTableView.insertRows(at: [IndexPath(item: 0, section: 0)], with: .fade)
                            } else {
                                let index = self.userChefs.firstIndex { $0.chefEmail == chefEmail }
                                if index == nil {
                                    self.userChefs.append(newItem)
                                    self.chefs = self.userChefs
                                    self.itemTableView.insertRows(at: [IndexPath(item: self.chefs.count - 1, section: 0)], with: .fade)
                                } else {
                                    self.userChefs[index!].timesLiked = self.userChefs[index!].timesLiked + 1
                                }
                            }
                            
                        }
                    }}
            }
        }
        } else {
            self.userChefs = self.chefs
            self.itemTableView.reloadData()
            itemTableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        }
    }

    private func loadUserLikes() {
//        var chefImage = UIImage()
//        var itemImage = UIImage()

        userOrders.removeAll()
        userChefs.removeAll()
        userLikes.removeAll()
        userReviews.removeAll()
        itemTableView.reloadData()
        
        
        if self.likes.isEmpty {
            db.collection("User").document(user).collection("UserLikes").getDocuments { documents, error in
            if error == nil {
                if documents != nil {
                for doc in documents!.documents {
                    let data = doc.data()

                    if let chefEmail = data["chefEmail"] as? String, let chefUsername = data["chefUsername"] as? String, let chefImageId = data["profileImageId"] as? String, let imageCount = data["imageCount"] as? Int, let itemDescription = data["itemDescription"] as? String, let itemPrice = data["itemPrice"] as? String, let itemTitle = data["itemTitle"] as? String, let itemType = data["itemType"] as? String, let city = data["city"] as? String, let state = data["state"] as? String, let expectations = data["expectations"] as? Int, let chefRating = data["chefRating"] as? Int, let quality = data["quality"] as? Int, let signatureDishId = data["signatureDishId"] as? String {
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
                                        self.itemTableView.insertRows(at: [IndexPath(item: 0, section: 0)], with: .fade)
                                    } else {
                                        self.userLikes.append(newItem)
                                        self.likes = self.userLikes
                                        self.itemTableView.insertRows(at: [IndexPath(item: self.likes.count - 1, section: 0)], with: .fade)
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
            self.itemTableView.reloadData()
            itemTableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        }
    }

    private func loadUserReviews() {
        

        userOrders.removeAll()
        userChefs.removeAll()
        userLikes.removeAll()
        userReviews.removeAll()
        itemTableView.reloadData()

        if self.reviews.isEmpty {
            db.collection("User").document(user).collection("UserReviews").getDocuments { documents, error in
            if error == nil {
                if documents != nil {
                    for doc in documents!.documents {
                        let data = doc.data()


                        if let chefEmail = data["chefEmail"] as? String, let chefImageId = data["chefImageId"] as? String, let chefUsername = data["chefUsername"] as? String, let date = data["date"] as? String, let itemTitle = data["itemTitle"] as? String, let itemType = data["itemType"] as? String, let userChefRating = data["chefRating"] as? Int, let userExpectationsRating = data["expectations"] as? Int, let qualityRating = data["quality"] as? Int, let userRecommendation = data["recommend"] as? Int, let userReviewTextField = data["thoughts"] as? String, let liked = data["liked"] as? [String] {

                            print("reviews happening")
                            let newItem = UserReviews(chefEmail: chefEmail, chefImageId: chefImageId, chefImage: UIImage(), chefName: chefUsername, date: date, documentID: doc.documentID, itemTitle: itemTitle, itemType: itemType, liked: liked, user: self.user, userChefRating: userChefRating, userExpectationsRating: userExpectationsRating, userImageId: userImageId, userQualityRating: qualityRating, userRecommendation: userRecommendation, userReviewTextField: userReviewTextField)

                            if self.userReviews.isEmpty {
                                self.userReviews.append(newItem)
                                self.reviews = self.userReviews
                                self.itemTableView.insertRows(at: [IndexPath(item: 0, section: 0)], with: .fade)
                            } else {
                                let index = self.userReviews.firstIndex(where: { $0.documentID == doc.documentID })
                                if index == nil {
                                    self.userReviews.append(newItem)
                                    self.reviews = self.userReviews
                                    self.itemTableView.insertRows(at: [IndexPath(item: self.reviews.count - 1, section: 0)], with: .fade)
                                }
                            }
                        
                        }
                    }
                }
            }
        }
        } else {
            self.userReviews = self.reviews
            self.itemTableView.reloadData()
            itemTableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        }
    }
    
    
    private func loadChefInfo() {
        
        let storageRef = storage.reference()
        
        db.collection("Chef").document(user).collection("PersonalInfo").getDocuments { documents, error in
            if error == nil {
                for doc in documents!.documents {
                    let data = doc.data()
                    
                    if let chefPassion = data["chefPassion"] as? String, let city = data["city"] as? String, let education = data["education"] as? String, let fullName = data["fullName"] as? String, let state = data["state"] as? String, let username = data["chefName"] as? String, let email = data["email"] as? String {
                        self.chefEmail = email
                        let chefRef = storageRef.child("chefs/\(email)/profileImage/\(self.user).png").downloadURL { itemUrl, error in
                        
                            
                        URLSession.shared.dataTask(with: itemUrl!) { (data, response, error) in
                                  // Error handling...
                                  guard let imageData = data else { return }

                            print("happening itemdata")
                                  DispatchQueue.main.async {
                                      self.chefImage.image = UIImage(data: imageData)!
                                  }
                                }.resume()
                            
                         
                        
                        
                        
                              
                        self.chefImage.layer.borderWidth = 1
                        self.chefImage.layer.masksToBounds = false
                        self.chefImage.layer.borderColor = UIColor.white.cgColor
                        self.chefImage.layer.cornerRadius = self.chefImage.frame.height/2
                        self.chefImage.clipsToBounds = true
                        self.educationText.text = "Education: \(education)"
                        self.chefPassion.text = chefPassion
                        self.location.text = "Location: \(city), \(state)"
                        self.userName.text = "@\(username)"
                        
                    
                
                    }}
            }
            }
        }
    }
    
    private func loadChefItems() {
        if !items.isEmpty {
            items.removeAll()
            itemTableView.reloadData()
        }
        
        
        var itemsI : [FeedMenuItems]
        
        if toggle == "Cater Items" {
            itemsI = cateringItems
        } else {
           itemsI = mealKitItems
        }
        if itemsI.isEmpty {
        
            db.collection("Chef").document(user).collection(toggle).getDocuments { documents, error in
            if error == nil {
                for doc in documents!.documents {
                    
                    let data = doc.data()
                    
                    if let chefEmail = data["chefEmail"] as? String, let chefPassion = data["chefPassion"] as? String, let chefUsername = data["chefUsername"] as? String, let profileImageId = data["profileImageId"] as? String, let menuItemId = data["randomVariable"] as? String, let itemTitle = data["itemTitle"] as? String, let itemDescription = data["itemDescription"] as? String, let itemPrice = data["itemPrice"] as? String, let date = data["date"], let imageCount = data["imageCount"] as? Int, let itemType = data["itemType"] as? String, let city = data["city"] as? String, let state = data["state"] as? String, let zipCode = data["zipCode"] as? String, let user = data["user"] as? String, let healthy = data["healthy"] as? Int, let creative = data["creative"] as? Int, let vegan = data["vegan"] as? Int, let burger = data["burger"] as? Int, let seafood = data["seafood"] as? Int, let pasta = data["pasta"] as? Int, let workout = data["workout"] as? Int, let lowCal = data["lowCal"] as? Int, let lowCarb = data["lowCarb"] as? Int {
                        
                        
                        
                        self.db.collection("Cater Items").document(menuItemId).getDocument { document, error in
                            if error == nil {
                                if document != nil {
                                    let data = document!.data()
                                    
                                    if let liked = data!["liked"] as? [String], let itemOrders = data!["itemOrders"] as? Int, let itemRating = data!["itemRating"] as? [Double] {
                              
                              
                                        let newItem = FeedMenuItems(chefEmail: chefEmail, chefPassion: chefPassion, chefUsername: chefUsername, chefImageId: profileImageId, chefImage: UIImage(), menuItemId: menuItemId, itemImage: UIImage(), itemTitle: itemTitle, itemDescription: itemDescription, itemPrice: itemPrice, liked: liked, itemOrders: itemOrders, itemRating: itemRating, date: "\(date)", imageCount: imageCount, itemCalories: "0", itemType: itemType, city: city, state: state, zipCode: zipCode, user: user, healthy: healthy, creative: creative, vegan: vegan, burger: burger, seafood: seafood, pasta: pasta, workout: workout, lowCal: lowCal, lowCarb: lowCarb)
                                        
                                        if self.toggle == "Cater Items" {
                                            if self.cateringItems.isEmpty {
                                                self.cateringItems.append(newItem)
                                                self.items = self.cateringItems
                                                self.itemTableView.insertRows(at: [IndexPath(item: 0, section: 0)], with: .fade)
                                            } else {
                                                let index = self.cateringItems.firstIndex { $0.menuItemId == menuItemId }
                                                if index == nil {
                                                    self.cateringItems.append(newItem)
                                                    self.items = self.cateringItems
                                                    self.itemTableView.insertRows(at: [IndexPath(item: self.cateringItems.count - 1, section: 0)], with: .fade)
                                                }
                                            }
                                        } else if self.toggle == "MealKit Items" {
                                            if self.mealKitItems.isEmpty {
                                                self.mealKitItems.append(newItem)
                                                self.items = self.mealKitItems
                                                self.itemTableView.insertRows(at: [IndexPath(item: 0, section: 0)], with: .fade)
                                            } else {
                                                let index = self.mealKitItems.firstIndex { $0.menuItemId == menuItemId }
                                                if index == nil {
                                                    self.mealKitItems.append(newItem)
                                                    self.items = self.mealKitItems
                                                    self.itemTableView.insertRows(at: [IndexPath(item: self.mealKitItems.count - 1, section: 0)], with: .fade)
                                                }}}}
                                        
                                    
                                }
                            }
                        }
        }
        }}}
            
        } else {
            
            if self.toggle == "Cater Items" {
                self.items = self.cateringItems
            } else {
                self.items = self.mealKitItems
            }
            
            self.itemTableView.reloadData()
            if self.itemTableView.numberOfRows(inSection: 0) != 0 {
                self.itemTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }}
    }
    
    private func loadPersonalChefInfo() {
        if !items.isEmpty {
            items.removeAll()
            itemTableView.reloadData()
        }
            
        
        db.collection("Chef").document(user).collection("Executive Items").getDocuments { documents, error in
            if error == nil {
                if documents != nil {
                    for doc in documents!.documents {
                        let data = doc.data()
                        
                        let typeOfInfo = data["typeOfService"] as? String
                        let complete = data["complete"] as? String
                        
                        if typeOfInfo == "info" && complete == "yes" {
                            
                            if let briefIntroduction = data["briefIntroduction"] as? String, let lengthOfPersonalChef = data["lengthOfPersonalChef"] as? String, let specialty = data["specialty"] as? String, let servicePrice = data["servicePrice"] as? String, let expectations = data["expectations"] as? Int, let chefRating = data["chefRating"] as? Int, let quality = data["quality"] as? Int, let chefName = data["chefName"] as? String, let whatHelpsYouExcel = data["whatHelpsYouExcel"] as? String, let mostPrizedAccomplishment = data["mostPrizedAccomplishment"] as? String, let weeks = data["weeks"] as? Int, let months = data["months"] as? Int, let trialRun = data["trialRun"] as? Int, let hourlyOrPersSession = data["hourlyOrPerSession"] as? String, let liked = data["liked"] as? [String], let itemOrders = data["itemOrders"] as? Int, let itemRating = data["itemRating"] as? [Double], let city = data["city"] as? String, let state = data["state"] as? String, let chefEmail = data["chefEmail"] as? String, let signatureDishId = data["signatureDishId"] as? String, let zipCode = data["zipCode"] as? String, let openToMenuRequests = data["openToMenuRequests"] as? String {
                                print("happening personal chef")
                                var availability = ""
                                if trialRun == 0 {
                                    availability = "Trial Run"
                                }
                                if weeks == 0 {
                                    availability = "\(availability)  Weeks"
                                }
                                if months == 0 {
                                    availability = "\(availability)  Months"
                                }
                                
                                self.personalChefItem = PersonalChefInfo(chefName: chefName, chefEmail: chefEmail, chefImageId: self.user, chefImage: self.chefImage.image!, city: city, state: state, zipCode: zipCode, signatureDishImage: UIImage(), signatureDishId: signatureDishId, option1Title: "", option2Title: "", option3Title: "", option4Title: "", briefIntroduction: briefIntroduction, howLongBeenAChef: lengthOfPersonalChef, specialty: specialty, whatHelpesYouExcel: whatHelpsYouExcel, mostPrizedAccomplishment: mostPrizedAccomplishment, availabilty: availability, hourlyOrPerSession: hourlyOrPersSession, servicePrice: servicePrice, trialRun: trialRun, weeks: weeks, months: months, liked: liked, itemOrders: itemOrders, itemRating: itemRating, expectations: expectations, chefRating: chefRating, quality: quality, documentId: doc.documentID, openToMenuRequests: openToMenuRequests)
                              
                                
                            }
                            
                        }
                        if typeOfInfo == "Signature Dish" {
                            let chefEmail = data["chefEmail"] as! String
                            print("happening personal chef 2")
                                    self.storage.reference().child("chefs/\(chefEmail)/Executive Items/\(doc.documentID)0.png").downloadURL { imageUrl, error in
                                        if error == nil {
                                            URLSession.shared.dataTask(with: imageUrl!) { (data, response, error) in
                                                // Error handling...
                                                guard let imageData = data else { return }
                                                
                                                print("happening itemdata")
                                                DispatchQueue.main.async {
                                                    if self.personalChefItem != nil {
                                                        self.personalChefItem!.signatureDishImage = UIImage(data: imageData)!
                                                        self.itemTableView.reloadData()
                                                    }
                                                }
                                            }.resume()
                                        }
                                    }
                                }
                            
                        
                    }
                        }
                
            }
        }
    }
    
    private var createdAt = 0
    private func loadContent() {
        let json: [String: Any] = ["createdAt" : "\(createdAt)"]
        
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        // MARK: Fetch the Intent client secret, Ephemeral Key secret, Customer ID, and publishable key
        var request = URLRequest(url: URL(string: "https://taiste-video.onrender.com/get-videos")!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
          guard let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                let videos = json["videos"] as? [[String:Any]],
                let self = self else {
            // Handle error
            return
          }
            
          DispatchQueue.main.async {
              
              if videos.count == 0 {
                  
              } else {
                  for i in 0..<videos.count {
                      let id = videos[i]["id"]!
                      let createdAtI = videos[i]["createdAt"]!
                      if i == videos.count - 1 {
                          self.createdAt = createdAtI as! Int
                      }
                      var views = 0
                      var liked : [String] = []
                      var comments = 0
                      var shared = 0
                      
                      self.db.collection("Videos").document("\(id)").getDocument { document, error in
                          if error == nil {
                              
                              if document!.exists {
                                  let data = document!.data()
                                  
                                  if data!["views"] != nil {
                                      views = data!["views"] as! Int
                                  }
                                  
                                  if data!["liked"] != nil {
                                      liked = data!["liked"] as! [String]
                                  }
                                  
                                  if data!["shared"] != nil {
                                      shared = data!["shared"] as! Int
                                  }
                                  
                                  if data!["comments"] != nil {
                                      comments = data!["comments"] as! Int
                                  }
                              }
                      }
                          print("videos \(videos)")
                          print("dataUri \(videos[i]["dataUrl"]! as! String)")
                          
                          let newVideo = VideoModel(dataUri: videos[i]["dataUrl"]! as! String, id: videos[i]["id"]! as! String, videoDate: String(createdAtI as! Int), user: videos[i]["name"]! as! String, description: videos[i]["description"]! as! String, views: views, liked: liked, comments: comments, shared: shared, thumbNailUrl: videos[i]["thumbnailUrl"]! as! String)
                          
                          if self.content.isEmpty {
                              self.content.append(newVideo)
                              self.contentCollectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
                              
                          } else {
                              let index = self.content.firstIndex { $0.id == id as! String
                              }
                              if index == nil {
                                  self.content.append(newVideo)
                                  self.contentCollectionView.insertItems(at: [IndexPath(item: self.content.count - 1, section: 0)])
                              }
                          }
                      }
                  }
              }
          }
        })
        task.resume()
    }
    
    private var item : FeedMenuItems?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProfileAsUserToOrderDetailsSegue" {
            let info = segue.destination as! OrderDetailsViewController
            info.item = item
        }
    }
    
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func cateringButtonPressed(_ sender: Any) {
        toggle = "Cater Items"
        loadChefItems()
        contentCollectionView.isHidden = true
        itemTableView.isHidden = false
        comingSoon.isHidden = true
        cateringButton.setTitleColor(UIColor.white, for: .normal)
        cateringButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
        personalChefButton.backgroundColor = UIColor.white
        personalChefButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        mealKitButton.backgroundColor = UIColor.white
        mealKitButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        contentButton.backgroundColor = UIColor.white
        contentButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
    }
    
    @IBAction func personalChefButtonPressed(_ sender: Any) {
        toggle = "Executive Items"
        loadPersonalChefInfo()
        contentCollectionView.isHidden = true
        itemTableView.isHidden = false
        comingSoon.isHidden = true
        cateringButton.backgroundColor = UIColor.white
        cateringButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        personalChefButton.setTitleColor(UIColor.white, for: .normal)
        personalChefButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
        mealKitButton.backgroundColor = UIColor.white
        mealKitButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        contentButton.backgroundColor = UIColor.white
        contentButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
    }
    
    @IBAction func mealKitButtonPressed(_ sender: Any) {
        toggle = "MealKit Items"
        loadChefItems()
        contentCollectionView.isHidden = true
        itemTableView.isHidden = false
        comingSoon.isHidden = true
        cateringButton.backgroundColor = UIColor.white
        cateringButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        personalChefButton.backgroundColor = UIColor.white
        personalChefButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        mealKitButton.setTitleColor(UIColor.white, for: .normal)
        mealKitButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
        contentButton.backgroundColor = UIColor.white
        contentButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
    }
    
    @IBAction func contentButtonPressed(_ sender: Any) {
        loadContent()
        contentCollectionView.isHidden = false
        itemTableView.isHidden = true
        comingSoon.isHidden = true
        cateringButton.backgroundColor = UIColor.white
        cateringButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        personalChefButton.backgroundColor = UIColor.white
        personalChefButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        mealKitButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        mealKitButton.backgroundColor = UIColor.white
        contentButton.setTitleColor(UIColor.white, for: .normal)
        contentButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
    }
    
    @IBAction func orderButtonPressed(_ sender: Any) {
        toggle = "Orders"
        loadUserOrders()
        ordersButton.setTitleColor(UIColor.white, for: .normal)
        ordersButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
        chefsButton.backgroundColor = UIColor.white
        chefsButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        likesButton.backgroundColor = UIColor.white
        likesButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        reviewsButton.backgroundColor = UIColor.white
        reviewsButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        
    }
    
    @IBAction func chefsButtonPressed(_ sender: Any) {
        toggle = "Chefs"
        loadUserChefs()
        ordersButton.backgroundColor = UIColor.white
        ordersButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        chefsButton.setTitleColor(UIColor.white, for: .normal)
        chefsButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
        likesButton.backgroundColor = UIColor.white
        likesButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        reviewsButton.backgroundColor = UIColor.white
        reviewsButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
    }
    
    @IBAction func likesButtonPressed(_ sender: Any) {
        toggle = "Likes"
        loadUserLikes()
        ordersButton.backgroundColor = UIColor.white
        ordersButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        chefsButton.backgroundColor = UIColor.white
        chefsButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        likesButton.setTitleColor(UIColor.white, for: .normal)
        likesButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
        reviewsButton.backgroundColor = UIColor.white
        reviewsButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
    }
    
    
    @IBAction func messagesButtonPressed(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "Messages") as? MessagesViewController  {
            vc.otherUser = user
            vc.otherUserName = "\(self.userName.text!)"
            vc.chefOrUser = "Chef"
            vc.eventTypeAndQuantityText = "na"
            vc.travelFeeOrMessage = "MessageRequests"
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func reviewsButtonPressed(_ sender: Any) {
        toggle = "Reviews"
        loadUserReviews()
        ordersButton.backgroundColor = UIColor.white
        ordersButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        chefsButton.backgroundColor = UIColor.white
        chefsButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        likesButton.backgroundColor = UIColor.white
        likesButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        reviewsButton.setTitleColor(UIColor.white, for: .normal)
        reviewsButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
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

extension ProfileAsUserViewController :  UITableViewDelegate, UITableViewDataSource  {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if chefOrUser == "chef" {
            if toggle == "Cater Items" || toggle == "MealKit Items" {
                return items.count
            } else {
                if personalChefItem != nil {
                    return 1
                } else {
                    return 0
                }
            }
        } else {
            if self.toggle == "Orders" {
                return userOrders.count
            } else if self.toggle == "Chefs" {
                return userChefs.count
            } else if self.toggle == "Likes" {
                return userLikes.count
            } else {
                return userReviews.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if chefOrUser == "chef" {
            if toggle == "Cater Items" || toggle == "MealKit Items" {
                let cell = itemTableView.dequeueReusableCell(withIdentifier: "ChefItemReusableCell", for: indexPath) as! ChefItemTableViewCell
                var item = items[indexPath.row]
                cell.editImage.isHidden = true
                
                //        cell.chefImage.image = item.chefImage
                cell.itemTitle.text = item.itemTitle
                cell.itemImage.image = item.itemImage
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
                if item.liked.firstIndex(of: Auth.auth().currentUser!.email!) != nil {
                    cell.likeImage.image = UIImage(systemName: "heart.fill")
                } else {
                    cell.likeImage.image = UIImage(systemName: "heart")
                }
                
                storage.reference().child("chefs/\(item.chefEmail)/\(item.itemType)/\(item.menuItemId)0.png").downloadURL { itemUrl, error in
                    
                    if error == nil {
                        
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
                }
                
                cell.itemImageButtonTapped = {
                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ItemDetail") as? ItemDetailViewController  {
                        vc.chefEmail = item.chefEmail
                        vc.imageCount = item.imageCount
                        vc.menuItemId = item.menuItemId
                        vc.itemType = item.itemType
                        vc.itemTitleI = item.itemTitle
                        vc.itemDescriptionI = item.itemDescription
                        vc.itemImage = item.itemImage
                        vc.item = item
                        vc.caterOrPersonal = "cater"
                        self.present(vc, animated: true, completion: nil)
                    }
                }
                
                cell.orderButtonTapped = {
                    if Auth.auth().currentUser!.displayName! != "Chef" {
                        self.item = item
                        self.performSegue(withIdentifier: "ProfileAsUserToOrderDetailsSegue", sender: self)
                    } else {
                        self.showToast(message: "Please create a user account to order.", font: .systemFont(ofSize: 12))
                    }
                }
                
                cell.likeImageButtonTapped = {
                    self.db.collection("\(item.itemType)").document(item.menuItemId).getDocument(completion: { document, error in
                        if error == nil {
                            if document != nil {
                                let data = document!.data()
                                
                                let liked = data!["liked"] as? [String]
                                let data1 : [String: Any] = ["chefEmail" : item.chefEmail, "chefPassion" : item.chefPassion, "chefUsername" : item.chefUsername, "profileImageId" : item.chefImageId, "menuItemId" : item.menuItemId, "itemTitle" : item.itemTitle, "itemDescription" : item.itemDescription, "itemPrice" : item.itemPrice, "liked" : liked, "itemOrders" : item.itemOrders, "itemRating": item.itemRating, "imageCount" : item.imageCount, "itemType" : item.itemType, "city" : item.city, "state" : item.state, "user" : item.user, "healthy" : item.healthy, "creative" : item.creative, "vegan" : item.vegan, "burger" : item.burger, "seafood" : item.seafood, "pasta" : item.pasta, "workout" : item.workout, "lowCal" : item.lowCal, "lowCarb" : item.lowCarb, "expectations" : 0, "chefRating" : 0, "quality" : 0]
                                if (liked!.firstIndex(of: Auth.auth().currentUser!.email!) != nil) {
                                    self.db.collection("\(item.itemType)").document(item.menuItemId).updateData(["liked" : FieldValue.arrayRemove(["\(Auth.auth().currentUser!.email!)"])])
                                    self.db.collection("User").document(Auth.auth().currentUser!.uid).collection("UserLikes").document(item.menuItemId).delete()
                                    
                                    cell.likeImage.image = UIImage(systemName: "heart")
                                    cell.likeText.text = "\(Int(cell.likeText.text!)! - 1)"
                                } else {
                                    self.db.collection("\(item.itemType)").document(item.menuItemId).updateData(["liked" : FieldValue.arrayUnion(["\(Auth.auth().currentUser!.email!)"])])
                                    self.db.collection("User").document(Auth.auth().currentUser!.uid).collection("UserLikes").document(item.menuItemId).setData(data1)
                                    cell.likeImage.image = UIImage(systemName: "heart.fill")
                                    cell.likeText.text = "\(Int(cell.likeText.text!)! + 1)"
                                }
                                
                            }
                        }
                    })
                    let date = Date()
                    let df = DateFormatter()
                    
                    let date1 =  df.string(from: Date())
                    let data3: [String: Any] = ["notification" : "\(guserName) has just liked your item (\(item.itemType))  \(item.itemTitle)", "date" : date1]
                    let data4: [String: Any] = ["notifications" : "yes"]
                    self.db.collection("Chef").document(item.chefImageId).collection("Notifications").document().setData(data3)
                    self.db.collection("Chef").document(item.chefImageId).updateData(data4)
                }
                
                return cell
            } else {
               
                let cell = itemTableView.dequeueReusableCell(withIdentifier: "PersonalChefReusableCell", for: indexPath) as! PersonalChefTableViewCell
                var item = personalChefItem!
                
                cell.chefImage.image = item.chefImage
                cell.chefName.text = item.chefName
                cell.briefIntro.text = item.briefIntroduction
                cell.servicePrice.text = "$\(item.servicePrice)"
                
                let storageRef = self.storage.reference()
                let itemRef = self.storage.reference()
                
                storageRef.child("chefs/\(item.chefEmail)/profileImage/\(item.chefImageId).png").downloadURL { imageUrl, error in
                    
                    URLSession.shared.dataTask(with: imageUrl!) { (data, response, error) in
                        // Error handling...
                        guard let imageData = data else { return }
                        
                        print("happening itemdata")
                        DispatchQueue.main.async {
                            cell.chefImage.image = UIImage(data: imageData)!
                            item.chefImage = UIImage(data: imageData)!
                        }
                    }.resume()
                    
                }
                
                
                itemRef.child("chefs/\(item.chefEmail)/Executive Items/\(item.signatureDishId)0.png").downloadURL { imageUrl, error in
                    
                    if error == nil {
                        URLSession.shared.dataTask(with: imageUrl!) { (data, response, error) in
                            // Error handling...
                            guard let imageData = data else { return }
                            
                            print("happening itemdata")
                            DispatchQueue.main.async {
                                cell.signatureImage.image = UIImage(data: imageData)!
                                item.signatureDishImage = UIImage(data: imageData)!
                            }
                        }.resume()
                    }
                }
                
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
                
                cell.orderButton.isHidden = false
                cell.editInfoButton.isHidden = true
                
                
                cell.orderButtonTapped = {
                    if Auth.auth().currentUser!.displayName! == "Chef" {
                        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "PersonalChefOrderDetail") as? PersonalChefOrderDetailViewController {
                            vc.personalChefInfo = item
                            
                            self.present(vc, animated: true, completion: nil)
                        }
                    }  else {
                        self.showToast(message: "Please create a user account to order.", font: .systemFont(ofSize: 12))
                }
                }
                
                cell.detailButtonTapped = {
                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ItemDetail") as? ItemDetailViewController {
                        vc.caterOrPersonal = "personal"
                        vc.personalChefInfo = item
                        self.present(vc, animated: true, completion: nil)
                    }
                }
                return cell
            }
        } else {
            if toggle == "Orders" {
                if userOrders[indexPath.row].typeOfService == "Cater Items" {
                    var cell = itemTableView.dequeueReusableCell(withIdentifier: "UserOrdersAndLikesReusableCell", for: indexPath) as! UserOrdersAndLikesTableViewCell
                    
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
                                order.chefImage = UIImage(data: imageData)!
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
                    
                    cell.orderButtonTapped = {
                        let item = order
                        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "OrderDetail") as? OrderDetailsViewController  {
                            vc.item = FeedMenuItems(chefEmail: item.chefEmail, chefPassion: "", chefUsername: item.chefName, chefImageId: item.chefImageId, menuItemId: item.documentId, itemTitle: item.itemTitle, itemDescription: item.itemDescription, itemPrice: item.itemPrice, liked: item.liked, itemOrders: item.itemOrders, itemRating: item.itemRating, date: "", imageCount: item.imageCount, itemCalories: "\(item.itemCalories)", itemType: item.typeOfService, city: item.city, state: item.state, zipCode: item.zipCode, user: item.chefImageId, healthy: 0, creative: 0, vegan: 0, burger: 0, seafood: 0, pasta: 0, workout: 0, lowCal: 0, lowCarb: 0)
                            self.present(vc, animated: true, completion: nil)
                        }}
                    
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
                            vc.item = FeedMenuItems(chefEmail: order.chefEmail, chefPassion: "", chefUsername: order.chefEmail, chefImageId: order.chefImageId, menuItemId: order.menuItemId, itemTitle: order.itemTitle, itemDescription: order.itemDescription, itemPrice: order.itemPrice, liked: order.liked, itemOrders: order.itemOrders, itemRating: order.itemRating, date: order.orderDate, imageCount: order.imageCount, itemCalories: "\(order.itemCalories)", itemType: order.typeOfService, city: order.city, state: order.state, zipCode: order.zipCode, user: order.chefImageId, healthy: 0, creative: 0, vegan: 0, burger: 0, seafood: 0, pasta: 0, workout: 0, lowCal: 0, lowCarb: 0)
                            self.present(vc, animated: true, completion: nil)
                            
                        }}
                    
                    
                    
                    
                    return cell
                } else {
                   
                    var cell = itemTableView.dequeueReusableCell(withIdentifier: "PersonalChefTableViewCell", for: indexPath) as! PersonalChefTableViewCell
                    
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
                    
                    storageRef.child("chefs/\(order.chefEmail)/profileImage/\(order.chefImageId).png").downloadURL { itemUrl, error in
                        
                        URLSession.shared.dataTask(with: itemUrl!) { (data, response, error) in
                            // Error handling...
                            guard let imageData = data else { return }
                            
                            print("happening itemdata")
                            DispatchQueue.main.async {
                                cell.chefImage.image = UIImage(data: imageData)!
                            }
                        }.resume()
                    }
                    
                    itemRef.child("chefs/\(order.chefEmail)/Executive Items/\(order.signatureDishId)0.png").downloadURL { itemUrl, error in
                        
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
                    cell.orderButtonTapped = {
                        if Auth.auth().currentUser!.displayName! == "Chef" {
                            let item = order
                            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "PersonalChefOrderDetail") as? PersonalChefOrderDetailViewController  {
                                vc.item = FeedMenuItems(chefEmail: item.chefEmail, chefPassion: "", chefUsername: item.chefName, chefImageId: item.chefImageId, menuItemId: item.documentId, itemTitle: item.itemTitle, itemDescription: item.itemDescription, itemPrice: item.itemPrice, liked: item.liked, itemOrders: item.itemOrders, itemRating: item.itemRating, date: "", imageCount: item.imageCount, itemCalories: "\(item.itemCalories)", itemType: item.typeOfService, city: item.city, state: item.state, zipCode: item.zipCode, user: item.chefImageId, healthy: 0, creative: 0, vegan: 0, burger: 0, seafood: 0, pasta: 0, workout: 0, lowCal: 0, lowCarb: 0)
                                self.present(vc, animated: true, completion: nil)
                            }} else {
                                self.showToast(message: "Please create a user account to order.", font: .systemFont(ofSize: 12))
                            }}
                    
                    
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
                
            var cell = itemTableView.dequeueReusableCell(withIdentifier: "UserChefsReusableCell", for: indexPath) as! UserChefsTableViewCell
                
                var item = userChefs[indexPath.row]
                
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
                            item.chefImage = UIImage(data: imageData)!
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
                   
                    var cell = itemTableView.dequeueReusableCell(withIdentifier: "UserOrdersAndLikesReusableCell", for: indexPath) as! UserOrdersAndLikesTableViewCell
                    
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
                    cell.userImage.image = item.chefImage
                    
                    cell.itemImage.image = item.itemImage
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
                                item.chefImage = UIImage(data: imageData)!
                            }
                        }.resume()
                    }
                    itemRef.child("chefs/\(item.chefEmail)/\(item.itemType)/\(item.documentId)0.png").downloadURL { itemUrl, error in
                        
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
                    cell.orderButtonTapped = {
                        if Auth.auth().currentUser!.displayName! == "Chef" {
                            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "OrderDetail") as? OrderDetailsViewController  {
                                vc.item = FeedMenuItems(chefEmail: item.chefEmail, chefPassion: "", chefUsername: item.chefName, chefImageId: item.chefImageId, menuItemId: item.documentId, itemTitle: item.itemTitle, itemDescription: item.itemDescription, itemPrice: item.itemPrice, liked: item.liked, itemOrders: item.itemOrders, itemRating: item.itemRating, date: "", imageCount: item.imageCount, itemCalories: "\(item.itemCalories)", itemType: item.itemType, city: item.city, state: item.state, zipCode: item.zipCode, user: item.chefImageId, healthy: 0, creative: 0, vegan: 0, burger: 0, seafood: 0, pasta: 0, workout: 0, lowCal: 0, lowCarb: 0)
                                self.present(vc, animated: true, completion: nil)
                            }
                        } else {
                            self.showToast(message: "Please create a user account to order.", font: .systemFont(ofSize: 12))
                        }}
                    
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
                            vc.item = FeedMenuItems(chefEmail: item.chefEmail, chefPassion: "", chefUsername: item.chefEmail, chefImageId: item.chefImageId, menuItemId: item.documentId, itemTitle: item.itemTitle, itemDescription: item.itemDescription, itemPrice: item.itemPrice, liked: item.liked, itemOrders: item.itemOrders, itemRating: item.itemRating, date: "", imageCount: item.imageCount, itemCalories: "\(item.itemCalories)", itemType: item.itemType, city: item.city, state: item.state, zipCode: item.zipCode, user: item.chefImageId, healthy: 0, creative: 0, vegan: 0, burger: 0, seafood: 0, pasta: 0, workout: 0, lowCal: 0, lowCarb: 0)
                            self.present(vc, animated: true, completion: nil)
                        }
                    }
                    
                    //                cell.likeImageButtonTapped = {
                    //                    if let index = self.userLikes.firstIndex(where: { $0.documentId == item.documentId }) {
                    //                        self.userLikes.remove(at: index)
                    //                        self.itemTableView.deleteRows(at: [IndexPath(item:index, section: 0)], with: .fade)
                    //                        self.db.collection("User").document(Auth.auth().currentUser!.uid).collection("UserLikes").document(item.documentId).delete()
                    //                    }
                    //                }
                    
                    
                    return cell
                } else {
                    
                    var cell = itemTableView.dequeueReusableCell(withIdentifier: "PersonalChefReusableCell", for: indexPath) as! PersonalChefTableViewCell
                    
                    var item = userLikes[indexPath.row]
                    
                    cell.chefName.text = item.chefName
                    cell.briefIntro.text = item.itemDescription
                    cell.chefLikes.text = "\(item.liked.count)"
                    cell.chefOrders.text = "\(item.itemOrders)"
                    cell.chefRating.text = "\(item.chefRating)"
                    
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
                    itemRef.child("chefs/\(item.chefEmail)/Executive Items/\(item.signatureDishId)0.png").downloadURL { itemUrl, error in
                        
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
                    
                    cell.orderButtonTapped = {
                        if Auth.auth().currentUser!.displayName! == "Chef" {
                            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "PersonalChefOrderDetail") as? PersonalChefOrderDetailViewController  {
                                vc.personalChefInfo = PersonalChefInfo(chefName: item.chefName, chefEmail: item.chefEmail, chefImageId: item.chefImageId, chefImage: item.chefImage!, city: item.city, state: item.state, zipCode: item.zipCode, signatureDishImage: item.itemImage!, signatureDishId: "", option1Title: "", option2Title: "", option3Title: "", option4Title: "", briefIntroduction: item.itemDescription, howLongBeenAChef: "", specialty: "", whatHelpesYouExcel: "", mostPrizedAccomplishment: "", availabilty: "", hourlyOrPerSession: "", servicePrice: item.itemPrice, trialRun: 0, weeks: 0, months: 0, liked: item.liked, itemOrders: Int(exactly: item.itemOrders)!, itemRating: [0.0], expectations: item.expectations, chefRating: item.chefRating, quality: item.quality, documentId: item.documentId, openToMenuRequests: "")
                                self.present(vc, animated: true, completion: nil)
                            }
                        } else {
                            self.showToast(message: "Please create a user account to order.", font: .systemFont(ofSize: 12))
                        }}
                    
                    cell.chefImageButtonTapped = {
                        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileAsUser") as? ProfileAsUserViewController  {
                            vc.user = item.chefImageId
                            vc.chefOrUser = "chef"
                            self.present(vc, animated: true, completion: nil)
                        }
                    }
                    
                    cell.detailButtonTapped = {
                        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ItemDetail") as? ItemDetailViewController  {
                            print("detail happening")
                            vc.caterOrPersonal = "personal"
                            vc.personalChefInfo = PersonalChefInfo(chefName: item.chefName, chefEmail: item.chefEmail, chefImageId: item.chefImageId, chefImage: item.chefImage!, city: item.city, state: item.state, zipCode: item.zipCode, signatureDishImage: item.itemImage!, signatureDishId: "", option1Title: "", option2Title: "", option3Title: "", option4Title: "", briefIntroduction: "", howLongBeenAChef: "", specialty: "", whatHelpesYouExcel: "", mostPrizedAccomplishment: "", availabilty: "", hourlyOrPerSession: "", servicePrice: "", trialRun: 0, weeks: 0, months: 0, liked: [], itemOrders: 0, itemRating: [0.0], expectations: 0, chefRating: 0, quality: 0, documentId: "", openToMenuRequests: "")
                            self.present(vc, animated: true, completion: nil)
                        }
                    }
                    
                    cell.likeButtonTapped = {
                        self.db.collection("Executive Items").document(item.documentId).getDocument(completion: { document, error in
                            if error == nil {
                                if document != nil {
                                    let data = document!.data()
                                    
                                    let liked = data!["liked"] as? [String]
                                    let data1 : [String: Any] = ["chefEmail" : item.chefEmail, "chefPassion" : item.itemDescription, "chefUsername" : item.chefName, "profileImageId" : item.chefImageId, "menuItemId" : item.documentId, "itemTitle" : "Executive Chef", "itemDescription" : item.itemDescription, "itemPrice" : item.itemPrice, "liked" : liked!, "itemOrders" : item.itemOrders, "itemRating": item.itemRating, "imageCount" : 0, "itemType" : "Executive Item", "city" : item.city, "state" : item.state, "user" : item.chefImageId, "healthy" : 0, "creative" : 0, "vegan" : 0, "burger" : 0, "seafood" : 0, "pasta" : 0, "workout" : 0, "lowCal" : 0, "lowCarb" : 0, "expectations" : item.expectations, "chefRating" : item.chefRating, "quality" : item.quality]
                                    if (liked!.firstIndex(of: Auth.auth().currentUser!.email!) != nil) {
                                        self.db.collection("Executive Items").document(item.documentId).updateData(["liked" : FieldValue.arrayRemove(["\(Auth.auth().currentUser!.email!)"])])
                                        self.db.collection("User").document(Auth.auth().currentUser!.uid).collection("UserLikes").document(item.documentId).delete()
                                        
                                        cell.likeImage.image = UIImage(systemName: "heart")
                                        cell.chefLikes.text = "\(Int(cell.chefLikes.text!)! - 1)"
                                    } else {
                                        self.db.collection("Executive Items").document(item.documentId).updateData(["liked" : FieldValue.arrayUnion(["\(Auth.auth().currentUser!.email!)"])])
                                        self.db.collection("User").document(Auth.auth().currentUser!.uid).collection("UserLikes").document(item.documentId).setData(data1)
                                        
                                        cell.likeImage.image = UIImage(systemName: "heart.fill")
                                        cell.chefLikes.text = "\(Int(cell.chefLikes.text!)! + 1)"
                                    }
                                    
                                }
                            }
                        })
                        
                     
                        let date = Date()
                        let df = DateFormatter()
                        df.dateFormat = "MM-dd-yyyy hh:mm a"
                        let date1 =  df.string(from: Date())
                        let data3: [String: Any] = ["notification" : "\(guserName) has just liked your item (\(item.itemType)) \(item.itemTitle).", "date" : date1]
                        let data4: [String: Any] = ["notifications" : "yes"]
                        self.db.collection("Chef").document(item.chefImageId).collection("Notifications").document().setData(data3)
                        self.db.collection("Chef").document(item.chefImageId).updateData(data4)
                        
                    }
                    
                    
                    return cell
                }
                
            } else {
                
            var cell = itemTableView.dequeueReusableCell(withIdentifier: "UserReviewsReusableCell", for: indexPath) as! UserReviewsTableViewCell
                
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
}

extension ProfileAsUserViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return content.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = contentCollectionView.dequeueReusableCell(withReuseIdentifier: "ChefContentCollectionViewReusableCell", for: indexPath) as! ChefContentCollectionViewCell
        
        let content = content[indexPath.row]

        cell.viewText.text = "\(content.liked.count)"
            cell.configure(model: content)
    
        cell.videoViewButtonTapped = {
            var cont : [VideoModel] = []
            cont.append(content)
            print("indexpath.row \(indexPath.row)")
            for i in 0..<self.content.count {
                if content.id != self.content[i].id {
                    
                    cont.append(self.content[i])
                }
            }
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "Feed") as? FeedViewController  {
                vc.chefOrFeed = "user"
                vc.content = cont
                vc.index = indexPath.row
                self.present(vc, animated: true, completion: nil)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (contentCollectionView.frame.size.width / 3) - 3, height: (contentCollectionView.frame.size.height / 3) - 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
    
}

