//
//  SearchViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 5/2/23.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import SystemConfiguration

class SearchViewController: UIViewController, UISearchResultsUpdating {
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    private var data : [Search] = []
    private var searchResults : [Search] = []
    
    private let searchController = UISearchController()
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Search"
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchReusableCell")
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.searchController?.searchBar.autocapitalizationType = .none
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
        
        if Auth.auth().currentUser != nil {
            setupData()
        } else {
            self.showToast(message: "Something went wrong. Please check your connection.", font: .systemFont(ofSize: 12))
        }
        } else {
              self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.tintColor = UIColor(red: 160/255, green: 162/255, blue: 104/255, alpha: 1)
        self.tabBarController?.tabBar.barTintColor = UIColor.white
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
       
        guard let text = searchController.searchBar.text else {
            return
        }
        searchResults.removeAll()
        for string in data {
            if string.userFullName.starts(with: text) || string.userName.starts(with: text) {
                searchResults.append(string)
                tableView.reloadData()
            }
        }
        setupData()
        print("text \(text)")
        } else {
              self.showToast(message: "Seems to be a problem with your internet. Please check your connection.", font: .systemFont(ofSize: 12))
        }
    }
    
    private var count = 0
    private func setupData() {
        let storageRef = storage.reference()
        
        db.collection("Usernames").getDocuments { documents, error in
            if error == nil {
                if self.data.count != documents?.documents.count {
                    for doc in documents!.documents {
                        let data = doc.data()
                        self.count = documents!.documents.count
                        if let username = data["username"] as? String, let fullName = data["fullName"] as? String, let email = data["email"] as? String, let chefOrUser = data["chefOrUser"] as? String {
                            var chefOrUser1 = ""
                            if chefOrUser == "User" {
                                chefOrUser1 = "users"
                            } else {
                                chefOrUser1 = "chefs"
                            }
                            
                            storageRef.child("\(chefOrUser1)/\(email)/profileImage/\(doc.documentID).png").downloadURL { imageUrl, error in
                                if imageUrl != nil {
                                    URLSession.shared.dataTask(with: imageUrl!) { (data, response, error) in
                                        // Error handling...
                                        guard let imageData = data else { return }
                                        
                                        print("happening itemdata")
                                        DispatchQueue.main.async {
                                            
                                            if self.data.isEmpty {
                                                self.data.append(Search(userName: username, userEmail: email, userFullName: fullName, userImage: UIImage(data: imageData)!, pictureId: doc.documentID, chefOrUser: chefOrUser))
                                            } else {
                                                let index = self.data.firstIndex { $0.pictureId == doc.documentID }
                                                   if index == nil {
                                                       self.data.append(Search(userName: username, userEmail: email, userFullName: fullName, userImage: UIImage(data: imageData)!, pictureId: doc.documentID, chefOrUser: chefOrUser))
                                                               
                                                                  
                                                }
                                            }
                                        }
                                    }.resume()
                                }
                                
                            }
                           
                        }
                    }
                }
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

extension SearchViewController :  UITableViewDelegate, UITableViewDataSource  {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !searchResults.isEmpty {
            return searchResults.count
        }
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchReusableCell", for: indexPath) as! SearchTableViewCell
        var user = data[indexPath.row]
        if !searchResults.isEmpty {
            user = searchResults[indexPath.row]
            cell.userName.text = searchResults[indexPath.row].userName
            cell.userFullName.text = searchResults[indexPath.row].userFullName
            cell.userImage.image = searchResults[indexPath.row].userImage
        } 
        
        
        var chefOrUser = ""
        if user.chefOrUser == "User" { chefOrUser = "users" } else { chefOrUser = "chefs" }
        
        let storageRef = storage.reference()
        print("cheforuser \(chefOrUser)")
        print("\(user.userEmail)")
        print("\(user.pictureId)")
        
        
       
        
        cell.userProfileTapped = {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileAsUser") as? ProfileAsUserViewController  {
                vc.user = user.pictureId
                vc.chefOrUser = "\(chefOrUser.prefix(4))"
                self.present(vc, animated: true, completion: nil)
            }
        }
        
        
        return cell
    
    }
}

public class Reachability {

    class func isConnectedToNetwork() -> Bool {

        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }

        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }

        /* Only Working for WIFI
        let isReachable = flags == .reachable
        let needsConnection = flags == .connectionRequired

        return isReachable && !needsConnection
        */

        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)

        return ret

    }
}
