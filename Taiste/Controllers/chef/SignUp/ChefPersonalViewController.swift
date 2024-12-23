//
//  ChefPersonalViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 4/29/23.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class ChefPersonalViewController: UIViewController {

    let storage = Storage.storage()
    let db = Firestore.firestore()
    
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var fullName: UITextField!
    @IBOutlet weak var chefName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var education: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var newOrEdit = "new"
    var userImage1: UIImage?
    var userImageData: Data?
    var pictureId = UUID().uuidString
    
    private var documentId = ""
    
    var newUser = ""
    private var usernames : [Usernames] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if newOrEdit == "new" {
            saveButton.setTitle("Continue", for: .normal)
        } else {
            loadPersonalInfo()
            self.email.isEnabled = false
            saveButton.setTitle("Save", for: .normal)
        }
        userImage.layer.borderWidth = 1
        userImage.layer.masksToBounds = false
        userImage.layer.borderColor = UIColor.white.cgColor
        userImage.layer.cornerRadius = userImage.frame.height/2
        userImage.clipsToBounds = true
        
        if newUser == "yes" {
            self.email.text = Auth.auth().currentUser!.email!
            self.password.text = "**********"
            self.confirmPassword.text = "**********"
            self.email.isEnabled = false
            self.password.isEnabled = false
            self.confirmPassword.isEnabled = false
        }
        if Reachability.isConnectedToNetwork(){
        print("Internet Connection Available!")
        
        loadUsernames()
        } else {
        self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
       }
    }
    
    private func loadUsernames() {
        db.collection("Usernames").getDocuments { documents, error in
            if error == nil {
                for doc in documents!.documents {
                    let data = doc.data()
                    
                    
                    if let username = data["username"] as? String, let email = data["email"] as? String {
                        let name = Usernames(username: username, email: email)
                        
                        
                        if self.usernames.count == 0 {
                            self.usernames.append(name)
                        } else {
                            if let index = self.usernames.firstIndex(where: { $0.username == username }) {} else {
                                self.usernames.append(name)
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func loadPersonalInfo() {
        let storageRef = storage.reference()
        self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("PersonalInfo").getDocuments { documents, error in
            if error == nil {
                if documents != nil {
                    for doc in documents!.documents {
                        let data = doc.data()
                        
                        if let chefName = data["chefName"] as? String, let education = data["education"] as? String, let email = data["email"] as? String, let fullName = data["fullName"] as? String {
                            
                            storageRef.child("chefs/\(Auth.auth().currentUser!.email!)/profileImage/\(Auth.auth().currentUser!.uid).png").getData(maxSize: 15 * 1024 * 1024) { data, error in
                                if error == nil {
                                    self.userImage.image = UIImage(data: data!)
                                }
                            }
                            
                            self.chefName.text = chefName
                            self.fullName.text = fullName
                            self.education.text = education
                            self.email.text = email
                            self.password.text = "*********"
                            self.confirmPassword.text = "*********"
                            self.documentId = doc.documentID
                            
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func imageButtonPressed(_ sender: Any) {
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
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if Reachability.isConnectedToNetwork(){
        print("Internet Connection Available!")
        
            if newUser == "Yes" {
                if fullName.text == "" {
                    self.showToast(message: "Please enter your full name.", font: .systemFont(ofSize: 12))
                } else if chefName.text == "" || "\(chefName.text!)".contains(" ") == true {
                    self.showToast(message: "Please enter your chefname with no spaces.", font: .systemFont(ofSize: 12))
                } else if email.text == "" || !isValidEmail(email.text!) {
                    self.showToast(message: "Please enter your valid email.", font: .systemFont(ofSize: 12))
                } else if chefName.text == "" || "\(chefName.text!)".contains(" ") == true || searchForSpecialChar(search: chefName.text!) || chefName.text!.count < 4 {
                    self.showToast(message: "Please enter your chefName with no spaces, no special characters, and longer than 3 characters.", font: .systemFont(ofSize: 12))
                } else if usernames.contains(where: { $0.email == self.email.text }) {
                    self.showToast(message: "This email is already in use.", font: .systemFont(ofSize: 12))
                } else if isPasswordValid(password: password.text!) == false || password.text != confirmPassword.text {
                    self.showToast(message: "Please make sure password has 1 uppercase letter, 1 special character, 1 number, 1 lowercase letter, and matches with the second insert.", font: .systemFont(ofSize: 12))
                } else if education.text == "" {
                    self.showToast(message: "Please enter education. Can be 'Self-Educated'", font: .systemFont(ofSize: 12))
                } else {
                    var profilePic = ""
                    let storageRef = storage.reference()
                    if userImageData != nil {
                        profilePic = "yes"
                        storageRef.child("chefs/\(self.email.text!)/profileImage/\(Auth.auth().currentUser!.uid).png").putData(self.userImageData!)
                    } else {
                        profilePic = "no"
                        let image = UIImage(named: "default_image")!.pngData()
                        storageRef.child("chefs/\(self.email.text!)/profileImage/\(Auth.auth().currentUser!.uid).png").putData(image!)
                    }
                    
                    let data: [String: Any] = ["fullName" : self.fullName.text!, "chefName" : self.chefName.text!, "email": self.email.text!, "education" : self.education.text!, "chefPassion" : "", "city" : "", "state" : "", "zipCode" : ""]
                    let data1: [String: Any] = ["username" : self.chefName.text!, "email" : self.email.text!, "chefOrUser" : "Chef", "fullName" : self.fullName.text!]
                    let data2: [String: Any] = ["chefOrUser" : "Chef", "chargeForPayout" : 0.0, "notificationToken" : "", "notifications" : "", "profilePic" : profilePic]
                    self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("PersonalInfo").document().setData(data)
                    self.db.collection("Chef").document(Auth.auth().currentUser!.uid).setData(data2)
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.displayName = "Chef"
                    
                    changeRequest?.commitChanges { error in
                        // ...
                    }
                    self.performSegue(withIdentifier: "ChefPersonalToChefBusinessSegue", sender: self)
                }
                
            } else {
                if newOrEdit == "new" {
                    if fullName.text == "" {
                        self.showToast(message: "Please enter your full name.", font: .systemFont(ofSize: 12))
                    } else if chefName.text == "" || "\(chefName.text!)".contains(" ") == true || searchForSpecialChar(search: chefName.text!) || chefName.text!.count < 4 {
                        self.showToast(message: "Please enter your chefName with no spaces, no special characters, and longer than 3 characters.", font: .systemFont(ofSize: 12))
                    } else if email.text == "" || !isValidEmail(email.text!) {
                        self.showToast(message: "Please enter your valid email.", font: .systemFont(ofSize: 12))
                    } else if usernames.contains(where: { $0.username == self.chefName.text }) {
                        self.showToast(message: "This username is already taken. Please select another one.", font: .systemFont(ofSize: 12))
                    } else if usernames.contains(where: { $0.email == self.email.text }) {
                        self.showToast(message: "This email is already in use.", font: .systemFont(ofSize: 12))
                    } else if isPasswordValid(password: password.text!) == false || password.text != confirmPassword.text {
                        self.showToast(message: "Please make sure password has 1 uppercase letter, 1 special character, 1 number, 1 lowercase letter, and matches with the second insert.", font: .systemFont(ofSize: 12))
                    } else if education.text == "" {
                        self.showToast(message: "Please enter education. Can be 'Self-Educated'", font: .systemFont(ofSize: 12))
                    } else {
                        var profilePic = ""
                        
                        let storageRef = storage.reference()
                        Auth.auth().createUser(withEmail: email.text!, password: password.text!) { authResult, error in
                            
                            if error == nil {
                                if self.userImage1 != nil {
                                    profilePic = "yes"
                                    storageRef.child("chefs/\(self.email.text!)/profileImage/\(authResult!.user.uid).png").putData(self.userImageData!)
                                }
                                if self.userImageData == nil || self.userImage1 == nil {
                                    profilePic = "no"
                                    let image = UIImage(named: "default_image")!.pngData()
                                    storageRef.child("chefs/\(self.email.text!)/profileImage/\(authResult!.user.uid).png").putData(image!)
                                    
                                }
                                let data: [String: Any] = ["fullName" : self.fullName.text!, "chefName" : self.chefName.text!, "email": self.email.text!, "education" : self.education.text!, "chefPassion" : "", "city" : "", "state" : "", "zipCode" : ""]
                                let data1: [String: Any] = ["username" : self.chefName.text!, "email" : self.email.text!, "chefOrUser" : "Chef", "fullName" : self.fullName.text!]
                                let data2: [String: Any] = ["chefOrUser" : "Chef", "chargeForPayout" : 0.0, "notificationToken" : "", "notifications" : "", "profilePic" : profilePic]
                                self.db.collection("Chef").document(authResult!.user.uid).collection("PersonalInfo").document().setData(data)
                                self.db.collection("Usernames").document(authResult!.user.uid).setData(data1)
                                self.db.collection("Chef").document(authResult!.user.uid).setData(data2)
                                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                                changeRequest?.displayName = "Chef"
                                
                                changeRequest?.commitChanges { error in
                                    // ...
                                }
                                self.performSegue(withIdentifier: "ChefPersonalToChefBusinessSegue", sender: self)
                            } else {
                                self.showToast(message: "Something went wrong. Please try again. \(error?.localizedDescription)", font: .systemFont(ofSize: 12))
                            }
                        }}} else {
                            if fullName.text == "" {
                                self.showToast(message: "Please enter your full name.", font: .systemFont(ofSize: 12))
                            } else if chefName.text == "" || "\(chefName.text)".contains(" ") == true {
                                self.showToast(message: "Please enter your chefname with no spaces.", font: .systemFont(ofSize: 12))
                            } else if email.text == "" || !isValidEmail(email.text!) {
                                self.showToast(message: "Please enter your valid email.", font: .systemFont(ofSize: 12))
                            } else if education.text == "" {
                                self.showToast(message: "Please enter education. Can be 'Self-Educated'", font: .systemFont(ofSize: 12))
                            } else {
                                
                                if !password.text!.contains("*") {
                                    if isPasswordValid(password: password.text!) == false || password.text != confirmPassword.text {
                                        self.showToast(message: "Please make sure password has 1 uppercase letter, 1 special character, 1 number, 1 lowercase letter, and matches with the second insert.", font: .systemFont(ofSize: 12))
                                    } else {
                                        Auth.auth().currentUser?.updatePassword(to: password.text!) { error in
                                            // ...
                                            if error == nil {
                                                let data: [String: Any] = ["fullName" : self.fullName.text!, "chefName" : self.chefName.text!, "email": self.email.text!, "education" : self.education.text!]
                                                let data1: [String: Any] = ["username" : self.chefName.text!, "email" : self.email.text!, "chefOrUser" : "Chef", "fullName" : self.fullName.text!]
                                                
                                                self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("PersonalInfo").document(self.documentId).updateData(data)
                                                self.db.collection("Usernames").document(Auth.auth().currentUser!.uid).updateData(data1)
                                                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                                                changeRequest?.displayName = self.chefName.text
                                                
                                                changeRequest?.commitChanges { error in
                                                    // ...
                                                }
                                                self.performSegue(withIdentifier: "ChefPersonalInfoToChefHomeSegue", sender: self)
                                            } else {
                                                self.showToast(message: "Something went wrong. Please try again. \(error?.localizedDescription)", font: .systemFont(ofSize: 12))
                                            }
                                            
                                            print("yes")
                                        }
                                    }
                                    
                                } else {
                                    let data: [String: Any] = ["fullName" : self.fullName.text!, "chefName" : self.chefName.text!, "email": self.email.text!, "education" : self.education.text!]
                                    let data1: [String: Any] = ["username" : self.chefName.text!, "email" : self.email.text!, "chefOrUser" : "Chef", "fullName" : self.fullName.text!]
                                    
                                    self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("PersonalInfo").document(self.documentId).updateData(data)
                                    self.db.collection("Usernames").document(Auth.auth().currentUser!.uid).updateData(data1)
                                    self.showToast(message: "Info updated.", font: .systemFont(ofSize: 12))
                                    self.performSegue(withIdentifier: "ChefPersonalInfoToChefHomeSegue", sender: self)
                                }}}}
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
        UIView.animate(withDuration: 5.0, delay: 0.1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
}

extension ChefPersonalViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        self.userImage.image = image
        self.userImage1 = image
        self.userImageData = image.pngData()
        
        if newOrEdit == "edit" {
            let storageRef = self.storage.reference()
            let data : [String: Any] = ["profilePic" : "yes"]
            db.collection("Chef").document(Auth.auth().currentUser!.uid).updateData(data)
            storageRef.child("chefs/\(Auth.auth().currentUser!.email!)/profileImage/\(Auth.auth().currentUser!.uid).png").putData(image.pngData()!, metadata: nil) { metatdata, error in
                if error == nil {
                    self.showToast(message: "Image Updated.", font: .systemFont(ofSize: 12))
                }
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    
}
func isPasswordValid(password: String) -> Bool {
    let passRegEx = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[d$@$!%*?&#])[A-Za-z\\dd$@$!%*?&#]{8,}"
    let passwordTest = NSPredicate(format: "SELF MATCHES %@", passRegEx)
    print("password \(passwordTest.evaluate(with: password))")
    return passwordTest.evaluate(with: password)
}

func searchForSpecialChar(search: String) -> Bool {
    let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
    if search.rangeOfCharacter(from: characterset.inverted) != nil {
        print("string contains special characters")
        return true
    }
    return false
}
