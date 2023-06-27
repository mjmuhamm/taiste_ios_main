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
    private var personalChefItem : PersonalChefInfo?
    private var mealKitItems : [FeedMenuItems] = []
    
    private var chefNameText = ""
    private var items: [FeedMenuItems] = []
    
    private var city = ""
    private var state = ""
    private var zipCode = ""
    private var latitude = ""
    private var longitude = ""
    private var profileImageId = ""
    private var menuItemId = UUID().uuidString
    @IBOutlet weak var newNotificationImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chefImage.layer.borderWidth = 1
        chefImage.layer.masksToBounds = false
        chefImage.layer.borderColor = UIColor.white.cgColor
        chefImage.layer.cornerRadius = chefImage.frame.height/2
        chefImage.clipsToBounds = true
        meTableView.register(UINib(nibName: "PersonalChefTableViewCell", bundle: nil), forCellReuseIdentifier: "PersonalChefReusableCell")
        meTableView.register(UINib(nibName: "ChefItemTableViewCell", bundle: nil), forCellReuseIdentifier: "ChefItemReusableCell")
        meTableView.delegate = self
        meTableView.dataSource = self
       
        
        
        contentCollectionView.register(UINib(nibName: "ChefContentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ChefContentCollectionViewReusableCell")
        contentCollectionView.delegate = self
        contentCollectionView.dataSource = self
        if Reachability.isConnectedToNetwork(){
        print("Internet Connection Available!")
            payout()
        loadChefInfo()
        loadItems()
        loadNotifications()
        } else {
        self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
       }
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.tintColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
        self.tabBarController?.tabBar.barTintColor = UIColor.white
    }
    
    private func loadNotifications() {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            if Auth.auth().currentUser != nil {
                db.collection("Chef").document(Auth.auth().currentUser!.uid).addSnapshotListener { document, error in
                    if error == nil {
                        if document != nil {
                            let data = document!.data()
                            if let notifications = data?["notifications"] as? String {
                                if notifications == "yes" {
                                    self.newNotificationImage.isHidden = false
                                } else {
                                    self.newNotificationImage.isHidden = true
                                }
                            }
                        }
                    }
                }
            } else {
                self.showToast(message: "Something went wrong. Please check connection.", font: .systemFont(ofSize: 12))
            }
        } else {
            self.showToast(message: "Something went wrong. Please check your connection.", font: .systemFont(ofSize: 12))
        }
    }
    private func loadChefInfo() {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            if Auth.auth().currentUser != nil {
                let storageRef = storage.reference()
                db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("PersonalInfo").addSnapshotListener { documents, error in
                    if error == nil {
                        for doc in documents!.documents {
                            let data = doc.data()
                            
                            if let chefPassion = data["chefPassion"] as? String, let city = data["city"] as? String, let education = data["education"] as? String, let fullName = data["fullName"] as? String, let state = data["state"] as? String, let username = data["chefName"] as? String, let zipCode = data["zipCode"] as? String, let email = data["email"] as? String {
                                
                                print("email \(Auth.auth().currentUser!.email!)")
                                print("uid \(Auth.auth().currentUser!.uid)")
                                
                                
                                
                                storageRef.child("chefs/\(email)/profileImage/\(Auth.auth().currentUser!.uid).png").downloadURL { itemUrl, error in
                                    
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
                                self.chefNameText = username
                                gChefName = username
                                self.city = city
                                self.state = state
                                self.zipCode = zipCode
                                self.profileImageId = Auth.auth().currentUser!.uid
                                
                            }
                        }
                    }
                }
            } else {
                self.showToast(message: "Something went wrong. Please check your connection.", font: .systemFont(ofSize: 12))
            }
        } else {
            self.showToast(message: "Something went wrong. Please check your connection.", font: .systemFont(ofSize: 12))
        }
    }
    
    private func loadItems() {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            if Auth.auth().currentUser != nil {
                
                
                let storageRef = storage.reference()
                if !cateringItems.isEmpty {
                    meTableView.reloadData()
                }
                
                
                var itemsI : [FeedMenuItems]
                
                if toggle == "Cater Items" {
                    itemsI = cateringItems
                } else {
                    itemsI = mealKitItems
                }
                    
                    db.collection("Chef").document(Auth.auth().currentUser!.uid).collection(toggle).addSnapshotListener { documents, error in
                        if error == nil {
                            for doc in documents!.documents {
                                
                                let data = doc.data()
                                
                                if let chefEmail = data["chefEmail"] as? String, let chefPassion = data["chefPassion"] as? String, let chefUsername = data["chefUsername"] as? String, let profileImageId = data["profileImageId"] as? String, let menuItemId = data["randomVariable"] as? String, let itemTitle = data["itemTitle"] as? String, let itemDescription = data["itemDescription"] as? String, let itemPrice = data["itemPrice"] as? String, let liked = data["liked"] as? [String], let itemOrders = data["itemOrders"] as? Int, let itemRating = data["itemRating"] as? [Double], let date = data["date"], let imageCount = data["imageCount"] as? Int, let itemType = data["itemType"] as? String, let city = data["city"] as? String, let state = data["state"] as? String, let zipCode = data["zipCode"] as? String, let user = data["user"] as? String, let healthy = data["healthy"] as? Int, let creative = data["creative"] as? Int, let vegan = data["vegan"] as? Int, let burger = data["burger"] as? Int, let seafood = data["seafood"] as? Int, let pasta = data["pasta"] as? Int, let workout = data["workout"] as? Int, let lowCal = data["lowCal"] as? Int, let lowCarb = data["lowCarb"] as? Int {
                                    
                                    var image = UIImage()
                                    
                                    
                                    
                                    let newItem = FeedMenuItems(chefEmail: chefEmail, chefPassion: chefPassion, chefUsername: chefUsername, chefImageId: profileImageId, chefImage: UIImage(), menuItemId: menuItemId, itemImage: UIImage(), itemTitle: itemTitle, itemDescription: itemDescription, itemPrice: itemPrice, liked: liked, itemOrders: itemOrders, itemRating: itemRating, date: "\(date)", imageCount: imageCount, itemCalories: "0", itemType: itemType, city: city, state: state, zipCode: zipCode, user: user, healthy: healthy, creative: creative, vegan: vegan, burger: burger, seafood: seafood, pasta: pasta, workout: workout, lowCal: lowCal, lowCarb: lowCarb, live: "live")
                                    
                                    if itemType == "Cater Items" {
                                            let index = self.cateringItems.firstIndex { $0.menuItemId == menuItemId }
                                            if index == nil {
                                                self.cateringItems.append(newItem)
                                                self.meTableView.insertRows(at: [IndexPath(item: self.cateringItems.count - 1, section: 0)], with: .fade)
                                            }
                                        
                                    } else if itemType == "MealKit Items" {
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
                                    }}}
                        }
                    }
                
            } else {
                self.showToast(message: "Something went wrong. Please check your connection.", font: .systemFont(ofSize: 12))
            }
        } else {
            self.showToast(message: "Something went wrong. Please check your connection.", font: .systemFont(ofSize: 12))
        }
    }
    var owe = 0.0
    ///------------
    private func payout() {
        let db = Firestore.firestore()
        let date = Date()
        let dfCompare = DateFormatter()
        dfCompare.dateFormat = "MM-dd-yyyy HH:mm"
        
        
        db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("Orders").addSnapshotListener { documents, error in
            if error == nil {
                if documents != nil {
                    for doc in documents!.documents {
                        let data = doc.data()
                        
                        if var eventDates = data["eventDates"] as? [String], var eventTimes = data["eventTimes"] as? [String], let totalCostOfEvent = data["totalCostOfEvent"] as? Double, let orderUpdate = data["orderUpdate"] as? String, let typeOfService = data["typeOfService"] as? String, let menuItemId = data["menuItemId"] as? String, let userImageId = data["userImageId"] as? String, let chefImageId = data["chefImageId"] as? String, var payoutDates = data["payoutDates"] as? [String] {
                            
                                
                            if orderUpdate == "Scheduled" {
                                var newEventDates : [Date] = []
                                var percent : Double?
                                for i in 0..<eventDates.count {
                                    var eventHour = Int(eventTimes[i].prefix(2))!
                                    var eventTime = ""
                                    if eventTimes[i].suffix(2) == "PM" {
                                        eventHour = eventHour + 12
                                    }
                                    
                                    eventTime = "\(eventHour):\(eventTimes[i].suffix(5).prefix(2))"
                                    let newTime = dfCompare.date(from: "\(eventDates[i]) \(eventTime)")
                                    
                                    print("eventTime \(eventDates[i]) \(eventTime)")
                                    
                                    newEventDates.append(newTime!)
                                    newEventDates = newEventDates.sorted(by: { $0.compare($1) == .orderedAscending })
                                
                                    }
                                for i in 0..<newEventDates.count {
                                    let tod = dfCompare.string(from: Date())
                                    let today = dfCompare.date(from: tod)
                                    
                                    let x = today!.distance(to: newEventDates[i]) / 3600
                                    let hourAfterEventEnds = x + 1
                                    
                                        if hourAfterEventEnds <= 0 {
                                            if !payoutDates.contains("\(newEventDates[i])") {
                                                let data5: [String: Any] = ["payoutDates" : newEventDates[i]]
                                                self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("Orders").document(menuItemId).updateData(["payoutDates" : FieldValue.arrayUnion(["\(newEventDates[i])"])])
                                                self.db.collection("Orders").document(menuItemId).updateData(["payoutDates" : FieldValue.arrayUnion(["\(newEventDates[i])"])])
                                                self.transfer(transferAmount: (totalCostOfEvent - (totalCostOfEvent * 0.05)) / Double(eventDates.count), orderId: doc.documentID, userImageId: userImageId, chefImageId: chefImageId, type: typeOfService, eventDate: "", complete: "")
                                                if payoutDates.count + 1 == eventDates.count {
                                                    let data4: [String: Any] = ["orderUpdate" : "complete"]
                                                    self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("Orders").document(menuItemId).updateData(data4)
                                                    self.db.collection("Orders").document(menuItemId).updateData(data4)
                                                } else {
                                                    payoutDates.append("123")
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
    private func transfer(transferAmount: Double, orderId: String, userImageId: String, chefImageId: String, type: String, eventDate: String, complete: String) {
        let date = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let df1 = DateFormatter()
        df1.dateFormat = "MM-dd-yyyy hh:mm a"
        if Auth.auth().currentUser != nil {
            self.db.collection("Chef").document(Auth.auth().currentUser!.uid).getDocument { document, error in
                if error == nil {
                    if document != nil {
                        let data = document!.data()
                        if let owe = data!["chargeForPayout"] as? Double {
                            if transferAmount - owe < 0 {
                                let amountOwed = owe - transferAmount
                                let owe : [String : Any] = ["chargeForPayout" : amountOwed]
                                self.db.collection("Chef").document(Auth.auth().currentUser!.uid).updateData(owe)
                                let data4: [String: Any] = ["notification" : "You still owed $\(owe) from cancellations. Your new amount owed is $\(amountOwed).", "date": df.string(from: Date())]
                                let data5: [String: Any] = ["notifications" : "yes"]
                                self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("Notifications").document().setData(data4)
                                self.db.collection("Chef").document(Auth.auth().currentUser!.uid).updateData(data5)
                            } else {
                        
                                self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("BankingInfo").getDocuments { documents, error in
                if error == nil {
                    if documents != nil {
                        for doc in documents!.documents {
                            let data = doc.data()
                            
                            if let stripeAccountId = data["stripeAccountId"] as? String {
                                let a = (transferAmount - owe) * 100
                                
                                let amount = String(format: "%.0f", a)
                                
                                let json: [String: Any] = ["amount": amount, "stripeAccountId" : stripeAccountId]
                                
                                let jsonData = try? JSONSerialization.data(withJSONObject: json)
                                // MARK: Fetch the Intent client secret, Ephemeral Key secret, Customer ID, and publishable key
                                var request = URLRequest(url: URL(string: "https://taiste-payments.onrender.com/transfer")!)
                                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                                request.httpMethod = "POST"
                                request.httpBody = jsonData
                                let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data,response, error) in
                                    guard let data = data,
                                          let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                                          let transferId = json["transferId"], let self = self else {
                                        // Handle error
                                        return
                                    }
                                    
                                    DispatchQueue.main.async {
                                        
                                        let data : [String: Any] = ["transferId" : transferId, "orderId" : orderId, "date" : df.string(from: Date()), "userImageId" : userImageId, "chefImageId" : chefImageId]
                                        self.db.collection("Transfers").document(orderId).setData(data)
                                        let data1: [String: Any] = ["notifications" : "yes"]
                                        let data2: [String: Any] = ["notification" : "a payout of $\(String(format: "%.2f", transferAmount)) is on its way for \(eventDate).", "date" : df1.string(from: Date())]
                                        self.db.collection("Chef").document(chefImageId).updateData(data1)
                                        self.db.collection("Chef").document(chefImageId).collection("Notifications").document().setData(data2)
                                        if type != "Executive Items" || complete == "yes" {
                                            let data2 : [String : Any] = ["orderUpdate" : "complete"]
                                            self.db.collection("Chef").document(chefImageId).collection("Orders").document(orderId).updateData(data2)
                                            self.db.collection("User").document(userImageId).collection("Orders").document(orderId).updateData(data2)
                                            self.db.collection("Orders").document(orderId).updateData(data2)
                                        }
                                        
                                        self.showToast(message: "$\(String(format: "%.2f", transferAmount)) payout on the way.", font: .systemFont(ofSize: 12))
                                    }
                                })
                                task.resume()
                            }
                            
                        }
                    }
                    }
                }}}}
                }
            }
        } else {
            self.showToast(message: "Something went wrong. Please check your connection.", font: .systemFont(ofSize: 12))
        }
    }
    ///--------------
    private func loadPersonalChefInfo() {
        if Auth.auth().currentUser != nil {
            if !items.isEmpty {
                items.removeAll()
                meTableView.reloadData()
            }
            
            
            db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("Executive Items").getDocuments { documents, error in
                if error == nil {
                    if documents != nil {
                        for doc in documents!.documents {
                            let data = doc.data()
                            
                            let typeOfInfo = data["typeOfService"] as? String
                            let complete = data["complete"] as? String
                            
                            
                            if typeOfInfo == "info" && complete == "yes" {
                                print("happening personal chef")
                                if let briefIntroduction = data["briefIntroduction"] as? String, let lengthOfPersonalChef = data["lengthOfPersonalChef"] as? String, let specialty = data["specialty"] as? String, let servicePrice = data["servicePrice"] as? String, let expectations = data["expectations"] as? Int, let chefRating = data["chefRating"] as? Int, let quality = data["quality"] as? Int, let chefName = data["chefName"] as? String, let whatHelpsYouExcel = data["whatHelpsYouExcel"] as? String, let mostPrizedAccomplishment = data["mostPrizedAccomplishment"] as? String, let weeks = data["weeks"] as? Int, let months = data["months"] as? Int, let trialRun = data["trialRun"] as? Int, let hourlyOrPersSession = data["hourlyOrPerSession"] as? String, let liked = data["liked"] as? [String], let itemOrders = data["itemOrders"] as? Int, let itemRating = data["itemRating"] as? [Double], let complete = data["complete"] as? String, let openToMenuRequests = data["openToMenuRequests"] as? String {
                                    
                                    self.addContentButton.isHidden = true
                                    
                                    var availability = ""
                                    if trialRun != 0 {
                                        availability = "Trial Run"
                                    }
                                    if weeks != 0 {
                                        availability = "\(availability)  Weeks"
                                    }
                                    if months != 0 {
                                        availability = "\(availability)  Months"
                                    }
                                    
                                    self.personalChefItem = PersonalChefInfo(chefName: chefName, chefEmail: Auth.auth().currentUser!.email!, chefImageId: Auth.auth().currentUser!.uid, chefImage: self.chefImage.image!, city: self.city, state: self.state, zipCode: self.zipCode, signatureDishImage: UIImage(), signatureDishId: "", option1Title: "", option2Title: "", option3Title: "", option4Title: "", briefIntroduction: briefIntroduction, howLongBeenAChef: lengthOfPersonalChef, specialty: specialty, whatHelpesYouExcel: whatHelpsYouExcel, mostPrizedAccomplishment: mostPrizedAccomplishment, availabilty: availability, hourlyOrPerSession: hourlyOrPersSession, servicePrice: servicePrice, trialRun: trialRun, weeks: weeks, months: months, liked: liked, itemOrders: itemOrders, itemRating: itemRating, expectations: expectations, chefRating: chefRating, quality: quality, documentId: doc.documentID, openToMenuRequests: openToMenuRequests)
                                    
                                    
                                }
                                
                            }
                            if typeOfInfo == "Signature Dish" {
                                print("happening personal chef 2")
                                let email = data["chefEmail"] as! String
                                self.storage.reference().child("chefs/\(email)/Executive Items/\(doc.documentID)0.png").downloadURL { imageUrl, error in
                                    if error == nil {
                                        URLSession.shared.dataTask(with: imageUrl!) { (data, response, error) in
                                            // Error handling...
                                            guard let imageData = data else { return }
                                            
                                            print("happening itemdata")
                                            DispatchQueue.main.async {
                                                if self.personalChefItem != nil {
                                                    self.personalChefItem!.signatureDishImage = UIImage(data: imageData)!
                                                    self.meTableView.reloadData()
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
        } else {
            self.showToast(message: "Something went wrong. Please check your connection.", font: .systemFont(ofSize: 12))
        }
    }
    private var createdAt = 0
    private func loadContent() {
        if Auth.auth().currentUser != nil {
            let json: [String: Any] = ["name" : "\(self.chefNameText)"]
            
            
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            // MARK: Fetch the Intent client secret, Ephemeral Key secret, Customer ID, and publishable key
            var request = URLRequest(url: URL(string: "https://taiste-video.onrender.com/get-user-videos")!)
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
                                
                                var description = ""
                                if videos[i]["description"] as? String != nil {
                                    description = videos[i]["description"] as! String
                                }
                                
                                let newVideo = VideoModel(dataUri: videos[i]["dataUrl"]! as! String, id: videos[i]["id"]! as! String, videoDate: String(createdAtI as! Int), user: videos[i]["name"]! as! String, description: description, views: views, liked: liked, comments: comments, shared: shared, thumbNailUrl: videos[i]["thumbnailUrl"]! as! String)
                                
                                if self.content.isEmpty {
                                    self.content.append(newVideo)
                                    //                              self.contentCollectionView.insertItems(at:  )
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
        } else {
            self.showToast(message: "Something went wrong. Please check your connection.", font: .systemFont(ofSize: 12))
        }
    }
    
    private func loadBankingInfo() {
        if Auth.auth().currentUser != nil {
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
        } else {
            self.showToast(message: "Something went wrong. Please check your connection.", font: .systemFont(ofSize: 12))
        }
    }
    
    private func retrieveIndividualAccount(stripeAccountId: String) {
            let json: [String: Any] = ["stripeAccountId": "\(stripeAccountId)"]
            
        
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            // MARK: Fetch the Intent client secret, Ephemeral Key secret, Customer ID, and publishable key
            var request = URLRequest(url: URL(string: "https://taiste-payments.onrender.com/retrieve-individual-account")!)
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
            var request = URLRequest(url: URL(string: "https://taiste-payments.onrender.com/retrieve-business-account")!)
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
        var request = URLRequest(url: URL(string: "https://taiste-payments.onrender.com/retrieve-external-account")!)
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
        if Reachability.isConnectedToNetwork(){
        print("Internet Connection Available!")
       
        toggle = "Cater Items"
        loadItems()
        addContentButton.isHidden = false
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
        } else {
        self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
       }
    }
    
    @IBAction func personalChefButtonPressed(_ sender: Any) {
        if Reachability.isConnectedToNetwork(){
        print("Internet Connection Available!")
        
        toggle = "Executive Items"
        loadPersonalChefInfo()
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
        } else {
        self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
       }
    }
    
    @IBAction func mealKitButtonPressed(_ sender: Any) {
        if Reachability.isConnectedToNetwork(){
        print("Internet Connection Available!")
        
//        var abc = toggle
            self.showToast(message: "Coming Soon.", font: .systemFont(ofSize: 12))
//        toggle = "MealKit Items"
//        loadItems()
//        addContentButton.isHidden = false
//        comingSoon.isHidden = true
//        contentCollectionView.isHidden = true
//        meTableView.isHidden = false
//        bankingView.isHidden = true
//        cateringButton.backgroundColor = UIColor.white
//        cateringButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
//        personalChefButton.backgroundColor = UIColor.white
//        personalChefButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
//        mealKitButton.setTitleColor(UIColor.white, for: .normal)
//        mealKitButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
//        contentButton.backgroundColor = UIColor.white
//        contentButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
//        bankingButton.backgroundColor = UIColor.white
//        bankingButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        } else {
        self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
       }
        
        
    }
    
    @IBAction func contentButtonPressed(_ sender: Any) {
        if Reachability.isConnectedToNetwork(){
        print("Internet Connection Available!")
        
        toggle = "Content"
        loadContent()
        addContentButton.isHidden = false
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
        } else {
        self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
       }
    }
    
    
    @IBAction func bankingButtonPressed(_ sender: MDCButton) {
        if Reachability.isConnectedToNetwork(){
        print("Internet Connection Available!")
        
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
        } else {
        self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
       }
       
    }
    
    @IBAction func addContentButtonPressed(_ sender: MDCButton) {
        if toggle == "MealKit Items" {
                if self.mealKitItems.count == 0 {
                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: "GuideToMealKits") as? GuideToMealKitViewController  {
                        self.present(vc, animated: true, completion: nil)
                    }
            } else {
                performSegue(withIdentifier: "ChefMeToMenuItemSegue", sender: self)
            }
        
        } else if toggle == "Executive Items" {
            if self.personalChefItem == nil {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "GuideToExecutiveItems") as? GuideToExecutiveItemsViewController  {
                    self.present(vc, animated: true, completion: nil)
                }
        } else {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "PersonalChef") as? PersonalChefViewController  {
                vc.chefImageI = self.chefImage.image
                vc.chefName = self.chefName.text!
                vc.city = self.city
                vc.state = self.state
                vc.zipCode = self.zipCode
                if self.personalChefItem != nil {
                    vc.personalChefItem = self.personalChefItem!
                }
                
                self.present(vc, animated: true, completion: nil)
            }
        }
        } else if toggle == "Cater Items" {
            if self.cateringItems.count == 0 {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "GuideToCaterItems") as? GuideToCaterItemsViewController  {
                    self.present(vc, animated: true, completion: nil)
                }
        } else {
            performSegue(withIdentifier: "ChefMeToMenuItemSegue", sender: self)
        }
        } else if toggle == "Content" {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ContentItem") as? AddContentViewController  {
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func notificationsButtonPressed(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "Notifications") as? NotificationsViewController {
            vc.chefOrUser = "Chef"
            self.present(vc, animated: true, completion: nil)
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


extension ChefMeViewController :  UITableViewDelegate, UITableViewDataSource  {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if toggle == "Cater Items" || toggle == "MealKit Items" {
            return cateringItems.count
        } else if toggle == "Executive Items" {
            if personalChefItem == nil {
                return 0
            } else {
                return 1
            }
        } else {
            return items.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if toggle == "Cater Items" || toggle == "MealKit Items" {
        var cell = meTableView.dequeueReusableCell(withIdentifier: "ChefItemReusableCell", for: indexPath) as! ChefItemTableViewCell
        var item = cateringItems[indexPath.row]
        cell.editImage.isHidden = true
        
        var vari = self.toggle
        if cateringItems.count == 0 {
            
            self.noItemsText.isHidden = false
        } else {
            self.noItemsText.isHidden = true
        }
        print("vari \(vari)")
        
            if self.toggle == "MealKit Items" {
                cell.liveLabel.isHidden = false
                if item.live != "yes" {
                    cell.liveLabel.text = "not live"
                    cell.liveLabel.textColor = UIColor.red
                } else {
                    cell.liveLabel.text = "live"
                    cell.liveLabel.textColor = UIColor.green
                }
            } else {
                cell.liveLabel.isHidden = true
            }
            if indexPath.row == 0 {
                cell.itemImage.image = UIImage()
            }
            
            let storageRef = storage.reference()
            storageRef.child("chefs/\(item.chefEmail)/\(self.toggle)/\(item.menuItemId)0.png").downloadURL { itemUrl, error in
                if itemUrl != nil {
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
                    vc.caterOrPersonal = "cater"
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
        } else {
            meTableView.register(UINib(nibName: "PersonalChefTableViewCell", bundle: nil), forCellReuseIdentifier: "PersonalChefReusableCell")
            let cell = meTableView.dequeueReusableCell(withIdentifier: "PersonalChefReusableCell", for: indexPath) as! PersonalChefTableViewCell
            
            if personalChefItem != nil {
                let item = personalChefItem!
                cell.chefImage.image = item.chefImage
                cell.signatureImage.image = item.signatureDishImage
                cell.chefName.text = item.chefName
                cell.briefIntro.text = item.briefIntroduction
                cell.servicePrice.text = "$\(item.servicePrice)"
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
                
                cell.orderButton.isHidden = true
                cell.editInfoButton.isHidden = false
                cell.editInfoButtonTapped = {
                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: "PersonalChef") as? PersonalChefViewController {
                        vc.chefImageI = self.chefImage.image
                        vc.chefName = self.chefName.text!
                        vc.personalChefItem = self.personalChefItem
                        vc.city = self.city
                        vc.state = self.state
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
                
            }
            return cell
        }
        
        
    }
    
}

extension ChefMeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
                vc.chefOrFeed = "chef"
                vc.content = cont
                vc.yes = "Yes"
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
