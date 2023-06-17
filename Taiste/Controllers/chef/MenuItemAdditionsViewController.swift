//
//  MenuItemAdditionsViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 6/17/23.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import Firebase
import MaterialComponents.MaterialButtons
import MaterialComponents

class MenuItemAdditionsViewController: UIViewController {

    let db = Firestore.firestore()
    let storage = Storage.storage()
    @IBOutlet weak var preperationLabel: UILabel!
    @IBOutlet weak var preperationGuideButton: UIButton!
    @IBOutlet weak var uploadPreperationContentButton: UIButton!
    @IBOutlet weak var preperationContentLabel: UILabel!
    @IBOutlet weak var ingredientsLabel: UILabel!
    
    private var ingredientsImage : UIImage?
    private var preperationImage : UIImage?
    private var contentVideo : URL?
    
    var chefOrUser = ""
    var chefImageId = ""
    
    var typeOfItem = ""
    private var toggle = ""
    private var chefName = ""
    var documentId = ""
    var itemTitle = ""
    
    private var ingredientsId = ""
    private var preperationId = ""
    private var contentId = ""
    @IBOutlet weak var saveButton: MDCButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadUsername()
        if chefOrUser != "" {
            saveButton.isHidden = true
        }
        loadItems()
        
        
        
        // Do any additional setup after loading the view.
    }
    
    private func loadUsername() {
        db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("PersonalInfo").getDocuments { documents, error in
            if error == nil {
                if documents != nil {
                    for doc in documents!.documents {
                        let data = doc.data()
                        
                        if let chefName = data["chefName"] as? String {
                            self.chefName = chefName
                        }
                    }
                }
            }
        }
    }
    
    private func loadItems() {
        var b = ""
        if chefOrUser != "" {b = chefImageId } else { b = Auth.auth().currentUser!.uid }
        var a : [String] = ["Ingredients", "Preperation", "Content"]
        for i in 0..<3 {
            db.collection("Chef").document(b).collection(typeOfItem).document(documentId).collection(a[i]).getDocuments { documents, error in
                if error == nil {
                    if documents != nil {
                        for doc in documents!.documents {
                            let data = doc.data()
                            if let documentId = data["documentId"] as? String {
                                if a[i] == "Ingredients" {
                                    self.ingredientsId = doc.documentID
                                    self.ingredientsLabel.text = "Added"
                                    self.ingredientsLabel.textColor = UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1)
                                } else if a[i] == "Preperation" {
                                    self.preperationId = doc.documentID
                                    self.preperationLabel.text = "Added"
                                    self.preperationLabel.textColor = UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1)
                                } else if a[i] == "Content" {
                                    self.contentId == doc.documentID
                                    self.preperationContentLabel.text = "Added"
                                    self.preperationContentLabel.textColor = UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1)
                                }
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    

    @IBAction func uploadIngredientsButtonPressed(_ sender: Any) {
        if Reachability.isConnectedToNetwork(){
            toggle = "ingredients"
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
    
    @IBAction func uploadPreperationGuideButtonPressed(_ sender: Any) {
        toggle = "preperation"
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
    
    @IBAction func uploadPreperationContentVideoButtonPressed(_ sender: Any) {
        toggle = "content"
        
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if typeOfItem != "Executive Items" {
            if typeOfItem == "MealKit Items" {
                if ingredientsLabel.text == "Added" && preperationLabel.text == "Added" && preperationContentLabel.text == "Added" {
                    let data : [String: Any] = ["live" : "yes"]
                    db.collection("Chef").document(Auth.auth().currentUser!.uid).collection(self.typeOfItem).document(self.documentId).updateData(data)
                }
                
            }
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChefTab") as? ChefTabViewController  {
                self.present(vc, animated: true, completion: nil)
            }
        } else {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "PersonalChef") as? PersonalChefViewController  {
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
  
    
    private func saveVideo(name: String, description: String, videoUrl: URL, documentId: String) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            
            let storageRef = storage.reference()
            let json: [String: Any] = ["name": "\(name)", "description" : "\(description)", "videoUrl" : "\(videoUrl)"]
            
            
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            // MARK: Fetch the Intent client secret, Ephemeral Key secret, Customer ID, and publishable key
            var request = URLRequest(url: URL(string: "https://taiste-payments.onrender.com/upload-video")!)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = jsonData
            let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                      let entryId = json["entry_id"] as? String,
                      let self = self else {
                    // Handle error
                    return
                }
                DispatchQueue.main.async {
                    self.showToast(message: "Content Added.", font: .systemFont(ofSize: 12))
                    
                    self.contentId = entryId
                    let data: [String: Any] = ["documentId" : entryId]
                    self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection(self.typeOfItem).document(self.documentId).collection("Content").document(entryId).setData(data)
                    self.db.collection("Videos").document(entryId).setData(data)
                    
                    //                storageRef.child("chefs/malik@cheftesting.com/Content/\(self.videoId).png").delete { error in
                    //                    if error == nil {
                    //                    }
                    //                }
                }
                
            })
            task.resume()
            
        } else {
            self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
        }
        
    }
    
    
    private func deleteVideo(entryId: String) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            
            let storageRef = storage.reference()
            let json: [String: Any] = ["entryId" : entryId]
            
            
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            // MARK: Fetch the Intent client secret, Ephemeral Key secret, Customer ID, and publishable key
            var request = URLRequest(url: URL(string: "https://taiste-payments.onrender.com/delete-video")!)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = jsonData
            let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                      let self = self else {
                    // Handle error
                    return
                }
                DispatchQueue.main.async {
                    
                    self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("MealKit Items").document(self.documentId).collection("Content").document(entryId).delete()
                    self.db.collection("Videos").document(entryId).delete()
                    
                    //                storageRef.child("chefs/malik@cheftesting.com/Content/\(self.videoId).png").delete { error in
                    //                    if error == nil {
                    //                    }
                    //                }
                }
                
            })
            task.resume()
            
        } else {
            self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
        }
        
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true)
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

extension MenuItemAdditionsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        if toggle != "content" {
            guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
                return
            }
            let storageRef = storage.reference()
            let documentId = UUID().uuidString
            if toggle == "ingredients" {
                if ingredientsId == "" {
                    ingredientsImage = image
                    ingredientsLabel.text = "Added"
                    ingredientsId = documentId
                    let data: [String: Any] = ["documentId" : documentId]
                    self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection(self.typeOfItem).document(self.documentId).collection("Ingredients").document(documentId).setData(data)
                    storageRef.child("chefs/\(Auth.auth().currentUser!.email!)/MealKit Items/\(self.documentId)/Ingredients/\(documentId).png").putData(image.pngData()!)
                    ingredientsLabel.textColor = UIColor(red:98/255, green: 99/255, blue: 72/255, alpha:1)
                } else {
                    storageRef.child("chefs/\(Auth.auth().currentUser!.email!)/\(self.typeOfItem)/\(self.documentId)/Ingredients/\(documentId).png").putData(image.pngData()!)
                }
            } else if toggle == "preperation" {
                if preperationId == "" {
                    preperationImage = image
                    preperationLabel.text = "Added"
                    preperationId = documentId
                    let data: [String: Any] = ["documentId" : documentId]
                    self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection(self.typeOfItem).document(self.documentId).collection("Preperation").document(documentId).setData(data)
                    storageRef.child("chefs/\(Auth.auth().currentUser!.email!)/\(self.typeOfItem)/\(self.documentId)/Preperation/\(documentId).png").putData(image.pngData()!)
                    preperationLabel.textColor = UIColor(red:98/255, green: 99/255, blue: 72/255, alpha:1)
                }
            } else {
                storageRef.child("chefs/\(Auth.auth().currentUser!.email!)/\(self.typeOfItem)/\(self.documentId)/Preperation/\(documentId).png").putData(image.pngData()!)
            }
            self.showToast(message: "Image Added.", font: .systemFont(ofSize: 12))
            picker.dismiss(animated: true, completion: nil)
        } else {
            guard let video = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL else {
                return
            }
            if toggle == "content" {
                if contentId == "" {
                    contentVideo = video.absoluteURL!
                    let documentId = UUID().uuidString
                    let name = Auth.auth().currentUser!.email!
                    preperationContentLabel.text = documentId
                    contentId = documentId
                    preperationContentLabel.textColor = UIColor(red:98/255, green: 99/255, blue: 72/255, alpha:1)
                    let storageRef = self.storage.reference()
                    storageRef.child("chefs/\(name)/\(self.typeOfItem)/\(self.documentId)/Content/\(documentId).png").putFile(from: contentVideo!, metadata: nil, completion: { storage, error in
                        
                        storageRef.child("chefs/\(name)/Content/\(self.documentId).png").downloadURL(completion: { url, error in
                            
                            if error == nil {
                                self.saveVideo(name: self.chefName, description: "Content Video for \(self.itemTitle)", videoUrl: url!, documentId: documentId)
                            }
                        })
                        
                        
                    })
                } else {
                    self.deleteVideo(entryId: self.contentId)
                    contentVideo = video.absoluteURL!
                    let documentId = UUID().uuidString
                    let name = Auth.auth().currentUser!.email!
                    preperationContentLabel.text = documentId
                    preperationContentLabel.textColor = UIColor(red:98/255, green: 99/255, blue: 72/255, alpha:1)
                    let storageRef = self.storage.reference()
                    storageRef.child("chefs/\(name)/\(self.typeOfItem)/\(self.documentId)/Content/\(documentId).png").putFile(from: contentVideo!, metadata: nil, completion: { storage, error in
                        
                        storageRef.child("chefs/\(name)/Content/\(self.documentId).png").downloadURL(completion: { url, error in
                            
                            if error == nil {
                                self.saveVideo(name: self.chefName, description: "Content Video for \(self.itemTitle)", videoUrl: url!, documentId: documentId)
                            }
                        })
                        
                        
                    })
                }
            }
        }
        picker.dismiss(animated: true, completion: nil)
        }
     
     
        
      
      
        
    
    
}
