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
    
    @IBOutlet weak var itemCalories: UILabel!
    
    private var imgArr : [UIImage] = []

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if item != nil {
            itemTitle.text = item!.itemTitle
            itemDescription.text = item!.itemDescription
            imgArr.append(item!.itemImage!)
        } else {
            itemTitle.text = itemTitleI
            itemDescription.text = itemDescriptionI
            imgArr.append(itemImage!)
        }
        
        
        self.pageControl.numberOfPages = self.imgArr.count
        self.pageControl.currentPage = 0
        sliderCollectionView.reloadData()
        print("item \(item)")
        
        loadImages()

        
        // Do any additional setup after loading the view.
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
    
    @IBAction func reviewsButtonPressed(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "Reviews") as? ReviewsViewController {
            vc.item = self.item
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
