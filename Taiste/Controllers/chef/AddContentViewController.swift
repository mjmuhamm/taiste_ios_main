//
//  AddContentViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 4/29/23.
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
import AVFoundation

class AddContentViewController: UIViewController {
  
    @IBOutlet weak var addVideoButton: MDCButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var contentDescription: UITextField!
    
    var player : AVPlayer!
    var layer : AVPlayerLayer!
    
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var playPauseImage: UIImageView!
    
    @IBOutlet weak var actiityIndicator: UIActivityIndicatorView!
    
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    var videoId = UUID().uuidString
    var videoUrl : URL?
    private var chefName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        actiityIndicator.isHidden = true
        
        loadUsername()
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
    
    private func saveVideo(name: String, description: String, videoUrl: URL) {
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
                      let self = self else {
                    // Handle error
                    return
                }
                DispatchQueue.main.async {
                    
                    self.showToastCompletion(message: "Item Saved.", font: .systemFont(ofSize: 12))
                    self.actiityIndicator.stopAnimating()
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
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func addVideoButtonPressed(_ sender: Any) {
        if pauseButton.isSelected == false && player != nil {
            player.pause()
            playPauseImage.isHidden = false
            pauseButton.isSelected = true
        }
        
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let video = UIImagePickerController()
            video.allowsEditing = true
            video.mediaTypes = [UTType.movie.identifier]
            video.delegate = self
            self.present(video, animated: true, completion: nil)
        }
    }
    
    @IBAction func pauseButtonPressed(_ sender: Any) {
        if pauseButton.isSelected {
            pauseButton.isSelected = false
            playPauseImage.isHidden = true
            player.play()
        } else {
            pauseButton.isSelected = true
            playPauseImage.isHidden = false
            player.pause()
        }
    }
    
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        var description = ""
        if  contentDescription.text != nil && !self.contentDescription.text!.isEmpty {
            description = self.contentDescription.text!
        }
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            let storageRef = storage.reference()
            if videoUrl != nil {
                actiityIndicator.isHidden = false
                actiityIndicator.startAnimating()
                
                storageRef.child("chefs/\(Auth.auth().currentUser!.email!)/Content/\(videoId).png").putFile(from: videoUrl!, metadata: nil, completion: { storage, error in
                    
                    storageRef.child("chefs/\(Auth.auth().currentUser!.email!)/Content/\(self.videoId).png").downloadURL(completion: { url, error in
                        
                        if error == nil {
                            self.saveVideo(name: self.chefName, description: description, videoUrl: url!)
                        }
                    })
                    
                    
                })
                
            }
        }  else {
            self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
        }
        
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        
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
            self.dismiss(animated: true, completion: nil)
            toastLabel.removeFromSuperview()
        })
    }
    
    
    
}

extension AddContentViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        print("info \(info)")
        guard let video = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL else {
            return
        }
        print("video \(video)")
        videoUrl = video.absoluteURL
        player = AVPlayer(url: URL(string: "\(video)")!)
        playPauseImage.isHidden = true
        pauseButton.isSelected = false
        layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspectFill
        layer.frame = self.videoView.bounds
        self.videoView.layer.addSublayer(layer)
        
        player.play()
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
}
