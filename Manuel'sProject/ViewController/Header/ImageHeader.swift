//
//  ImageHeader.swift
//  Manuel'sProject
//
//  Created by Manuel González Bernáldez on 8/3/22.
//

import UIKit

class ImageHeader: UITableViewHeaderFooterView {
    
    var theView = ImageHeaderView()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.addSubview(theView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
