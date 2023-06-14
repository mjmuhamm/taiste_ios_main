//
//  Notifications.swift
//  Taiste
//
//  Created by Malik Muhammad on 5/31/23.
//

import Foundation

struct Notifications {
    let chefOrUser: String
    let messageOrEvent: String
    let notification: String
    let date: String
    let documentId: String
}

struct MessageNotification {
    let chefOrUser: String
    let notification: String
    let userName: String
    let userEmail: String
    let userImageId: String
    let date: String
    let documentId: String
}
