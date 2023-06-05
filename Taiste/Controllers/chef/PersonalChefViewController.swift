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

class PersonalChefViewController: UIViewController {
    
    let db = Firestore.firestore()
    let storage = Storage.storage()

    @IBOutlet weak var chefImage: UIImageView!
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
    var itemRating = 0.0
    
    var city = ""
    var state = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chefImage.layer.cornerRadius = 6
        specialDishImage.layer.cornerRadius = 6
        self.chefImage.image = self.chefImageI!
        if personalChefItem != nil {
            insertInfo()
        }
        

    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        
    }
    
    
    private func insertInfo() {
      
                                
        self.briefIntroduction.text = self.personalChefItem!.briefIntroduction
        self.lengthOfPersonalChef.text = self.personalChefItem!.howLongBeenAChef
        self.specialty.text = self.personalChefItem!.specialty
        self.whatHelpsYouExcel.text = self.personalChefItem!.whatHelpesYouExcel
        self.hourlyOrPerSession = self.personalChefItem!.hourlyOrPerSession
        self.personalChefPrice.text = self.personalChefItem!.servicePrice
        self.documentId = self.personalChefItem!.documentId
        self.expectations = self.personalChefItem!.expectations
        self.chefRating = self.personalChefItem!.chefRating
        self.quality = self.personalChefItem!.quality
        self.liked = self.personalChefItem!.liked
        self.itemOrders = self.personalChefItem!.itemOrders
        self.itemRating = self.personalChefItem!.itemRating
                                
        if self.personalChefItem!.weeks == 0 {
                                    self.weeksButton.isSelected = false
                                    self.weeks = 0
                                    self.weeksButton.setTitleColor(UIColor(red:98/255, green: 99/255, blue: 72/255, alpha:1), for: .normal)
                                    self.weeksButton.backgroundColor = UIColor.white
                                } else {
                                    self.weeksButton.isSelected = true
                                    self.weeks = 1
                                    self.weeksButton.setTitleColor(UIColor.white, for:.normal)
                                    self.weeksButton.backgroundColor = UIColor(red:160/255, green: 162/255, blue: 104/255,alpha: 1)
                                }
        if self.personalChefItem!.months == 0 {
                                    self.monthsButton.isSelected = false
                                    self.months = 0
                                    self.monthsButton.setTitleColor(UIColor(red:98/255, green: 99/255, blue: 72/255, alpha:1), for: .normal)
                                    self.monthsButton.backgroundColor = UIColor.white
                                } else {
                                    self.monthsButton.isSelected = true
                                    self.months = 1
                                    self.monthsButton.setTitleColor(UIColor.white, for:.normal)
                                    self.monthsButton.backgroundColor = UIColor(red:160/255, green: 162/255, blue: 104/255,alpha: 1)
                                }
        if self.personalChefItem!.trialRun == 0 {
                                    self.trialRunButton.isSelected = false
                                    self.trialRun = 0
                                    self.trialRunButton.setTitleColor(UIColor(red:98/255, green: 99/255, blue: 72/255, alpha:1), for: .normal)
                                    self.trialRunButton.backgroundColor = UIColor.white
                                } else {
                                    self.trialRunButton.isSelected = true
                                    self.trialRun = 1
                                    self.trialRunButton.setTitleColor(UIColor.white, for:.normal)
                                    self.trialRunButton.backgroundColor = UIColor(red:160/255, green: 162/255, blue: 104/255,alpha: 1)
                                }
        if self.personalChefItem!.hourlyOrPerSession == "hourly" {
                                    self.hourlyButton.setTitleColor(UIColor(red:98/255, green: 99/255, blue: 72/255, alpha:1), for: .normal)
                                    self.hourlyButton.backgroundColor = UIColor.white
                                    self.perSessionButton.setTitleColor(UIColor.white, for:.normal)
                                    self.perSessionButton.backgroundColor = UIColor(red:160/255, green: 162/255, blue: 104/255,alpha: 1)
                                } else {
                                    self.perSessionButton.setTitleColor(UIColor(red:98/255, green: 99/255, blue: 72/255, alpha:1), for: .normal)
                                    self.perSessionButton.backgroundColor = UIColor.white
                                    self.hourlyButton.setTitleColor(UIColor.white, for:.normal)
                                    self.hourlyButton.backgroundColor = UIColor(red:160/255, green: 162/255, blue: 104/255,alpha: 1)
                                }
                                
                        
                    
    }
    
    @IBAction func addSpecialDishImage(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "MenuItem") as? MenuItemViewController {
            vc.newOrEdit = "signature"
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func option1ButtonPressed(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "MenuItem") as? MenuItemViewController {
            vc.newOrEdit = "option1"
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func option2ButtonPressed(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "MenuItem") as? MenuItemViewController {
            vc.newOrEdit = "option2"
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func option3ButtonPressed(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "MenuItem") as? MenuItemViewController {
            vc.newOrEdit = "option3"
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func option4ButtonPressed(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "MenuItem") as? MenuItemViewController {
            vc.newOrEdit = "option4"
            self.present(vc, animated: true, completion: nil)
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
        if briefIntroduction.text == "Brief Introduction and why people should believe in your ability." || briefIntroduction.text == "" {
            showToast(message: "Please provide a brief introduction of why people should believe in your ability.", font: .systemFont(ofSize: 12))
        } else if lengthOfPersonalChef.text == "" {
            showToast(message: "Please enter the length in which you have been a personal chef.", font: .systemFont(ofSize: 12))
        } else if whatHelpsYouExcel.text == "" {
            showToast(message: "Please share what helps you excel?", font: .systemFont(ofSize: 12))
        } else if mostPrizedAccomplishments.text == "" {
            showToast(message: "Please list your most prized accomplishment.", font: .systemFont(ofSize: 12))
        } else if weeks == 0 && months == 0 && trialRun == 0 {
            showToast(message: "Please select the times in which you are avalailable: Weeks, Months, or Extended Periods.", font: .systemFont(ofSize: 12))
        } else if personalChefPrice.text == "" {
            showToast(message: "Please enter your price for this service.", font: .systemFont(ofSize: 12))
        } else if specialty.text == "" {
            showToast(message: "Please enter your specialty.", font: .systemFont(ofSize: 12))
        } else {
            let a = String(format: "%.2f", personalChefPrice.text!)
            let info: [String: Any] = ["typeOfInfo" : "info", "briefIntroduction" : briefIntroduction.text!, "lengthOfPersonalChef" : lengthOfPersonalChef.text!, "specialty" : specialty.text!, "whatHelpsYouExcel" : whatHelpsYouExcel.text!, "trialRun" : trialRun, "weeks" : weeks, "months" : months, "hourlyOrPerSession" : hourlyOrPerSession, "servicePrice" : personalChefPrice.text!, "expectations" : expectations, "chefRating" : chefRating, "quality" : quality, "chefName" : chefName, "mostPrizedAccomplishment" : mostPrizedAccomplishments.text!, "chefImageId" : Auth.auth().currentUser!.uid, "chefEmail" : Auth.auth().currentUser!.email!, "city" : self.city, "state": self.state, "liked" : liked, "itemOrders" : itemOrders, "itemRating" : itemRating]
            if newOrEdit == "new" {
                db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("Executive Item").document(documentId).setData(info)
                db.collection("Executive Items").document(documentId).setData(info)
            } else {
                db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("Executive Item").document(documentId).updateData(info)
                db.collection("Executive Items").document(documentId).updateData(info)
            }
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
