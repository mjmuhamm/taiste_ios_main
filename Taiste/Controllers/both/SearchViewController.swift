//
//  SearchViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 5/2/23.
//

import UIKit

class SearchViewController: UIViewController, UISearchResultsUpdating {
    
    
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    private var data : [String] = []
    private var searchResults : [String] = []
    
    private let searchController = UISearchController()
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Search"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchReusableCell")
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        setupData()
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {
            return
        }
        searchResults.removeAll()
        for string in data {
            if string.starts(with: text) {
                searchResults.append(string)
                tableView.reloadData()
            }
        }
        print("text \(text)")
    }
    
    private func setupData() {
        data.append("John")
        data.append("Abe")
        data.append("Jenny")
        data.append("Dan")
        data.append("Zach")
        data.append("Luke")
        data.append("Kevin")
        data.append("Briana")
        data.append("Melanie")
        data.append("Sarah")
        data.append("Shawn")
        data.append("Teri")
        data.append("Tom")
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
        if !searchResults.isEmpty {
            cell.userName.text = searchResults[indexPath.row]
        } else {
            cell.userName.text = data[indexPath.row]
        }
        
        
        
        return cell
    
    }
}
