//
//  CollectionCellTypeI.swift
//  Manuel'sProject
//
//  Created by Manuel González Bernáldez on 11/3/22.
//

import UIKit

final class CollectionCellTypeI: UICollectionViewCell {

    @IBOutlet weak var filmTitle: UILabel!
    @IBOutlet weak var filmImage: UIImageView!
    
    override func prepareForReuse() {
        filmTitle.text = nil
        filmImage.image = nil
    }

}
