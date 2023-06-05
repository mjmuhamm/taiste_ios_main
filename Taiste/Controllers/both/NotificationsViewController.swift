//
//  NotificationsViewController.swift
//  Taiste
//
//  Created by Malik Muhammad on 5/31/23.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import Firebase

class NotificationsViewController: UIViewController {

    private let db = Firestore.firestore()
    
    var chefOrUser = ""
    
    private var notifications : [Notifications] = []
    
    @IBOutlet weak var notificationsTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationsTableView.delegate = self
        notificationsTableView.dataSource = self
        // Do any additional setup after loading the view.
        notificationsTableView.register(UINib(nibName: "NotificationsTableViewCell", bundle: nil), forCellReuseIdentifier: "NotificationsReusableCell")
    }
    
    private func loadNotifications() {
        
    }

    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    
}

extension NotificationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = notificationsTableView.dequeueReusableCell(withIdentifier: "NotificationsReusableCell", for: indexPath) as! NotificationsTableViewCell
        
        let note = notifications[indexPath.row]
        
        cell.notification.text = note.notification
        cell.notificationDate.text = note.notificationDate
        
        cell.notificationTapped = {
            
        }
        
        return cell
    }
    
    
}
