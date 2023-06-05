//
//  Reviews.swift
//  Taiste
//
//  Created by Malik Muhammad on 5/30/23.
//

import Foundation
import UIKit

struct Reviews {
    let date: String
    let expectations: Int
    let quality: Int
    let chefRating: Int
    let likes: [String]
    let recommend: Int
    let thoughts: String
    let image: UIImage
    let userImageId: String
    let userEmail: String
    let documentId: String
}

struct ReviewData {
    let expectationsMet: Int
    let quality: Int
    let chefRating: Int
}
