//
//  CellTypeI.swift
//  Manuel'sProject
//
//  Created by Manuel González Bernáldez on 8/3/22.
//

import UIKit

class CellTypeI: UITableViewCell {

    @IBOutlet weak var filmImage: UIImageView!
    @IBOutlet weak var filmTitle: UILabel!
    @IBOutlet weak var filmGenre: UILabel!
    @IBOutlet weak var favouriteButton: UIButton!
    var link: MainViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func pressedButton() {
        link?.pressedFavButton(cell: self)
    }
}
