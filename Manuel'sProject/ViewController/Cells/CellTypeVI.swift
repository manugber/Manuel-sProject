//
//  CellTypeVI.swift
//  Manuel'sProject
//
//  Created by Manuel González Bernáldez on 22/3/22.
//

import UIKit

final class CellTypeVI: UITableViewCell {
    
    @IBOutlet weak var trailerButton: UIButton!
    var controller: FilmDetailsViewController?
    
    @IBAction func pressedButton(_ sender: UIButton) {
        controller?.loadTrailer()
    }
}
