//
//  CellTypeVI.swift
//  Manuel'sProject
//
//  Created by Manuel González Bernáldez on 22/3/22.
//

import UIKit

class CellTypeVI: UITableViewCell {
    
    @IBOutlet weak var trailerButton: UIButton!
    var controller: FilmDetailsViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func pressedButton(_ sender: UIButton) {
        controller?.loadTrailer()
    }
    
    func linkController(controller: FilmDetailsViewController) {
        self.controller = controller
    }
    
}
