//
//  FilterViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 5/25/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import MaterialComponents.MaterialButtons
import MaterialComponents

class FilterViewController: UIViewController {
    
    private let db = Firestore.firestore()
    
    @IBOutlet weak var localButton: MDCButton!
    @IBOutlet weak var regionButton: MDCButton!
    @IBOutlet weak var nationButton: MDCButton!
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var state: UITextField!
    
    @IBOutlet weak var stateConstant: NSLayoutConstraint!
    //22
    //154
    
    @IBOutlet weak var preferencesConstant: NSLayoutConstraint!
    //73.5
    //14.5
    
    @IBOutlet weak var surpriseMeConstant: NSLayoutConstraint!
    //68.5
    //9.5
    
    @IBOutlet weak var surpriseMeButton: MDCButton!
    @IBOutlet weak var burgerButton: MDCButton!
    @IBOutlet weak var creativeButton: MDCButton!
    @IBOutlet weak var lowCalButton: MDCButton!
    @IBOutlet weak var lowCarbButton: MDCButton!
    @IBOutlet weak var pastaButton: MDCButton!
    @IBOutlet weak var healthyButton: MDCButton!
    @IBOutlet weak var veganButton: MDCButton!
    @IBOutlet weak var seafoodButton: MDCButton!
    @IBOutlet weak var workoutButton: MDCButton!
    
    private var local = 1
    private var region = 0
    private var nation = 0
    
    private var surpriseMe = 0
    private var burger = 0
    private var creative = 0
    private var lowCal = 0
    private var lowCarb = 0
    private var pasta = 0
    private var healthy = 0
    private var vegan = 0
    private var seafood = 0
    private var workout = 0
    
    private var documentId = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            
            loadFilter()
        } else {
            self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
        }
        // Do any additional setup after loading the view.
    }
    
    private func loadFilter() {
        db.collection("User").document(Auth.auth().currentUser!.uid).collection("PersonalInfo").getDocuments { documents, error in
            if error == nil {
                for doc in documents!.documents {
                    let data = doc.data()
                    
                    if let local = data["local"] as? Int, let region = data["region"] as? Int, let nation = data["nation"] as? Int, let city = data["city"] as? String, let state = data["state"] as? String, let burger = data["burger"] as? Int, let creative = data["creative"] as? Int, let lowCal = data["lowCal"] as? Int, let lowCarb = data["lowCarb"] as? Int, let pasta = data["pasta"] as? Int, let healthy = data["healthy"] as? Int, let vegan = data["vegan"] as? Int, let seafood = data["seafood"] as? Int, let workout = data["workout"] as? Int, let surpriseMe = data["surpriseMe"] as? Int {
                        
                        self.local = local
                        self.region = region
                        self.nation = nation
                        self.surpriseMe = surpriseMe
                        self.burger = burger
                        self.creative = creative
                        self.lowCal = lowCal
                        self.lowCarb = lowCarb
                        self.pasta = pasta
                        self.healthy = healthy
                        self.vegan = vegan
                        self.seafood = seafood
                        self.workout = workout
                        self.documentId = doc.documentID
                        
                        if local == 1 {
                            self.city.isHidden = false
                            self.state.isHidden = false
                            self.city.text = city
                            self.state.text = state
                            self.stateConstant.constant = 154
                            self.preferencesConstant.constant = 73.5
                            self.surpriseMeConstant.constant = 68.5
                            self.localButton.setTitleColor(UIColor.white, for: .normal)
                            self.localButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
                            self.regionButton.backgroundColor = UIColor.white
                            self.regionButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
                            self.nationButton.backgroundColor = UIColor.white
                            self.nationButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
                        } else if region == 1 {
                            self.local = 0
                            self.region = 1
                            self.nation = 0
                            self.city.isHidden = true
                            self.state.isHidden = false
                            self.state.text = state
                            self.stateConstant.constant = 22
                            self.preferencesConstant.constant = 73.5
                            self.surpriseMeConstant.constant = 68.5
                            self.regionButton.setTitleColor(UIColor.white, for: .normal)
                            self.regionButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
                            self.localButton.backgroundColor = UIColor.white
                            self.localButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
                            self.nationButton.backgroundColor = UIColor.white
                            self.nationButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
                        } else if nation == 1 {
                            self.local = 0
                            self.region = 0
                            self.nation = 1
                            self.city.isHidden = true
                            self.state.isHidden = true
                            self.preferencesConstant.constant = 14.5
                            self.surpriseMeConstant.constant = 9.5
                            self.nationButton.setTitleColor(UIColor.white, for: .normal)
                            self.nationButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
                            self.localButton.backgroundColor = UIColor.white
                            self.localButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
                            self.regionButton.backgroundColor = UIColor.white
                            self.regionButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
                            
                        }
                        if surpriseMe == 1 {
                            self.surpriseMeButton.setTitleColor(UIColor.white, for: .normal)
                            self.surpriseMeButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
                        } else {
                            self.surpriseMeButton.backgroundColor = UIColor.white
                            self.surpriseMeButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
                        }
                        if burger == 1 {
                                self.burgerButton.setTitleColor(UIColor.white, for: .normal)
                                self.burgerButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
                            } else {
                                self.burgerButton.backgroundColor = UIColor.white
                                self.burgerButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
                            }
                        
                        if creative == 1 {
                                self.creativeButton.setTitleColor(UIColor.white, for: .normal)
                                self.creativeButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
                            } else {
                                self.creativeButton.backgroundColor = UIColor.white
                                self.creativeButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
                        }
                        if lowCal == 1 {
                                self.lowCalButton.setTitleColor(UIColor.white, for: .normal)
                                self.lowCalButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
                            } else {
                                self.lowCalButton.backgroundColor = UIColor.white
                                self.lowCalButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
                            }
                        if lowCarb == 1 {
                                self.lowCarbButton.setTitleColor(UIColor.white, for: .normal)
                                self.lowCarbButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
                            } else {
                                self.lowCarbButton.backgroundColor = UIColor.white
                                self.lowCarbButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
                            }
                        if pasta == 1 {
                            self.pastaButton.setTitleColor(UIColor.white, for: .normal)
                            self.pastaButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
                        } else {
                            self.pastaButton.backgroundColor = UIColor.white
                            self.pastaButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
                        }
                        if healthy == 1 {
                            self.healthyButton.setTitleColor(UIColor.white, for: .normal)
                            self.healthyButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
                        } else {
                            self.healthyButton.backgroundColor = UIColor.white
                            self.healthyButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
                        }
                        if vegan == 1 {
                            self.veganButton.setTitleColor(UIColor.white, for: .normal)
                            self.veganButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
                        } else {
                            self.veganButton.backgroundColor = UIColor.white
                            self.veganButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
                        }
                        if seafood == 1 {
                            self.seafoodButton.setTitleColor(UIColor.white, for: .normal)
                            self.seafoodButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
                        } else {
                            self.seafoodButton.backgroundColor = UIColor.white
                            self.seafoodButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
                        }
                        if workout == 1 {
                            self.workoutButton.setTitleColor(UIColor.white, for: .normal)
                            self.workoutButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
                        } else {
                            self.workoutButton.backgroundColor = UIColor.white
                            self.workoutButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
                        }
                        
                    }
                    
                }
            }
        }
    }
    
    private func stateFilter(state: String) -> String {
        var stateAbbr : [String] = ["AL", "AK", "AZ", "AR", "AS", "CA", "CO", "CT", "DE", "DC", "FL", "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", "MA", "MI", "MN", "MS", "MO", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "PR", "RI", "SC", "SD", "TN", "TX", "TT", "UT", "VT", "VA", "VI", "WA", "WY", "WV", "WI", "WY" ]
        
        
        for i in 0..<stateAbbr.count {
            let a = stateAbbr[i].lowercased()
            if a == state.lowercased() {
                return "good"
            }
        }
        
        return "not good"
      
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func localButtonPressed(_ sender: Any) {
        local = 1
        region = 0
        nation = 0
        city.isHidden = false
        state.isHidden = false
        stateConstant.constant = 154
        preferencesConstant.constant = 73.5
        surpriseMeConstant.constant = 68.5
        
        localButton.setTitleColor(UIColor.white, for: .normal)
        localButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
        regionButton.backgroundColor = UIColor.white
        regionButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        nationButton.backgroundColor = UIColor.white
        nationButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        
    }
    
    @IBAction func regionButtonPressed(_ sender: Any) {
        local = 0
        region = 1
        nation = 0
        city.isHidden = true
        state.isHidden = false
        stateConstant.constant = 22
        preferencesConstant.constant = 73.5
        surpriseMeConstant.constant = 68.5
        
        regionButton.setTitleColor(UIColor.white, for: .normal)
        regionButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
        localButton.backgroundColor = UIColor.white
        localButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        nationButton.backgroundColor = UIColor.white
        nationButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        
    }
    
    @IBAction func nationButtonPressed(_ sender: Any) {
        local = 0
        region = 0
        nation = 1
        city.isHidden = true
        state.isHidden = true
        preferencesConstant.constant = 14.5
        surpriseMeConstant.constant = 9.5
        nationButton.setTitleColor(UIColor.white, for: .normal)
        nationButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
        localButton.backgroundColor = UIColor.white
        localButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        regionButton.backgroundColor = UIColor.white
        regionButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        
    }
    
    @IBAction func surpriseMeButtonPressed(_ sender: Any) {
        if surpriseMe == 0 {
            surpriseMeButton.setTitleColor(UIColor.white, for: .normal)
            surpriseMeButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
            surpriseMe = 1
        } else {
            surpriseMeButton.backgroundColor = UIColor.white
            surpriseMeButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
            surpriseMe = 0
        }
    }
    
    
    @IBAction func burgerButtonPressed(_ sender: Any) {
        if burger == 0 {
            burgerButton.setTitleColor(UIColor.white, for: .normal)
            burgerButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
            burger = 1
        } else {
            burgerButton.backgroundColor = UIColor.white
            burgerButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
            burger = 0
        }
    }
    
    @IBAction func creativeButtonPressed(_ sender: Any) {
        if creative == 0 {
            creativeButton.setTitleColor(UIColor.white, for: .normal)
            creativeButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
            creative = 1
        } else {
            creativeButton.backgroundColor = UIColor.white
            creativeButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
            creative = 0
        }
    }
    
    @IBAction func lowCalButtonPressed(_ sender: Any) {
        if lowCal == 0 {
            lowCalButton.setTitleColor(UIColor.white, for: .normal)
            lowCalButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
            lowCal = 1
        } else {
            lowCalButton.backgroundColor = UIColor.white
            lowCalButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
            lowCal = 0
        }
        
    }
    
    @IBAction func lowCarbButtonPressed(_ sender: Any) {
        if lowCarb == 0 {
            lowCarbButton.setTitleColor(UIColor.white, for: .normal)
            lowCarbButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
            lowCarb = 1
        } else {
            lowCarbButton.backgroundColor = UIColor.white
            lowCarbButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
            lowCarb = 0
        }
    }
    
    @IBAction func pastaButtonPressed(_ sender: Any) {
        if pasta == 0 {
            pastaButton.setTitleColor(UIColor.white, for: .normal)
            pastaButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
            pasta = 1
        } else {
            pastaButton.backgroundColor = UIColor.white
            pastaButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
            pasta = 0
        }
    }
    
    @IBAction func healthyButtonPressed(_ sender: Any) {
        if healthy == 0 {
            healthyButton.setTitleColor(UIColor.white, for: .normal)
            healthyButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
            healthy = 1
        } else {
            healthyButton.backgroundColor = UIColor.white
            healthyButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
            healthy = 0
        }
    }
    
    @IBAction func veganButtonPressed(_ sender: Any) {
        if vegan == 0 {
            veganButton.setTitleColor(UIColor.white, for: .normal)
            veganButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
            vegan = 1
        } else {
            veganButton.backgroundColor = UIColor.white
            veganButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
            vegan = 0
        }
    }
    
    @IBAction func seafoodButtonPressed(_ sender: Any) {
        if seafood == 0 {
            seafoodButton.setTitleColor(UIColor.white, for: .normal)
            seafoodButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
            seafood = 1
        } else {
            seafoodButton.backgroundColor = UIColor.white
            seafoodButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
            seafood = 0
        }
    }
    
    @IBAction func workoutButtonPressed(_ sender: Any) {
        if workout == 0 {
            workoutButton.setTitleColor(UIColor.white, for: .normal)
            workoutButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
            workout = 1
        } else {
            workoutButton.backgroundColor = UIColor.white
            workoutButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
            workout = 0
        }
    }
   
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if local == 1 && (city.text == "" || state.text == "") {
            self.showToast(message: "Please enter a city and state.", font: .systemFont(ofSize: 12))
        } else if region == 1 && state.text == "" {
            self.showToast(message: "Please enter a state.", font: .systemFont(ofSize: 12))
        } else if region == 1 || local == 1 && stateFilter(state: state.text!) != "good" {
            self.showToast(message: "Please enter the abbreviation of your state selection.", font: .systemFont(ofSize: 12))
        } else {
            let data: [String: Any] = ["local" : local, "region" : region, "nation" : nation, "city" : city.text, "state" : state.text, "burger" : burger, "creative" : creative, "lowCal" : lowCal, "lowCarb" : lowCarb, "pasta" : pasta, "healthy" : healthy, "vegan" : vegan, "seafood" : seafood, "workout" : workout, "surpriseMe" : surpriseMe]
            db.collection("User").document(Auth.auth().currentUser!.uid).collection("PersonalInfo").document(documentId).updateData(data)
            self.performSegue(withIdentifier: "filterToUserTabSegue", sender: self)
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
