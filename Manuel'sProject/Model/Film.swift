//
//  Elemento.swift
//  Manuel'sProject
//
//  Created by Manuel González Bernáldez on 8/3/22.
//

import Foundation

struct Film: Codable, Equatable {
    
    var title: String = ""
    var genre: String = ""
    var director: String = ""
    var mainActor: String = ""
    var description: String = ""
    var image: String = ""
    var isFavourite: Bool = false
    
}
