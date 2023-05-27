//
//  FeedMenuItems.swift
//  Taiste
//
//  Created by Malik Muhammad on 2/24/22.
//

import Foundation
import UIKit


struct FeedMenuItems {
    let chefEmail: String
    let chefPassion: String
    let chefUsername: String
    let chefImageId: String
    let chefImage: UIImage?
    let menuItemId: String
    var itemImage: UIImage?
    let itemTitle: String
    let itemDescription: String
    let itemPrice: String
    let liked: [String]
    let itemOrders: Int
    let itemRating: Double
    let date: String
    let imageCount: Int
    let itemCalories: String
    let itemType: String
    let city: String
    let state: String
    let zipCode: String
    let user: String
    let healthy: Int
    let creative: Int
    let vegan: Int
    let burger: Int
    let seafood: Int
    let pasta: Int
    let workout: Int
    let lowCal: Int
    let lowCarb: Int
}

struct Filter{
    let local: Int
    let region: Int
    let nation: Int
    let city: String
    let state: String
    let burger: Int
    let creative: Int
    let lowCal: Int
    let lowCarb: Int
    let pasta: Int
    let healthy: Int
    let vegan: Int
    let seafood: Int
    let workout: Int
    let surpriseMe: Int
}
