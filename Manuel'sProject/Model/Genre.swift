//
//  Genre.swift
//  Manuel'sProject
//
//  Created by Manuel González Bernáldez on 14/3/22.
//

import Foundation

struct Genre: Codable, Hashable {
    var id: Int
    var name: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
