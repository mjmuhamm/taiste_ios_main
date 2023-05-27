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
        
        setupData()
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
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
                                if error == nil {
                                    URLSession.shared.dataTask(with: imageUrl!) { (data, response, error) in
                                        // Error handling...
                                        guard let imageData = data else { return }
                                        
                                        print("happening itemdata")
                                        DispatchQueue.main.async {
                                            let image = UIImage(data: imageData)!
                                            
                                            
                                            if self.data.isEmpty {
                                                self.data.append(Search(userName: username, userEmail: email, userFullName: fullName, userImage: image, pictureId: doc.documentID, chefOrUser: chefOrUser))
                                            } else {
                                                let index = self.data.firstIndex { $0.pictureId == doc.documentID }
                                                if index == nil {
                                                    self.data.append(Search(userName: username, userEmail: email, userFullName: fullName, userImage: image, pictureId: doc.documentID, chefOrUser: chefOrUser))
                                                    
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
        if user.chefOrUser == "User" {
            chefOrUser = "users"
        } else {
            chefOrUser = "chefs"
        }
        
       
        
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
