//

//
//  ChefMeViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 2/23/22.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import MaterialComponents.MaterialButtons
import MaterialComponents

var gChefName = ""
class ChefMeViewController: UIViewController {
 
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
//    private let chef = Auth.auth().currentUser!.e
    
    @IBOutlet weak var noItemsText: UILabel!
    @IBOutlet weak var educationText: UILabel!
    @IBOutlet weak var chefPassion: UILabel!
    @IBOutlet weak var location: UILabel!
    
    @IBOutlet weak var cateringButton: MDCButton!
    @IBOutlet weak var personalChefButton: MDCButton!
    @IBOutlet weak var mealKitButton: MDCButton!
    @IBOutlet weak var contentButton: MDCButton!
    @IBOutlet weak var bankingButton: MDCButton!
    @IBOutlet weak var addContentButton: MDCButton!
    
    @IBOutlet weak var comingSoon: UILabel!
    
    @IBOutlet weak var chefName: UILabel!
    @IBOutlet weak var chefImage: UIImageView!
    
    @IBOutlet weak var meTableView: UITableView!
    @IBOutlet weak var bankingView: UIView!
    
    @IBOutlet weak var contentCollectionView: UICollectionView!
    
    //Banking
    @IBOutlet weak var cardPaymentsX: UIImageView!
    @IBOutlet weak var cardPaymentsWarning: UIImageView!
    @IBOutlet weak var cardPaymentsGreen: UIImageView!
    
    @IBOutlet weak var transfersX: UIImageView!
    @IBOutlet weak var transfersWarning: UIImageView!
    @IBOutlet weak var transfersGreen: UIImageView!
    
    @IBOutlet weak var statusUpdateInfoLabel: UILabel!
    @IBOutlet weak var pendingAmountLabel: UILabel!
    @IBOutlet weak var availableAmountLabel: UILabel!
    
    @IBOutlet weak var accountNumberLabel: UILabel!
    @IBOutlet weak var editAccountInfoButton: UIButton!
    
    private var stripeAccountId = ""
    
    //
    
    private var toggle = "Cater Items"
    private var content : [VideoModel] = []
    
    private var cateringItems : [FeedMenuItems] = []
    private var personalChefItems : [FeedMenuItems] = []
    private var mealKitItems : [FeedMenuItems] = []
    
    private var items: [FeedMenuItems] = []
    
    private var city = ""
    private var state = ""
    private var zipCode = ""
    private var latitude = ""
    private var longitude = ""
    private var profileImageId = ""
    private var menuItemId = UUID().uuidString
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chefImage.layer.borderWidth = 1
        chefImage.layer.masksToBounds = false
        chefImage.layer.borderColor = UIColor.white.cgColor
        chefImage.layer.cornerRadius = chefImage.frame.height/2
        chefImage.clipsToBounds = true
        
        meTableView.register(UINib(nibName: "ChefItemTableViewCell", bundle: nil), forCellReuseIdentifier: "ChefItemReusableCell")
        meTableView.delegate = self
        meTableView.dataSource = self
        
        
        contentCollectionView.register(UINib(nibName: "ChefContentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ChefContentCollectionViewReusableCell")
        contentCollectionView.delegate = self
        contentCollectionView.dataSource = self
        
        loadChefInfo()
        loadItems()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.tintColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
        self.tabBarController?.tabBar.barTintColor = UIColor.white
    }
    
    private func loadChefInfo() {
        let storageRef = storage.reference()
        db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("PersonalInfo").getDocuments { documents, error in
            if error == nil {
                for doc in documents!.documents {
                    let data = doc.data()
                    
                    if let chefPassion = data["chefPassion"] as? String, let city = data["city"] as? String, let education = data["education"] as? String, let fullName = data["fullName"] as? String, let state = data["state"] as? String, let username = data["chefName"] as? String, let zipCode = data["zipCode"] as? String {
                        
                        print("email \(Auth.auth().currentUser!.email!)")
                        print("uid \(Auth.auth().currentUser!.uid)")
                        
                        storageRef.child("chefs/\(Auth.auth().currentUser!.email!)/profileImage/\(Auth.auth().currentUser!.uid).png").downloadURL { itemUrl, error in
                            
                            URLSession.shared.dataTask(with: itemUrl!) { (data, response, error) in
                                // Error handling...
                                guard let imageData = data else { return }
                                
                                print("happening itemdata")
                                DispatchQueue.main.async {
                                    self.chefImage.image = UIImage(data: imageData)!
                                }
                            }.resume()
                        }
                        
                        self.educationText.text = "Education: \(education)"
                        self.chefPassion.text = chefPassion
                        self.location.text = "Location: \(city), \(state)"
                        self.chefName.text = "@\(username)"
                        gChefName = username
                        self.city = city
                        self.state = state
                        self.zipCode = zipCode
                        self.profileImageId = Auth.auth().currentUser!.uid
                        
                    }
                }
            }
        }
    }
    
    private func loadItems() {
        let storageRef = storage.reference()
        if !items.isEmpty {
            items.removeAll()
            meTableView.reloadData()
        }
      
        
        var itemsI : [FeedMenuItems]
        
        if toggle == "Cater Items" {
            itemsI = cateringItems
        } else if toggle == "Executive Items" {
            itemsI = personalChefItems
        } else {
           itemsI = mealKitItems
        }
        if itemsI.isEmpty {
        
            db.collection("Chef").document(Auth.auth().currentUser!.uid).collection(toggle).addSnapshotListener { documents, error in
            if error == nil {
                for doc in documents!.documents {
                    
                    let data = doc.data()
                    
                    if let chefEmail = data["chefEmail"] as? String, let chefPassion = data["chefPassion"] as? String, let chefUsername = data["chefUsername"] as? String, let profileImageId = data["profileImageId"] as? String, let menuItemId = data["randomVariable"] as? String, let itemTitle = data["itemTitle"] as? String, let itemDescription = data["itemDescription"] as? String, let itemPrice = data["itemPrice"] as? String, let liked = data["liked"] as? [String], let itemOrders = data["itemOrders"] as? Int, let itemRating = data["itemRating"], let date = data["date"], let imageCount = data["imageCount"] as? Int, let itemType = data["itemType"] as? String, let city = data["city"] as? String, let state = data["state"] as? String, let zipCode = data["zipCode"] as? String, let user = data["user"] as? String, let healthy = data["healthy"] as? Int, let creative = data["creative"] as? Int, let vegan = data["vegan"] as? Int, let burger = data["burger"] as? Int, let seafood = data["seafood"] as? Int, let pasta = data["pasta"] as? Int, let workout = data["workout"] as? Int, let lowCal = data["lowCal"] as? Int, let lowCarb = data["lowCarb"] as? Int {
                        
                            var image = UIImage()
                        
                        storageRef.child("chefs/\(Auth.auth().currentUser!.email!)/\(self.toggle)/\(menuItemId)0.png").getData(maxSize: 15 * 1024 * 1024) { data, error in
                            
                            if error == nil {
                                
                                image = UIImage(data: data!)!
                            } else {
                                print("error \(error?.localizedDescription)")
                                print("error \(error)")
                            }
                                        
                                        let newItem = FeedMenuItems(chefEmail: chefEmail, chefPassion: chefPassion, chefUsername: chefUsername, chefImageId: profileImageId, chefImage: image, menuItemId: menuItemId, itemImage: image, itemTitle: itemTitle, itemDescription: itemDescription, itemPrice: itemPrice, liked: liked, itemOrders: itemOrders, itemRating: 0.0, date: "\(date)", imageCount: imageCount, itemCalories: "0", itemType: itemType, city: city, state: state, zipCode: zipCode, user: user, healthy: healthy, creative: creative, vegan: vegan, burger: burger, seafood: seafood, pasta: pasta, workout: workout, lowCal: lowCal, lowCarb: lowCarb)
                                        
                                        if self.toggle == "Cater Items" {
                                            if self.cateringItems.isEmpty {
                                                self.cateringItems.append(newItem)
                                                self.items = self.cateringItems
                                                self.meTableView.insertRows(at: [IndexPath(item: 0, section: 0)], with: .fade)
                                            } else {
                                                let index = self.cateringItems.firstIndex { $0.menuItemId == menuItemId }
                                                if index == nil {
                                                    self.cateringItems.append(newItem)
                                                    self.items = self.cateringItems
                                                    self.meTableView.insertRows(at: [IndexPath(item: self.cateringItems.count - 1, section: 0)], with: .fade)
                                                }
                                            }
                                        } else if self.toggle == "Executive Items" {
                                            if self.personalChefItems.isEmpty {
                                                self.personalChefItems.append(newItem)
                                                self.items = self.personalChefItems
                                                self.meTableView.insertRows(at: [IndexPath(item: 0, section: 0)], with: .fade)
                                            } else {
                                                let index = self.personalChefItems.firstIndex { $0.menuItemId == menuItemId }
                                                if index == nil {
                                                    self.personalChefItems.append(newItem)
                                                    self.items = self.personalChefItems
                                                    self.meTableView.insertRows(at: [IndexPath(item: self.personalChefItems.count - 1, section: 0)], with: .fade)
                                                }
                                            }
                                        } else if self.toggle == "MealKit Items" {
                                            if self.mealKitItems.isEmpty {
                                                self.mealKitItems.append(newItem)
                                                self.items = self.mealKitItems
                                                self.meTableView.insertRows(at: [IndexPath(item: 0, section: 0)], with: .fade)
                                            } else {
                                                let index = self.mealKitItems.firstIndex { $0.menuItemId == menuItemId }
                                                if index == nil {
                                                    self.mealKitItems.append(newItem)
                                                    self.items = self.mealKitItems
                                                    self.meTableView.insertRows(at: [IndexPath(item: self.mealKitItems.count - 1, section: 0)], with: .fade)
                                                }
                                            }
                                        }
                                                            
                    }
                        }
                    
                
                }
            }
        }
        } else {
            
            if toggle == "Cater Items" {
                items = cateringItems
            } else if toggle == "Executive Items" {
                items = personalChefItems
            } else {
               items = mealKitItems
            }
            
            meTableView.reloadData()
            
        }
    }
    private var createdAt = 0
    private func loadContent() {
        let json: [String: Any] = ["name": "\(Auth.auth().currentUser!.email!)"]
        
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        // MARK: Fetch the Intent client secret, Ephemeral Key secret, Customer ID, and publishable key
        var request = URLRequest(url: URL(string: "https://ruh-video.herokuapp.com/get-user-videos")!)
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
            
            if videos.count == 0 {
                
            } else {
                for i in 0..<videos.count {
          DispatchQueue.main.async {
              
              
                      let id = videos[i]["id"]!
                      let createdAtI = videos[i]["createdAt"]!
                      if i == videos.count - 1 {
                          self.createdAt = createdAtI as! Int
                      }
                      var views = 0
                      var liked : [String] = []
                      var comments = 0
                      var shared = 0
                      print("videos count \(videos.count)")
                      let data : [String : Any] = ["views" : 0, "liked" : [], "shared" : 0, "comments" : 0]
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
                       
                          
                          let newVideo = VideoModel(dataUri: videos[i]["dataUrl"]! as! String, id: videos[i]["id"]! as! String, videoDate: String(createdAtI as! Int), user: videos[i]["name"]! as! String, description: videos[i]["description"]! as! String, views: views, liked: liked, comments: comments, shared: shared, thumbNailUrl: videos[i]["thumbnailUrl"]! as! String)
                          
                          if self.content.isEmpty {
                              self.content.append(newVideo)
//                              self.contentCollectionView.insertItems(at: <#T##[IndexPath]#>)
                              self.contentCollectionView.reloadData()
//                              let newIndexPath = IndexPath(item: self.content.count - 1, section: 0)
//                              self.contentCollectionView.insertItems(at: [newIndexPath])
                              
                          } else {
                              let index = self.content.firstIndex { $0.id == id as! String }
                              if index == nil {
                                  self.content.append(newVideo)
                                  
                                  let newIndexPath = IndexPath(item: self.content.count - 1, section: 0)
//                                  self.contentCollectionView.insertItems(at: [newIndexPath])
                                  self.contentCollectionView.reloadData()
                              }
                          }
                      if i == videos.count - 1 {
//                          self.contentCollectionView.reloadData()
                      }
                      print("done")
                      
                  }
              }
              }
                          }
        })
        task.resume()
    }
    
    private func loadBankingInfo() {
        db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("BankingInfo").getDocuments { documents, error in
            if error == nil {
                if documents != nil {
                    for doc in documents!.documents {
                        let data = doc.data()
                        print("id \(doc.documentID)")
                            
                            if let accountType = data["accountType"] as? String, let externalAccountId = data["externalAccountId"] as? String, let id = data["stripeAccountId"] as? String {
                                
                                self.stripeAccountId = id
                                if accountType == "Individual" {
                                    self.retrieveIndividualAccount(stripeAccountId: id)
                                    self.retrieveExternalAccount(stripeAccountId: id, externalAccountId: externalAccountId)
                                } else {
                                    self.retrieveBusinessAccount(stripeAccountId: id)
                                    self.retrieveExternalAccount(stripeAccountId: id, externalAccountId: externalAccountId)
                                }
                                
                            }
                        }
                }
            }
        }
    }
    
    private func retrieveIndividualAccount(stripeAccountId: String) {
            let json: [String: Any] = ["stripeAccountId": "\(stripeAccountId)"]
            
        
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            // MARK: Fetch the Intent client secret, Ephemeral Key secret, Customer ID, and publishable key
            var request = URLRequest(url: URL(string: "https://ruh.herokuapp.com/retrieve-individual-account")!)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = jsonData
            let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
              guard let data = data,
                    let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                    let cardPayments = json["card_payments"],
                    let transfers = json["transfers"],
                    let currentlyDue = json["currently_due"],
                    let eventuallyDue = json["eventually_due"],
                    let current_deadline = json["current_deadline"],
                    let available = json["available"] as? Int,
                    let pending = json["pending"] as? Int,
                    let self = self else {
                // Handle error
                return
              }
                
              DispatchQueue.main.async {
                  if "\(cardPayments)" == "active" {
                      self.cardPaymentsGreen.isHidden = false
                  } else {
                      self.cardPaymentsWarning.isHidden = false
                  }
                  
                  if "\(transfers)" == "active" {
                      self.transfersGreen.isHidden = false
                  } else {
                      self.transfersWarning.isHidden = false
                  }
                  if "\(cardPayments)" != "active" || "\(transfers)" != "active" {
                      self.statusUpdateInfoLabel.text = "\(currentlyDue); \(eventuallyDue); \(current_deadline)"
                  }
                  
                  self.availableAmountLabel.text = "$\(String(format: "%.2f", Double(available / 100)))"
                  self.pendingAmountLabel.text = "$\(String(format: "%.2f", Double(pending / 100)))"
                  
                  
                  print("card_payments \(cardPayments)")
                  print("currentlyDue \(currentlyDue)")
                  print("eventuallyDue \(eventuallyDue)")
                  print("currentDeadline \(current_deadline)")
                  print("transfers \(transfers)")
                  print("available \(available)")
                  print("pending \(pending)")
                  }
            })
            task.resume()
        }
    
    private func retrieveBusinessAccount(stripeAccountId: String) {
            let json: [String: Any] = ["stripeAccountId": "\(stripeAccountId)"]
            
        
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            // MARK: Fetch the Intent client secret, Ephemeral Key secret, Customer ID, and publishable key
            var request = URLRequest(url: URL(string: "https://ruh.herokuapp.com/retrieve-business-account")!)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = jsonData
            let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
              guard let data = data,
                    let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                    let cardPayments = json["card_payments"],
                    let transfers = json["transfers"],
                    let currentlyDue = json["currently_due"],
                    let eventuallyDue = json["eventually_due"],
                    let current_deadline = json["current_deadline"],
                    let available = json["available"] as? Int,
                    let pending = json["pending"] as? Int,
                    let self = self else {
                // Handle error
                return
              }
                
              DispatchQueue.main.async {
                  
                      print("happening \(pending)")
                  if "\(cardPayments)" == "active" {
                      self.cardPaymentsGreen.isHidden = false
                  } else {
                      self.cardPaymentsWarning.isHidden = false
                  }
                  
                  if "\(transfers)" == "active" {
                      self.transfersGreen.isHidden = false
                  } else {
                      self.transfersWarning.isHidden = false
                  }
                  if "\(cardPayments)" != "active" || "\(transfers)" != "active" {
                      self.statusUpdateInfoLabel.text = "\(currentlyDue); \(eventuallyDue); \(current_deadline)"
                  }
                  
                  self.availableAmountLabel.text = "$\(String(format: "%.2f", available / 100))"
                  self.pendingAmountLabel.text = "$\(String(format: "%.2f", pending / 100))"
                  
                  
                  print("card_payments \(cardPayments)")
                  print("currentlyDue \(currentlyDue)")
                  print("eventuallyDue \(eventuallyDue)")
                  print("currentDeadline \(current_deadline)")
                  print("transfers \(transfers)")
                  print("available \(available)")
                  print("pending \(pending)")
                 
              }
            })
            task.resume()
        }
    
    private func retrieveExternalAccount(stripeAccountId: String, externalAccountId: String) {
        let json: [String: Any] = ["stripeAccountId": "\(stripeAccountId)", "externalAccountId" : "\(externalAccountId)"]
        
    
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        // MARK: Fetch the Intent client secret, Ephemeral Key secret, Customer ID, and publishable key
        var request = URLRequest(url: URL(string: "https://ruh.herokuapp.com/retrieve-external-account")!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
          guard let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                let accountNumber = json["account_number"],
                let self = self else {
            // Handle error
            return
          }
            
          DispatchQueue.main.async {
              self.accountNumberLabel.text = "****\(accountNumber)"
              }
        })
        task.resume()
    }
    
    @IBAction func cateringButtonPressed(_ sender: Any) {
        toggle = "Cater Items"
        loadItems()
        contentCollectionView.isHidden = true
        meTableView.isHidden = false
        bankingView.isHidden = true
        comingSoon.isHidden = true
        cateringButton.setTitleColor(UIColor.white, for:.normal)
        cateringButton.backgroundColor = UIColor(red:160/255, green: 162/255, blue: 104/255,alpha: 1)
        personalChefButton.backgroundColor = UIColor.white
        personalChefButton.setTitleColor(UIColor(red:98/255, green: 99/255, blue: 72/255, alpha:1), for: .normal)
        mealKitButton.backgroundColor = UIColor.white
        mealKitButton.setTitleColor(UIColor(red: 98/255,green: 99/255, blue: 72/255, alpha: 1), for:.normal)
        contentButton.backgroundColor = UIColor.white
        contentButton.setTitleColor(UIColor(red: 98/255,green: 99/255, blue: 72/255, alpha: 1), for:.normal)
        bankingButton.backgroundColor = UIColor.white
        bankingButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
    }
    
    @IBAction func personalChefButtonPressed(_ sender: Any) {
        toggle = "Executive Items"
        loadItems()
        contentCollectionView.isHidden = true
        meTableView.isHidden = false
        bankingView.isHidden = true
        comingSoon.isHidden = true
        cateringButton.backgroundColor = UIColor.white
        cateringButton.setTitleColor(UIColor(red: 98/255,green: 99/255, blue: 72/255, alpha: 1), for:.normal)
        personalChefButton.setTitleColor(UIColor.white,for: .normal)
        personalChefButton.backgroundColor = UIColor(red:160/255, green: 162/255, blue: 104/255,alpha: 1)
        mealKitButton.backgroundColor = UIColor.white
        mealKitButton.setTitleColor(UIColor(red: 98/255,green: 99/255, blue: 72/255, alpha: 1), for:.normal)
        contentButton.backgroundColor = UIColor.white
        contentButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        bankingButton.backgroundColor = UIColor.white
        bankingButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
    }
    
    @IBAction func mealKitButtonPressed(_ sender: Any) {
        toggle = "MealKit Items"
//        loadItems()
        comingSoon.isHidden = false
        contentCollectionView.isHidden = true
        meTableView.isHidden = false
        bankingView.isHidden = true
        
        cateringButton.backgroundColor = UIColor.white
        cateringButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        personalChefButton.backgroundColor = UIColor.white
        personalChefButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        mealKitButton.setTitleColor(UIColor.white, for: .normal)
        mealKitButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
        contentButton.backgroundColor = UIColor.white
        contentButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        bankingButton.backgroundColor = UIColor.white
        bankingButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
    }
    
    @IBAction func contentButtonPressed(_ sender: Any) {
        toggle = "Content"
        loadContent()
        contentCollectionView.isHidden = false
        meTableView.isHidden = true
        bankingView.isHidden = true
        comingSoon.isHidden = true
        cateringButton.backgroundColor = UIColor.white
        cateringButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        personalChefButton.backgroundColor = UIColor.white
        personalChefButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        mealKitButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        mealKitButton.backgroundColor = UIColor.white
        contentButton.setTitleColor(UIColor.white, for: .normal)
        contentButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
        bankingButton.backgroundColor = UIColor.white
        bankingButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
    }
    
    
    @IBAction func bankingButtonPressed(_ sender: MDCButton) {
        toggle = "Banking"
        contentCollectionView.isHidden = true
        meTableView.isHidden = true
        bankingView.isHidden = false
        comingSoon.isHidden = true
        loadBankingInfo()
        
        cateringButton.backgroundColor = UIColor.white
        cateringButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        personalChefButton.backgroundColor = UIColor.white
        personalChefButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        mealKitButton.backgroundColor = UIColor.white
        mealKitButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        contentButton.backgroundColor = UIColor.white
        contentButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        bankingButton.setTitleColor(UIColor.white, for: .normal)
        bankingButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
       
    }
    
    @IBAction func addContentButtonPressed(_ sender: MDCButton) {
        if toggle != "Content" && toggle != "MealKit Items" {
        performSegue(withIdentifier: "ChefMeToMenuItemSegue", sender: self)
        } else {
            performSegue(withIdentifier: "ChefMeToContentSegue", sender: self)
        }
    }
    
    @IBAction func editAccountInfoButtonPressed(_ sender: UIButton) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if segue.identifier == "ChefMeToMenuItemSegue" {
            let info = segue.destination as! MenuItemViewController
            if toggle == "Banking" {
                toggle = "Cater Items"
            }
            info.typeOfitem = toggle
            info.chefPassion = chefPassion.text!
            info.chefUsername = chefName.text!
            info.city = self.city
            info.state = self.state
            info.latitude = self.latitude
            info.longitude = self.longitude
            info.profileImageId = self.profileImageId
            info.zipCode = self.zipCode
        }
    }
    
    
    
    
}


extension ChefMeViewController :  UITableViewDelegate, UITableViewDataSource  {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = meTableView.dequeueReusableCell(withIdentifier: "ChefItemReusableCell", for: indexPath) as! ChefItemTableViewCell
        var item = items[indexPath.row]
        cell.editImage.isHidden = true
        
        var vari = self.toggle
        if items.count == 0 {
            if self.toggle == "Executive Items" {
                vari = "Personal Chef Items"
            }
            self.noItemsText.text = "There are no \(vari) yet."
            self.noItemsText.isHidden = false
        } else {
            self.noItemsText.isHidden = true
        }
        print("vari \(vari)")
        
        if toggle != "Content" {
            let storageRef = storage.reference()
            storageRef.child("chefs/\(Auth.auth().currentUser!.email!)/\(vari)/\(item.menuItemId)0.png").downloadURL { itemUrl, error in
                
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
        cell.itemTitle.text = item.itemTitle
        cell.itemDescription.text = item.itemDescription
        cell.itemPrice.text = "$\(item.itemPrice)"
        cell.likeText.text = "\(item.liked.count)"
        cell.orderText.text = "\(item.itemOrders)"
        cell.ratingText.text = "\(item.itemRating)"
        cell.editImage.isHidden = false
        
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
                self.present(vc, animated: true, completion: nil)
            }
        }
        
        cell.editButtonTapped = {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "MenuItem") as? MenuItemViewController {
                vc.newOrEdit = "edit"
                vc.typeOfitem = self.toggle
                vc.chefPassion = self.chefPassion.text!
                vc.chefUsername = self.chefName.text!
                vc.city = self.city
                vc.state = self.state
                vc.latitude = self.latitude
                vc.longitude = self.longitude
                vc.profileImageId = self.profileImageId
                vc.menuItemId = item.menuItemId
                vc.zipCode = self.zipCode
                self.present(vc, animated: true, completion: nil)
            }
        }
        
        return cell
    }
    
}

extension ChefMeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
