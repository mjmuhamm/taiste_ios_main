//
//  MenuItemViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 4/27/23.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import MobileCoreServices
import UniformTypeIdentifiers

import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_Theming
import MaterialComponents.MaterialTextControls_FilledTextAreasTheming
import MaterialComponents.MaterialTextControls_FilledTextFieldsTheming
import MaterialComponents.MaterialTextControls_OutlinedTextAreasTheming
import MaterialComponents.MaterialTextControls_OutlinedTextFieldsTheming

class MenuItemViewController: UIViewController, UITextViewDelegate {
    
    private let db = Firestore.firestore()
    let storage = Storage.storage()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var itemTitle: UITextField!
    @IBOutlet weak var itemDescription: UITextView!
    @IBOutlet weak var itemCalories: UITextField!
    @IBOutlet weak var itemPrice: UITextField!
    
    @IBOutlet weak var sliderCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var burgerButton: MDCButton!
    @IBOutlet weak var creativeButton: MDCButton!
    @IBOutlet weak var lowCalButton: MDCButton!
    @IBOutlet weak var lowCarbButton: MDCButton!
    @IBOutlet weak var pastaButton: MDCButton!
    @IBOutlet weak var healthyButton: MDCButton!
    @IBOutlet weak var veganButton: MDCButton!
    @IBOutlet weak var seafoodButton: MDCButton!
    @IBOutlet weak var workoutButton: MDCButton!
    
    private var imgArr : [UIImage] = []
    private var imgArrData : [Data] = []
    
    var currentIndex = 0
    
    private var burger = 0
    private var creative = 0
    private var lowCal = 0
    private var lowCarb = 0
    private var pasta = 0
    private var healthy = 0
    private var vegan = 0
    private var seafood = 0
    private var workout = 0
    
    
    var newOrEdit = "new"
    var typeOfitem = ""
    var menuItemId = UUID().uuidString
    var chefPassion = ""
    var chefUsername = ""
    var city = ""
    var state = ""
    var latitude = ""
    var longitude = ""
    var profileImageId = ""
    var zipCode = ""
    var itemLikes = 0
    var itemOrders = 0
    var itemRating : [Double] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("menuitemid \(menuItemId)")
        print("toggle \(typeOfitem)")
        print("auth \(Auth.auth().currentUser!.uid)")
        self.sliderCollectionView.delegate = self
        self.sliderCollectionView.dataSource = self
        self.pageControl.currentPage = 0
        // Do any additional setup after loading the view.
        
        if newOrEdit == "edit" {
            loadEditedItem()
        }
        
        titleLabel.text = typeOfitem
    }
    
    private func loadEditedItem() {
        let storageRef = storage.reference()
        
        db.collection("Chef").document(Auth.auth().currentUser!.uid).collection(typeOfitem).document(menuItemId).getDocument { document, error in
            
            if error == nil {
                if document != nil {
                    let data = document!.data()
                    
                    if let itemTitle = data!["itemTitle"] as? String, let imageCount = data!["imageCount"] as? Int, let itemDescription = data!["itemDescription"] as? String, let itemLikes = data!["itemLikes"] as? Int, let itemOrders = data!["itemOrders"] as? Int, let itemRating = data!["itemRating"] as? [Double], let itemCalories = data!["itemCalories"] as? String, let itemPrice = data!["itemPrice"] as? String, let burger = data!["burger"] as? Int, let creative = data!["creative"] as? Int, let lowCal = data!["lowCal"] as? Int, let lowCarb = data!["lowCarb"] as? Int, let pasta = data!["pasta"] as? Int, let healthy = data!["healthy"] as? Int, let vegan = data!["vegan"] as? Int, let seafood = data!["seafood"] as? Int, let workout = data!["workout"] as? Int {
                        
                        for i in 0..<imageCount {
                            storageRef.child("chefs/\(Auth.auth().currentUser!.email!)/\(self.typeOfitem)/\(self.menuItemId)\(i).png").getData(maxSize: 15 * 1024 * 1024) { data, error in
                                
                                if error == nil {
                                    self.imgArrData.append(data!)
                                    self.imgArr.append(UIImage(data: data!)!)
                                    self.pageControl.numberOfPages = self.imgArr.count
                                    self.sliderCollectionView.reloadData()
                                }
                            }
                        }
                        
                        self.itemTitle.text = itemTitle
                        self.itemDescription.text = itemDescription
                        self.itemCalories.text = itemCalories
                        self.itemPrice.text = itemPrice
                        self.itemLikes = itemLikes
                        self.itemOrders = itemOrders
                        self.itemRating = itemRating
                        
                        if burger == 1 {
                            self.burgerButton.isSelected = true
                            self.burger = 1
                            self.burgerButton.setTitleColor(UIColor.white, for:.normal)
                            self.burgerButton.backgroundColor = UIColor(red:160/255, green: 162/255, blue: 104/255,alpha: 1)
                        }
                        if creative == 1 {
                            self.creativeButton.isSelected = true
                            self.creative = 1
                            self.creativeButton.setTitleColor(UIColor.white, for:.normal)
                            self.creativeButton.backgroundColor = UIColor(red:160/255, green: 162/255, blue: 104/255,alpha: 1)
                        }
                        if lowCal == 1 {
                            self.lowCalButton.isSelected = true
                            self.lowCal = 1
                            self.lowCalButton.setTitleColor(UIColor.white, for:.normal)
                            self.lowCalButton.backgroundColor = UIColor(red:160/255, green: 162/255, blue: 104/255,alpha: 1)
                        }
                        if lowCarb == 1 {
                            self.lowCarbButton.isSelected = true
                            self.lowCarb = 1
                            self.lowCarbButton.setTitleColor(UIColor.white, for:.normal)
                            self.lowCarbButton.backgroundColor = UIColor(red:160/255, green: 162/255, blue: 104/255,alpha: 1)
                        }
                        if pasta == 1 {
                            self.pastaButton.isSelected = true
                            self.pasta = 1
                            self.pastaButton.setTitleColor(UIColor.white, for:.normal)
                            self.pastaButton.backgroundColor = UIColor(red:160/255, green: 162/255, blue: 104/255,alpha: 1)
                        }
                        if healthy == 1 {
                            self.healthyButton.isSelected = true
                            self.healthy = 1
                            self.healthyButton.setTitleColor(UIColor.white, for:.normal)
                            self.healthyButton.backgroundColor = UIColor(red:160/255, green: 162/255, blue: 104/255,alpha: 1)
                        }
                        if vegan == 1 {
                            self.veganButton.isSelected = true
                            self.vegan = 1
                            self.veganButton.setTitleColor(UIColor.white, for:.normal)
                            self.veganButton.backgroundColor = UIColor(red:160/255, green: 162/255, blue: 104/255,alpha: 1)
                        }
                        if seafood == 1 {
                            self.seafoodButton.isSelected = true
                            self.seafood = 1
                            self.seafoodButton.setTitleColor(UIColor.white, for:.normal)
                            self.seafoodButton.backgroundColor = UIColor(red:160/255, green: 162/255, blue: 104/255,alpha: 1)
                        }
                        if workout == 1 {
                            self.workoutButton.isSelected = true
                            self.workout = 1
                            self.workoutButton.setTitleColor(UIColor.white, for:.normal)
                            self.workoutButton.backgroundColor = UIColor(red:160/255, green: 162/255, blue: 104/255,alpha: 1)
                        }
                        }
                }
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if itemDescription.textColor == UIColor.lightGray {
            itemDescription.text = nil
            itemDescription.textColor = UIColor(red:160/255, green: 162/255, blue: 104/255,alpha: 1)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if itemDescription.text.isEmpty {
            itemDescription.text = "Item Description"
            itemDescription.textColor = UIColor.lightGray
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelImageButtonPressed(_ sender: Any) {
        if newOrEdit == "edit" {
            let alert = UIAlertController(title: "Are you sure you want to delete?", message: nil, preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (handler) in
                let storageRef = self.storage.reference()
                storageRef.child("chefs/\(Auth.auth().currentUser!.email)/\(self.typeOfitem)/\(self.menuItemId)\(self.currentIndex).png").delete { error in
                    if error == nil {
                        self.showToast(message: "Image deleted.", font: .systemFont(ofSize: 12))
                        
                        self.imgArr.remove(at: self.currentIndex)
                        self.imgArrData.remove(at: self.currentIndex)
                        self.pageControl.numberOfPages = self.imgArr.count
                        self.sliderCollectionView.reloadData()
                    }
                }
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (handler) in
                alert.dismiss(animated: true, completion: nil)
            }))
            
            present(alert, animated: true, completion: nil)
       
        } else {
        imgArr.remove(at: currentIndex)
        imgArrData.remove(at: currentIndex)
        self.pageControl.numberOfPages = imgArr.count
        self.sliderCollectionView.reloadData()
        }
    }
    
    @IBAction func addImageButtonPressed(_ sender: Any) {
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
        
        
    }
    
    @IBAction func burgerButtonPressed(_ sender: Any) {
        if burgerButton.isSelected {
            burgerButton.isSelected = false
            burger = 0
            burgerButton.setTitleColor(UIColor(red:98/255, green: 99/255, blue: 72/255, alpha:1), for: .normal)
            burgerButton.backgroundColor = UIColor.white
        } else {
            burgerButton.isSelected = true
            burger = 1
            burgerButton.setTitleColor(UIColor.white, for:.normal)
            burgerButton.backgroundColor = UIColor(red:160/255, green: 162/255, blue: 104/255,alpha: 1)
        }
        
    }
    @IBAction func creativeButtonPressed(_ sender: Any) {
        if creativeButton.isSelected {
            creativeButton.isSelected = false
            creative = 0
            creativeButton.setTitleColor(UIColor(red:98/255, green: 99/255, blue: 72/255, alpha:1), for: .normal)
            creativeButton.backgroundColor = UIColor.white
        } else {
            creativeButton.isSelected = true
            creative = 1
            creativeButton.setTitleColor(UIColor.white, for:.normal)
            creativeButton.backgroundColor = UIColor(red:160/255, green: 162/255, blue: 104/255,alpha: 1)
        }
    }
    
    @IBAction func lowCalButtonPressed(_ sender: Any) {
        if lowCalButton.isSelected {
            lowCalButton.isSelected = false
            lowCal = 0
            lowCalButton.setTitleColor(UIColor(red:98/255, green: 99/255, blue: 72/255, alpha:1), for: .normal)
            lowCalButton.backgroundColor = UIColor.white
        } else {
            lowCalButton.isSelected = true
            lowCal = 1
            lowCalButton.setTitleColor(UIColor.white, for:.normal)
            lowCalButton.backgroundColor = UIColor(red:160/255, green: 162/255, blue: 104/255,alpha: 1)
        }
    }
    
    @IBAction func lowCarbButtonPressed(_ sender: Any) {
        if lowCarbButton.isSelected {
            lowCarbButton.isSelected = false
            lowCarb = 0
            lowCarbButton.setTitleColor(UIColor(red:98/255, green: 99/255, blue: 72/255, alpha:1), for: .normal)
            lowCarbButton.backgroundColor = UIColor.white
        } else {
            lowCarbButton.isSelected = true
            lowCarb = 1
            lowCarbButton.setTitleColor(UIColor.white, for:.normal)
            lowCarbButton.backgroundColor = UIColor(red:160/255, green: 162/255, blue: 104/255,alpha: 1)
        }
    }
    
    @IBAction func pastaButtonPressed(_ sender: Any) {
        if pastaButton.isSelected {
            pastaButton.isSelected = false
            pasta = 0
            pastaButton.setTitleColor(UIColor(red:98/255, green: 99/255, blue: 72/255, alpha:1), for: .normal)
            pastaButton.backgroundColor = UIColor.white
        } else {
            pastaButton.isSelected = true
            pasta = 1
            pastaButton.setTitleColor(UIColor.white, for:.normal)
            pastaButton.backgroundColor = UIColor(red:160/255, green: 162/255, blue: 104/255,alpha: 1)
        }
    }
    
    @IBAction func healthyButtonPressed(_ sender: Any) {
        if healthyButton.isSelected {
            healthyButton.isSelected = false
            healthy = 0
            healthyButton.setTitleColor(UIColor(red:98/255, green: 99/255, blue: 72/255, alpha:1), for: .normal)
            healthyButton.backgroundColor = UIColor.white
        } else {
            healthyButton.isSelected = true
            healthy = 1
            healthyButton.setTitleColor(UIColor.white, for:.normal)
            healthyButton.backgroundColor = UIColor(red:160/255, green: 162/255, blue: 104/255,alpha: 1)
        }
    }
    
    @IBAction func veganButtonPressed(_ sender: Any) {
        if veganButton.isSelected {
            veganButton.isSelected = false
            vegan = 0
            veganButton.setTitleColor(UIColor(red:98/255, green: 99/255, blue: 72/255, alpha:1), for: .normal)
            veganButton.backgroundColor = UIColor.white
        } else {
            veganButton.isSelected = true
            vegan = 1
            veganButton.setTitleColor(UIColor.white, for:.normal)
            veganButton.backgroundColor = UIColor(red:160/255, green: 162/255, blue: 104/255,alpha: 1)
        }
    }
    
    @IBAction func seafoodButtonPressed(_ sender: Any) {
        if seafoodButton.isSelected {
            seafoodButton.isSelected = false
            seafood = 0
            seafoodButton.setTitleColor(UIColor(red:98/255, green: 99/255, blue: 72/255, alpha:1), for: .normal)
            seafoodButton.backgroundColor = UIColor.white
        } else {
            seafoodButton.isSelected = true
            seafood = 1
            seafoodButton.setTitleColor(UIColor.white, for:.normal)
            seafoodButton.backgroundColor = UIColor(red:160/255, green: 162/255, blue: 104/255,alpha: 1)
        }
    }
    
    @IBAction func workoutButtonPressed(_ sender: Any) {
        if workoutButton.isSelected {
            workoutButton.isSelected = false
            workout = 0
            workoutButton.setTitleColor(UIColor(red:98/255, green: 99/255, blue: 72/255, alpha:1), for: .normal)
            workoutButton.backgroundColor = UIColor.white
        } else {
            workoutButton.isSelected = true
            workout = 1
            workoutButton.setTitleColor(UIColor.white, for:.normal)
            workoutButton.backgroundColor = UIColor(red:160/255, green: 162/255, blue: 104/255,alpha: 1)
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if itemTitle.text == "" {
            self.showToast(message: "Please enter an item title.", font: .systemFont(ofSize: 12))
        } else if imgArr.count == 0 {
            self.showToast(message: "Please select at least 1 image.", font: .systemFont(ofSize: 12))
        } else if itemDescription.text == "" {
            self.showToast(message: "Please enter an item description.", font: .systemFont(ofSize: 12))
        } else if itemCalories.text == "" {
            self.showToast(message: "Please enter a number for calories", font: .systemFont(ofSize: 12))
        } else if itemPrice.text == "" {
            self.showToast(message: "Please enter a price.", font: .systemFont(ofSize: 12))
        } else {
        let storageRef = storage.reference()
        
        
        
        let data: [String: Any] = ["available" : "Yes", "burger" : burger, "chefEmail" : Auth.auth().currentUser!.email!, "chefPassion" : chefPassion, "chefUsername" : chefUsername, "city" : city, "creative" : creative, "date" : Date(), "healthy" : healthy, "imageCount" : imgArr.count, "itemCalories" : itemCalories.text!, "itemDescription" : itemDescription.text!, "itemLikes" : self.itemLikes, "itemOrders" : self.itemOrders, "itemPrice" : itemPrice.text!, "itemRating" : self.itemRating, "itemTitle" : itemTitle.text!, "itemType" : typeOfitem, "liked" : [], "lowCal" : lowCal, "lowCarb" : lowCarb, "pasta" : pasta, "profileImageId" : profileImageId, "quantityLimit" : "No Limit", "randomVariable" : menuItemId, "seafood" : seafood, "state" : state, "typeOfService" : typeOfitem, "user" : Auth.auth().currentUser!.email!, "vegan" : vegan, "workout" : workout, "zipCode" : zipCode]
        
        if newOrEdit == "new" {
            
            db.collection("Chef").document(Auth.auth().currentUser!.uid).collection(typeOfitem).document(menuItemId).setData(data)
            db.collection("\(self.typeOfitem)").document(menuItemId).setData(data)
            for i in 0..<imgArr.count {
                storageRef.child("chefs/\(Auth.auth().currentUser!.email!)/\(typeOfitem)/\(menuItemId)\(i).png").putData(imgArrData[i], metadata: nil) { data, error in
                    if error == nil {
                        
                        if i == self.imgArr.count-1 {
                            self.showToastCompletion(message: "Item Saved.", font: .systemFont(ofSize: 12))
                        }
                    }
                }
            }
        } else {
            db.collection("Chef").document(Auth.auth().currentUser!.uid).collection(typeOfitem).document(menuItemId).updateData(data)
            for i in 0..<imgArr.count {
                storageRef.child("chefs/\(Auth.auth().currentUser!.email!)/\(typeOfitem)/\(menuItemId)\(i).png").putData(imgArrData[i], metadata: nil) { data, error in
                    if error == nil {
                        
                        if i == self.imgArr.count-1 {
                            self.showToastCompletion(message: "Item Saved.", font: .systemFont(ofSize: 12))
                        }
                    }
                }
            }
        }
        
        
        
        }
        
    }
    
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
        UIView.animate(withDuration: 3.0, delay: 0.1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            self.performSegue(withIdentifier: "MenuItemToHomeSegue", sender: self)
            toastLabel.removeFromSuperview()
        })
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
        UIView.animate(withDuration: 3.0, delay: 0.1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

extension MenuItemViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        self.imgArr.append(image)
        self.imgArrData.append(image.pngData()!)
        self.pageControl.numberOfPages = self.imgArr.count
        self.sliderCollectionView.reloadData()
//        imageView.image = image
        print("image arr count\(self.imgArr.count)")
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    
}

extension MenuItemViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
