//
//  Banking.swift
//  Taiste
//
//  Created by Malik Muhammad on 5/1/23.
//

import Foundation

struct IndividualBankingInfo {
    
    let stripeAccountId: String
    var termsOfServiceAcceptance: String
    let mccCode: String
    let businessUrl: String
    let firstName: String
    let lastName: String
    let month: String
    let day: String
    let year: String
    let phoneNumber: String
    let email: String
    let streetAddress: String
    let city: String
    let state: String
    let zipCode: String
    let last4ofSSN: String
    var externalAccount: ExternalAccount?
    
}

struct BusinessBankingInfo {
    let stripeAccountId: String
    var termsOfServiceAcceptance: String
    let mccCode: String
    let businessUrl: String
    let companyName: String
    let companyPhone: String
    let streetAddress: String
    let city: String
    let state: String
    let zipCode: String
    let companyTaxId: String
    var externalAccount: ExternalAccount?
    var representative: Representative?
    var owner1: Representative?
    var owner2: Representative?
    var owner3: Representative?
    var owner4: Representative?
    var bankingInfoDocumentId: String
}

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
