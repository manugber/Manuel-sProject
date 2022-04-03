//
//  CellTypeI.swift
//  Manuel'sProject
//
//  Created by Manuel González Bernáldez on 8/3/22.
//

import UIKit

final class CellTypeI: UITableViewCell {

    @IBOutlet weak var filmImage: UIImageView!
    @IBOutlet weak var filmTitle: UILabel!
    @IBOutlet weak var filmGenre: UILabel!
    @IBOutlet weak var favouriteButton: UIButton!
    var link: MainViewController?
    
    override func prepareForReuse() {
        filmTitle.text = nil
        filmGenre.text = nil
        favouriteButton.imageView?.image = nil
        filmImage.image = nil
    }
    
    @IBAction func pressedButton() {
        link?.pressedFavButton(cell: self)
    }
}
