//
//  Elemento.swift
//  Manuel'sProject
//
//  Created by Manuel González Bernáldez on 8/3/22.
//

import Foundation
import UIKit

struct Film: Codable, Equatable, Hashable {
//    var adult: Bool
//    var backdrop_path: String
    var genre_ids: [Int]
    let id: Int
//    var original_language: String
//    var original_title: String
    let overview: String
    var popularity: Double?
    var poster_path: String?
    var release_date: String?
    let title: String
//    var isFavourite: Bool?
//    var video: Bool
//    var vote_average: Double
//    var vote_count: Int
    var mainGenre: String?
    
}
