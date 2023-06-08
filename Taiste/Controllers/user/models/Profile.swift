//
//  Profile.swift
//  Taiste
//
//  Created by Malik Muhammad on 3/1/22.
//

import Foundation
import UIKit


struct UserOrders {
    
    let chefName: String
    let chefEmail: String
    let chefImageId: String
    var chefImage: UIImage?
    let city: String
    let state: String
    let zipCode: String
    let eventDates: [String]
    let itemTitle: String
    let itemDescription: String
    let itemPrice: String
    let menuItemId: String
    var itemImage: UIImage?
    let orderDate: String
    let orderUpdate: String
    let totalCostOfEvent: Double
    let travelFee: String
    let typeOfService: String
    let imageCount: Int
    let liked: [String]
    let itemOrders: Int
    let itemRating: [Double]
    let itemCalories: Int
    let documentId: String
    let expectations: Int
    let chefRating: Int
    let quality: Int
    let signatureDishId: String

}

struct UserChefs {
    
    let chefEmail: String
    let chefImageId: String
    var chefImage: UIImage?
    let chefName: String
    let chefPassion: String
    var timesLiked: Int
    var chefLiked: [String]
    var chefOrders: Int
    var chefRating: [Double]
    
}

struct UserLikes {
    
    let chefName: String
    let chefEmail: String
    let chefImageId: String
    var chefImage: UIImage?
    let itemType: String
    let city: String
    let state: String
    let zipCode: String
    let itemTitle: String
    let itemDescription: String
    let itemPrice: String
    var itemImage: UIImage?
    let imageCount: Int
    let liked: [String]
    let itemOrders: Int
    let itemRating: [Double]
    let itemCalories: Int
    let documentId: String
    let expectations: Int
    let chefRating: Int
    let quality: Int
    let signatureDishId: String
    
}

struct UserReviews {
    
    let chefEmail: String
    let chefImageId: String
    let chefImage: UIImage?
    let chefName: String
    let date: String
    let documentID: String
    let itemTitle: String
    let itemType: String
    let liked: [String]
    let user: String
    let userChefRating: Int
    let userExpectationsRating: Int
    let userImageId: String
    let userQualityRating: Int
    let userRecommendation: Int
    let userReviewTextField: String
    
}


