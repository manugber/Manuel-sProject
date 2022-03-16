//
//  Elemento.swift
//  Manuel'sProject
//
//  Created by Manuel González Bernáldez on 8/3/22.
//

import Foundation
import UIKit

struct Film: Codable, Equatable {
//    var adult: Bool
//    var backdrop_path: String
    var genre_ids: [Int]
    var id: Int
//    var original_language: String
//    var original_title: String
    var overview: String
//    var popularity: Double
    var poster_path: String
    var release_date: String
    var title: String
//    var video: Bool
//    var vote_average: Double
//    var vote_count: Int
    
}


//var id: Int
//var title: String
//var genre: [Int]
//   var director: String = ""
//    var mainActor: String = ""
//var overview: String
//var poster_path: String
//var release_date: String
//    var isFavourite: Bool = false
