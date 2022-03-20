//
//  DataController.swift
//  Manuel'sProject
//
//  Created by Manuel González Bernáldez on 18/3/22.
//

import Foundation
import UIKit

class DataController {
    
    var favourites = [Film]()
    var genres = [Genre]()
    var filmsForGenre = [Int]()
    var images = [Int: UIImage]()
    var leftBarButtonTitle = "Género"
    var onlyFavs = false
    var searchActive = false
    var popularityOrder = true
    
    static var instance = DataController()
    
    private init() {}
    
}
