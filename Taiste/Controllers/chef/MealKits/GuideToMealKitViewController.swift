//
//  GuideToMealKitViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 6/17/23.
//

import UIKit
import FirebaseFirestore
import Firebase
import MaterialComponents.MaterialButtons
import MaterialComponents

class GuideToMealKitViewController: UIViewController {

    let db = Firestore.firestore()
   
    @IBOutlet weak var continueButton: MDCButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        continueButton.applyOutlinedTheme(withScheme: globalContainerScheme())
        continueButton.layer.cornerRadius = 2
      
        // Do any additional setup after loading the view.
    }
    
    @IBAction func mealKitDeliveryExample(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "MealKitVideo") as? YoutubeViewController  {
            vc.example = "fullMealKitVideo"
            
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func menuItemPostPressed(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "MealKitVideo") as? YoutubeViewController  {
            vc.example = "menuItemPost"
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func ingredientsPressed(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "MealKitVideo") as? YoutubeViewController  {
            vc.example = "ingredients"
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func preperationGuidePressed(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "MealKitVideo") as? YoutubeViewController  {
            vc.example = "preperation"
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func prepContentPressed(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "MealKitVideo") as? YoutubeViewController  {
            vc.example = "contentVideo"
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func ingredientsWrappingPressed(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "MealKitVideo") as? YoutubeViewController  {
            vc.example = "ingredientsWrapping"
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func boxingPressed(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "MealKitVideo") as? YoutubeViewController  {
            vc.example = "shipping"
            self.present(vc, animated: true, completion: nil)
        }
        
    }
   
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("PersonalInfo").getDocuments { documents, error in
                if error == nil {
                    if documents != nil {
                        for doc in documents!.documents {
                            let data = doc.data()
                            
                            if let chefPassion = data["chefPassion"] as? String, let city = data["city"] as? String, let state = data["state"] as? String, let zipCode = data["zipCode"] as? String, let chefName = data["chefName"] as? String {
                                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "MenuItem") as? MenuItemViewController  {
                                    vc.typeOfitem = "MealKit Items"
                                    vc.chefPassion = chefPassion
                                    vc.chefUsername = chefName
                                    vc.city = city
                                    vc.state = state
                                    vc.latitude = ""
                                    vc.longitude = ""
                                    vc.profileImageId = Auth.auth().currentUser!.uid
                                    vc.zipCode = zipCode
                                    self.present(vc, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                }
            }
        }  else {
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
}
