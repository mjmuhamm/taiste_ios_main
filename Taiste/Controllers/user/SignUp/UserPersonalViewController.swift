//
//  UserPersonalViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 5/3/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import MaterialComponents.MaterialButtons
import MaterialComponents

class UserPersonalViewController: UIViewController {

    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var fullName: UITextField!
    @IBOutlet weak var userName: UITextField!
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var state: UITextField!
    
    @IBOutlet weak var stateConstant: NSLayoutConstraint!
    @IBOutlet weak var preferenceConstant: NSLayoutConstraint!
    @IBOutlet weak var surpriseMeConstant: NSLayoutConstraint!
    //64.5
    
    @IBOutlet weak var localButton: MDCButton!
    @IBOutlet weak var regionButton: MDCButton!
    @IBOutlet weak var nationButton: MDCButton!
    
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
    
    var local = 0
    var region = 0
    var nation = 0
    var surpriseMe = 0
    var burger = 0
    var creative = 0
    var lowCal = 0
    var lowCarb = 0
    var pasta = 0
    var healthy = 0
    var vegan = 0
    var seafood = 0
    var workout = 0
    
    private var documentId = ""
    
    var newOrEdit = "new"
    
    private var userImage1 : UIImage?
    private var userImageData : Data?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        userImage.layer.borderWidth = 1
        userImage.layer.masksToBounds = false
        userImage.layer.borderColor = UIColor.white.cgColor
        userImage.layer.cornerRadius = userImage.frame.height/2
        userImage.clipsToBounds = true
        if newOrEdit == "edit" {
            loadPersonalInfo()
        }
        
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func userImageButtonPressed(_ sender: Any) {
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
    
    private func loadPersonalInfo() {
        db.collection("User").document(Auth.auth().currentUser!.uid).collection("PersonalInfo").getDocuments { documents, error in
            if error == nil {
                for doc in documents!.documents {
                    let data = doc.data()
                    
                    if let local = data["local"] as? Int, let region = data["region"] as? Int, let nation = data["nation"] as? Int, let city = data["city"] as? String, let state = data["state"] as? String, let burger = data["burger"] as? Int, let creative = data["creative"] as? Int, let lowCal = data["lowCal"] as? Int, let lowCarb = data["lowCarb"] as? Int, let pasta = data["pasta"] as? Int, let healthy = data["healthy"] as? Int, let vegan = data["vegan"] as? Int, let seafood = data["seafood"] as? Int, let workout = data["workout"] as? Int, let surpriseMe = data["surpriseMe"] as? Int, let fullName = data["fullName"] as? String, let username = data["userName"] as? String, let email = data["email"] as? String {
                        
                        self.fullName.text = fullName
                        self.userName.text = username
                        self.email.text = email
                        self.password.text = "*********"
                        self.confirmPassword.text = "*********"
                        self.documentId = doc.documentID
                        
                        self.storage.reference().child("users/\(Auth.auth().currentUser!.email!)/profileImage/\(Auth.auth().currentUser!.uid).png").downloadURL { imageUrl, error in
                            
                            URLSession.shared.dataTask(with: imageUrl!) { (data, response, error) in
                                // Error handling...
                                guard let imageData = data else { return }
                                
                                print("happening itemdata")
                                DispatchQueue.main.async {
                                    self.userImage.image = UIImage(data: imageData)!
                                }
                            }.resume()
                        }
                        
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
                            self.preferenceConstant.constant = 69.5
                            self.surpriseMeConstant.constant = 64.5
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
                            self.preferenceConstant.constant = 69.5
                            self.surpriseMeConstant.constant = 64.5
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
                            self.preferenceConstant.constant = 29.5
                            self.surpriseMeConstant.constant = 24.5
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
    
    @IBAction func localButtonPressed(_ sender: Any) {
        local = 1
        region = 0
        nation = 0
        city.isHidden = false
        state.isHidden = false
        stateConstant.constant = 152
        preferenceConstant.constant = 69.5
        surpriseMeConstant.constant = 64.5
        
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
        stateConstant.constant = 10
        preferenceConstant.constant = 69.5
        surpriseMeConstant.constant = 64.5
        
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
        
        preferenceConstant.constant = 29.5
        surpriseMeConstant.constant = 24.5
        nationButton.setTitleColor(UIColor.white, for: .normal)
        nationButton.backgroundColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
        localButton.backgroundColor = UIColor.white
        localButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        regionButton.backgroundColor = UIColor.white
        regionButton.setTitleColor(UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1), for: .normal)
        
    }
    
    @IBAction func surpriseMeButtonPressed(_ sender: Any) {
        if surpriseMe == 0 {
            surpriseMe = 1
            surpriseMeButton.setTitleColor(UIColor.white, for:.normal)
            surpriseMeButton.backgroundColor = UIColor(red:160/255, green: 162/255, blue: 104/255,alpha: 1)
        } else {
            surpriseMe = 0
            surpriseMeButton.setTitleColor(UIColor(red:98/255, green: 99/255, blue: 72/255, alpha:1), for: .normal)
            surpriseMeButton.backgroundColor = UIColor.white
            
        }
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
        if Auth.auth().currentUser != nil {
            if fullName.text == "" {
                self.showToast(message: "Please enter your full name.", font: .systemFont(ofSize: 12))
            } else if userName.text == "" || "\(userName.text)".contains(" ") == true {
                self.showToast(message: "Please enter your chefname with no spaces.", font: .systemFont(ofSize: 12))
            } else if email.text == "" || !isValidEmail(email.text!) {
                self.showToast(message: "Please enter your valid email.", font: .systemFont(ofSize: 12))
            } else if local == 1 && (city.text == "" || state.text == "")  {
                self.showToast(message: "Please enter your city, state.", font: .systemFont(ofSize: 12))
            } else if region == 1 && state.text == "" {
                self.showToast(message: "Please enter your state.", font: .systemFont(ofSize: 12))
            } else if userImageData == nil {
                self.showToast(message: "Please add an image.", font: .systemFont(ofSize: 12))
            } else  {
                
                if newOrEdit != "edit" {
                    if isPasswordValid(password: password.text!) == false || password.text != confirmPassword.text {
                        self.showToast(message: "Please make sure password has 1 uppercase letter, 1 special character, 1 number, 1 lowercase letter, and matches with the second insert.", font: .systemFont(ofSize: 12))
                        
                        let storageRef = storage.reference()
                        Auth.auth().createUser(withEmail: email.text!, password: password.text!) { authResult, error in
                            
                            if error == nil {
                                if self.userImage1 != nil {
                                    storageRef.child("users//\(self.email.text!)/profileImage/\(authResult!.user.uid).png").putData(self.userImageData!)
                                }
                                let data: [String: Any] = ["fullName" : self.fullName.text, "userName" : self.userName.text, "email": self.email.text,  "city" : self.city.text, "state" : self.state.text, "burger" : self.burger, "creative" : self.creative, "lowCal" : self.lowCal, "lowCarb" : self.lowCarb, "pasta" : self.pasta, "healthy" : self.healthy, "vegan" : self.vegan, "seafood" : self.seafood, "workout" : self.workout, "local" : self.local, "region" : self.region, "nation" : self.nation, "surpriseMe" : self.surpriseMe]
                                let data1: [String: Any] = ["username" : self.userName.text!, "email" : self.email.text!, "chefOrUser" : "User", "fullName" : self.fullName.text! ]
                                let data2: [String: Any] = ["chefOrUser" : "User", "privatizeData" : "no", "notificationToken" : "", "notifications" : ""]
                                self.db.collection("User").document(authResult!.user.uid).collection("PersonalInfo").document().setData(data)
                                self.db.collection("Usernames").document(authResult!.user.uid).setData(data1)
                                self.db.collection("User").document(authResult!.user.uid).setData(data2)
                                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                                changeRequest?.displayName = "User"
                                changeRequest?.commitChanges { error in
                                    // ...
                                }
                                self.performSegue(withIdentifier: "UserPreferencesToHome", sender: self)
                            } else {
                                self.showToast(message: "Something went wrong. Please try again. \(error?.localizedDescription)", font: .systemFont(ofSize: 12))
                            }
                        }
                    }
                } else {
                    let data: [String: Any] = ["fullName" : self.fullName.text, "userName" : self.userName.text, "email": self.email.text,  "city" : self.city.text, "state" : self.state.text, "burger" : self.burger, "creative" : self.creative, "lowCal" : self.lowCal, "lowCarb" : self.lowCarb, "pasta" : self.pasta, "healthy" : self.healthy, "vegan" : self.vegan, "seafood" : self.seafood, "workout" : self.workout, "local" : self.local, "region" : self.region, "nation" : self.nation, "surpriseMe" : self.surpriseMe]
                    let data1: [String: Any] = ["username" : self.userName.text!, "email" : self.email.text!, "chefOrUser" : "User", "fullName" : self.fullName.text! ]
                    if self.password.text != "" && !(self.password.text?.contains("*"))! {
                        if !isPasswordValid(password: self.password.text!) {
                            self.showToast(message: "Please enter a valid password to change your password.", font: .systemFont(ofSize: 12))
                        } else {
                            Auth.auth().currentUser!.updatePassword(to: self.password.text!)
                            self.db.collection("User").document(Auth.auth().currentUser!.uid).collection("PersonalInfo").document(documentId).updateData(data)
                            self.db.collection("Usernames").document(Auth.auth().currentUser!.uid).updateData(data1)
                            self.showToast(message: "Profile Updated.", font: .systemFont(ofSize: 12))
                            
                            
                        }
                    }
                    self.dismiss(animated: true, completion: nil)
                }
                
            }
        } else {
            self.showToast(message: "Something went wrong. Please check your connection.", font: .systemFont(ofSize: 12))
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
        UIView.animate(withDuration: 5.0, delay: 0.1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

extension UserPersonalViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        self.userImage.image = image
        self.userImage1 = image
        if newOrEdit == "edit" {
            let storageRef = storage.reference()
            storageRef.child("users/\(Auth.auth().currentUser!.email!)/profileImage/\(Auth.auth().currentUser!.uid).png").putData(image.pngData()!)
            self.showToast(message: "Image Updated.", font: .systemFont(ofSize: 12))
        }
        self.userImageData = image.pngData()
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    
}
