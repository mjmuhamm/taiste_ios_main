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
    @IBOutlet weak var chefName: UILabel!
    @IBOutlet weak var chefImage: UIImageView!
    @IBOutlet weak var signatureTitle: UILabel!
    @IBOutlet weak var signatureImage: UIImageView!
    
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
            loadReviews()
        } else if caterOrPersonal == "personal" {
            self.personalChefView.isHidden = false
            self.payStack.isHidden = false
            self.payButton.isHidden = false
            self.itemCalories.isHidden = true
            self.chefImage.image = personalChefInfo!.chefImage
            self.chefName.text = personalChefInfo!.chefName
            self.briefIntroduction.text = personalChefInfo!.briefIntroduction
            
        } else if caterOrPersonal == "dish" {
            self.reviewButton.isHidden = true
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
            loadReviews()
        }
        
        
        self.pageControl.numberOfPages = self.imgArr.count
        self.pageControl.currentPage = 0
        sliderCollectionView.reloadData()
        print("item \(item)")
        self.itemCalories.text = "Calories: \(item!.itemCalories)"
        

        
        // Do any additional setup after loading the view.
    }
    
    private func loadReviews() {
        let storageRef = storage.reference()
        
        db.collection(item!.itemType).document(item!.menuItemId).collection("UserReviews").addSnapshotListener { documents, error in
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
    
    @IBAction func chefImageButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func signatureDishButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func option1ButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func option2ButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func option3ButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func option4ButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func payButtonPressed(_ sender: Any) {
        
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
