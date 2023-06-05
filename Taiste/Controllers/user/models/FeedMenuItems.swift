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
    var chefImage: UIImage?
    let menuItemId: String
    var itemImage: UIImage?
    let itemTitle: String
    let itemDescription: String
    let itemPrice: String
    let liked: [String]
    let itemOrders: Int
    let itemRating: [Double]
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

struct PersonalChefInfo {
    
    let chefName: String
    let chefEmail: String
    let chefImageId: String
    let chefImage: UIImage
    let city: String
    let state: String
    var signatureDishImage: UIImage
    var option1Title: String
    var option2Title: String
    var option3Title: String
    var option4Title: String
    let briefIntroduction: String
    var howLongBeenAChef: String
    var specialty: String
    var whatHelpesYouExcel: String
    var mostPrizedAccomplishment: String
    var availabilty: String
    let hourlyOrPerSession: String
    let servicePrice: String
    let trialRun: Int
    let weeks: Int
    let months: Int
    let liked: [String]
    let itemOrders: Int
    let itemRating: Double
    let expectations: Int
    let chefRating: Int
    let quality: Int
    let documentId: String
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
