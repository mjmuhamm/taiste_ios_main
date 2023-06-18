//
//  ItemDetailViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 2/25/22.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import MaterialComponents.MaterialButtons
import MaterialComponents

class ItemDetailViewController: UIViewController {

    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var sliderCollectionView: UICollectionView!
    @IBOutlet weak var itemDescription: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var expectations1: UIImageView!
    @IBOutlet weak var expectations2: UIImageView!
    @IBOutlet weak var expecations3: UIImageView!
    @IBOutlet weak var expecations4: UIImageView!
    @IBOutlet weak var expecations5: UIImageView!
    
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
    
    @IBOutlet weak var reviewButton: UIButton!
    private var imgArr : [UIImage] = []
    
    @IBOutlet weak var personalChefView: UIView!
    @IBOutlet weak var signatureTitle: UILabel!
    @IBOutlet weak var signatureImage: UIImageView!
    
    @IBOutlet weak var option1Button: UIButton!
    @IBOutlet weak var option1Text: UILabel!
    @IBOutlet weak var option2Button: UIButton!
    @IBOutlet weak var option2Text: UILabel!
    @IBOutlet weak var option3Button: UIButton!
    @IBOutlet weak var option3Text: UILabel!
    @IBOutlet weak var option4Button: UIButton!
    @IBOutlet weak var option4Text: UILabel!
    @IBOutlet weak var briefIntroduction: UILabel!
    
    @IBOutlet weak var howLongBeenAChef: UILabel!
    @IBOutlet weak var specialty: UILabel!
    @IBOutlet weak var whatHelpsYouExcel: UILabel!
    @IBOutlet weak var mostPrizedAccomplishment: UILabel!
    @IBOutlet weak var availableText: UILabel!
    @IBOutlet weak var openToMenuRequests: UILabel!
    @IBOutlet weak var payStack: UIStackView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var payButton: UIButton!
    
    @IBOutlet weak var additionalButton: UIButton!
    private var started = "Yes"
    var item : FeedMenuItems?
    
    
    var imageCount = 0
    var chefEmail = ""
    var menuItemId = ""
    var itemType = ""
    var itemTitleI = ""
    var itemDescriptionI = ""
    var itemImage : UIImage? = nil
    var currentIndex = 0
    
    private var reviews : [Reviews] = []
    private var reviewData: [ReviewData] = []
    
    private var expectationsData = 0
    private var qualityData = 0
    private var chefRatingData = 0
    @IBOutlet weak var ratingStack: UIStackView!
    
    var personalChefInfo : PersonalChefInfo?
    var caterOrPersonal = ""
    var chefImageI : UIImage?
    var chefNameI = ""
    
    
    //MealKit
    
    @IBOutlet weak var denyButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var acceptDenyStack: UIStackView!
    @IBOutlet weak var mealKitView: UIView!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var cancelButton: MDCButton!
    @IBOutlet weak var uploadImageButton: MDCButton!
    
    @IBOutlet weak var viewLabel: UILabel!
    private var imgArr1 : [MenuItemImage] = []
    private var imgArrData : [Data] = []
    var isMealKit = ""
    var mealKitOrderId = ""
    var receiverImageId = ""
    var receiverUserName = ""
    var mealKitItemTitle = ""
    var mealKitNewOrEdit = ""
    private var acceptOrDeny = ""
    
    private var chefImageId = ""
    @IBOutlet weak var itemCalories: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
       
        signatureImage.layer.cornerRadius = 6
        if  caterOrPersonal == "cater" {
            self.personalChefView.isHidden = true
            self.payStack.isHidden = true
            self.payButton.isHidden = true
            self.additionalButton.isHidden = false
            if item != nil {
                itemTitle.text = item!.itemTitle
                itemDescription.text = item!.itemDescription
                imgArr.append(item!.itemImage!)
                itemCalories.text = "Calories: \(item!.itemCalories)"
            } else {
                itemTitle.text = itemTitleI
                itemDescription.text = itemDescriptionI
                imgArr.append(itemImage!)
            }
            
            loadImages()
            loadReviews(itemType: item!.itemType, documentId: item!.menuItemId)
            self.pageControl.numberOfPages = self.imgArr.count
            self.pageControl.currentPage = 0
            sliderCollectionView.reloadData()
        
        } else if caterOrPersonal == "personal" {
            loadExecutiveItem()
            
        } else if isMealKit != "" {
            
            self.mealKitView.isHidden = false
            
            self.additionalButton.isHidden = true
            self.reviewButton.isHidden = true
            self.ratingStack.isHidden = true
            loadMealKitDeliveryImages()
            if Auth.auth().currentUser!.displayName! == "Chef" {
                self.itemDescription.text = "Please upload pictures of your meal kit preperation, shipping containers, and shipping label, for your customer to approve."
                if Auth.auth().currentUser!.displayName! == "Chef" {
                    self.uploadButton.isHidden = false
                } else {
                    self.acceptDenyStack.isHidden = false
                }
                self.acceptButton.isEnabled = false
                self.denyButton.isEnabled = false
                self.cancelButton.isHidden = false
                self.uploadImageButton.isHidden = false
                self.itemTitle.isHidden = true
                self.viewLabel.text = "MealKit Delivery"
            } else {
                self.itemDescription.text = "Here, you can expect pictures from  your chef of meal kit preperation, shipping containers, and shipping label, for you to approve. Please keep us informed with any problems."
                self.acceptDenyStack.isHidden = false
                self.uploadButton.isHidden = true
                
            }
            self.pageControl.numberOfPages = self.imgArr.count
            self.pageControl.currentPage = 0
            sliderCollectionView.reloadData()
        
            
        } else {
                //personal chef dish view
            self.reviewButton.isHidden = true
            self.personalChefView.isHidden = true
            self.payStack.isHidden = true
            self.payButton.isHidden = true
            
            self.additionalButton.isHidden = false
            self.itemTitle.isHidden = false
            self.sliderCollectionView.isHidden = false
            self.itemDescription.isHidden = false
            
            if item != nil {
                itemTitle.text = item!.itemTitle
                itemDescription.text = item!.itemDescription
                imgArr.append(item!.itemImage!)
                itemCalories.text = "Calories: \(item!.itemCalories)"
            } else {
                itemTitle.text = itemTitleI
                itemDescription.text = itemDescriptionI
                
            }
            
            loadDish()
                self.pageControl.numberOfPages = self.imgArr.count
                self.pageControl.currentPage = 0
                sliderCollectionView.reloadData()
            
        }
            
        
            
        } else {
              self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
        }
        
        // Do any additional setup after loading the view.
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
    
    
    private func loadExecutiveItem() {
        db.collection("Chef").document(personalChefInfo!.chefImageId).collection("Executive Items").getDocuments { documents, error in
            if error == nil {
                for doc in documents!.documents {
                    let data = doc.data()
                    
                    let typeOfInfo = data["typeOfService"] as? String
                    
                    if typeOfInfo == "info" {
                        if let briefIntroduction = data["briefIntroduction"] as? String, let lengthOfPersonalChef = data["lengthOfPersonalChef"] as? String, let specialty = data["specialty"] as? String, let servicePrice = data["servicePrice"] as? String, let expectations = data["expectations"] as? Int, let chefRating = data["chefRating"] as? Int, let quality = data["quality"] as? Int, let chefName = data["chefName"] as? String, let whatHelpsYouExcel = data["whatHelpsYouExcel"] as? String, let mostPrizedAccomplishment = data["mostPrizedAccomplishment"] as? String, let weeks = data["weeks"] as? Int, let months = data["months"] as? Int, let trialRun = data["trialRun"] as? Int, let hourlyOrPersSession = data["hourlyOrPerSession"] as? String, let liked = data["liked"] as? [String], let itemOrders = data["itemOrders"] as? Int, let itemRating = data["itemRating"] as? [Double], let complete = data["complete"] as? String, let city = data["city"] as? String, let state = data["state"] as? String, let zipCode = data["zipCode"] as? String, let chefImageId = data["chefImageId"] as? String, let chefEmail = data["chefEmail"] as? String, let openToMenuRequests = data["openToMenuRequests"] as? String {
                            
                            var availability = ""
                            if trialRun == 1 {
                                availability = "Trial Run"
                            }
                            if weeks == 1 {
                                availability = "\(availability)  Weeks"
                            }
                            if months == 1 {
                                availability = "\(availability)  Months"
                            }
                            
                            self.personalChefInfo = PersonalChefInfo(chefName: chefName, chefEmail: chefEmail, chefImageId: chefImageId, chefImage: self.personalChefInfo!.chefImage, city: city, state: state, zipCode: zipCode, signatureDishImage: self.personalChefInfo!.signatureDishImage, signatureDishId: "", option1Title: "", option2Title: "", option3Title: "", option4Title: "", briefIntroduction: briefIntroduction, howLongBeenAChef: lengthOfPersonalChef, specialty: specialty, whatHelpesYouExcel: whatHelpsYouExcel, mostPrizedAccomplishment: mostPrizedAccomplishment, availabilty: availability, hourlyOrPerSession: hourlyOrPersSession, servicePrice: servicePrice, trialRun: trialRun, weeks: weeks, months: months, liked: liked, itemOrders: itemOrders, itemRating: itemRating, expectations: expectations, chefRating: chefRating, quality: quality, documentId: doc.documentID, openToMenuRequests: openToMenuRequests)
                            
                            self.personalChefView.isHidden = false
                            self.payStack.isHidden = false
                            self.payButton.isHidden = false
                            self.additionalButton.isHidden = true
                            self.openToMenuRequests.text = openToMenuRequests
                            
                            
                            self.signatureImage.image = self.personalChefInfo!.signatureDishImage
                            self.signatureImage.layer.cornerRadius = 6
                            
                            
                            self.briefIntroduction.text = self.personalChefInfo!.briefIntroduction
                            self.howLongBeenAChef.text = lengthOfPersonalChef
                            self.specialty.text = specialty
                            self.whatHelpsYouExcel.text = whatHelpsYouExcel
                            self.mostPrizedAccomplishment.text = mostPrizedAccomplishment
                            self.availableText.text = availability
                            self.openToMenuRequests.text = openToMenuRequests
                            self.priceLabel.text = "$\(servicePrice)"
                            self.loadReviews(itemType: "Executive Items", documentId: doc.documentID)
                            
                        }
                    } else if typeOfInfo == "Signature Dish" {
                        let itemTitle = data["itemTitle"] as! String
                        self.signatureTitle.text = itemTitle
                    } else if typeOfInfo == "Option 1" {
                        let itemTitle = data["itemTitle"] as! String
                        self.option1Text.text = itemTitle
                        self.option1Button.isHidden = false
                        self.option1Text.isHidden = false
                        self.option1Text.textColor = UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1)
                    } else if typeOfInfo == "Option 2" {
                        let itemTitle = data["itemTitle"] as! String
                        self.option2Text.text = itemTitle
                        self.option2Text.isHidden = false
                        self.option2Button.isHidden = false
                        self.option2Text.textColor = UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1)
                    } else if typeOfInfo == "Option 3" {
                        let itemTitle = data["itemTitle"] as! String
                        self.option3Text.text = itemTitle
                        self.option3Text.isHidden = false
                        self.option3Button.isHidden = false
                        self.option3Text.textColor = UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1)
                    } else if typeOfInfo == "Option 4" {
                        let itemTitle = data["itemTitle"] as! String
                        self.option4Text.text = itemTitle
                        self.option4Text.isHidden = false
                        self.option4Button.isHidden = false
                        self.option4Text.textColor = UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1)
                    }
                }
            }
        }
    }
    
    private func loadDish() {
        
        db.collection("Chef").document(personalChefInfo!.chefImageId).collection("Executive Items").getDocuments { documents, error in
            if error == nil {
                for doc in documents!.documents {
                    let data = doc.data()
                    
                    let typeOfInfo = data["typeOfService"] as! String
                    print("typeofinfo \(typeOfInfo)")
                    print("cater or personal \(self.caterOrPersonal)")
                    if typeOfInfo == self.caterOrPersonal {
                        print("type of info happening")
                        if let itemTitle = data["itemTitle"] as? String, let imageCount = data["imageCount"] as? Int, let chefEmail = data["chefEmail"] as? String, let itemDescription = data["itemDescription"] as? String, let itemCalories = data["itemCalories"] as? String {
                            
                            self.itemCalories.text = "Calories: \(itemCalories)"
                            self.itemTitle.text = itemTitle
                            self.itemDescription.text = itemDescription
                            self.reviewButton.isHidden = true
                            self.payStack.isHidden = true
                            self.itemType = "Executive Items"
                            self.chefImageId = self.personalChefInfo!.chefImageId
                            self.menuItemId = doc.documentID
                            
                            
                            for i in 0..<imageCount {
                                self.storage.reference().child("chefs/\(chefEmail)/Executive Items/\(doc.documentID)\(i).png").downloadURL { imageUrl, error in
                                    if error == nil {
                                        URLSession.shared.dataTask(with: imageUrl!) { (data, response, error) in
                                            // Error handling...
                                            guard let imageData = data else { return }
                                            
                                            print("happening itemdata")
                                            DispatchQueue.main.async {
                                                self.imgArr.append(UIImage(data: imageData)!)
                                                self.pageControl.numberOfPages = self.imgArr.count
                                                self.sliderCollectionView.reloadData()
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
    }
    
    
    
    
    private func loadReviews(itemType: String, documentId: String) {
        
        
        let storageRef = storage.reference()
        
        db.collection(itemType).document(documentId).collection("UserReviews").addSnapshotListener { documents, error in
            if error == nil {
                if documents != nil {
                    for doc in documents!.documents {
                        let data = doc.data()
                        
                        if let date = data["date"] as? String, let expectations = data["expectations"] as? Int, let likes = data["liked"] as? [String], let quality = data["quality"] as? Int, let recommend = data["recommend"] as? Int, let chefRating = data["chefRating"] as? Int, let thoughts = data["thoughts"] as? String, let userImageId = data["userImageId"] as? String, let userEmail = data["userEmail"] as? String {
                            
                            if let index = self.reviews.firstIndex(where: { $0.documentId == doc.documentID }) {} else {
                            
                                       
                                DispatchQueue.main.async {

                                    self.reviews.append(Reviews(date: date, expectations: expectations, quality: quality, chefRating: chefRating, likes: likes, recommend: recommend, thoughts: thoughts, image: UIImage(), userImageId: userImageId, userEmail: userEmail, documentId: doc.documentID))
                                    
                                    self.reviewData.append(ReviewData(expectationsMet: expectations, quality: quality, chefRating: chefRating))
                                    self.expectationsData = self.expectationsData + expectations
                                    self.qualityData = self.qualityData + quality
                                    self.chefRatingData = self.chefRatingData + chefRating
                                    
                                    if self.reviewData.count == documents?.documents.count {
                                        var exp = self.expectationsData / self.reviewData.count
                                        var qual = self.qualityData / self.reviewData.count
                                        var chefr = self.chefRatingData / self.reviewData.count
                                        print("exp \(exp)")
                                        print("qual \(qual)")
                                        print("chefr \(chefr)")
                                        if exp > 4 {
                                            self.expectations1.image = UIImage(systemName: "star.fill")
                                            self.expectations2.image = UIImage(systemName: "star.fill")
                                            self.expecations3.image = UIImage(systemName: "star.fill")
                                            self.expecations4.image = UIImage(systemName: "star.fill")
                                            self.expecations5.image = UIImage(systemName: "star.fill")
                                        } else if exp > 3 && exp < 5 {
                                            self.expectations1.image = UIImage(systemName: "star.fill")
                                            self.expectations2.image = UIImage(systemName: "star.fill")
                                            self.expecations3.image = UIImage(systemName: "star.fill")
                                            self.expecations4.image = UIImage(systemName: "star.fill")
                                        } else if exp > 2 && exp < 4 {
                                            self.expectations1.image = UIImage(systemName: "star.fill")
                                            self.expectations2.image = UIImage(systemName: "star.fill")
                                            self.expecations3.image = UIImage(systemName: "star.fill")
                                        } else if exp > 1 && exp < 3 {
                                            self.expectations1.image = UIImage(systemName: "star.fill")
                                            self.expectations2.image = UIImage(systemName: "star.fill")
                                        } else if exp < 2 {
                                            self.expectations1.image = UIImage(systemName: "star.fill")
                                        }
                                        if qual > 4 {
                                            self.quality1.image = UIImage(systemName: "star.fill")
                                            self.quality2.image = UIImage(systemName: "star.fill")
                                            self.quality3.image = UIImage(systemName: "star.fill")
                                            self.quality4.image = UIImage(systemName: "star.fill")
                                            self.quality5.image = UIImage(systemName: "star.fill")
                                        } else if qual > 3 && qual < 5 {
                                            self.quality1.image = UIImage(systemName: "star.fill")
                                            self.quality2.image = UIImage(systemName: "star.fill")
                                            self.quality3.image = UIImage(systemName: "star.fill")
                                            self.quality4.image = UIImage(systemName: "star.fill")
                                        } else if qual > 2 && qual < 4 {
                                            self.quality1.image = UIImage(systemName: "star.fill")
                                            self.quality2.image = UIImage(systemName: "star.fill")
                                            self.quality3.image = UIImage(systemName: "star.fill")
                                        } else if qual > 1 && qual < 3 {
                                            self.quality1.image = UIImage(systemName: "star.fill")
                                            self.quality2.image = UIImage(systemName: "star.fill")
                                        } else if qual < 2 {
                                            self.quality1.image = UIImage(systemName: "star.fill")
                                        }
                                        
                                        if chefr > 4 {
                                            self.chefRating1.image = UIImage(systemName: "star.fill")
                                            self.chefRating2.image = UIImage(systemName: "star.fill")
                                            self.chefRating3.image = UIImage(systemName: "star.fill")
                                            self.chefRating4.image = UIImage(systemName: "star.fill")
                                            self.chefRating5.image = UIImage(systemName: "star.fill")
                                        } else if chefr > 3 && chefr < 5 {
                                            self.chefRating1.image = UIImage(systemName: "star.fill")
                                            self.chefRating2.image = UIImage(systemName: "star.fill")
                                            self.chefRating3.image = UIImage(systemName: "star.fill")
                                            self.chefRating4.image = UIImage(systemName: "star.fill")
                                        } else if chefr > 2 && chefr < 4 {
                                            self.chefRating1.image = UIImage(systemName: "star.fill")
                                            self.chefRating2.image = UIImage(systemName: "star.fill")
                                            self.chefRating3.image = UIImage(systemName: "star.fill")
                                        } else if chefr > 1 && chefr < 3 {
                                            self.chefRating1.image = UIImage(systemName: "star.fill")
                                            self.chefRating2.image = UIImage(systemName: "star.fill")
                                        } else if chefr < 2 {
                                            self.chefRating1.image = UIImage(systemName: "star.fill")
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
    
    
    private func loadImages() {
        if item != nil {
            itemType = item!.itemType
            imageCount = item!.imageCount
            menuItemId = item!.menuItemId
            chefEmail = item!.chefEmail
        }
        for i in 1..<imageCount {
            storage.reference().child("chefs/\(item!.chefEmail)/\(item!.itemType)/\(item!.menuItemId)\(i).png").downloadURL { itemUri, error in
                if error == nil {

                    URLSession.shared.dataTask(with: itemUri!) { (data, response, error) in
                              // Error handling...
                              guard let imageData = data else { return }

                        print("happening itemdata")
                              DispatchQueue.main.async {
                                  self.imgArr.append(UIImage(data: imageData)!)
                                  self.pageControl.numberOfPages = self.imgArr.count
                                  self.sliderCollectionView.reloadData()
                              }
                            }.resume()

                        
                    
                    
                }
            }
            
        }
    }
    
    private func loadMealKitDeliveryImages() {
        db.collection(Auth.auth().currentUser!.displayName!).document(Auth.auth().currentUser!.uid).collection("Orders").document(self.mealKitOrderId).collection("MealKit Delivery").document(self.mealKitOrderId).getDocument { document, error in
            if error == nil {
                if document != nil {
                    let data = document!.data()
                    self.mealKitNewOrEdit = "edit"
                    if let imageCount = data?["imageCount"] as? Int {
                        self.acceptButton.isEnabled = true
                        self.denyButton.isEnabled = true
                        self.uploadButton.isEnabled = true
                        self.uploadButton.setTitle("Save", for: .normal)
                        for i in 0..<imageCount {
                            var path = "mealKitDelivery/\(self.mealKitOrderId)\(i).png"
                            self.storage.reference().child(path).downloadURL { url, error in
                                URLSession.shared.dataTask(with: url!) { (data, response, error) in
                                          // Error handling...
                                          guard let imageData = data else { return }

                                    print("happening itemdata")
                                          DispatchQueue.main.async {
                                              let img = MenuItemImage(img: UIImage(data: imageData)!, imgPath: path)
                                              self.imgArr1.append(img)
                                              self.pageControl.numberOfPages = self.imgArr1.count
                                              self.sliderCollectionView.reloadData()
                                          }
                                        }.resume()
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func subscribeToTopic(userNotification: String, chefNotification: String, orderId: String, itemTitle: String) {
        let json: [String: Any] = ["notificationToken1": userNotification, "notificationToken2" : chefNotification, "topic" : orderId]
        
    
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        // MARK: Fetch the Intent client secret, Ephemeral Key secret, Customer ID, and publishable key
        var request = URLRequest(url: URL(string: "https://taiste-payments.onrender.com/subscribe-to-topic")!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
          guard let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
               
                let self = self else {
            // Handle error
            return
          }
            
          DispatchQueue.main.async {
              if Auth.auth().currentUser!.displayName == "Chef" {
                  if self.acceptOrDeny == "accepted" {
                      self.sendMessage(title: "Meal Kit Delivery Notification", notification: "\(self.receiverUserName) has accepted your image upload! Payout is on its way.", topic: orderId)
                  } else {
                      self.sendMessage(title: "Meal Kit Delivery Notification", notification: "\(self.receiverUserName) has denied your image upload. Our internal team will review this. In the meantime, please try again with new methods.", topic: orderId)
                  }
              } else {
                  self.sendMessage(title: "Meal Kit Delivery Notification", notification: "New images uploaded for your \(self.mealKitItemTitle) order; awaiting your approval.", topic: orderId)
              }
              
          }
        })
        task.resume()
    }
    
    private func sendMessage(title: String, notification: String, topic: String) {
        let json: [String: Any] = ["title": title, "notification" : notification, "topic" : topic]
        
    
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        // MARK: Fetch the Intent client secret, Ephemeral Key secret, Customer ID, and publishable key
        var request = URLRequest(url: URL(string: "https://taiste-payments.onrender.com/send-message")!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
          guard let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                
                let self = self else {
            // Handle error
            return
          }
            
          DispatchQueue.main.async {
              
          }
        })
        task.resume()
    }
    
    private func notify() {
        let date = Date()
        let df = DateFormatter()
        df.dateFormat = "MM-dd-yyyy hh:mm:ss a"
        db.collection(Auth.auth().currentUser!.displayName!).document(Auth.auth().currentUser!.uid).getDocument { document, error in
            if error == nil {
                if document != nil {
                let data = document!.data()
                
                    if let token = data?["notificationToken"] as? String {
                        var a = ""
                        if Auth.auth().currentUser!.displayName! == "Chef" {
                            self.db.collection("User").document(self.receiverImageId).getDocument { document, error in
                                if error == nil {
                                    if document != nil {
                                        let data = document!.data()
                                        if let token1 = data?["notificationToken"] as? String {
                                            self.subscribeToTopic(userNotification: token, chefNotification: token1, orderId: self.mealKitOrderId, itemTitle: self.mealKitItemTitle)
                                        }
                                    }
                                }
                            }
                            let data3: [String: Any] = ["notifications" : "yes"]
                            let data4: [String: Any] = ["notification" : "New images uploaded for your \(self.mealKitItemTitle) order.", "date" :  df.string(from: Date())]
                            self.db.collection("User").document(self.receiverImageId).updateData(data3)
                            self.db.collection("User").document(self.receiverImageId).collection("Notifications").document().setData(data4)
                        } else {
                            self.db.collection("Chef").document(self.receiverImageId).getDocument { document, error in
                                if error == nil {
                                    if document != nil {
                                        let data = document!.data()
                                        if let token1 = data?["notificationToken"] as? String {
                                            self.subscribeToTopic(userNotification: token, chefNotification: token1, orderId: self.mealKitOrderId, itemTitle: self.acceptOrDeny)
                                        }
                                    }
                                }
                            }
                            let data3: [String: Any] = ["notifications" : "yes"]
                            self.db.collection("Chef").document(self.receiverImageId).updateData(data3)
                            if self.acceptOrDeny == "accepted" {
                                let data4: [String: Any] = ["notification" : "\(self.receiverUserName) has accepted your image uploads! Your payout is on its way.", "date" :  df.string(from: Date())]
                                self.db.collection("Chef").document(self.receiverImageId).collection("Notifications").document().setData(data4)
                            } else if self.acceptOrDeny == "denied" {
                                let data4: [String: Any] = ["notification" : "\(self.receiverUserName) has denied your image upload. Our internal team will review this. In the meantime, please try again with new methods.", "date" : df.string(from: Date())]
                                self.db.collection("Chef").document(self.receiverImageId).collection("Notifications").document().setData(data4)
                            } else {
                                let data4: [String: Any] = ["notification" : "Your meal kit purchase, \(self.mealKitItemTitle), has new images to approve. ", "date" : df.string(from: Date())]
                                self.db.collection("User").document(self.receiverImageId).collection("Notifications").document().setData(data4)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func signatureDishButtonPressed(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ItemDetail") as? ItemDetailViewController {
            vc.caterOrPersonal = "Signature Dish"
            vc.personalChefInfo = personalChefInfo!
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func option1ButtonPressed(_ sender: Any) {
        if option1Text.text != "No Item" {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ItemDetail") as? ItemDetailViewController {
                vc.caterOrPersonal = "Option 1"
                vc.personalChefInfo = personalChefInfo!
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func option2ButtonPressed(_ sender: Any) {
        if option2Text.text != "No Item" {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ItemDetail") as? ItemDetailViewController {
                vc.caterOrPersonal = "Option 2"
                vc.personalChefInfo = personalChefInfo!
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func option3ButtonPressed(_ sender: Any) {
        if option3Text.text != "No Item" {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ItemDetail") as? ItemDetailViewController {
                vc.caterOrPersonal = "Option 3"
                vc.personalChefInfo = personalChefInfo!
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func option4ButtonPressed(_ sender: Any) {
        if option4Text.text != "No Item" {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ItemDetail") as? ItemDetailViewController {
                vc.caterOrPersonal = "Option 4"
                vc.personalChefInfo = personalChefInfo!
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func payButtonPressed(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "PersonalChefOrderDetail") as? PersonalChefOrderDetailViewController {
            vc.personalChefInfo = personalChefInfo
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    
    
    
    @IBAction func reviewsButtonPressed(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "Reviews") as? ReviewsViewController {
            vc.item = self.item
            vc.reviews = self.reviews
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func additionButtonPressed(_ sender: Any) {
        
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "MenuItemAdditions") as? MenuItemAdditionsViewController {
                if self.item != nil {
                    vc.typeOfItem = self.item!.itemType
                    vc.chefOrUser = "user"
                    vc.chefImageId = self.item!.chefImageId
                    vc.menuItemId = self.item!.menuItemId
                    vc.chefEmail = self.item!.chefEmail
                } else {
                    vc.typeOfItem = self.itemType
                    vc.chefOrUser = "user"
                    vc.chefImageId = self.personalChefInfo!.chefImageId
                    vc.menuItemId = self.menuItemId
                    vc.chefEmail = self.personalChefInfo!.chefEmail
                }
                self.present(vc, animated: true, completion: nil)
            }
        
    }
    
    
    
    @IBAction func cancelImageButtonPressed(_ sender: Any) {
        if Reachability.isConnectedToNetwork(){
        print("Internet Connection Available!")
    
        if mealKitNewOrEdit == "edit" {
            let alert = UIAlertController(title: "Are you sure you want to delete?", message: nil, preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (handler) in
                let storageRef = self.storage.reference()
                let renewRef = self.storage.reference()
                var path = self.imgArr1[self.currentIndex].imgPath
                
                for i in 0..<self.imgArr1.count {
                    Task {
                    try? await storageRef.child(self.imgArr1[i].imgPath).delete()
                    }
                    
                }
                self.imgArr1.remove(at: self.currentIndex)
                self.imgArrData.remove(at: self.currentIndex)
                if self.imgArr1.count == 0 {
                    self.cancelButton.isHidden = true
                }
                self.pageControl.numberOfPages = self.imgArr.count
                self.sliderCollectionView.reloadData()
                
                for i in 0..<self.imgArr.count {
                    renewRef.child("mealKitDelivery/\(self.mealKitOrderId)\(i).png").putData(self.imgArrData[i])
                }
                let data: [String: Any] = ["imageCount" : self.imgArr.count]
                self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("Orders").document(self.mealKitOrderId).collection("MealKit Delivery").document(self.mealKitOrderId).updateData(data)
                self.db.collection("User").document(self.receiverImageId).collection("Orders").document(self.mealKitOrderId).collection("MealKit Delivery").document(self.mealKitOrderId).updateData(data)
                self.showToast(message: "Image deleted.", font: .systemFont(ofSize: 12))
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (handler) in
                alert.dismiss(animated: true, completion: nil)
            }))
            present(alert, animated: true, completion: nil)
        } else {
        imgArr1.remove(at: currentIndex)
        imgArrData.remove(at: currentIndex)
            if self.imgArr1.count == 0 {
                self.cancelButton.isHidden = true
            }
        self.pageControl.numberOfPages = imgArr1.count
        self.sliderCollectionView.reloadData()
        }
            
    } else {
    self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
   }
    }
    @IBAction func uploadImageButtonPressed(_ sender: Any) {
        if Reachability.isConnectedToNetwork(){
        print("Internet Connection Available!")
     
            let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (handler) in
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    let image = UIImagePickerController()
                    image.allowsEditing = true
                    image.sourceType = .camera
                    image.delegate = self
                    //                image.mediaTypes = [UTType.image.identifier]
                    self.present(image, animated: true, completion: nil)
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (handler) in
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    let image = UIImagePickerController()
                    image.allowsEditing = true
                    image.delegate = self
                    self.present(image, animated: true, completion: nil)
                    
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (handler) in
                alert.dismiss(animated: true, completion: nil)
            }))
            present(alert, animated: true, completion: nil)
        
            
    } else {
    self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
   }
        
    }
    
    @IBAction func acceptButtonPressed(_ sender: Any) {
        if Reachability.isConnectedToNetwork(){
        print("Internet Connection Available!")
            
                let alert = UIAlertController(title: "Are you sure you want to delete this item?", message: nil, preferredStyle: .actionSheet)
                
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (handler) in
                    self.acceptOrDeny = "accepted"
                    let data : [String: Any] = ["acceptOrDeny" : "accept"]
                    self.notify()
                    self.db.collection("Chef").document(self.receiverImageId).collection("Orders").document(self.mealKitOrderId).collection("MealKit Delivery").document(self.mealKitOrderId).updateData(data)
                        self.db.collection("User").document(Auth.auth().currentUser!.uid).collection("Orders").document(self.mealKitOrderId).collection("MealKit Delivery").document(self.mealKitOrderId).updateData(data)
                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserTab") as? UserTabViewController {
                        self.showToast(message: "Item Accepted. Your items should arrive soon.", font: .systemFont(ofSize: 12))
                        self.present(vc, animated: true, completion: nil)
                    }
                    
                    
                }))
                
                alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (handler) in
                    alert.dismiss(animated: true, completion: nil)
                }))
                
                present(alert, animated: true, completion: nil)
       
        } else {
        self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
       }
    }
    
    
    @IBAction func denyButtonPressed(_ sender: Any) {
        if Reachability.isConnectedToNetwork(){
        print("Internet Connection Available!")
            let alert = UIAlertController(title: "Are you sure you want to delete this item?", message: nil, preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (handler) in
                self.acceptOrDeny = "denied"
                self.notify()
                let data : [String: Any] = ["acceptOrDeny" : "deny"]
                self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("Orders").document(self.mealKitOrderId).collection("MealKit Delivery").document(self.mealKitOrderId).updateData(data)
                self.db.collection("User").document(self.receiverImageId).collection("Orders").document(self.mealKitOrderId).collection("MealKit Delivery").document(self.mealKitOrderId).updateData(data)
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserTab") as? UserTabViewController {
                    self.showToast(message: "Item Denied.", font: .systemFont(ofSize: 12))
                    self.present(vc, animated: true, completion: nil)
                }
                
                
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (handler) in
                alert.dismiss(animated: true, completion: nil)
            }))
            
            present(alert, animated: true, completion: nil)
      
        } else {
        self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
       }
    }
    
    
    
    @IBAction func uploadButtonPressed(_ sender: Any) {
        if Reachability.isConnectedToNetwork(){
        print("Internet Connection Available!")
            if imgArr1.count > 0 {
                if mealKitNewOrEdit != "edit" {
                    let data : [String: Any] = ["imageCount" : imgArr1.count, "acceptOrDeny" : ""]
                    self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("Orders").document(self.mealKitOrderId).collection("MealKit Delivery").document(self.mealKitOrderId).setData(data)
                    self.db.collection("User").document(self.receiverImageId).collection("Orders").document(self.mealKitOrderId).collection("MealKit Delivery").document(self.mealKitOrderId).setData(data)
                    for i in 0..<imgArr1.count {
                        self.storage.reference().child("mealKitDelivery/\(self.mealKitOrderId)\(self.imgArr.count - 1).png").putData(imgArrData[i])
                    }
                } else {
                    let data : [String: Any] = ["imageCount" : imgArr1.count]
                    self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("Orders").document(self.mealKitOrderId).collection("MealKit Delivery").document(self.mealKitOrderId).updateData(data)
                    self.db.collection("User").document(self.receiverImageId).collection("Orders").document(self.mealKitOrderId).collection("MealKit Delivery").document(self.mealKitOrderId).updateData(data)
                }
                self.showToast(message: "Images Saved.", font: .systemFont(ofSize: 12))
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserTab") as? UserTabViewController {
                    self.present(vc, animated: true, completion: nil)
                }
            } else {
                self.showToast(message: "Please upload your images of containers, shipping box, and shipping label.", font: .systemFont(ofSize: 12))
            }
            
        } else {
            self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
           }
    }
    
    
    
}

extension ItemDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.isMealKit != "" {
            return imgArr1.count
        } else {
            return imgArr.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = sliderCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if let vc = cell.viewWithTag(111) as? UIImageView {
            if self.isMealKit != "" {
                vc.image = imgArr1[indexPath.row].img
            } else {
                vc.image = imgArr[indexPath.row]
            }
            
        }
       
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = sliderCollectionView.frame.size
        return CGSize(width: size.width, height: size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentIndex = Int(scrollView.contentOffset.x / sliderCollectionView.frame.size.width)
        pageControl.currentPage = currentIndex
        
    }
}

extension ItemDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        self.imgArr1.append(MenuItemImage(img: image, imgPath: ""))
        self.imgArrData.append(image.pngData()!)
        self.cancelButton.isHidden = false
        self.pageControl.numberOfPages = self.imgArr1.count
        var path = "mealKitDelivery/\(self.mealKitOrderId)\(self.imgArr.count - 1).png"
        if mealKitNewOrEdit == "edit" {
            let storageRef = self.storage.reference()
            storageRef.child(path).putData(image.pngData()!)
            
            let data: [String: Any] = ["imageCount" : self.imgArr1.count]
            self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("Orders").document(self.mealKitOrderId).collection("MealKit Delivery").document(self.mealKitOrderId).updateData(data)
            self.db.collection("User").document(self.receiverImageId).collection("Orders").document(self.mealKitOrderId).collection("MealKit Delivery").document(self.mealKitOrderId).updateData(data)
            
            self.showToast(message: "Image Added.", font: .systemFont(ofSize: 12))
        }
        self.sliderCollectionView.reloadData()
//        imageView.image = image
        print("image arr count\(self.imgArr.count)")
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    
}
