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

import MobileCoreServices
import UniformTypeIdentifiers

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
    private var contentVideo = ""
    
    var chefOrUser = ""
    var chefEmail = ""
    var chefImageId = ""
    
    var typeOfItem = ""
    private var toggle = ""
    private var chefName = ""
    var menuItemId = ""
    var itemTitle = ""
    
    private var ingredientsId = ""
    private var preperationId = ""
    private var contentId = ""
    @IBOutlet weak var saveButton: MDCButton!
    
    @IBOutlet weak var ingredientsButton: UIButton!
    @IBOutlet weak var promotionalContentVideoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if chefOrUser != "user" {
            loadUsername()
            chefEmail = Auth.auth().currentUser!.email!
        }
        if chefOrUser != "" {
            saveButton.isHidden = true
            self.ingredientsButton.isEnabled = false
            self.preperationGuideButton.isEnabled = false
            self.uploadPreperationContentButton.isEnabled = false
        }
        if typeOfItem == "MealKit Items" {
            promotionalContentVideoLabel.text = "Preperation Guide Content Video"
        }
        loadItems()
        ingredientsLabel.text = "No Ingredients Uploaded"
        ingredientsLabel.textColor = UIColor.systemGray4
        preperationLabel.text = "No Preperation Guide Uploaded"
        preperationLabel.textColor = UIColor.systemGray4
        preperationContentLabel.text = "No Video Content Uploaded"
        preperationContentLabel.textColor = UIColor.systemGray4
        
        
        
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
        let a : [String] = ["Ingredients", "Preperation", "Content"]
        for i in 0..<3 {
            db.collection("Chef").document(b).collection(typeOfItem).document(menuItemId).collection(a[i]).getDocuments { documents, error in
                if error == nil {
                    if documents != nil {
                        for doc in documents!.documents {
                            let data = doc.data()
                            if let documentId = data["documentId"] as? String {
                                if a[i] == "Ingredients" {
                                    
                                    print("chefs chefs/\(self.chefEmail)/\(self.typeOfItem)/\(self.menuItemId)/Ingredients/\(doc.documentID).png")
                                    self.storage.reference().child("chefs/\(self.chefEmail)/\(self.typeOfItem)/\(self.menuItemId)/Ingredients/\(doc.documentID).png").downloadURL { url, error in
                                        
                                        if error == nil {
                                            URLSession.shared.dataTask(with: url!) { (data, response, error) in
                                                // Error handling...
                                                guard let imageData = data else { return }
                                                
                                                print("happening itemdata")
                                                DispatchQueue.main.async {
                                                    self.ingredientsId = doc.documentID
                                                    self.ingredientsLabel.text = "Added"
                                                    self.ingredientsImage = UIImage(data: imageData)!
                                                    self.ingredientsButton.isEnabled = true
                                                    
                                                }
                                            }.resume()
                                        }
                                    }
                                    
                                    
                                    self.ingredientsLabel.textColor = UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1)
                                } else if a[i] == "Preperation" {
                                    self.storage.reference().child("chefs/\(self.chefEmail)/\(self.typeOfItem)/\(self.menuItemId)/Preperation/\(doc.documentID).png").downloadURL { url, error in
                                        if error == nil {
                                            URLSession.shared.dataTask(with: url!) { (data, response, error) in
                                                // Error handling...
                                                guard let imageData = data else { return }
                                                
                                                print("happening itemdata")
                                                DispatchQueue.main.async {
                                                    self.preperationId = doc.documentID
                                                    self.preperationLabel.text = "Added"
                                                    self.preperationGuideButton.isEnabled = true
                                                    self.preperationImage = UIImage(data: imageData)!
                                                    
                                                }
                                            }.resume()
                                        }
                                    }
                                    
                                    
                                    
                                    
                                    self.preperationLabel.textColor = UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1)
                                } else if a[i] == "Content" {
                                    self.contentVideo = self.getVideo(id: doc.documentID)
                                    self.preperationContentLabel.textColor = UIColor(red: 98/255, green: 99/255, blue: 72/255, alpha: 1)
                                }
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    private func getVideo(id: String) -> String {
        var dataUri = ""
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            db.collection("Chef").document(Auth.auth().currentUser!.uid).collection("PersonalInfo").getDocuments { documents, error in
                if error == nil {
                    if documents != nil {
                        for doc in documents!.documents {
                            let data = doc.data()
                            
                            if let name = data["chefName"] as? String {
                 
                                let storageRef = self.storage.reference()
            let json: [String: Any] = ["name": "\(name)"]
            
            
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            // MARK: Fetch the Intent client secret, Ephemeral Key secret, Customer ID, and publishable key
            var request = URLRequest(url: URL(string: "https://taiste-video.onrender.com/get-user-videos")!)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = jsonData
            let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                      let videos = json["videos"] as? [[String:Any]],
                      let self = self else {
                    // Handle error
                    return
                }
                DispatchQueue.main.async {
                    self.showToast(message: "Content Added.", font: .systemFont(ofSize: 12))
                    print("id \(id)")
                    for i in 0..<videos.count {
                        
                        var id2 = "\(videos[i]["id"]!)"
                        print("id2  \(id2)")
                        
                        
                         
                        if id == id2 {
                            self.contentVideo = "\(videos[i]["dataUrl"]!)"
                            self.contentId = id2
                            self.preperationContentLabel.text = "Added"
                            self.uploadPreperationContentButton.isEnabled = true
                            dataUri = "\(videos[i]["dataUrl"]!)"
                        }
                        
                    }
                    
                    
                    
                }
                
            })
            task.resume()
                                
                            }
                        }
                    }
                }
            }
            
        } else {
            self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
        }
        return dataUri
    }
    

    @IBAction func uploadIngredientsButtonPressed(_ sender: Any) {
        if Reachability.isConnectedToNetwork(){
            toggle = "ingredients"
        print("Internet Connection Available!")
     
            if chefOrUser != "" {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "MealKitVideo") as? YoutubeViewController  {
                    vc.example = "uploadIngredient"
                    vc.image = self.ingredientsImage!
                    vc.typeOfDisplay = "Ingredients Guide"
                    self.present(vc, animated: true, completion: nil)
                }
            } else {
                
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
    } else {
    self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
   }
        
    }
    
    @IBAction func uploadPreperationGuideButtonPressed(_ sender: Any) {
        toggle = "preperation"
        if Reachability.isConnectedToNetwork(){
        print("Internet Connection Available!")
            if chefOrUser != "" {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "MealKitVideo") as? YoutubeViewController  {
                    vc.example = "prepGuide"
                    vc.image = self.preperationImage!
                    vc.typeOfDisplay = "Preperation Guide"
                    self.present(vc, animated: true, completion: nil)
                }
            } else {
                
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
        
            
    } else {
    self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
   }
        
    }
    
    @IBAction func uploadPreperationContentVideoButtonPressed(_ sender: Any) {
        toggle = "content"
        if chefOrUser != "" {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "MealKitVideo") as? YoutubeViewController  {
                vc.example = "videoContent"
                vc.videoUrl = self.contentVideo
                if self.typeOfItem == "MealKit Items" {
                    vc.typeOfDisplay = "Preperation Content Guide"
                } else {
                    vc.typeOfDisplay = "Promotional Content"
                }
                self.present(vc, animated: true, completion: nil)
            }
        } else {
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let video = UIImagePickerController()
                video.allowsEditing = true
                video.mediaTypes = [UTType.movie.identifier]
                video.delegate = self
                self.present(video, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if typeOfItem != "Executive Items" {
            if typeOfItem == "MealKit Items" {
                if ingredientsLabel.text == "Added" && preperationLabel.text == "Added" && preperationContentLabel.text == "Added" {
                    let data : [String: Any] = ["live" : "yes"]
                    db.collection("Chef").document(Auth.auth().currentUser!.uid).collection(self.typeOfItem).document(self.menuItemId).updateData(data)
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
            var request = URLRequest(url: URL(string: "https://taiste-video.onrender.com/upload-video")!)
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
                    self.saveButton.isEnabled = true
                    self.contentId = entryId
                    let data: [String: Any] = ["documentId" : entryId]
                    self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection(self.typeOfItem).document(self.menuItemId).collection("Content").document(entryId).setData(data)
                    self.db.collection(self.typeOfItem).document(self.menuItemId).collection("Content").document(entryId).setData(data)
                    self.db.collection("Videos").document(entryId).setData(data)
                    
                   
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
                    
                    self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection(self.typeOfItem).document(self.menuItemId).collection("Content").document(entryId).delete()
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
                    self.db.collection(self.typeOfItem).document(self.menuItemId).collection("Ingredients").document(documentId).setData(data)
                    self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection(self.typeOfItem).document(self.menuItemId).collection("Ingredients").document(documentId).setData(data)
                    storageRef.child("chefs/\(Auth.auth().currentUser!.email!)/\(self.typeOfItem)/\(self.menuItemId)/Ingredients/\(documentId).png").putData(image.pngData()!)
                    ingredientsLabel.textColor = UIColor(red:98/255, green: 99/255, blue: 72/255, alpha:1)
                } else {
                    let data: [String: Any] = ["documentId" : self.ingredientsId]
                    self.db.collection(self.typeOfItem).document(self.menuItemId).collection("Ingredients").document(documentId).updateData(data)
                    storageRef.child("chefs/\(Auth.auth().currentUser!.email!)/\(self.typeOfItem)/\(self.menuItemId)/Ingredients/\(self.ingredientsId).png").putData(image.pngData()!)
                }
            } else if toggle == "preperation" {
                if preperationId == "" {
                    preperationImage = image
                    preperationLabel.text = "Added"
                    preperationId = documentId
                    let data: [String: Any] = ["documentId" : documentId]
                    self.db.collection(self.typeOfItem).document(self.menuItemId).collection("Preperation").document(documentId).setData(data)
                    self.db.collection("Chef").document(Auth.auth().currentUser!.uid).collection(self.typeOfItem).document(self.menuItemId).collection("Preperation").document(documentId).setData(data)
                    storageRef.child("chefs/\(Auth.auth().currentUser!.email!)/\(self.typeOfItem)/\(self.menuItemId)/Preperation/\(documentId).png").putData(image.pngData()!)
                    preperationLabel.textColor = UIColor(red:98/255, green: 99/255, blue: 72/255, alpha:1)
                }
            } else {
                let data: [String: Any] = ["documentId" : self.preperationId]
                self.db.collection(self.typeOfItem).document(self.menuItemId).collection("Preperation").document(documentId).updateData(data)
                storageRef.child("chefs/\(Auth.auth().currentUser!.email!)/\(self.typeOfItem)/\(self.menuItemId)/Preperation/\(self.preperationId).png").putData(image.pngData()!)
            }
            self.showToast(message: "Image Added.", font: .systemFont(ofSize: 12))
            picker.dismiss(animated: true, completion: nil)
        } else {
            guard let video = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL else {
                return
            }
            if toggle == "content" {
                if contentId == "" {
                    contentVideo = "\(video.absoluteURL!)"
                    let documentId = UUID().uuidString
                    let name = Auth.auth().currentUser!.email!
                    preperationContentLabel.text = "Added"
                    contentId = documentId
                    preperationContentLabel.textColor = UIColor(red:98/255, green: 99/255, blue: 72/255, alpha:1)
                    let storageRef = self.storage.reference()
                    storageRef.child("chefs/\(name)/\(self.typeOfItem)/\(self.menuItemId)/Content/\(documentId).png").putFile(from: URL(string: self.contentVideo)!, metadata: nil, completion: { storage, error in
                        
                        storageRef.child("chefs/\(name)/\(self.typeOfItem)/\(self.menuItemId)/Content/\(documentId).png").downloadURL(completion: { url, error in
                            
                            if error == nil {
                                self.saveButton.isEnabled = false
                                print("url \(url!)")
                                self.saveVideo(name: self.chefName, description: "Content Video for \(self.itemTitle)", videoUrl: url!, documentId: documentId)
                            }
                        })
                        
                        
                    })
                } else {
                    self.deleteVideo(entryId: self.contentVideo)
                    contentVideo = "\(video.absoluteURL!)"
                    let documentId = UUID().uuidString
                    let name = Auth.auth().currentUser!.email!
                    preperationContentLabel.text = "Added"
                    preperationContentLabel.textColor = UIColor(red:98/255, green: 99/255, blue: 72/255, alpha:1)
                    let storageRef = self.storage.reference()
                    storageRef.child("chefs/\(name)/\(self.typeOfItem)/\(self.menuItemId)/Content/\(documentId).png").putFile(from: URL(string: self.contentVideo)!, metadata: nil, completion: { storage, error in
                        
                        storageRef.child("chefs/\(name)/\(self.typeOfItem)/\(self.menuItemId)/Content/\(documentId).png").downloadURL(completion: { url, error in
                            
                            if error == nil {
                                print("content happening")
                                self.saveVideo(name: self.chefName, description: "Content Video for \(self.itemTitle)", videoUrl: url!, documentId: documentId)
                            } else {
                                print("error content \(error?.localizedDescription)")
                            }
                        })
                        
                        
                    })
                }
            }
        }
        picker.dismiss(animated: true, completion: nil)
        }
     
     
        
      
      
        
    
    
}
