//
//  HomeViewController.swift
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

class HomeViewController: UIViewController {
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private let user = "malik@testing.com"
    
    @IBOutlet weak var cateringButton: MDCButton!
    @IBOutlet weak var personalChefButton: MDCButton!
    @IBOutlet weak var mealKitButton: MDCButton!
    
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var checkoutButton: UIButton!
    
    @IBOutlet weak var homeTableView: UITableView!
    @IBOutlet weak var foodTotal: UILabel!
    
    private var cateringItems : [FeedMenuItems] = []
    private var personalChefItems: [FeedMenuItems] = []
    private var mealKitItems : [FeedMenuItems] = []
    
    private var items : [FeedMenuItems] = []
    
    private var cart : [String] = []
    private var totalPrice = 0.0
    
    private var toggle = "Cater Items"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homeTableView.delegate = self
        homeTableView.dataSource = self
        
        homeTableView.register(UINib(nibName: "HomeTableViewCell", bundle: nil), forCellReuseIdentifier: "HomeReusableCell")
        

        loadCart()
        loadItems()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.tintColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
        self.tabBarController?.tabBar.barTintColor = UIColor.white
    }
    
    private func loadCart() {
        db.collection("User").document(Auth.auth().currentUser!.uid).collection("Cart").getDocuments { documents, error in
            if error == nil {
                for doc in documents!.documents {
                    let data = doc.data()
                    
                    if let totalCostOfEvent = data["totalCostOfEvent"] as? Double {
                        
                        if self.cart.count == 0 {
                            self.cart.append(doc.documentID)
                            self.totalPrice += totalCostOfEvent
                            let num = String(format: "%.2f", self.totalPrice)
                            self.foodTotal.text = "$\(num)"
                        } else {
                            let index = self.cart.firstIndex { $0 == doc.documentID}
                            if index == nil {
                                self.cart.append(doc.documentID)
                                self.totalPrice += totalCostOfEvent
                                let num = String(format: "%.2f", self.totalPrice)
                                self.foodTotal.text = "$\(num)"
                            }
                            
                        }
                    }
                }
            }
        }
    }
    
    
    
    private func loadItems() {
        let storageRef = storage.reference()
        if !items.isEmpty {
            items.removeAll()
            homeTableView.reloadData()
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
        
        db.collection(toggle).getDocuments { documents, error in
            if error == nil {
                for doc in documents!.documents {
                    
                    let data = doc.data()
                    
                    if let chefEmail = data["chefEmail"] as? String, let chefPassion = data["chefPassion"] as? String, let chefUsername = data["chefUsername"] as? String, let profileImageId = data["profileImageId"] as? String, let menuItemId = data["randomVariable"] as? String, let itemTitle = data["itemTitle"] as? String, let itemDescription = data["itemDescription"] as? String, let itemPrice = data["itemPrice"] as? String, let liked = data["liked"] as? [String], let itemOrders = data["itemOrders"] as? Int, let itemRating = data["itemRating"], let date = data["date"], let imageCount = data["imageCount"] as? Int, let itemType = data["itemType"] as? String, let city = data["city"] as? String, let state = data["state"] as? String, let zipCode = data["zipCode"] as? String, let user = data["user"] as? String, let healthy = data["healthy"] as? Int, let creative = data["creative"] as? Int, let vegan = data["vegan"] as? Int, let burger = data["burger"] as? Int, let seafood = data["seafood"] as? Int, let pasta = data["pasta"] as? Int, let workout = data["workout"] as? Int, let lowCal = data["lowCal"] as? Int, let lowCarb = data["lowCarb"] as? Int {
                        
                            
                        storageRef.child("chefs/\(chefEmail)/profileImage/\(profileImageId).png").getData(maxSize: 15 * 1024 * 1024) { data, error in
                        
                            if error != nil {
                                print("error \(error)")
                            }
                              let chefImage = UIImage(data: data!)!
                            
                            
                        storageRef.child("chefs/\(chefEmail)/\(self.toggle)/\(menuItemId)0.png").getData(maxSize: 15 * 1024 * 1024) { data1, error in
                            
                               let image = UIImage(data: data1!)!
                            
                            
                                        let newItem = FeedMenuItems(chefEmail: chefEmail, chefPassion: chefPassion, chefUsername: chefUsername, chefImageId: profileImageId, chefImage: chefImage, menuItemId: menuItemId, itemImage: image, itemTitle: itemTitle, itemDescription: itemDescription, itemPrice: itemPrice, liked: liked, itemOrders: itemOrders, itemRating: 0.0, date: "\(date)", imageCount: imageCount, itemCalories: "0", itemType: itemType, city: city, state: state, zipCode: zipCode, user: user, healthy: healthy, creative: creative, vegan: vegan, burger: burger, seafood: seafood, pasta: pasta, workout: workout, lowCal: lowCal, lowCarb: lowCarb)
                                        
                                        if self.toggle == "Cater Items" {
                                            if self.cateringItems.isEmpty {
                                                self.cateringItems.append(newItem)
                                                self.items = self.cateringItems
                                                self.homeTableView.insertRows(at: [IndexPath(item: 0, section: 0)], with: .fade)
                                            } else {
                                                let index = self.cateringItems.firstIndex { $0.menuItemId == menuItemId }
                                                if index == nil {
                                                    self.cateringItems.append(newItem)
                                                    self.items = self.cateringItems
                                                    self.homeTableView.insertRows(at: [IndexPath(item: self.cateringItems.count - 1, section: 0)], with: .fade)
                                                }
                                            }
                                        } else if self.toggle == "Executive Items" {
                                            if self.personalChefItems.isEmpty {
                                                self.personalChefItems.append(newItem)
                                                self.items = self.personalChefItems
                                                self.homeTableView.insertRows(at: [IndexPath(item: 0, section: 0)], with: .fade)
                                            } else {
                                                let index = self.personalChefItems.firstIndex { $0.menuItemId == menuItemId }
                                                if index == nil {
                                                    self.personalChefItems.append(newItem)
                                                    self.items = self.personalChefItems
                                                    self.homeTableView.insertRows(at: [IndexPath(item: self.personalChefItems.count - 1, section: 0)], with: .fade)
                                                }
                                            }
                                        } else if self.toggle == "MealKit Items" {
                                            if self.mealKitItems.isEmpty {
                                                self.mealKitItems.append(newItem)
                                                self.items = self.mealKitItems
                                                self.homeTableView.insertRows(at: [IndexPath(item: 0, section: 0)], with: .fade)
                                            } else {
                                                let index = self.mealKitItems.firstIndex { $0.menuItemId == menuItemId }
                                                if index == nil {
                                                    self.mealKitItems.append(newItem)
                                                    self.items = self.mealKitItems
                                                    self.homeTableView.insertRows(at: [IndexPath(item: self.mealKitItems.count - 1, section: 0)], with: .fade)
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
            
            if self.toggle == "Cater Items" {
                self.items = self.cateringItems
            } else if self.toggle == "Executive Items" {
                self.items = self.personalChefItems
            } else {
                self.items = self.mealKitItems
            }
            self.homeTableView.reloadData()
            if self.homeTableView.numberOfRows(inSection: 0) != 0 {
                self.homeTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
              }
        }
    }
    
    
    @IBAction func cateringButtonPressed(_ sender: MDCButton) {
        toggle = "Cater Items"
        loadItems()
        cateringButton.setTitleColor(UIColor.white, for: .normal)
        cateringButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
        personalChefButton.backgroundColor = UIColor.white
        personalChefButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        mealKitButton.backgroundColor = UIColor.white
        mealKitButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        
        
        
    }
    
    @IBAction func personalChefButtonPressed(_ sender: MDCButton) {
        toggle = "Executive Items"
        loadItems()
        cateringButton.backgroundColor = UIColor.white
        cateringButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        personalChefButton.setTitleColor(UIColor.white, for: .normal)
        personalChefButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
        mealKitButton.backgroundColor = UIColor.white
        mealKitButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
    }
    
    
    @IBAction func mealKitButtonPressed(_ sender: MDCButton) {
        toggle = "MealKit Items"
        loadItems()
        cateringButton.backgroundColor = UIColor.white
        cateringButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        personalChefButton.backgroundColor = UIColor.white
        personalChefButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        mealKitButton.setTitleColor(UIColor.white, for: .normal)
        mealKitButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
    
    }
    
    
    @IBAction func filterButtonPressed(_ sender: Any) {
    }
    
    @IBAction func checkoutButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "HomeToCheckoutSegue", sender: self)
    }
    
    private var item : FeedMenuItems?
    private var chef = ""
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HomeToItemDetailSegue" {
            let info = segue.destination as! ItemDetailViewController
            info.item = item!
        } else if segue.identifier == "HomeToProfileAsUserSegue" {
            let info = segue.destination as! ProfileAsUserViewController
            info.user = chef
            info.chefOrUser = "chef"
        } else if segue.identifier == "HomeToOrderDetailSegue" {
            let info = segue.destination as! OrderDetailsViewController
            info.item = item
        }
    }
    
}

extension HomeViewController :  UITableViewDelegate, UITableViewDataSource  {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = homeTableView.dequeueReusableCell(withIdentifier: "HomeReusableCell", for: indexPath) as! HomeTableViewCell
        var item = items[indexPath.row]
        if toggle == "Cater Items" {
            item = cateringItems[indexPath.row]
        } else if toggle == "Executive Items" {
            item = personalChefItems[indexPath.row]
        } else {
            item = mealKitItems[indexPath.row]
        }
        
        var chefImage = UIImage()
        var itemImage = UIImage()
        let storageRef = storage.reference()
        let chefRef = storageRef.child("chefs/\(item.chefEmail)/profileImage/\(item.chefImageId).png")
        let itemRef = storageRef.child("chefs/\(item.chefEmail)/\(item.itemType)/\(item.menuItemId)0.png")
        
//        DispatchQueue.main.async {
//        chefRef.getData(maxSize: 15 * 1024 * 1024) { data, error in
//          if let error = error {
//              print("error \(error)")
//            // Uh-oh, an error occurred!
//          } else {
//            print("occuring")
//            chefImage = UIImage(data: data!)!
//              cell.chefImage.image = UIImage(data: data!)
//              itemRef.getData(maxSize: 15 * 1024 * 1024) { data, error in
//                if let error = error {
//                  // Uh-oh, an error occurred!
//                    print("error 2 \(error)")
//                } else {
//                  // Data for "images/island.jpg" is returned
//                    print("occuring 2")
//                  itemImage = UIImage(data: data!)!
//                    cell.itemImage.image = UIImage(data: data!)
//                }}}}}
            
        

        cell.chefImage.image = item.chefImage
        cell.itemImage.image = item.itemImage
        cell.itemTitle.text = item.itemTitle
        cell.itemPrice.text = "$\(item.itemPrice)"
        cell.itemDescription.text = item.itemDescription
        cell.likeText.text = "\(item.liked.count)"
        cell.orderText.text = "\(item.itemOrders)"
        cell.ratingText.text = "\(item.itemRating)"
        if item.liked.firstIndex(of: Auth.auth().currentUser!.email!) != nil {
            cell.likeImage.image = UIImage(systemName: "heart.fill")
        } else {
            cell.likeImage.image = UIImage(systemName: "heart")
        }
        
        cell.itemImageButtonTapped = {
            self.item = item
            self.performSegue(withIdentifier: "HomeToItemDetailSegue", sender: self)
        }
        
        cell.chefImageButtonTapped = {
            self.chef = item.chefImageId
            self.performSegue(withIdentifier: "HomeToProfileAsUserSegue", sender: self)
        }
        
        cell.orderButtonTapped = {
            self.item = item
            self.performSegue(withIdentifier: "HomeToOrderDetailSegue", sender: self)
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
    }
    
}
