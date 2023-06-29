//
//  FeedViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 2/23/22.
//

import UIKit
import Firebase
import CoreMedia

class FeedViewController: UIViewController {
    
    private let db = Firestore.firestore()

    var content : [VideoModel] = []
    var chefOrFeed = ""
    var index = 0
    @IBOutlet weak var collectionView: UICollectionView!
    var yes = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            
            collectionView.register(UINib(nibName: "FeedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FeedCollectionViewReusableCell")
            collectionView.dataSource = self
            collectionView.delegate = self
            if chefOrFeed == "" {
                
                   
              
            } else {
                collectionView.reloadData()
            }
        }  else {
             self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
       }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.tintColor = UIColor.white
        self.tabBarController?.tabBar.barTintColor = UIColor.black
        loadContent()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        collectionView.reloadData()
    }
    

    private var createdAt = 0
    private func loadContent() {
        let json: [String: Any] = ["created_at": "\(createdAt)"]
        
    
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        // MARK: Fetch the Intent client secret, Ephemeral Key secret, Customer ID, and publishable key
        var request = URLRequest(url: URL(string: "https://taiste-video.onrender.com/get-videos")!)
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
                
                if videos.count == 0 {
                    
                } else {
                    for i in 0..<videos.count {
                        let id = videos[i]["id"]!
                        let createdAtI = videos[i]["createdAt"]!
                        if i == videos.count - 1 {
                            self.createdAt = createdAtI as! Int
                        }
                        var views = 0
                        var liked : [String] = []
                        var comments = 0
                        var shared = 0
                        
                        
                      
                        var name = "\(videos[i]["name"]!)"
                        if name == "malik@cheftesting.com" || name == "malik@cheftesting2.com" {
                            name = "@chefTest"
                        }
                        print("name \(name)")
                        if name != "sample" && name != "sample1" {
                            var description = videos[i]["description"]! as! String
                            if videos[i]["description"]! as! String == "no description" {
                                description = ""
                            }
                            self.db.collection("Videos").document("\(id)").getDocument { document, error in
                                if error == nil {
                                    
                                    if document!.exists {
                                        let data = document!.data()
                                        
                                        views = Int("\(data!["views"]!)")!
                                        
                                        if data!["liked"] != nil {
                                            liked = data!["liked"] as! [String]
                                        }
                                        
                                        if data!["shared"] != nil {
                                            shared = data!["shared"] as! Int
                                        }
                                        
                                        if data!["comments"] != nil {
                                            comments = data!["comments"] as! Int
                                        }
                                    }
                                }
                                print("videos \(videos)")
                                print("dataUri \(videos[i]["dataUrl"]! as! String)")
                                
                                let newVideo = VideoModel(dataUri: videos[i]["dataUrl"]! as! String, id: videos[i]["id"]! as! String, videoDate: String(createdAtI as! Int), user: name, description: description, views: views, liked: liked, comments: comments, shared: shared, thumbNailUrl: videos[i]["thumbnailUrl"]! as! String)
                                
                                if self.content.isEmpty {
                                    self.content.append(newVideo)
                                    self.content.shuffle()
                                    self.collectionView.reloadData()
                                    
                                } else {
                                    let index = self.content.firstIndex { $0.id == id as! String
                                    }
                                    if index == nil {
                                        self.content.append(newVideo)
                                        self.content.shuffle()
                                        self.collectionView.reloadData()
                                    }
                                }
                            }
                        }
                    }
                }
            }
            })
        
            task.resume()
        
    }
    
    private func deleteVideo(id: String) {
        let json: [String: Any] = ["entryId": id]
        
    
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        // MARK: Fetch the Intent client secret, Ephemeral Key secret, Customer ID, and publishable key
        var request = URLRequest(url: URL(string: "https://taiste-video.onrender.com/delete-video")!)
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
              self.showToastCompletion(message: "Item Deleted", font: .systemFont(ofSize: 12))
              self.dismiss(animated: true)
          }
        })
        task.resume()
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
            self.dismiss(animated: true)
            toastLabel.removeFromSuperview()
        })
    }

}

extension FeedViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return content.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedCollectionViewReusableCell", for: indexPath) as! FeedCollectionViewCell
        
        var model = content[indexPath.row]
        
        
        cell.configure(model: model)
        cell.likeText.text = "\(model.liked.count)"
        cell.commentText.text = "\(model.comments)"
        cell.shareText.text = "\(model.shared)"
        cell.userName.text = model.user
        cell.videoDescription.text = model.description
        
        if (model.liked.contains(Auth.auth().currentUser!.email!)) {
            cell.likeImage.image = UIImage(systemName: "heart.fill")
        } else {
            cell.likeImage.image = UIImage(systemName: "heart")
        }
        
        cell.likeButtonTapped = {
            if !model.liked.contains(Auth.auth().currentUser!.email!) {
                self.db.collection("Videos").document(model.id).updateData(["liked" : FieldValue.arrayUnion(["\(Auth.auth().currentUser!.email!)"])])
                model.liked.append(Auth.auth().currentUser!.email!)
                cell.likeText.text = "\(Int(cell.likeText.text!)! + 1)"
                cell.likeImage.image = UIImage(systemName: "heart.fill")
                
            } else {
                self.db.collection("Videos").document(model.id).updateData(["liked" : FieldValue.arrayRemove(["\(Auth.auth().currentUser!.email!)"])])
                if let index = model.liked.firstIndex(where: { $0 == "\(Auth.auth().currentUser!.email!)" }) {
                    model.liked.remove(at: index)
                }
                
                model.liked.append(Auth.auth().currentUser!.email!)
                cell.likeText.text = "\(Int(cell.likeText.text!)! - 1)"
                cell.likeImage.image = UIImage(systemName: "heart")
            }
        }
        
        
        if chefOrFeed != "" {
            cell.backButton.isHidden = false
            if chefOrFeed == "chef" {
                print("feed happening 212")
                cell.deleteButton.isHidden = false
            }
        } else {
            cell.backButton.isHidden = true
            cell.deleteButton.isHidden = true
        }
        
        
        cell.backButtonTapped = {
            self.dismiss(animated: true)
        }
        
        if yes != "" {
            cell.deleteButton.isHidden = false
        }
        cell.deleteButtonTapped = {
            
            let alert = UIAlertController(title: "Are you sure you want to delete this item?", message: nil, preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (handler) in
                self.deleteVideo(id: model.id)
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (handler) in
                alert.dismiss(animated: true, completion: nil)
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        cell.playPauseButtonTapped = {
            cell.playPauseButton.isSelected = !cell.playPauseButton.isSelected
            if (cell.playPauseButton.isSelected) {
                cell.player.pause()
                cell.playImage.isHidden = false
            } else {
                cell.player.play()
                cell.playImage.isHidden = true
            }
        }
        
        cell.commentButtonTapped = {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "Comments") as? CommentsViewController  {
                vc.videoId = model.id
                self.present(vc, animated: true, completion: nil)
            }
        }
        
        
        
        return cell
    }
//
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? FeedCollectionViewCell {
            cell.playImage.isHidden = true
            cell.player?.seek(to: CMTime.zero)
            cell.player?.play()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? FeedCollectionViewCell {
            cell.player?.pause()
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0 )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    
    
    
}
