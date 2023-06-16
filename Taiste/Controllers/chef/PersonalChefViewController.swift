//
//  PersonalChefViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 6/4/23.
//

import UIKit
import Firebase
import FirebaseStorage
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_Theming
import MaterialComponents.MaterialTextControls_FilledTextAreasTheming
import MaterialComponents.MaterialTextControls_FilledTextFieldsTheming
import MaterialComponents.MaterialTextControls_OutlinedTextAreasTheming
import MaterialComponents.MaterialTextControls_OutlinedTextFieldsTheming

class PersonalChefViewController: UIViewController, UITextViewDelegate {
    
    let db = Firestore.firestore()
    let storage = Storage.storage()

    @IBOutlet weak var specialDishImage: UIImageView!

    @IBOutlet weak var briefIntroduction: UITextView!
    
    @IBOutlet weak var option1Button: UIButton!
    @IBOutlet weak var option1Text: UILabel!
    
    @IBOutlet weak var option2Button: UIButton!
    @IBOutlet weak var option2Text: UILabel!
    
    @IBOutlet weak var option3Button: UIButton!
    @IBOutlet weak var option3Text: UILabel!
    
    @IBOutlet weak var option4Button: UIButton!
    @IBOutlet weak var option4Text: UILabel!
    
    @IBOutlet weak var hourlyButton: MDCButton!
    @IBOutlet weak var perSessionButton: MDCButton!
    @IBOutlet weak var personalChefPrice: UITextField!
    
    @IBOutlet weak var lengthOfPersonalChef: UITextField!
    @IBOutlet weak var specialty: UITextField!
    @IBOutlet weak var whatHelpsYouExcel: UITextField!
    @IBOutlet weak var mostPrizedAccomplishments: UITextField!
    
    @IBOutlet weak var trialRunButton: MDCButton!
    @IBOutlet weak var weeksButton: MDCButton!
    @IBOutlet weak var monthsButton: MDCButton!
    
    @IBOutlet weak var menuRequestsYesButton: MDCButton!
    @IBOutlet weak var menuRequestsNoButton: MDCButton!
    
    var personalChefItem: PersonalChefInfo?
    var chefName = ""
    var chefImageI : UIImage?
    private var documentId = UUID().uuidString
    var newOrEdit = "new"
    
    var hourlyOrPerSession = "hourly"
    var trialRun = 0
    var weeks = 0
    var months = 0
    
    var expectations = 0
    var chefRating = 0
    var quality = 0
    var liked : [String] = []
    var itemOrders = 0
    var itemRating = [0.0]
    
    var city = ""
    var state = ""
    var zipCode = ""
    var signatureDishId = ""
    var complete = ""
    var openToMenuRequests = "Yes"
   
    
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        briefIntroduction.delegate = self
        specialDishImage.layer.cornerRadius = 6
        if Reachability.isConnectedToNetwork(){
        print("Internet Connection Available!")
            loadPersonalChefInfo()
        } else {
            self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
        }
        
        print("color \(briefIntroduction.textColor)")
        

    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.textColor != UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1) {
                   textView.text = nil
                   textView.textColor = UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1)
               }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Brief Introduction, and why people should believe in your ability."
            textView.textColor = UIColor.lightGray
        }
    }
    
    private func loadPersonalChefInfo() {
        
        db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("Executive Items").getDocuments { documents, error in
            if error == nil {
                if documents != nil {
                    print("documents \(documents)")
                    if documents!.count == 0 {
                        let info: [String: Any] = ["typeOfService" : "info", "briefIntroduction" : "", "lengthOfPersonalChef" : "", "specialty" : "", "whatHelpsYouExcel" : "", "trialRun" : self.trialRun, "weeks" : self.weeks, "months" : self.months, "hourlyOrPerSession" : self.hourlyOrPerSession, "servicePrice" : "", "expectations" : 0, "chefRating" : 0, "quality" : 0, "chefName" : self.chefName, "mostPrizedAccomplishment" : "", "chefImageId" : Auth.auth().currentUser!.uid, "chefEmail" : Auth.auth().currentUser!.email!, "city" : self.city, "state": self.state, "zipCode" : self.zipCode, "liked" : [], "itemOrders" : 0, "itemRating" : [0.0], "complete" : "", "signatureDishId" : "", "openToMenuRequests" : "Yes"]
                        
                        self.personalChefItem = PersonalChefInfo(chefName: self.chefName, chefEmail: Auth.auth().currentUser!.email!, chefImageId: Auth.auth().currentUser!.uid, chefImage: self.chefImageI!, city: self.city, state: self.state, zipCode: self.zipCode, signatureDishImage: UIImage(), signatureDishId: "", option1Title: "", option2Title: "", option3Title: "", option4Title: "", briefIntroduction: "", howLongBeenAChef: "", specialty: "", whatHelpesYouExcel: "", mostPrizedAccomplishment: "", availabilty: "", hourlyOrPerSession: "", servicePrice: "", trialRun: self.trialRun, weeks: self.weeks, months: self.months, liked: [], itemOrders: self.itemOrders, itemRating: [0.0], expectations: 0, chefRating: 0, quality: 0, documentId: self.documentId, openToMenuRequests: self.openToMenuRequests)
                        
                        self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("Executive Items").document(self.documentId).setData(info)
                    }
                    for doc in documents!.documents {
                        let data = doc.data()
                        let typeOfService = data["typeOfService"] as? String
                        
                        if typeOfService == "info" {
                            
                            if let briefIntroduction = data["briefIntroduction"] as? String, let lengthOfPersonalChef = data["lengthOfPersonalChef"] as? String, let specialty = data["specialty"] as? String, let servicePrice = data["servicePrice"] as? String, let expectations = data["expectations"] as? Int, let chefRating = data["chefRating"] as? Int, let quality = data["quality"] as? Int, let chefName = data["chefName"] as? String, let whatHelpsYouExcel = data["whatHelpsYouExcel"] as? String, let mostPrizedAccomplishment = data["mostPrizedAccomplishment"] as? String, let weeks = data["weeks"] as? Int, let months = data["months"] as? Int, let trialRun = data["trialRun"] as? Int, let hourlyOrPersSession = data["hourlyOrPerSession"] as? String, let liked = data["liked"] as? [String], let itemOrders = data["itemOrders"] as? Int, let itemRating = data["itemRating"] as? [Double], let complete = data["complete"] as? String, let openToMenuRequests = data["openToMenuRequests"] as? String {
                
                                self.briefIntroduction.text = briefIntroduction
                                if briefIntroduction != "Brief Introduction, and why people should believe in your ability." {
                                    self.briefIntroduction.textColor = UIColor(red:98/255, green: 99/255, blue: 72/255, alpha:1)
                                }
                                if briefIntroduction == "" {
                                    self.briefIntroduction.text = "Brief Introduction, and why people should believe in your ability."
                                    self.briefIntroduction.textColor = UIColor.lightGray
                                }
                                self.expectations = expectations
                                self.chefRating = chefRating
                                self.quality = quality
                                self.lengthOfPersonalChef.text = lengthOfPersonalChef
                                self.personalChefPrice.text = servicePrice
                                self.mostPrizedAccomplishments.text = mostPrizedAccomplishment
                                self.specialty.text = specialty
                                self.whatHelpsYouExcel.text = whatHelpsYouExcel
                                self.complete = complete
                                self.documentId = doc.documentID
                                print("this is document id origin \(self.documentId)")
                                var availability = ""
                                if trialRun != 0 {
                                    availability = "Trial Run"
                                    self.trialRunButton.isSelected = true
                                    self.trialRun = 1
                                    self.trialRunButton.setTitleColor(UIColor.white, for:.normal)
                                    self.trialRunButton.backgroundColor = UIColor(red:160/255, green: 162/255, blue: 104/255,alpha: 1)
                                }
                                if weeks != 0 {
                                    availability = "\(availability)  Weeks"
                                    
                                    self.weeksButton.isSelected = true
                                    self.weeks = 1
                                    self.weeksButton.setTitleColor(UIColor.white, for:.normal)
                                    self.weeksButton.backgroundColor = UIColor(red:160/255, green: 162/255, blue: 104/255,alpha: 1)
                                }
                                if months != 0 {
                                    availability = "\(availability)  Months"
                                    self.monthsButton.isSelected = true
                                    self.months = 1
                                    self.monthsButton.setTitleColor(UIColor.white, for:.normal)
                                    self.monthsButton.backgroundColor = UIColor(red:160/255, green: 162/255, blue: 104/255,alpha: 1)
                                }
                                
                                self.openToMenuRequests = openToMenuRequests
                                if openToMenuRequests == "Yes" {
                                    availability = "\(availability)  Months"
                                    
                                    self.menuRequestsYesButton.setTitleColor(UIColor.white, for:.normal)
                                    self.menuRequestsYesButton.backgroundColor = UIColor(red:160/255, green: 162/255, blue: 104/255,alpha: 1)
                                    self.menuRequestsNoButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
                                    self.menuRequestsNoButton.backgroundColor = UIColor.white
                                } else {
                                    self.menuRequestsNoButton.setTitleColor(UIColor.white, for:.normal)
                                    self.menuRequestsNoButton.backgroundColor = UIColor(red:160/255, green: 162/255, blue: 104/255,alpha: 1)
                                    self.menuRequestsYesButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
                                    self.menuRequestsYesButton.backgroundColor = UIColor.white
                                }
                                let storageRef = self.storage.reference()
                                let imageRef = self.storage.reference()
                                
                                self.personalChefItem = PersonalChefInfo(chefName: chefName, chefEmail: Auth.auth().currentUser!.email!, chefImageId: Auth.auth().currentUser!.uid, chefImage: UIImage(), city: self.city, state: self.state, zipCode: self.zipCode, signatureDishImage: UIImage(), signatureDishId: "", option1Title: "", option2Title: "", option3Title: "", option4Title: "", briefIntroduction: briefIntroduction, howLongBeenAChef: lengthOfPersonalChef, specialty: specialty, whatHelpesYouExcel: whatHelpsYouExcel, mostPrizedAccomplishment: mostPrizedAccomplishment, availabilty: availability, hourlyOrPerSession: hourlyOrPersSession, servicePrice: servicePrice, trialRun: trialRun, weeks: weeks, months: months, liked: liked, itemOrders: itemOrders, itemRating: itemRating, expectations: expectations, chefRating: chefRating, quality: quality, documentId: doc.documentID, openToMenuRequests: openToMenuRequests)
                                
                                
                            }
                            
                        } else {
                            
                            if typeOfService == "Signature Dish" {
                                self.signatureDishId = doc.documentID
                                self.storage.reference().child("chefs/\(Auth.auth().currentUser!.email!)/Executive Items/\(doc.documentID)0.png").downloadURL { imageUrl, error in
                                    if error == nil {
                                        URLSession.shared.dataTask(with: imageUrl!) { (data, response, error) in
                                            // Error handling...
                                            guard let imageData = data else { return }
                                            
                                            print("happening itemdata")
                                            DispatchQueue.main.async {
                                                self.specialDishImage.image = UIImage(data: imageData)!
                                                if self.personalChefItem != nil {
                                                    self.personalChefItem!.signatureDishImage = UIImage(data: imageData)!
                                                }
                                            }
                                        }.resume()
                                    }
                                }
                            } else if typeOfService == "Option 1" {
                                let itemTitle = data["itemTitle"] as! String
                                self.option1Text.text = itemTitle
                                if self.personalChefItem != nil {
                                    self.personalChefItem!.option1Title = itemTitle
                                    self.option2Button.isHidden = false
                                    self.option2Text.isHidden = false
                                }
                            } else if typeOfService == "Option 2" {
                                let itemTitle = data["itemTitle"] as! String
                                self.option2Text.text = itemTitle
                                
                                if self.personalChefItem != nil {
                                    self.personalChefItem!.option2Title = itemTitle
                                    self.option3Button.isHidden = false
                                    self.option3Text.isHidden = false
                                }
                            } else if typeOfService == "Option 3" {
                                let itemTitle = data["itemTitle"] as! String
                                self.option3Text.text = itemTitle
                                
                                if self.personalChefItem != nil {
                                    self.personalChefItem!.option3Title = itemTitle
                                    self.option4Button.isHidden = false
                                    self.option4Text.isHidden = false
                                }
                            } else if typeOfService == "Option 4" {
                                let itemTitle = data["itemTitle"] as! String
                                self.option4Text.text = itemTitle
                                
                                if self.personalChefItem != nil {
                                    self.personalChefItem!.option4Title = itemTitle
                                }
                            }
                        }
                        }
                        
                }
                
            }
        }
    }
    
    
    
    @IBAction func addSpecialDishImage(_ sender: Any) {
        if Reachability.isConnectedToNetwork(){
        print("Internet Connection Available!")
            
       
        let info: [String: Any] = ["typeOfService" : "info", "briefIntroduction" : briefIntroduction.text!, "lengthOfPersonalChef" : lengthOfPersonalChef.text!, "specialty" : specialty.text!, "whatHelpsYouExcel" : whatHelpsYouExcel.text!, "trialRun" : self.trialRun, "weeks" : self.weeks, "months" : self.months, "hourlyOrPerSession" : self.hourlyOrPerSession, "servicePrice" : personalChefPrice.text!, "expectations" : self.expectations, "chefRating" : self.chefRating, "quality" : self.quality, "chefName" : self.chefName, "mostPrizedAccomplishment" : mostPrizedAccomplishments.text!, "chefImageId" : Auth.auth().currentUser!.uid, "chefEmail" : Auth.auth().currentUser!.email!, "city" : self.city, "state": self.state, "liked" : [], "itemOrders" : 0, "itemRating" : [0.0], "openToMenuRequests" : self.openToMenuRequests]
        
        self.personalChefItem = PersonalChefInfo(chefName: self.chefName, chefEmail: Auth.auth().currentUser!.email!, chefImageId: Auth.auth().currentUser!.uid, chefImage: self.chefImageI!, city: self.city, state: self.state, zipCode: self.zipCode, signatureDishImage: UIImage(), signatureDishId: "", option1Title: "", option2Title: "", option3Title: "", option4Title: "", briefIntroduction: briefIntroduction.text!, howLongBeenAChef: lengthOfPersonalChef.text!, specialty: specialty.text!, whatHelpesYouExcel: whatHelpsYouExcel.text!, mostPrizedAccomplishment: mostPrizedAccomplishments.text!, availabilty: "", hourlyOrPerSession: self.hourlyOrPerSession, servicePrice: personalChefPrice.text!, trialRun: self.trialRun, weeks: self.weeks, months: self.months, liked: [], itemOrders: self.itemOrders, itemRating: self.itemRating, expectations: 0, chefRating: 0, quality: 0, documentId: self.documentId, openToMenuRequests: self.openToMenuRequests)
        
        self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("Executive Items").document(self.documentId).updateData(info)
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "MenuItem") as? MenuItemViewController {
            vc.newOrEdit = "signature"
            vc.city = self.city
            vc.state = self.state
            vc.zipCode = self.zipCode
            vc.chefUsername = self.chefName
            vc.typeOfitem = "Signature Dish"
            vc.personalChefItem = self.personalChefItem
            self.present(vc, animated: true, completion: nil)
        }
        
        } else {
            self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
        }
    }
    
    @IBAction func option1ButtonPressed(_ sender: Any) {
        if Reachability.isConnectedToNetwork(){
        print("Internet Connection Available!")
        
        
        let info: [String: Any] = ["typeOfService" : "info", "briefIntroduction" : briefIntroduction.text!, "lengthOfPersonalChef" : lengthOfPersonalChef.text!, "specialty" : specialty.text!, "whatHelpsYouExcel" : whatHelpsYouExcel.text!, "trialRun" : self.trialRun, "weeks" : self.weeks, "months" : self.months, "hourlyOrPerSession" : self.hourlyOrPerSession, "servicePrice" : personalChefPrice.text!, "expectations" : 0, "chefRating" : 0, "quality" : 0, "chefName" : self.chefName, "mostPrizedAccomplishment" : mostPrizedAccomplishments.text!, "chefImageId" : Auth.auth().currentUser!.uid, "chefEmail" : Auth.auth().currentUser!.email!, "city" : self.city, "state": self.state, "liked" : [], "itemOrders" : 0, "itemRating" : [0.0], "openToMenuRequests": self.openToMenuRequests]
        
        self.personalChefItem = PersonalChefInfo(chefName: self.chefName, chefEmail: Auth.auth().currentUser!.email!, chefImageId: Auth.auth().currentUser!.uid, chefImage: self.chefImageI!, city: self.city, state: self.state, zipCode: self.zipCode, signatureDishImage: UIImage(), signatureDishId: "", option1Title: "", option2Title: "", option3Title: "", option4Title: "", briefIntroduction: briefIntroduction.text!, howLongBeenAChef: lengthOfPersonalChef.text!, specialty: specialty.text!, whatHelpesYouExcel: whatHelpsYouExcel.text!, mostPrizedAccomplishment: mostPrizedAccomplishments.text!, availabilty: "", hourlyOrPerSession: self.hourlyOrPerSession, servicePrice: personalChefPrice.text!, trialRun: self.trialRun, weeks: self.weeks, months: self.months, liked: [], itemOrders: self.itemOrders, itemRating: self.itemRating, expectations: 0, chefRating: 0, quality: 0, documentId: self.documentId, openToMenuRequests: self.openToMenuRequests)
        
        self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("Executive Items").document(self.documentId).updateData(info)
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "MenuItem") as? MenuItemViewController {
            vc.newOrEdit = "option1"
            vc.city = self.city
            vc.state = self.state
            vc.chefUsername = self.chefName
            vc.zipCode = self.zipCode
            vc.typeOfitem = "Option 1"
            vc.personalChefItem = self.personalChefItem
            self.present(vc, animated: true, completion: nil)
        }
        } else {
            self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
        }
    }
    
    @IBAction func option2ButtonPressed(_ sender: Any) {
        if Reachability.isConnectedToNetwork(){
        print("Internet Connection Available!")
       
        let info: [String: Any] = ["typeOfService" : "info", "briefIntroduction" : briefIntroduction.text!, "lengthOfPersonalChef" : lengthOfPersonalChef.text!, "specialty" : specialty.text!, "whatHelpsYouExcel" : whatHelpsYouExcel.text!, "trialRun" : self.trialRun, "weeks" : self.weeks, "months" : self.months, "hourlyOrPerSession" : self.hourlyOrPerSession, "servicePrice" : personalChefPrice.text!, "expectations" : 0, "chefRating" : 0, "quality" : 0, "chefName" : self.chefName, "mostPrizedAccomplishment" : mostPrizedAccomplishments.text!, "chefImageId" : Auth.auth().currentUser!.uid, "chefEmail" : Auth.auth().currentUser!.email!, "city" : self.city, "state": self.state, "liked" : [], "itemOrders" : 0, "itemRating" : [0.0], "openToMenuRequests": self.openToMenuRequests]
        
        self.personalChefItem = PersonalChefInfo(chefName: self.chefName, chefEmail: Auth.auth().currentUser!.email!, chefImageId: Auth.auth().currentUser!.uid, chefImage: self.chefImageI!, city: self.city, state: self.state, zipCode: self.zipCode, signatureDishImage: UIImage(), signatureDishId: "", option1Title: "", option2Title: "", option3Title: "", option4Title: "", briefIntroduction: briefIntroduction.text!, howLongBeenAChef: lengthOfPersonalChef.text!, specialty: specialty.text!, whatHelpesYouExcel: whatHelpsYouExcel.text!, mostPrizedAccomplishment: mostPrizedAccomplishments.text!, availabilty: "", hourlyOrPerSession: self.hourlyOrPerSession, servicePrice: personalChefPrice.text!, trialRun: self.trialRun, weeks: self.weeks, months: self.months, liked: [], itemOrders: self.itemOrders, itemRating: self.itemRating, expectations: 0, chefRating: 0, quality: 0, documentId: self.documentId, openToMenuRequests: self.openToMenuRequests)
        
        self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("Executive Items").document(self.documentId).updateData(info)
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "MenuItem") as? MenuItemViewController {
            vc.newOrEdit = "option2"
            vc.city = self.city
            vc.chefUsername = self.chefName
            vc.state = self.state
            vc.zipCode = self.zipCode
            vc.typeOfitem = "Option 2"
            vc.personalChefItem = self.personalChefItem
            self.present(vc, animated: true, completion: nil)
        }
            
            } else {
                self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
            }
    }
    
    @IBAction func option3ButtonPressed(_ sender: Any) {
        if Reachability.isConnectedToNetwork(){
        print("Internet Connection Available!")
   
        let info: [String: Any] = ["typeOfService" : "info", "briefIntroduction" : briefIntroduction.text!, "lengthOfPersonalChef" : lengthOfPersonalChef.text!, "specialty" : specialty.text!, "whatHelpsYouExcel" : whatHelpsYouExcel.text!, "trialRun" : self.trialRun, "weeks" : self.weeks, "months" : self.months, "hourlyOrPerSession" : self.hourlyOrPerSession, "servicePrice" : personalChefPrice.text!, "expectations" : 0, "chefRating" : 0, "quality" : 0, "chefName" : self.chefName, "mostPrizedAccomplishment" : mostPrizedAccomplishments.text!, "chefImageId" : Auth.auth().currentUser!.uid, "chefEmail" : Auth.auth().currentUser!.email!, "city" : self.city, "state": self.state, "liked" : [], "itemOrders" : 0, "itemRating" : [0.0]]
        
        self.personalChefItem = PersonalChefInfo(chefName: self.chefName, chefEmail: Auth.auth().currentUser!.email!, chefImageId: Auth.auth().currentUser!.uid, chefImage: self.chefImageI!, city: self.city, state: self.state, zipCode: self.zipCode, signatureDishImage: UIImage(), signatureDishId: "", option1Title: "", option2Title: "", option3Title: "", option4Title: "", briefIntroduction: briefIntroduction.text!, howLongBeenAChef: lengthOfPersonalChef.text!, specialty: specialty.text!, whatHelpesYouExcel: whatHelpsYouExcel.text!, mostPrizedAccomplishment: mostPrizedAccomplishments.text!, availabilty: "", hourlyOrPerSession: self.hourlyOrPerSession, servicePrice: personalChefPrice.text!, trialRun: self.trialRun, weeks: self.weeks, months: self.months, liked: [], itemOrders: self.itemOrders, itemRating: self.itemRating, expectations: 0, chefRating: 0, quality: 0, documentId: self.documentId, openToMenuRequests: self.openToMenuRequests)
        
        self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("Executive Items").document(self.documentId).updateData(info)
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "MenuItem") as? MenuItemViewController {
            vc.newOrEdit = "option3"
            vc.city = self.city
            vc.chefUsername = self.chefName
            vc.state = self.state
            vc.zipCode = self.zipCode
            vc.typeOfitem = "Option 3"
            vc.personalChefItem = self.personalChefItem
            self.present(vc, animated: true, completion: nil)
        }
            
        } else {
                self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
            }
    }
    
    @IBAction func option4ButtonPressed(_ sender: Any) {
        if Reachability.isConnectedToNetwork(){
        print("Internet Connection Available!")
    
        let info: [String: Any] = ["typeOfService" : "info", "briefIntroduction" : briefIntroduction.text!, "lengthOfPersonalChef" : lengthOfPersonalChef.text!, "specialty" : specialty.text!, "whatHelpsYouExcel" : whatHelpsYouExcel.text!, "trialRun" : self.trialRun, "weeks" : self.weeks, "months" : self.months, "hourlyOrPerSession" : self.hourlyOrPerSession, "servicePrice" : personalChefPrice.text!, "expectations" : 0, "chefRating" : 0, "quality" : 0, "chefName" : self.chefName, "mostPrizedAccomplishment" : mostPrizedAccomplishments.text!, "chefImageId" : Auth.auth().currentUser!.uid, "chefEmail" : Auth.auth().currentUser!.email!, "city" : self.city, "state": self.state, "liked" : [], "itemOrders" : 0, "itemRating" : [0.0], "openToMenuRequests": self.openToMenuRequests]
        
        self.personalChefItem = PersonalChefInfo(chefName: self.chefName, chefEmail: Auth.auth().currentUser!.email!, chefImageId: Auth.auth().currentUser!.uid, chefImage: self.chefImageI!, city: self.city, state: self.state, zipCode: self.zipCode, signatureDishImage: UIImage(), signatureDishId: "", option1Title: "", option2Title: "", option3Title: "", option4Title: "", briefIntroduction: briefIntroduction.text!, howLongBeenAChef: lengthOfPersonalChef.text!, specialty: specialty.text!, whatHelpesYouExcel: whatHelpsYouExcel.text!, mostPrizedAccomplishment: mostPrizedAccomplishments.text!, availabilty: "", hourlyOrPerSession: self.hourlyOrPerSession, servicePrice: personalChefPrice.text!, trialRun: self.trialRun, weeks: self.weeks, months: self.months, liked: [], itemOrders: self.itemOrders, itemRating: self.itemRating, expectations: 0, chefRating: 0, quality: 0, documentId: self.documentId, openToMenuRequests: self.openToMenuRequests)
        
        self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("Executive Items").document(self.documentId).updateData(info)
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "MenuItem") as? MenuItemViewController {
            vc.newOrEdit = "option4"
            vc.city = self.city
            vc.chefUsername = self.chefName
            vc.state = self.state
            vc.zipCode = self.zipCode
            vc.typeOfitem = "Option 4"
            vc.personalChefItem = self.personalChefItem
            self.present(vc, animated: true, completion: nil)
        }
            
    } else {
    self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
   }
    }
    
    @IBAction func trialRunButtonPressed(_ sender: Any) {
        if trialRunButton.isSelected {
            trialRunButton.isSelected = false
            trialRun = 0
            trialRunButton.setTitleColor(UIColor(red:98/255, green: 99/255, blue: 72/255, alpha:1), for: .normal)
            trialRunButton.backgroundColor = UIColor.white
        } else {
            trialRunButton.isSelected = true
            trialRun = 1
            trialRunButton.setTitleColor(UIColor.white, for:.normal)
            trialRunButton.backgroundColor = UIColor(red:160/255, green: 162/255, blue: 104/255,alpha: 1)
        }
    }
    
    @IBAction func weeksButtonPressed(_ sender: Any) {
        if weeksButton.isSelected {
            weeksButton.isSelected = false
            weeks = 0
            weeksButton.setTitleColor(UIColor(red:98/255, green: 99/255, blue: 72/255, alpha:1), for: .normal)
            weeksButton.backgroundColor = UIColor.white
        } else {
            weeksButton.isSelected = true
            weeks = 1
            weeksButton.setTitleColor(UIColor.white, for:.normal)
            weeksButton.backgroundColor = UIColor(red:160/255, green: 162/255, blue: 104/255,alpha: 1)
        }
    }
    
    @IBAction func monthsButtonPressed(_ sender: Any) {
        if monthsButton.isSelected {
            monthsButton.isSelected = false
            months = 0
            monthsButton.setTitleColor(UIColor(red:98/255, green: 99/255, blue: 72/255, alpha:1), for: .normal)
            monthsButton.backgroundColor = UIColor.white
        } else {
            monthsButton.isSelected = true
            months = 1
            monthsButton.setTitleColor(UIColor.white, for:.normal)
            monthsButton.backgroundColor = UIColor(red:160/255, green: 162/255, blue: 104/255,alpha: 1)
        }
    }
    
    
    @IBAction func menuRequestsYesButtonPressed(_ sender: Any) {
        menuRequestsNoButton.setTitleColor(UIColor(red:98/255, green: 99/255, blue: 72/255, alpha:1), for: .normal)
        menuRequestsNoButton.backgroundColor = UIColor.white
        menuRequestsYesButton.setTitleColor(UIColor.white, for:.normal)
        menuRequestsYesButton.backgroundColor = UIColor(red:160/255, green: 162/255, blue: 104/255,alpha: 1)
    }
    
    @IBAction func menuRequestsNoButtonPressed(_ sender: Any) {
        menuRequestsYesButton.setTitleColor(UIColor(red:98/255, green: 99/255, blue: 72/255, alpha:1), for: .normal)
        menuRequestsYesButton.backgroundColor = UIColor.white
        menuRequestsNoButton.setTitleColor(UIColor.white, for:.normal)
        menuRequestsNoButton.backgroundColor = UIColor(red:160/255, green: 162/255, blue: 104/255,alpha: 1)
    }
    
    @IBAction func hourlyButtonPressed(_ sender: Any) {
        hourlyOrPerSession = "hourly"
        
        perSessionButton.setTitleColor(UIColor(red:98/255, green: 99/255, blue: 72/255, alpha:1), for: .normal)
        perSessionButton.backgroundColor = UIColor.white
        hourlyButton.setTitleColor(UIColor.white, for:.normal)
        hourlyButton.backgroundColor = UIColor(red:160/255, green: 162/255, blue: 104/255,alpha: 1)
        
        
    }
    
    @IBAction func perSessionButtonPressed(_ sender: Any) {
        hourlyOrPerSession = "perSession"
        hourlyButton.setTitleColor(UIColor(red:98/255, green: 99/255, blue: 72/255, alpha:1), for: .normal)
        hourlyButton.backgroundColor = UIColor.white
        perSessionButton.setTitleColor(UIColor.white, for:.normal)
        perSessionButton.backgroundColor = UIColor(red:160/255, green: 162/255, blue: 104/255,alpha: 1)
        
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if Reachability.isConnectedToNetwork(){
        print("Internet Connection Available!")
    
        if briefIntroduction.text == "Brief Introduction and why people should believe in your ability." || briefIntroduction.text == "" {
            showToast(message: "Please provide a brief introduction of why people should believe in your ability.", font: .systemFont(ofSize: 12))
        } else if lengthOfPersonalChef.text == "" {
            showToast(message: "Please enter the length in which you have been a personal chef.", font: .systemFont(ofSize: 12))
        } else if whatHelpsYouExcel.text == "" {
            showToast(message: "Please share what helps you excel?", font: .systemFont(ofSize: 12))
        } else if mostPrizedAccomplishments.text == "" {
            showToast(message: "Please list your most prized accomplishment.", font: .systemFont(ofSize: 12))
        } else if weeks == 0 && months == 0 && trialRun == 0 {
            showToast(message: "Please select the times in which you are willing to service consumers: Trial Runs, Weeks, or Months.", font: .systemFont(ofSize: 12))
        } else if personalChefPrice.text == "" {
            showToast(message: "Please enter your price for this service.", font: .systemFont(ofSize: 12))
        } else if specialty.text == "" {
            showToast(message: "Please enter your specialty.", font: .systemFont(ofSize: 12))
        } else {
            let a = String(format: "%.2f", Double(personalChefPrice.text!)!)
            let info1: [String: Any] = ["typeOfService" : "info", "briefIntroduction" : briefIntroduction.text!, "lengthOfPersonalChef" : lengthOfPersonalChef.text!, "specialty" : specialty.text!, "whatHelpsYouExcel" : whatHelpsYouExcel.text!, "trialRun" : trialRun, "weeks" : weeks, "months" : months, "hourlyOrPerSession" : hourlyOrPerSession, "servicePrice" : a, "expectations" : expectations, "chefRating" : chefRating, "quality" : quality, "chefName" : chefName, "mostPrizedAccomplishment" : mostPrizedAccomplishments.text!, "chefImageId" : Auth.auth().currentUser!.uid, "chefEmail" : Auth.auth().currentUser!.email!, "city" : self.city, "state": self.state, "zipCode" : self.zipCode, "liked" : liked, "itemOrders" : itemOrders, "itemRating" : itemRating, "complete" : "yes", "signatureDishId" : self.signatureDishId, "openToMenuRequests": self.openToMenuRequests]
            
            db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("Executive Items").document(documentId).updateData(info1)
            
            if complete == "yes" {
                self.db.collection("Executive Items").document(self.documentId).updateData(info1)
                self.showToastCompletion(message: "Item Saved.", font: .systemFont(ofSize: 12))
            } else {
                self.db.collection("Executive Items").document(self.documentId).setData(info1)
                self.showToastCompletion(message: "Item Saved.", font: .systemFont(ofSize: 12))
            }
            
        }
            
    } else {
    self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
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
            self.performSegue(withIdentifier: "PersonalChefToChefTabSegue", sender: self)
            toastLabel.removeFromSuperview()
        })
    }
    
}
