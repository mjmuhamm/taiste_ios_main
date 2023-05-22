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
    
    
    var toggle = "Cater Items"
    
    private var cateringItems : [FeedMenuItems] = []
    private var personalChefItems : [FeedMenuItems] = []
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
        

        // Do any additional setup after loading the view.
    }
    
    private func loadUserInfo() {
        let storageRef = storage.reference()
        let image : UIImage?
        db.collection("User").document(user).collection("PersonalInfo").getDocuments { documents, error in
            if error == nil {
                if documents != nil {
                        for doc in documents!.documents {
                            let data = doc.data()

                        if let fullName = data["fullName"] as? String, let email = data["email"] as? String, let city = data["city"] as? String, let state = data["state"] as? String, let userName = data["userName"] as? String, let burger = data["burger"] as? Int, let creative = data["creative"] as? Int, let healthy = data["healthy"] as? Int, let lowCal = data["lowCal"] as? Int, let lowCarb = data["lowCarb"] as? Int, let pasta = data["pasta"] as? Int, let seafood = data["seafood"] as? Int, let workout = data["workout"] as? Int {

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

                        self.userName.text = "@\(userName)"
                        self.location.text = "Location: \(city), \(state)"
                        }
                        }

                }
            }
        }
    }


    private func loadUserOrders() {
        let storageRef = storage.reference()
        var chefImage = UIImage()
        var itemImage = UIImage()

        userOrders.removeAll()
        userChefs.removeAll()
        userLikes.removeAll()
        userReviews.removeAll()
        itemTableView.reloadData()
        itemTableView.register(UINib(nibName: "UserOrdersAndLikesTableViewCell", bundle: nil), forCellReuseIdentifier: "UserOrdersAndLikesReusableCell")

        if self.orders.isEmpty {
            db.collection("User").document(user).collection("Orders").getDocuments { documents, error in
            if documents != nil {
                for doc in documents!.documents {
                    let data = doc.data()

                    if let chefEmail = data["chefEmail"] as? String, let chefImageId = data["chefImageId"] as? String, let city = data["city"] as? String, let eventDates = data["eventDates"] as? [String], let itemTitle = data["itemTitle"] as? String, let itemDescription = data["itemDescription"] as? String, let menuItemId = data["menuItemId"] as? String, let orderDate = data["orderDate"] as? String, let orderUpdate = data["orderUpdate"] as? String, let totalCostOfEvent = data["totalCostOfEvent"] as? Double, let travelFee = data["travelFee"] as? String, let typeOfService = data["typeOfService"] as? String, let unitPrice = data["unitPrice"] as? String, let imageCount = data["imageCount"] as? Int, let itemCalories = data["itemCalories"] as? String, let state = data["state"] as? String{

                        self.db.collection("\(typeOfService)").document(menuItemId).getDocument { document, error in
                            if error == nil {
                                if document != nil {
                                    let data1 = document!.data()

                                    if let liked = data1!["liked"] as? [String], let itemOrders = data1!["itemOrders"] as? Int, let itemRating = data1!["itemRating"] {

                                let newItem = UserOrders(chefEmail: chefEmail, chefImageId: chefImageId, chefImage: chefImage, city: city, state: state, zipCode: "", eventDates: eventDates, itemTitle: itemTitle, itemDescription: itemDescription, itemPrice: unitPrice, menuItemId: menuItemId, itemImage: itemImage, orderDate: orderDate, orderUpdate: orderUpdate, totalCostOfEvent: totalCostOfEvent, travelFee: travelFee, typeOfService: typeOfService, imageCount: imageCount, liked: liked, itemOrders: itemOrders, itemRating: 0.0, itemCalories: Int(itemCalories)!, documentId: doc.documentID)

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
        let storageRef = storage.reference()
        userOrders.removeAll()
        userChefs.removeAll()
        userLikes.removeAll()
        userReviews.removeAll()
        itemTableView.reloadData()
        itemTableView.register(UINib(nibName: "UserChefsTableViewCell", bundle: nil), forCellReuseIdentifier: "UserChefsReusableCell")

        if self.chefs.isEmpty {
            db.collection("User").document(user).collection("UserLikes").getDocuments { documents, error in

            if error == nil {
                for doc in documents!.documents {
                    let data = doc.data()

                    if let chefEmail = data["chefEmail"] as? String, let chefImageId = data["profileImageId"] as? String, let chefName = data["chefUsername"] as? String, let chefPassion = data["chefPassion"] as? String{

                        print("chefs happening")


                        let liked : [String] = []
                        let newItem = UserChefs(chefEmail: chefEmail, chefImageId: chefImageId, chefImage: UIImage(), chefName: chefName, chefPassion: chefPassion, timesLiked: 0, chefLiked: liked, chefOrders: 0, chefRating: 0)

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
                }
            }
        }
        } else {
            self.userChefs = self.chefs
            self.itemTableView.reloadData()
            itemTableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        }
    }

    private func loadUserLikes() {
        let storageRef = storage.reference()
//        var chefImage = UIImage()
//        var itemImage = UIImage()

        userOrders.removeAll()
        userChefs.removeAll()
        userLikes.removeAll()
        userReviews.removeAll()
        itemTableView.reloadData()
        itemTableView.register(UINib(nibName: "UserOrdersAndLikesTableViewCell", bundle: nil), forCellReuseIdentifier: "UserOrdersAndLikesReusableCell")
        if self.likes.isEmpty {
            db.collection("User").document(user).collection("UserLikes").getDocuments { documents, error in
            if error == nil {
                if documents != nil {
                for doc in documents!.documents {
                    let data = doc.data()

                    if let chefEmail = data["chefEmail"] as? String, let chefImageId = data["profileImageId"] as? String, let imageCount = data["imageCount"] as? Int, let itemDescription = data["itemDescription"] as? String, let itemPrice = data["itemPrice"] as? String, let itemTitle = data["itemTitle"] as? String, let itemType = data["itemType"] as? String, let city = data["city"] as? String, let state = data["state"] as? String {
                        print("likes happening")

                        var liked : [String] = []
                        var itemOrders = 0
                        var itemRating = 0.0




                        self.db.collection(itemType).document(doc.documentID).getDocument { document, error in
                            if error == nil {
                                if document!.exists {
                                    let data1 = document?.data()

                                    if let likedI = data1!["liked"] as? [String], let itemOrdersI = data1!["itemOrders"] as? Int, let itemRating1 = data1!["itemRating"] as? Int {
                                        liked = likedI
                                        itemOrders = itemOrdersI


                                        let newItem = UserLikes(chefEmail: chefEmail, chefImageId: chefImageId, chefImage: UIImage(), itemType: itemType, city: city, state: state, zipCode: "", itemTitle: itemTitle, itemDescription: itemDescription, itemPrice: itemPrice, itemImage: UIImage(), imageCount: imageCount, liked: liked, itemOrders: itemOrders, itemRating: itemRating, itemCalories: 0, documentId: doc.documentID)

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
        let storageRef = storage.reference()
        itemTableView.register(UINib(nibName: "UserReviewsTableViewCell", bundle: nil), forCellReuseIdentifier: "UserReviewsReusableCell")

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
        
        
        var chefImage = UIImage()
        
       let storageRef = storage.reference()
        
        
        db.collection("Chef").document(user).collection("PersonalInfo").getDocuments { documents, error in
            if error == nil {
                for doc in documents!.documents {
                    let data = doc.data()
                    
                    if let chefPassion = data["chefPassion"] as? String, let city = data["city"] as? String, let education = data["education"] as? String, let fullName = data["fullName"] as? String, let state = data["state"] as? String, let username = data["chefName"] as? String, let email = data["email"] as? String {
                        
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
        let storageRef = storage.reference()
        
        if toggle == "Cater Items" {
            itemsI = cateringItems
        } else if toggle == "Executive Items" {
            itemsI = personalChefItems
        } else {
           itemsI = mealKitItems
        }
        if itemsI.isEmpty {
        
            db.collection("Chef").document(user).collection(toggle).getDocuments { documents, error in
            if error == nil {
                for doc in documents!.documents {
                    
                    let data = doc.data()
                    
                    if let chefEmail = data["chefEmail"] as? String, let chefPassion = data["chefPassion"] as? String, let chefUsername = data["chefUsername"] as? String, let profileImageId = data["profileImageId"] as? String, let menuItemId = data["randomVariable"] as? String, let itemTitle = data["itemTitle"] as? String, let itemDescription = data["itemDescription"] as? String, let itemPrice = data["itemPrice"] as? String, let date = data["date"], let imageCount = data["imageCount"] as? Int, let itemType = data["itemType"] as? String, let city = data["city"] as? String, let state = data["state"] as? String, let zipCode = data["zipCode"] as? String, let user = data["user"] as? String, let healthy = data["healthy"] as? Int, let creative = data["creative"] as? Int, let vegan = data["vegan"] as? Int, let burger = data["burger"] as? Int, let seafood = data["seafood"] as? Int, let pasta = data["pasta"] as? Int, let workout = data["workout"] as? Int, let lowCal = data["lowCal"] as? Int, let lowCarb = data["lowCarb"] as? Int {
                        
                        
                        
                        self.db.collection("\(itemType)").document(menuItemId).getDocument { document, error in
                            if error == nil {
                                if document != nil {
                                    let data = document!.data()
                                    
                                    if let liked = data!["liked"] as? [String], let itemOrders = data!["itemOrders"] as? Int, let itemRating = data!["itemRating"] {
                              
                              
                                        let newItem = FeedMenuItems(chefEmail: chefEmail, chefPassion: chefPassion, chefUsername: chefUsername, chefImageId: profileImageId, chefImage: UIImage(), menuItemId: menuItemId, itemImage: UIImage(), itemTitle: itemTitle, itemDescription: itemDescription, itemPrice: itemPrice, liked: liked, itemOrders: itemOrders, itemRating: 0.0, date: "\(date)", imageCount: imageCount, itemCalories: "0", itemType: itemType, city: city, state: state, zipCode: zipCode, user: user, healthy: healthy, creative: creative, vegan: vegan, burger: burger, seafood: seafood, pasta: pasta, workout: workout, lowCal: lowCal, lowCarb: lowCarb)
                                        
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
                                        } else if self.toggle == "Executive Items" {
                                            if self.personalChefItems.isEmpty {
                                                self.personalChefItems.append(newItem)
                                                self.items = self.personalChefItems
                                                self.itemTableView.insertRows(at: [IndexPath(item: 0, section: 0)], with: .fade)
                                            } else {
                                                let index = self.personalChefItems.firstIndex { $0.menuItemId == menuItemId }
                                                if index == nil {
                                                    self.personalChefItems.append(newItem)
                                                    self.items = self.personalChefItems
                                                    self.itemTableView.insertRows(at: [IndexPath(item: self.personalChefItems.count - 1, section: 0)], with: .fade)
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
            } else if self.toggle == "Executive Items" {
                self.items = self.personalChefItems
            } else {
                self.items = self.mealKitItems
            }
            
            self.itemTableView.reloadData()
            if self.itemTableView.numberOfRows(inSection: 0) != 0 {
                self.itemTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }}
    }
    
    private var createdAt = 0
    private func loadContent() {
        let json: [String: Any] = ["created_at": "\(createdAt)"]
        
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        // MARK: Fetch the Intent client secret, Ephemeral Key secret, Customer ID, and publishable key
        var request = URLRequest(url: URL(string: "https://ruh-video.herokuapp.com/get-videos")!)
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
        loadChefItems()
        contentCollectionView.isHidden = true
        itemTableView.isHidden = false
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
    
    
}

extension ProfileAsUserViewController :  UITableViewDelegate, UITableViewDataSource  {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if chefOrUser == "chef" {
            return items.count
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
            cell.ratingText.text = "\(item.itemRating)"
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
                    self.present(vc, animated: true, completion: nil)
                }
            }
            
            cell.orderButtonTapped = {
                self.item = item
                self.performSegue(withIdentifier: "ProfileAsUserToOrderDetailsSegue", sender: self)
            }
            
            cell.likeImageButtonTapped = {
                self.db.collection("\(item.itemType)").document(item.menuItemId).getDocument(completion: { document, error in
                    if error == nil {
                        if document != nil {
                            let data = document!.data()
                            
                            let liked = data!["liked"] as? [String]
                            let data1 : [String: Any] = ["chefEmail" : item.chefEmail, "chefPassion" : item.chefPassion, "chefUsername" : item.chefUsername, "profileImageId" : item.chefImageId, "menuItemId" : item.menuItemId, "itemTitle" : item.itemTitle, "itemDescription" : item.itemDescription, "itemPrice" : item.itemPrice, "liked" : liked, "itemOrders" : item.itemOrders, "itemRating": item.itemRating, "imageCount" : item.imageCount, "itemType" : item.itemType, "city" : item.city, "state" : item.state, "user" : item.user, "healthy" : item.healthy, "creative" : item.creative, "vegan" : item.vegan, "burger" : item.burger, "seafood" : item.seafood, "pasta" : item.pasta, "workout" : item.workout, "lowCal" : item.lowCal, "lowCarb" : item.lowCarb]
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
                
            }
            
            return cell
        } else {
            if toggle == "Orders" {
                
            var cell = itemTableView.dequeueReusableCell(withIdentifier: "UserOrdersAndLikesReusableCell", for: indexPath) as! UserOrdersAndLikesTableViewCell
            
            var order = userOrders[indexPath.row]
                
                cell.itemTitle.text = order.itemTitle
                cell.itemDescription.text = order.itemDescription
                cell.likeText.text = "\(order.liked.count)"
                cell.orderText.text = "\(order.itemOrders)"
                cell.itemPrice.text = "$\(order.itemPrice)"
                cell.ratingText.text = "\(order.itemRating)"
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
                                self.present(vc, animated: true, completion: nil)
                                
                            }}
                        
                    
                
                
            return cell
                
            } else if toggle == "Chefs" {
                
            var cell = itemTableView.dequeueReusableCell(withIdentifier: "UserChefsReusableCell", for: indexPath) as! UserChefsTableViewCell
                
                let item = userChefs[indexPath.row]
                
                cell.chefPassion.text = item.chefPassion
                cell.likeText.text = "\(item.chefLiked.count)"
                cell.orderText.text = "\(item.chefOrders)"
                cell.ratingText.text = "\(item.chefRating)"
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
                
            var cell = itemTableView.dequeueReusableCell(withIdentifier: "UserOrdersAndLikesReusableCell", for: indexPath) as! UserOrdersAndLikesTableViewCell
                
                let item = userLikes[indexPath.row]
                
                cell.itemTitle.text = item.itemTitle
                cell.itemDescription.text = item.itemDescription
                cell.itemPrice.text = "$\(item.itemPrice)"
                cell.likeText.text = "\(item.liked.count)"
                cell.orderText.text = "\(item.itemOrders)"
                cell.ratingText.text = "\(item.itemRating)"
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
       
            cell.configure(model: content)
        
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
