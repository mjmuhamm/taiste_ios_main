//
//  HomeViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 2/23/22.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore
import MaterialComponents.MaterialButtons
import MaterialComponents

var guserName = ""
class HomeViewController: UIViewController {

    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    let date = Date()
    let df = DateFormatter()
    
    
    
    @IBOutlet weak var cateringButton: MDCButton!
    @IBOutlet weak var personalChefButton: MDCButton!
    @IBOutlet weak var mealKitButton: MDCButton!
    
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var checkoutButton: UIButton!
    
    @IBOutlet weak var homeTableView: UITableView!
    @IBOutlet weak var foodTotal: UILabel!
    
    private var cateringItems : [FeedMenuItems] = []
    private var personalChefItems: [PersonalChefInfo] = []
    private var mealKitItems : [FeedMenuItems] = []
    
    private var items : [FeedMenuItems] = []
    
    private var cart : [String] = []
    private var totalPrice = 0.0
    private var filter: Filter?
    
    private var toggle = "Cater Items"
    
    private var happened = ""
    @IBOutlet weak var liveButton: MDCButton!
    @IBOutlet weak var chefStack: UIStackView!
    
    @IBOutlet weak var liveStack: UIStackView!
    @IBOutlet weak var foodTruckButton: MDCButton!
    @IBOutlet weak var restaurantButton: MDCButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        df.dateFormat = "MM-dd-yyyy hh:mm a"
        homeTableView.delegate = self
        homeTableView.dataSource = self
        
        homeTableView.register(UINib(nibName: "HomeTableViewCell", bundle: nil), forCellReuseIdentifier: "HomeReusableCell")
        homeTableView.register(UINib(nibName: "PersonalChefTableViewCell", bundle: nil), forCellReuseIdentifier: "PersonalChefReusableCell")
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            
            loadCart()
            loadFilter()
            loadUsername()
         } else {
             self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
         }

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.tintColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
        self.tabBarController?.tabBar.barTintColor = UIColor.white
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
    
  
    private func loadCart() {
        if Auth.auth().currentUser != nil {
        db.collection("User").document(Auth.auth().currentUser!.uid).collection("Cart").addSnapshotListener { documents, error in
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
            } else {
                self.showToast(message: "Something went wrong. Please check your connection.", font: .systemFont(ofSize: 12))
            }
        }
    }
    }
    
    private func loadFilter() {
        if Auth.auth().currentUser != nil {
            db.collection("User").document(Auth.auth().currentUser!.uid).collection("PersonalInfo").getDocuments { documents, error in
                if error == nil {
                    for doc in documents!.documents {
                        let data = doc.data()
                        
                        if let local = data["local"] as? Int, let region = data["region"] as? Int, let nation = data["nation"] as? Int, let city = data["city"] as? String, let state = data["state"] as? String, let burger = data["burger"] as? Int, let creative = data["creative"] as? Int, let lowCal = data["lowCal"] as? Int, let lowCarb = data["lowCarb"] as? Int, let pasta = data["pasta"] as? Int, let healthy = data["healthy"] as? Int, let vegan = data["vegan"] as? Int, let seafood = data["seafood"] as? Int, let workout = data["workout"] as? Int, let surpriseMe = data["surpriseMe"] as? Int {
                            
                            print("filter happening")
                            self.filter = Filter(local: local, region: region, nation: nation, city: city, state: state, burger: burger, creative: creative, lowCal: lowCal, lowCarb: lowCarb, pasta: pasta, healthy: healthy, vegan: vegan, seafood: seafood, workout: workout, surpriseMe: surpriseMe)
                            
                            self.loadItems(filter: self.filter!, go: "")
                            
                            
                        }
                        
                    }
                }
            }
        } else {
            self.showToast(message: "Something went wrong. Please check your connection.", font: .systemFont(ofSize: 12))
        }
    }
    
    private func loadItems(filter: Filter, go: String) {
        print("go \(go) 111")
        if go == "Yes" {
            showToast(message: "We widened your search criteria a bit.", font: .systemFont(ofSize: 12))
        }
        let storageRef = storage.reference()
        if !items.isEmpty {
            items.removeAll()
            homeTableView.reloadData()
        }
        
        var itemsI : [FeedMenuItems]
        
        if toggle == "Cater Items" {
            itemsI = cateringItems
        } else {
           itemsI = mealKitItems
        }
        if itemsI.isEmpty {
        happened = ""
        db.collection(toggle).getDocuments { documents, error in
            if error == nil {
                for doc in documents!.documents {
                    
                    let data = doc.data()
                    
                    if let chefEmail = data["chefEmail"] as? String, let chefPassion = data["chefPassion"] as? String, let chefUsername = data["chefUsername"] as? String, let profileImageId = data["profileImageId"] as? String, let menuItemId = data["randomVariable"] as? String, let itemTitle = data["itemTitle"] as? String, let itemDescription = data["itemDescription"] as? String, let itemPrice = data["itemPrice"] as? String, let liked = data["liked"] as? [String], let itemOrders = data["itemOrders"] as? Int, let itemRating = data["itemRating"] as? [Double], let date = data["date"], let imageCount = data["imageCount"] as? Int, let itemType = data["itemType"] as? String, let city = data["city"] as? String, let state = data["state"] as? String, let zipCode = data["zipCode"] as? String, let user = data["user"] as? String, let healthy = data["healthy"] as? Int, let creative = data["creative"] as? Int, let vegan = data["vegan"] as? Int, let burger = data["burger"] as? Int, let seafood = data["seafood"] as? Int, let pasta = data["pasta"] as? Int, let workout = data["workout"] as? Int, let lowCal = data["lowCal"] as? Int, let lowCarb = data["lowCarb"] as? Int, let itemCalories = data["itemCalories"] as? String {
                        
                       var location = ""
                        print("items happening")
                        var preference = ""
                        
                        if filter.local == 1 {
                            if filter.city == city || filter.state == state {
                                location = "go"
                            }
                        } else if filter.region == 1 {
                            if filter.state == state {
                                location = "go"
                            }
                        } else if filter.nation == 1 {
                            location = "go"
                        }
                        
                        
                        if (filter.burger == 1 && burger == 1) {
                            preference = "go"
                        } else if (filter.creative == 1 && creative == 1) {
                            preference = "go"
                        } else if (filter.pasta == 1 && pasta == 1) {
                            preference = "go"
                        } else if (filter.healthy == 1 && healthy == 1) {
                            preference = "go"
                        } else if (filter.vegan == 1 && vegan == 1) {
                            preference = "go"
                        } else if (filter.lowCal == 1 && lowCal == 1) {
                            preference = "go"
                        } else if (filter.lowCarb == 1 && lowCarb == 1) {
                            preference = "go"
                        } else if (filter.seafood == 1 && seafood == 1) {
                            preference = "go"
                        } else if (filter.workout == 1 && workout == 1) {
                            preference = "go"
                        } else if (filter.surpriseMe == 1) {
                            preference = "go"
                        } else if (filter.burger == 0 && filter.creative == 0 && filter.lowCal == 0 && filter.lowCarb == 0 && filter.pasta == 0 && filter.healthy == 0 && filter.vegan == 0 && filter.workout == 0 && filter.seafood == 0) {
                            preference = "go"
                        }
                        if (location == "go" && preference == "go") || go == "Yes" {
                            
                                let newItem = FeedMenuItems(chefEmail: chefEmail, chefPassion: chefPassion, chefUsername: chefUsername, chefImageId: profileImageId, chefImage: UIImage(), menuItemId: menuItemId, itemImage:  UIImage(), itemTitle: itemTitle, itemDescription: itemDescription, itemPrice: itemPrice, liked: liked, itemOrders: itemOrders, itemRating: itemRating, date: "\(date)", imageCount: imageCount, itemCalories: itemCalories, itemType: itemType, city: city, state: state, zipCode: zipCode, user: user, healthy: healthy, creative: creative, vegan: vegan, burger: burger, seafood: seafood, pasta: pasta, workout: workout, lowCal: lowCal, lowCarb: lowCarb, live: "")
                                
                                if self.toggle == "Cater Items" {
                                    
                                        let index = self.cateringItems.firstIndex { $0.menuItemId == menuItemId }
                                        if index == nil {
                                            self.cateringItems.append(newItem)
                                            self.items = self.cateringItems
                                            self.items.shuffle()
                                            self.homeTableView.insertRows(at: [IndexPath(item: self.cateringItems.count - 1, section: 0)], with: .fade)
                                        
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
                                            self.items.shuffle()
                                            self.homeTableView.insertRows(at: [IndexPath(item: self.mealKitItems.count - 1, section: 0)], with: .fade)
                                        }
                                    }
                                }
                        } else {
                            self.loadItems(filter: filter, go: "Yes")
                        }
                    }
                      }
                    
                }
        }
        } else {
            if self.toggle == "Cater Items" {
                self.items = self.cateringItems
            } else {
                self.items = self.mealKitItems
            }
            self.happened = "yes"
            self.homeTableView.reloadData()
            if self.homeTableView.numberOfRows(inSection: 0) != 0 {
                self.homeTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
              }
        }
    }
    
    private func loadExecutiveItems(filter: Filter, go: String) {
        if !items.isEmpty {
            items.removeAll()
            homeTableView.reloadData()
        }
        
        
        db.collection("Executive Items").getDocuments { documents, error in
            if error == nil {
                if documents != nil {
                    for doc in documents!.documents {
                        let data = doc.data()
                        
                            
                        if let briefIntroduction = data["briefIntroduction"] as? String, let lengthOfPersonalChef = data["lengthOfPersonalChef"] as? String, let specialty = data["specialty"] as? String, let servicePrice = data["servicePrice"] as? String, let expectations = data["expectations"] as? Int, let chefRating = data["chefRating"] as? Int, let quality = data["quality"] as? Int, let chefName = data["chefName"] as? String, let whatHelpsYouExcel = data["whatHelpsYouExcel"] as? String, let mostPrizedAccomplishment = data["mostPrizedAccomplishment"] as? String, let weeks = data["weeks"] as? Int, let months = data["months"] as? Int, let trialRun = data["trialRun"] as? Int, let hourlyOrPersSession = data["hourlyOrPerSession"] as? String, let chefImageId = data["chefImageId"] as? String, let chefEmail = data["chefEmail"] as? String, let city = data["city"] as? String, let state = data["state"] as? String, let liked = data["liked"] as? [String], let itemOrders = data["itemOrders"] as? Int, let itemRating = data["itemRating"] as? [Double], let signatureDishId = data["signatureDishId"] as? String, let zipCode = data["zipCode"] as? String, let openToMenuRequests = data["openToMenuRequests"] as? String {
                            
                            self.db.collection("Chef").document(chefImageId).collection("Executive Items").document(signatureDishId).getDocument { document, error in
                                
                                if error == nil {
                                    if document != nil {
                                            let data = document!.data()
                                            
                                            if let burger = data!["burger"] as? Int, let creative = data!["creative"] as? Int, let lowCal = data!["lowCal"] as? Int, let lowCarb = data!["lowCarb"] as? Int, let pasta = data!["pasta"] as? Int, let creative = data!["creative"] as? Int, let healthy = data!["healthy"] as? Int, let vegan = data!["vegan"] as? Int, let seafood = data!["seafood"] as? Int, let workout = data!["workout"] as? Int {
                                
                            
                            var location = ""
                            var preference = ""
                            
                            if filter.local == 1 {
                                if filter.city == city || filter.state == state {
                                    location = "go"
                                }
                            } else if filter.region == 1 {
                                if filter.state == state {
                                    location = "go"
                                }
                            } else if filter.nation == 1 {
                                location = "go"
                            }
                            
                            
                            if (filter.burger == 1 && burger == 1) {
                                preference = "go"
                            } else if (filter.creative == 1 && creative == 1) {
                                preference = "go"
                            } else if (filter.pasta == 1 && pasta == 1) {
                                preference = "go"
                            } else if (filter.healthy == 1 && healthy == 1) {
                                preference = "go"
                            } else if (filter.vegan == 1 && vegan == 1) {
                                preference = "go"
                            } else if (filter.lowCal == 1 && lowCal == 1) {
                                preference = "go"
                            } else if (filter.lowCarb == 1 && lowCarb == 1) {
                                preference = "go"
                            } else if (filter.seafood == 1 && seafood == 1) {
                                preference = "go"
                            } else if (filter.workout == 1 && workout == 1) {
                                preference = "go"
                            } else if (filter.surpriseMe == 1) {
                                preference = "go"
                            } else if (filter.burger == 0 && filter.creative == 0 && filter.lowCal == 0 && filter.lowCarb == 0 && filter.pasta == 0 && filter.healthy == 0 && filter.vegan == 0 && filter.workout == 0 && filter.seafood == 0) {
                                preference = "go"
                            }
                            
                            if (location == "go" && preference == "go") || go == "Yes" {
                                
                                
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
                                print("happening itemdata")
                                
                                DispatchQueue.main.async {
                                    let item = PersonalChefInfo(chefName: chefName, chefEmail: chefEmail, chefImageId: chefImageId, chefImage: UIImage(), city: city, state: state, zipCode: zipCode, signatureDishImage: UIImage(), signatureDishId: signatureDishId, option1Title: "", option2Title: "", option3Title: "", option4Title: "", briefIntroduction: briefIntroduction, howLongBeenAChef: lengthOfPersonalChef, specialty: specialty, whatHelpesYouExcel: whatHelpsYouExcel, mostPrizedAccomplishment: mostPrizedAccomplishment, availabilty: availability, hourlyOrPerSession: hourlyOrPersSession, servicePrice: servicePrice, trialRun: trialRun, weeks: weeks, months: months, liked: liked, itemOrders: itemOrders, itemRating: itemRating, expectations: expectations, chefRating: chefRating, quality: quality, documentId: doc.documentID, openToMenuRequests: openToMenuRequests)
                                    
                                   
                                        if let index = self.personalChefItems.firstIndex(where: { $0.chefImageId == chefImageId }) {} else {
                                            self.personalChefItems.append(item)
                                            self.personalChefItems.shuffle()
                                            self.homeTableView.insertRows(at: [IndexPath(item: self.personalChefItems.count - 1, section: 0)], with: .fade)
                                        }
                                    
                                    
                                    
                                }
                            }  else {
                                
                                self.loadExecutiveItems(filter: self.filter!, go: "Yes")
                                
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
    
    
    @IBAction func cateringButtonPressed(_ sender: MDCButton) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
           
        toggle = "Cater Items"
        loadItems(filter: self.filter!, go: "")
        cateringButton.setTitleColor(UIColor.white, for: .normal)
        cateringButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
        personalChefButton.backgroundColor = UIColor.white
        personalChefButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        mealKitButton.backgroundColor = UIColor.white
        mealKitButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        
        } else {
            self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
        }
        
    }
    
    @IBAction func personalChefButtonPressed(_ sender: MDCButton) {
        if Reachability.isConnectedToNetwork(){
        print("Internet Connection Available!")
   
        toggle = "Executive Items"
        loadExecutiveItems(filter: filter!, go: "")
        cateringButton.backgroundColor = UIColor.white
        cateringButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        personalChefButton.setTitleColor(UIColor.white, for: .normal)
        personalChefButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
        mealKitButton.backgroundColor = UIColor.white
        mealKitButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
    } else {
        self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
    }
    }
    
    
    @IBAction func mealKitButtonPressed(_ sender: MDCButton) {
        if Reachability.isConnectedToNetwork(){
        print("Internet Connection Available!")
   
//        toggle = "MealKit Items"
        self.showToast(message: "Coming Soon.", font: .systemFont(ofSize: 12))
//        loadItems(filter: self.filter!, go: "")
//        cateringButton.backgroundColor = UIColor.white
//        cateringButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
//        personalChefButton.backgroundColor = UIColor.white
//        personalChefButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
//        mealKitButton.setTitleColor(UIColor.white, for: .normal)
//        mealKitButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
        } else {
            self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
        }
    
    }
    
    @IBAction func liveButtonPressed(_ sender: Any) {
        if liveButton.imageView?.image == UIImage(systemName: "livephoto.badge.a") {
            liveButton.setImage(UIImage(systemName: "cooktop"), for: .normal)
            self.homeTableView.isHidden = true
            chefStack.isHidden = true
            liveStack.isHidden = false
        } else {
            liveButton.setImage(UIImage(systemName: "livephoto.badge.a"), for: .normal)
            chefStack.isHidden = false
            liveStack.isHidden = true
            self.homeTableView.isHidden = false
        }
    }
    
    @IBAction func foodTruckButtonPressed(_ sender: Any) {
        self.showToast(message: "Coming Soon.", font: .systemFont(ofSize: 12))
    }
    
    @IBAction func restuarantButtonPressed(_ sender: Any) {
        self.showToast(message: "Coming Soon.", font: .systemFont(ofSize: 12))
    }
    
    
    
    
    
    @IBAction func filterButtonPressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Filter") as? FilterViewController
        self.present(vc!, animated: true, completion: nil)
        
        
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
            info.caterOrPersonal = "cater"
        } else if segue.identifier == "HomeToProfileAsUserSegue" {
            let info = segue.destination as! ProfileAsUserViewController
            info.user = chef
            info.chefOrUser = "chef"
        } else if segue.identifier == "HomeToOrderDetailSegue" {
            let info = segue.destination as! OrderDetailsViewController
            info.item = item
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
    
    var personalChefItem : PersonalChefInfo?
    func showToastCompletion(message : String, font: UIFont) {
        
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
            if self.toggle != "Executive Items" {
                self.performSegue(withIdentifier: "HomeToOrderDetailSegue", sender: self)
            } else {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "PersonalChefOrderDetail") as? PersonalChefOrderDetailViewController {
                    vc.personalChefInfo = self.personalChefItem!
                    self.present(vc, animated: true, completion: nil)
                }
            }
            toastLabel.removeFromSuperview()
        })
    }
    
}

extension HomeViewController :  UITableViewDelegate, UITableViewDataSource  {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if toggle == "Executive Items" {
            return personalChefItems.count
        } else {
            return items.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if toggle == "Cater Items"  {
            let cell = homeTableView.dequeueReusableCell(withIdentifier: "HomeReusableCell", for: indexPath) as! HomeTableViewCell
            var item = items[indexPath.row]
            if toggle == "Cater Items" {
                item = cateringItems[indexPath.row]
            } else {
                item = mealKitItems[indexPath.row]
            }
            
            let chefRef = storage.reference()
            let itemRef = storage.reference()
            if indexPath.row == 0 {
                cell.itemImage.image = UIImage()
                cell.chefImage.image = UIImage()
            }
            print("chefEmail \(item.chefEmail)")
            print("\(item.chefImageId)")
                chefRef.child("chefs/\(item.chefEmail)/profileImage/\(item.chefImageId).png").downloadURL { imageUrl, error in
                    
                    
                    URLSession.shared.dataTask(with: imageUrl!) { (data, response, error) in
                        // Error handling...
                        guard let imageData = data else { return }
                        
                        print("happening itemdata")
                        DispatchQueue.main.async {
                            cell.chefImage.image = UIImage(data: imageData)!
                            if self.toggle == "Cater Items" {
                                self.cateringItems[indexPath.row].chefImage = UIImage(data: imageData)!
                                item.chefImage = UIImage(data: imageData)!
                            }
                            
                            
                        }
                    }.resume()
                    
                }
                
                
                itemRef.child("chefs/\(item.chefEmail)/\(self.toggle)/\(item.menuItemId)0.png").downloadURL { imageUrl, error in
                    
                    URLSession.shared.dataTask(with: imageUrl!) { (data, response, error) in
                        // Error handling...
                        guard let imageData = data else { return }
                        
                        print("happening itemdata")
                        DispatchQueue.main.async {
                            cell.itemImage.image = UIImage(data: imageData)!
                            if self.toggle == "Cater Items" {
                                self.cateringItems[indexPath.row].itemImage = UIImage(data: imageData)!
                                item.itemImage = UIImage(data: imageData)!
                            }
                            
                        }
                    }.resume()
                    
                }
            
            
            
            cell.itemTitle.text = item.itemTitle
            cell.itemPrice.text = "$\(item.itemPrice)"
            cell.itemDescription.text = item.itemDescription
            cell.likeText.text = "\(item.liked.count)"
            
            if item.liked.contains("\(Auth.auth().currentUser!.email!)") {
                cell.likeImage.image = UIImage(systemName: "heart.fill")
            } else {
                cell.likeImage.image = UIImage(systemName: "heart")
            }
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
            
            cell.itemImageButtonTapped = {
                self.item = item
                self.performSegue(withIdentifier: "HomeToItemDetailSegue", sender: self)
            }
            
            cell.chefImageButtonTapped = {
                self.chef = item.chefImageId
                self.performSegue(withIdentifier: "HomeToProfileAsUserSegue", sender: self)
            }
            
            cell.orderButtonTapped = {
                if item.chefUsername != "chefTest" {
                    self.item = item
                    self.performSegue(withIdentifier: "HomeToOrderDetailSegue", sender: self)
                } else {
                    self.showToastCompletion(message: "This is a test account. You will not be able to purchase this item.", font: .systemFont(ofSize: 12))
                    self.item = item
                    
                }
            }
            
            cell.likeImageButtonTapped = {
                self.db.collection("\(item.itemType)").document(item.menuItemId).getDocument(completion: { document, error in
                    if error == nil {
                        if document != nil {
                            let data = document!.data()
                            
                            let liked = data!["liked"] as? [String]
                            let data1 : [String: Any] = ["chefEmail" : item.chefEmail, "chefPassion" : item.chefPassion, "chefUsername" : item.chefUsername, "chefImageId" : item.chefImageId, "menuItemId" : item.menuItemId, "itemTitle" : item.itemTitle, "itemDescription" : item.itemDescription, "itemPrice" : item.itemPrice, "liked" : liked, "itemOrders" : item.itemOrders, "itemRating": item.itemRating, "imageCount" : item.imageCount, "itemType" : item.itemType, "city" : item.city, "state" : item.state, "user" : item.user, "healthy" : item.healthy, "creative" : item.creative, "vegan" : item.vegan, "burger" : item.burger, "seafood" : item.seafood, "pasta" : item.pasta, "workout" : item.workout, "lowCal" : item.lowCal, "lowCarb" : item.lowCarb, "expectations" : 0, "chefRating" : 0, "quality" : 0]
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
                let date =  self.df.string(from: Date())
                let data3: [String: Any] = ["notification" : "\(guserName) has just liked your item (\(item.itemType))  \(item.itemTitle)", "date" : date]
                let data4: [String: Any] = ["notifications" : "yes"]
                self.db.collection("Chef").document(item.chefImageId).collection("Notifications").document().setData(data3)
                self.db.collection("Chef").document(item.chefImageId).updateData(data4)
                
            }
            
            return cell
        } else {
            let cell = homeTableView.dequeueReusableCell(withIdentifier: "PersonalChefReusableCell", for: indexPath) as! PersonalChefTableViewCell
            
            var item = personalChefItems[indexPath.row]
                cell.chefImage.image = item.chefImage
                cell.chefName.text = "@\(item.chefName)"
                cell.briefIntro.text = item.briefIntroduction
                cell.servicePrice.text = "$\(item.servicePrice)"
            cell.chefLikes.text = "\(item.liked.count)"
            cell.chefOrders.text = "\(item.itemOrders)"
            cell.chefRating.text = "\(item.chefRating)"
            
            let storageRef = self.storage.reference()
            let itemRef = self.storage.reference()
            print("chefemail \(item.chefEmail)")
            print("imageid \(item.chefImageId)")
            storageRef.child("chefs/\(item.chefEmail)/profileImage/\(item.chefImageId).png").downloadURL { imageUrl, error in
                
                if error == nil {
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
                
            }
            
            
            itemRef.child("chefs/\(item.chefEmail)/Executive Items/\(item.signatureDishId)0.png").downloadURL { imageUrl, error in
                
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
                cell.chefImageButtonTapped = {
                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileAsUser") as? ProfileAsUserViewController {
                        vc.user = item.chefImageId
                        vc.chefOrUser = "chef"
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            
            cell.detailButtonTapped = {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ItemDetail") as? ItemDetailViewController {
                    vc.caterOrPersonal = "personal"
                    vc.personalChefInfo = item
                    self.present(vc, animated: true, completion: nil)
                }
            }
            
            cell.orderButtonTapped = {
                if item.chefName != "chefTest" {
                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: "PersonalChefOrderDetail") as? PersonalChefOrderDetailViewController {
                        vc.personalChefInfo = item
                        self.present(vc, animated: true, completion: nil)
                    }
                } else {
                    self.showToastCompletion(message: "This is a test account. You will not be able to purchase this item.", font: .systemFont(ofSize: 12))
                    self.personalChefItem = item
                }
            }
            
            cell.likeButtonTapped = {
                self.db.collection("Executive Items").document(item.documentId).getDocument(completion: { document, error in
                    if error == nil {
                        if document != nil {
                            let data = document!.data()
                            
                            let liked = data!["liked"] as? [String]
                            let data1 : [String: Any] = ["chefEmail" : item.chefEmail, "chefPassion" : item.briefIntroduction, "chefUsername" : item.chefName, "chefImageId" : item.chefImageId, "menuItemId" : item.documentId, "itemTitle" : "Executive Chef", "itemDescription" : item.briefIntroduction, "itemPrice" : item.servicePrice, "liked" : liked!, "itemOrders" : item.itemOrders, "itemRating": item.itemRating, "imageCount" : 0, "itemType" : "Executive Item", "city" : item.city, "state" : item.state, "user" : item.chefImageId, "healthy" : 0, "creative" : 0, "vegan" : 0, "burger" : 0, "seafood" : 0, "pasta" : 0, "workout" : 0, "lowCal" : 0, "lowCarb" : 0, "expectations" : item.expectations, "chefRating" : item.chefRating, "quality" : item.quality]
                            if (liked!.firstIndex(of: Auth.auth().currentUser!.email!) != nil) {
                                self.db.collection("Executive Items").document(item.documentId).updateData(["liked" : FieldValue.arrayRemove(["\(Auth.auth().currentUser!.email!)"])])
                                self.db.collection("User").document(Auth.auth().currentUser!.uid).collection("UserLikes").document(item.documentId).delete()
                                
                                let date =  self.df.string(from: Date())
                                let data3: [String: Any] = ["notification" : "\(guserName) has just liked your item (Executive Chef)", "date" : date]
                                let data4: [String: Any] = ["notifications" : "yes"]
                                self.db.collection("Chef").document(item.chefImageId).collection("Notifications").document().setData(data3)
                                self.db.collection("Chef").document(item.chefImageId).updateData(data4)
                                
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
                
            }
                
            
            return cell
        } 
    }
    
}
