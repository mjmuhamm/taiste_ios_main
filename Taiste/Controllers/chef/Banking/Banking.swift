//
//  Banking.swift
//  Taiste
//
//  Created by Malik Muhammad on 5/1/23.
//

import Foundation

struct Representative {
    
    let isPersonAnOwner: String
    let isPersonAnExectutive: String!
    let firstName: String
    let lastName: String
    let month: String
    let day: String
    let year: String
    let streetAddress: String
    let city: String
    let state: String
    let zipCode: String
    let emailAddress: String
    let phoneNumber: String
    let last4OfSSN: String
    let id: String
    
}

struct ExternalAccount {
    
    let bankName: String
    let accountHolder: String
    let accountNumber: String
    let routingNumber: String
    let id: String
}
