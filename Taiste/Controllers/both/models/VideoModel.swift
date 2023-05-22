//
//  VideoModel.swift
//  Taiste
//
//  Created by Malik Muhammad on 3/1/22.
//

import Foundation

struct VideoModel {
    
    let dataUri: String
    let id: String
    let videoDate: String
    let user: String
    let description: String
    let views: Int
    var liked: [String]
    var comments: Int
    var shared: Int
    var thumbNailUrl: String
    
}
