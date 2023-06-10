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
    @IBOutlet weak var itemCalories: UILabel!
    
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
    
    var personalChefInfo : PersonalChefInfo?
    var caterOrPersonal = ""
    var chefImageI : UIImage?
    var chefNameI = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signatureImage.layer.cornerRadius = 6
        if  caterOrPersonal == "cater" {
            self.personalChefView.isHidden = true
            self.payStack.isHidden = true
            self.payButton.isHidden = true
            self.itemCalories.isHidden = false
            if item != nil {
                itemTitle.text = item!.itemTitle
                itemDescription.text = item!.itemDescription
                imgArr.append(item!.itemImage!)
            } else {
                itemTitle.text = itemTitleI
                itemDescription.text = itemDescriptionI
                imgArr.append(itemImage!)
            }
            
            loadImages()
            loadReviews(itemType: item!.itemType, documentId: item!.menuItemId)
        } else if caterOrPersonal == "personal" {
            loadExecutiveItem()
            
        } else {
            self.reviewButton.isHidden = true
            self.personalChefView.isHidden = true
            self.payStack.isHidden = true
            self.payButton.isHidden = true
            self.itemCalories.isHidden = false
            self.itemTitle.isHidden = false
            self.sliderCollectionView.isHidden = false
            self.itemDescription.isHidden = false
            
            if item != nil {
                itemTitle.text = item!.itemTitle
                itemDescription.text = item!.itemDescription
                imgArr.append(item!.itemImage!)
            } else {
                itemTitle.text = itemTitleI
                itemDescription.text = itemDescriptionI
                
            }
            
            loadDish()
        }
        
        
        self.pageControl.numberOfPages = self.imgArr.count
        self.pageControl.currentPage = 0
        sliderCollectionView.reloadData()
        print("item \(item)")
        if item != nil {
            self.itemCalories.text = "Calories: \(item!.itemCalories)"
        }

        
        // Do any additional setup after loading the view.
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
                            self.itemCalories.isHidden = true
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
                        if let itemTitle = data["itemTitle"] as? String, let imageCount = data["imageCount"] as? Int, let chefEmail = data["chefEmail"] as? String, let itemDescription = data["itemDescription"] as? String {
                            
                            self.itemTitle.text = itemTitle
                            self.itemDescription.text = itemDescription
                            self.reviewButton.isHidden = true
                            self.payStack.isHidden = true
                            
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
    

}

extension ItemDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = sliderCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if let vc = cell.viewWithTag(111) as? UIImageView {
            vc.image = imgArr[indexPath.row]
            
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
