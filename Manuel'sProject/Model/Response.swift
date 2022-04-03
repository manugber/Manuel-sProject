//
//  Response.swift
//  Manuel'sProject
//
//  Created by Manuel González Bernáldez on 14/3/22.
//

import Foundation

struct ResponseFilms: Codable {
    var page: Int
    var results: Films
}

struct ResponseRelatedFilms: Codable {
    var cast: Films
}

struct ResponseGenres: Codable {
    var genres: [Genre]
}

struct ResponseTrailer: Codable {
    var results: [Trailer]
}
