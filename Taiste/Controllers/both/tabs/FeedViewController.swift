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

    private var content : [VideoModel] = []
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(UINib(nibName: "FeedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FeedCollectionViewReusableCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        loadContent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.tintColor = UIColor.white
        self.tabBarController?.tabBar.barTintColor = UIColor.black
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
                      
                      self.db.collection("Videos").document("\(id)").getDocument { document, error in
                          if error == nil {
                              
                              if document!.exists {
                                  let data = document!.data()
                                  
                                  if data!["views"] != nil {
                                      views = data!["views"] as! Int
                                  }
                                  
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
                          
                          let newVideo = VideoModel(dataUri: videos[i]["dataUrl"]! as! String, id: videos[i]["id"]! as! String, videoDate: String(createdAtI as! Int), user: videos[i]["name"]! as! String, description: videos[i]["description"]! as! String, views: views, liked: liked, comments: comments, shared: shared, thumbNailUrl: videos[i]["thumbnailUrl"]! as! String)
                          
                          if self.content.isEmpty {
                              self.content.append(newVideo)
                              self.collectionView.reloadData()
                              
                          } else {
                              let index = self.content.firstIndex { $0.id == id as! String
                              }
                              if index == nil {
                                  self.content.append(newVideo)
                                  self.collectionView.reloadData()
                              }
                          }
                      }
                  }
              }
          }
        })
        task.resume()
    }
    

}

extension FeedViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return content.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedCollectionViewReusableCell", for: indexPath) as! FeedCollectionViewCell
        
        let model = content[indexPath.row]
        
        cell.configure(model: model)
        cell.likeText.text = "\(model.liked.count)"
        cell.commentText.text = "\(model.comments)"
        cell.shareText.text = "\(model.shared)"
        
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
