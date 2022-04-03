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
    var genreIDS: [Int]
    let id: Int
//    var original_language: String
//    var original_title: String
    let overview: String
    var popularity: Double?
    var posterPath: String?
    var releaseDate: String?
    let title: String
//    var isFavourite: Bool?
//    var video: Bool
//    var vote_average: Double
//    var vote_count: Int
    var mainGenre: String?
    var genres: String?
    var isFavourite: Bool?
    
    enum CodingKeys: String, CodingKey {
            case genreIDS = "genre_ids"
            case id, overview, popularity
            case posterPath = "poster_path"
            case releaseDate = "release_date"
            case title
            case mainGenre
        }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

typealias Films = [Film]
